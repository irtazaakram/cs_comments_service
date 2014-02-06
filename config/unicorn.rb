worker_processes ENV['WORKER_PROCESSES'].to_i || 4
timeout 25
preload_app true
listen "unix:" + ENV['DATA_DIR'] + "/forum.sock", :backlog => 512
pid ENV['DATA_DIR'] + "/forum_unicorn.pid"

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Waiting for master to send QUIT'
  end
  ::Mongoid.default_session.disconnect
end
