# 例題：白昼夢
# https://atcoder.jp/contests/abs/tasks/arc065_a
class Daydream
  def self.run(s)
    s = s.match(/^(dream|dreamer|erase|eraser)+$/)
    s.nil? ? "NO" : s.length == 0 ? "YES" : 'NO'
  end
end
