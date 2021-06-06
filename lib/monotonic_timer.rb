require 'sys-uptime'

def timer
  start_time_in_seconds_since_boot = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  start_time = Sys::Uptime.boot_time + start_time_in_seconds_since_boot
  yield
  finish_time_in_seconds_since_boot = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  elapsed_time_in_seconds = finish_time_in_seconds_since_boot - start_time_in_seconds_since_boot
  finish_time = start_time + elapsed_time_in_seconds
  [start_time, finish_time, elapsed_time_in_seconds]
end

s, f, e = timer do
  puts 'code'
  sleep 3
end

p s, f, e
