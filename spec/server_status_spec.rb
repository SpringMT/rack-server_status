require 'spec_helper'

require File.dirname(__FILE__) + '/spec_helper'

describe Rack::ServerStatus do
  app = lambda { |env|
    [200, {'Content-Type' => 'text/plain'}, ["Hello, World!"]]
  }

  context 'confirm to Rack::Lint' do
    context 'Not affected WorkerScoreboard' do
      subject do
        Rack::Lint.new(Rack::ServerStatus.new(app))
      end
      it do
        response = Rack::MockRequest.new(subject).get('/')
        expect(response.body).to eq 'Hello, World!'
      end
    end
    context 'Affected WorkerScoreboard' do
      subject do
        Rack::Lint.new(Rack::ServerStatus.new(app, scoreboard_path: Dir.tmpdir))
      end
      it do
        response = Rack::MockRequest.new(subject).get('/')
        expect(response.body).to eq 'Hello, World!'
      end
    end
  end

  context 'return valid server-status' do
    subject do
      Rack::Lint.new(Rack::ServerStatus.new(app, scoreboard_path: Dir.tmpdir))
    end
    it do
      response = Rack::MockRequest.new(subject).get('/server-status')
      expect(response.successful?).to be_truthy
      expect(response.headers['Content-Type']).to eq 'text/plain'
    end
  end

  context 'return json valid server-status' do
    subject do
      Rack::Lint.new(Rack::ServerStatus.new(app, scoreboard_path: Dir.tmpdir))
    end
    it do
      response = Rack::MockRequest.new(subject).get('/server-status?json')
      expect(response.successful?).to be_truthy
      expect(response.headers['Content-Type']).to eq 'application/json; charset=utf-8'
    end
  end
end

