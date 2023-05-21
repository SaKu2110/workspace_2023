require_relative '../lib/daydream'

s = io.gets
exit 0 if s.nil?

result = Daydream.run(s.chomp)
p result
