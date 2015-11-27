# Rack::ServerStatus [![Build Status](https://travis-ci.org/SpringMT/rack-server_status.svg?branch=master)](https://travis-ci.org/SpringMT/rack-server_status)

This is a Ruby version of [kazeburo/Plack-Middleware-ServerStatus-Lite](https://github.com/kazeburo/Plack-Middleware-ServerStatus-Lite).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-server_status'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-server_status

## Usage
### Getting started
Tell your app to use the Rack::ServerStatus middleware.

#### For Rails 3+ apps

```
# In config/application.rb
config.middleware.use Rack::ServerStatus, scoreboard_path: './tmp'
```

#### Rackup files

```
# In config.ru
use Rack::ServerStatus, scoreboard_path: './tmp'
```

### Get Status

```
% curl http://server:port/server-status
Uptime: 1432227723 (12 seconds)
BusyWorkers: 1
IdleWorkers: 3
--
pid status remote_addr host method uri protocol ss
55091 _  -    0
55092 _  -    1
55093 A 127.0.0.1 localhost:3000 GET /server-status HTTP/1.1 0
55094 _  -    0

# JSON format
% curl http://server:port/server-status?json
{"Uptime":1432388968,"BusyWorkers":1,"IdleWorkers":3,"stats":[{"remote_addr":null,"host":"-","method":null,"uri":null,"protocol":null,"pid":87240,"status":"_","ss":2},{"remote_addr":"127.0.0.1","host":"localhost:3000","method":"GET","uri":"/server-status?json","protocol":"HTTP/1.1","pid":87241,"status":"A","ss":0},{"remote_addr":null,"host":"-","method":null,"uri":null,"protocol":null,"pid":87242,"status":"_","ss":3},{"remote_addr":null,"host":"-","method":null,"uri":null,"protocol":null,"pid":87243,"status":"_","ss":3}]}
```

## Configuration

| name | detail | example | default |
|------|--------|---------|---------|
| path | location that displays server status | `path: '/server-status'` | `/server-status` |
| allow | host based access control of a page of server status. | `allow: ['127.0.0.1']` | `[]` |
| scoreboard | scoreboard directory | `scoreboard_path: './tmp'` | nil |
| skip_ps_command |  | `skip_ps_command: true` | false |


## Contributing

1. Fork it ( https://github.com/[my-github-username]/rack-server_status/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
