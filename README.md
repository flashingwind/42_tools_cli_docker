# norminettとc-formatter-42とclangを1つのDockerイメージにまとめてみた

**このレポジトリーはアーカイブ状態にします。**

一応、[こっちは(VSCode devcontainer版)は生かしておくつもり](https://github.com/flashingwind/42_c_vscode_container/edit/master/README.md)。

## 背景

42tokyoという特殊な環境では、

- norminettと
- c-formatter-42がいる。ついでに
- clangも。

一応作ってみたけど、無いには無いなりの理由があるようで、c_formatter_42はVSCodeの連携ができないため、vscode使い物にならないのでレポジトリーをアーカイブ状態にする。マジで管理できないし。42落ちたし。

## 必要なもの(Requirements)

- Docker(利用するときは常に起動していること)
- git

## Setup

次の通りダウンロード(git clone)して、`./c_42_build.sh`でビルドし、このディレクトリーにPATHを通す。
ダウンロードする場所はどこでもいいが、できたフォルダは使ってる間は消せないので、じゃまにならないところにしてください。目障りであれば、`~/.docker_42_tools`とか隠してもかまわないが、以下の説明はフォルダ名を正しく読み替えてください。

VSCodeについては後述する。

```
git clone https://github.com/flashingwind/docker_42_tools.git docker_42_tools
cd docker_42_tools
./c_42_build.sh
```

これでDockerイメージができる。あとは好みでパスを通す。aliasの方がよければそれでも。

```
echo 'export PATH="~/.bin:$PATH"'>>~/.zshrc
source ~/.zshrc
```

一般的なzsh環境だと、これで使えると思われる。

```
export PATH=$PWD:PATH >> ~/.zshrc
```

最新版に維持する機能はないので、必要ならDockerイメージを消してビルド`./c_42_build.sh`し直すこと。

pipから再インストールされる。将来Pythonのバージョン由来のエラーとか、どうしようもないエラー(Pythonのバージョンが古いとか)が起きたら、必要ならDockerfileの中身を自分で編修することDockerfileの中身を自分で編集してほしい。

### Usage (macOS/Linux)

基本的には下記の通りですが、エラー時はDockerの起動と`./c_42_build.sh`を事前に実行して、イメージができているか確認してください。

Linuxでも同様に動くかもしれないです。Windows PowerShellはおそらく付属のスクリプト群の変数を変える必要があります。

#### Docker特有の注意点

Dockerの外でのカレントディレクトリー`.`をDockerコンテナ内のカレントディレクトリー`/code`に関連づけてあり、絶対パスは`/code/〜`となります。

相対パスなら同じになるので、相対パスでの指定をおすすめします。

#### norminette

パスを通してない場合でも、次のように使える。パスが通っていれば`norminette .`でよいはず。

ただし、dockerの都合上、引数はカレントディレクトリーからの相対パスとしてください。ディレクトリーであれば中の.cッファイルすべてを検査、ファイル名であれば、そのファイルを検査します。

フルパス(`/Users/xxxxx/……`)や`~`からはじまるパスを指定すると動きません。

大きなお世話ですが、43 Tokyo向けなので、はじめから`-R CheckForbiddenSourceHeader`がついています。オプションの恒久的変更は`norminette`ファイルを編集してください。

```bash
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

一時的にオプションを変えたいときは、`42bash`スクリプトで、直接bashにコマンドを渡します。

```bash
~/42/c00/ex01/ > 42bash "norminette ."
```

#### c_formatter_42

`c_formatter_42`スクリプトを作ってある。

`.c``.h`ファイルを指定すと、ファイル自体を上書きします。

VSCodeから使えません。

#### clang

やや癖がある。次のようにコンパイルのみだと、macOSでは実行できないファイルが生成される。

```
~/42/c00/ex01/ > cc ft_print_alphabet.c
```

Docker側で実行までしなければならない。

```
~/42/c00/ex01/ > cc "ft_print_alphabet.c && ./a.out"
```

また、実行のみ行うときは、

```
~/42/c00/ex01/ > 42bash "./a.out"
```

とする。

#### いざというとき

```
~/42/c00/ex01/ > 42bash_it
```

内部のシェルを起動、任意のコマンドを実行できる。[Ctrl]+[D]で抜ける。カレントディレクトリーは保存が反映されるが、イメージ自体は変更されないので、イメージの変更が必要であれば`Dockerfile`の`RUN`のあたりを編集し、再ビルドする必要がある。

## vscode連携

エディターはVisual Studio Codeしか使ってないので、それの設定だけ書く。次の拡張機能をVSCodeにインストールする。ただし、`pip……`コマンドは行わない。パスが通っている場合は、説明書き通りの設定でよさそうだ。

- [evilcat.norminette-42](https://marketplace.visualstudio.com/items?itemName=evilcat.norminette-42)
<!--
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

これらは外部にあるnorminetteや42-c-formatを利用している。そこで、このツールを使うためには設定が必要だ。

-->

## 謝辞(Thanks)

本レポジトリーは次のレポジトリーをフォークしてほんのちょっと改変したものである。

- [GitHub: alexandregv/norminette-docker)](https://github.com/alexandregv/norminette-docker)

