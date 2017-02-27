workers 1
c = Integer(ENV["PUMA_CONCURRENCY"])
threads c,c
bind "tcp://0.0.0.0:3000"
environment ENV.fetch("RAILS_ENV") { "development" }
plugin :tmp_restart
