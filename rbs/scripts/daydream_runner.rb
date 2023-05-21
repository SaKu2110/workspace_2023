require_relative '../lib/daydream'

s = gets
exit 0 if s.nil?

result = Daydream.run(s.chomp)
p result
