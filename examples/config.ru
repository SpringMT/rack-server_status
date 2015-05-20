$:.unshift File.join(File.dirname(__FILE__), '..',  'lib/')
require 'rack/server_status'

use Rack::ServerStatus, scoreboard_path: './tmp'

class HelloWorldApp
  def call(env)
    sleep 10
    [ 200, { 'Content-Type' => 'text/plain' }, ['Hello World!'] ]
  end
end

map "/foo" do
  run HelloWorldApp.new
end

