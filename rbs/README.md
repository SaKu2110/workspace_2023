# RBS

RBSをさらっと触ってみる  

## 環境構築

- ruby 3.2.2
- rbs 3.1
- typeprof 0.21.7
- steep 1.4.0

```
$ bundle install
$ bundle exec steep init
$ bundle exec typeprof scripts/daydream_runner.rb > sig/daydream.rbs
```

**周辺ツールの位置づけ**  
- RBS: 型情報を扱う言語。
- typeprof: 静的型解析器。プログラムの型解析ができる。型注釈が無くてもそれっぽく型を判断することが出来るのが特徴
- steep: 静的型検査器。RBSファイルを基にプログラムの型エラーを検知できる。

## 検証

**検証1: メソッドに誤った型を渡して呼び出してみた場合**  

変更箇所は `scripts/daydream_runner.rb`
```rb
# result = Daydream.run('erasedream')
result = Daydream.run(3) # 数値を入力する
p result
```

<details><summary>実行結果</summary><div>

```
$ bundle exec steep check
# Type checking files:

..................................................................F................

scripts/daydream_runner.rb:4:22: [error] Cannot pass a value of type `::Integer` as an argument of type `::String`
│   ::Integer <: ::String
│     ::Numeric <: ::String
│       ::Object <: ::String
│         ::BasicObject <: ::String
│
│ Diagnostic ID: Ruby::ArgumentTypeMismatch
│
└ result = Daydream.run(3)
                        ~

Detected 1 problem from 1 file
```
</div></details>

**検証2: 呼び出したメソッドの戻り値が文字列でない値の場合**  
変更箇所は `lib/daydream.rb`

```rb
class Daydream
  def self.run(s)
    s = s.match(/^(dream|dreamer|erase|eraser)+$/)
    s.length == 0 ? "YES" : 'NO'
    true # bool値を返却
  end
end
```

<details><summary>実行結果</summary><div>

```
$ bundle exec steep check
# Type checking files:

.........................................................................F.........

lib/daydream.rb:4:11: [error] Cannot allow method body have type `bool` because declared as type `::String`
│   bool <: ::String
│     (true | false) <: ::String
│       true <: ::String
│         ::TrueClass <: ::String
│           ::Object <: ::String
│             ::BasicObject <: ::String
│
│ Diagnostic ID: Ruby::MethodBodyTypeMismatch
│
└   def self.run(s)
             ~~~

Detected 1 problem from 1 file
```
</div></details>

**検証3: メソッド呼び出し元の型が必ずしも文字列とは限らない場合**  
競技プログラミングの問題では標準入力から受け取った値を引数として、`Daydream.run`に渡してあげる必要があります。  

変更箇所は `lib/daydream.rb`

```rb
s = gets.chomp

result = Daydream.run(s)
p result
```

<details><summary>実行結果</summary><div>

```
$ bundle exec steep check
# Type checking files:

.........................................................................F.........

scripts/daydream_runner.rb:4:9: [error] Type `(::String | nil)` does not have method `chomp`
│ Diagnostic ID: Ruby::NoMethod
│
└ s = gets.chomp
           ~~~~~

Detected 1 problem from 1 file
```
</div></details>

`gets`の戻り値は`String`と`nil`のどちらかなので、戻り値が`nil`だった時のことを考慮してコードを書いてあげる必要がある。   

```rb
s = gets
exit 0 if s.nil?

result = Daydream.run(s.chomp)
p result
```

## 参考

- [ruby/rbs - GitHub](https://github.com/ruby/rbs)
- [ruby/typeprof - GitHub](https://github.com/ruby/typeprof)
- [soutaro/steep - GitHub](https://github.com/soutaro/steep)
- [Ruby 3の静的解析機能のRBS、TypeProf、Steep、Sorbetの関係についてのノート](https://techlife.cookpad.com/entry/2020/12/09/120454)
