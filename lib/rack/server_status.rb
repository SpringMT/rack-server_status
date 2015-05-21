require 'rack/server_status/version'
require 'json'
require 'worker_scoreboard'

module Rack
  class ServerStatus
    def initialize(app, options = {})
      @app             = app
      @uptime          = Time.now.to_i
      @skip_ps_command = options[:skip_ps_command] || false
      @path            = options[:path]            || '/server-status'
      @allow           = options[:allow] || []
      scoreboard_path  = options[:scoreboard_path]
      unless scoreboard_path.nil?
        @scoreboard = WorkerScoreboard.new(scoreboard_path)
      end
    end

    def call(env)
      set_state!('A', env)

      @clean_proc = Remover.new
      ObjectSpace.define_finalizer(self, @clean_proc)

      if @path && env['PATH_INFO'] == @path
        res = handle_server_status(env)
        set_state!('_')
        return res
      end

      res = @app.call(env)
      set_state!('_')
      return res
    end

    private

    def set_state!(status = '_', env)
      return if @scoreboard.nil?
      prev = {}
      unless env.nil?
        prev = {
          remote_addr: env['REMOTE_ADDR'],
          host:        env['HTTP_HOST'] || '-',
          method:      env['REQUEST_METHOD'],
          uri:         env['REQUEST_URI'],
          protocol:    env['SERVER_PROTOCOL'],
          time:        Time.now.to_i
        }
      end
      prev[:pid]    = Process.pid
      prev[:ppid]   = Process.ppid
      prev[:uptime] = @uptime
      prev[:status] = status

      @scoreboard.update(prev.to_json)
    end

    def allowed?(address)
      return true if @allow.empty?
      @allow.include?(address)
    end

    def handle_server_status(env)
      unless allowed?(env['REMOTE_ADDR'])
        return [403, {'Content-Type' => 'text/plain'}, [ 'Forbidden' ]]
      end

      upsince = Time.now.to_i - @uptime
      duration = "#{upsince} seconds"
      body = "Uptime: #{@uptime} (#{duration})\n"
      status = {Uptime: @uptime}

      unless @scoreboard.nil?
        stats = @scoreboard.read_all
        parent_pid = Process.ppid
        all_workers = []
        idle = 0
        busy = 0
        if @skip_ps_command
          all_workers = stats.keys
        elsif RUBY_PLATFORM !~ /mswin(?!ce)|mingw|cygwin|bccwin/
          ps = `LC_ALL=C command ps -e -o ppid,pid`
          ps.each_line do |line|
            line.lstrip!
            next if line =~ /^\D/
            ppid, pid = line.chomp.split(/\s+/, 2)
            all_workers << pid.to_i if ppid.to_i == parent_pid
          end
        else
          all_workers = stats.keys
        end
        process_status_str = ''
        process_status_list = []

        all_workers.each do |pid|
          json =stats[pid] || '{}'
          pstatus = begin; JSON.parse(json, symbolize_names: true); rescue; end
          pstatus ||= {}
          if !pstatus[:status].nil? && pstatus[:status] == 'A'
            busy += 1
          else
            idle += 1
          end
          unless pstatus[:time].nil?
            pstatus[:ss] = Time.now.to_i - pstatus[:time].to_i
          end
          pstatus[:pid] ||= pid
          pstatus.delete :time
          pstatus.delete :ppid
          pstatus.delete :uptime
          process_status_str << sprintf("%s\n", [:pid, :status, :remote_addr, :host, :method, :uri, :protocol, :ss].map {|item| pstatus[item] || '' }.join(' '))
          process_status_list << pstatus
        end
        body << <<"EOF"
BusyWorkers: #{busy}
IdleWorkers: #{idle}
--
pid status remote_addr host method uri protocol ss
#{process_status_str}
EOF
        body.chomp!
        status[:BusyWorkers] = busy
        status[:IdleWorkers] = idle
        status[:stats]       = process_status_list
      else
        body << "WARN: Scoreboard has been disabled\n"
        status[:WARN] = 'Scoreboard has been disabled'
      end
      if (env['QUERY_STRING'] || '') =~ /\bjson\b/
        return [200, {'Content-Type' => 'application/json; charset=utf-8'}, [status.to_json]]
      end
      return [200, {'Content-Type' => 'text/plain'}, [body]]
    end

    class Remover
      def initialize
      end
      def call(*args)
        set_state!('_')
      end
    end

  end

end
