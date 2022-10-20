# norminettとc-formatter-42を1つのDockerイメージにまとめてみた

## 開発中!! (Under development)

42tokyoという特殊な環境では、ある特定のスタイルのコードを書くことが求められる。
特に、インストールがやっかいなのが、macOS標準のPythonで動かないツール、norminettとc-formatter-42である。norminett公式を含めnorminettのDockerイメージやDockerfileがあるが、c-formatter-42はないようだ。~~~別々にDockerイメージを作るとそこそこ容量を食うことであるし、まとめてしまうことにした。~~
無いにはないなりの理由があるようで、c-formatter-42はなんかうまくいかない。

ただ、私はいまPiscine受験生で、絶賛底辺を這いずり回っていて、落ちる可能性大だ。落ちたら更新しないだろう。42tokyoのメアドからメールをいただければ、レポジトリーはいつでも譲ります。

## 必要なもの(Requirements)

- Docker(利用するときは常に起動していること)
- git

## Setup

次の通りダウンロード(clone)して、docker buildし、ソースコード`*.c`のあるディレクトリーに移動して通常通り実行せよ。
ダウンロードする場所はどこでもいいが、できたフォルダは使ってる間は消せないので、じゃまにならないところにしてください。

VSCodeについては後述する。

```
git clone https://github.com/flashingwind/dockerfile_norminette_and_c-formatter-42.git
cd dockerfile_norminette_and_c-formatter-42
./c_42_build.sh
```

これでイメージができる。この長ったらしいフォルダー名を変えたり、場所を移すときは今のうちにやっておいてほしい。目障りであれば、`~/.42c_tools`とか隠してもかまわないが、以下の説明は変更したフォルダ名に読み替えてください。

このフォルダにいくつかスクリプトがあるので、パスを通しておく方がいいと思う。

```
export PATH=$PWD:PATH >> ~/.zshrc
```

最新版に維持する機能はないので、必要ならDockerでイメージを消してビルド`./c_42_build.sh`し直すこと。必要ならDockerfileの中身を自分で編修すること(Pythonのバージョンとか)。

だだし、最新版に更新する機能はないので、そうしたいときはイメージをビルドし直すこと。pipから再インストールされる。将来Pythonのバージョン由来のエラーとか、どうしようもないエラーが起きたr、Dockerfileの中身を自分で編集してほしい。

### Usage (macOS/Linuxなど)

基本的には下記の通りですが、Dockerの起動と`./c_42_build.sh`

#### norminette

パスを通してない場合でも、次のように使える。パスが通っていれば`norminette .`でよいはず。

ただし、dockerの都合上、引数はカレントディレクトリーからの相対パスとしてください。ディレクトリーであれば中の.cッファイルすべてを検査、ファイル名であれば、そのファイルを検査します。

フルパス(`/Users/xxxxx/……`)や`~`からはじまるパスをしていすると動きません。

大きなお世話ですが、43 Tokyo向けなので、はじめから`-R CheckForbiddenSourceHeader`がついています。オプションの変更は`norminette`ファイルを編集してください。

```
# あるフォルダ以下全部の.cファイルにnorminette実行:
cd ~/42/ex00
~/42/c00/ > ../docker_42_tools/norminette .
./ex00/ft_putchar.c: OK!
./ex01/ft_print_alphabet.c: OK!
./ex02/ft_print_reverse_alphabet.c: OK!
./ex03/ft_print_numbers.c: OK!
./ex04/ft_is_negative.c: OK!
./ex05/ft_print_comb.c: OK!
./ex06/ft_print_comb2.c: OK!
./ex07/ft_putnbr.c: OK!
./ex08/ft_print_combn.c: OK!

# 単一のファイルの検査:
~/42/c00/ > ../docker_42_tools/norminette ex00/ft_putchar.c
ex00/ft_putchar.c: OK!
```

Linuxでも同様に動くかもしれない。Windows PowerShellはスクリプトの変数を変える必要が有馬層です。しかし今、VirtualBoxを立ち上げて試す気力と時間がありません。情報はお待ちしています。

#### ~~c_formatter_42(現在使えません)~~

`_c_formatter_42`スクリプトを作ってあるけど、

```
FileNotFoundError: [Errno 2] No such file or directory: '/usr/local/lib/python3.10/site-packages/c_formatter_42/data/clang-format-linux'
```

ってなって使えません。この`clang-format-linux`自体も実行ファイルなので、実行してみましたが、やはり同様のエラーが。lsで見る分には正常なのですが、直接実行するとダメ。catでは開ける。

```
> docker run 42_c_tools-alpine:latest c_formatter_42
……
FileNotFoundError: [Errno 2] No such file or directory: '/usr/local/lib/python3.10/site-packages/c_formatter_42/data/clang-format-linux'

> docker run 42_c_tools-alpine:latest ls /usr/local/lib/python3.10/site-packages/c_formatter_42/data/
__init__.py
__pycache__
clang-format
clang-format-darwin
clang-format-linux
clang-format-win32.exe
```

#### clang

ややくせがある。つぎのようにコンパイルのみだと、macでは実行できないファイルが生成されるため、

```
~/42/c00/ex01/ > ~/42/docker_42_tools/cc ft_print_alphabet.c
```

Docker側で実行までしなければならない。

```
~/42/c00/ex01/ > ~/42/docker_42_tools/cc "ft_print_alphabet.c && ./a.out"
```

#### いざというとき

```
~/42/c00/ex01/ > ~/42/docker_42_tools/42 "./a.out"
```

任意のコマンドを実行できる。また、`docker run`で直接起動して、内部のシェルを起動すればなんでもできる。

## vscode連携

エディターはVisual Studio Codeしか使ってないので、それの設定だけ書く。次の2つの拡張機能をVSCodeにインストールする。

- [evilcat.norminette-42](https://marketplace.visualstudio.com/items?itemName=evilcat.norminette-42)
- ~~[keyhr.42-c-format](https://pypi.org/project/c-formatter-42/#:~:text=Install-,keyhr.42%2Dc%2Dformat,-extension.)

(関係ないけど、僕は「C/C++ Extension Pack」と「42 Header」も入れています。)

まず、VSCodeがデフォルトで42指定のフォーマットに整形するようにする。
42tokyoに特化するなら[Command]+[Shift]+[P]押下、「設定の検索」に「@lang:c Format」と打って検索(Enter)し、「42C Format (keyhr.42-c-format)」選択。それと、下記は、わたしはチェックしていない。

- Editor: Format On Save
- Editor: Format On Paste
- Editor: Format On Type

全部チェックを付けてもいいのだが、宣言時に初期化しなければらない配列や`const`、`static`などが、

```C
char str[]="test";
int list[]={1,2,3};
```

```C
char str[];
int list[];

str[]="test";
list[]={1,2,3};
```

みたいに分離される難点があって、それなら、コミット前などにソースコードを選択した状態で[Command]+[Shift]+[P]押下、「Format Selection」をしたほうがいいきがする。~~

これにより、マシンのどこにあるCファイルでも42形式にしちゃうようになります。まあいいんじゃないでしょうか。フォルダー限定(42の作業フォルダなど)の設定もできるけど、詳しくないんです。C言語で仕事してる人は自分で調べて。

これらは外部にあるnorminetteや~~42-c-format~~を利用している。そこで、このツールを使うためには設定が必要だ。


```
./c_42_build.sh
```

これでDockerイメージができる。あとは好みでパスを通す。aliasの方がよければそれでも。

```
echo 'export PATH="~/.bin:$PATH"'>>~/.zshrc
source ~/.zshrc
```

一般的なzsh環境だと、これで使えると思われる。evilcat.norminette-42拡張機能は、実行するコマンド(c-format-42やpython)のパスを指定できないので、こういう変則的なことをしている。

## 謝辞

本レポジトリーは次のレポジトリーをフォークしてほんのちょっと改変したものである。

- [GitHub: alexandregv/norminette-docker)](https://github.com/alexandregv/norminette-docker)
