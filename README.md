# MonotonicTimer

## With a block
```
timer = MonotonicTimer.time do |timer|
  1_000_000.times{i ||= 0; puts i += 1}
end
p timer.total_time
```

## Without a block
```
timer = MonotonicTimer.new
timer.start
1_000_000.times{i ||= 0; puts i += 1}
timer.stop
timer.total_time
```
