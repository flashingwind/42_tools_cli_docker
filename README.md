# norminettとc-formatter-42を1つのDockerイメージにまとめる

42tokyoという特殊な環境では、ある特定のスタイルのコードを書くことが求められる。
特に、インストールがやっかいなのが、macOS標準のPythonで動かないツール、norminettとc-formatter-42である。norminett公式を含めnorminettのDockerイメージやDockerfileがあるが、c-formatter-42はないようだ。別々にDockerイメージを作るとそこそこ容量を食うことであるし、まとめてしまうことにした。

## Usage

次の通りダウンロード(clone)して、docker buildし、ソースコード`*.c`のあるディレクトリーに移動して実行せよ。VSCodeについては後述する。

```
git clone https://github.com/flashingwind/dockerfile_norminette_and_c-formatter-42.git
```

だだし、最新版に維持する機能はないので、そうしたいときはイメージをビルドし直すこと。必要ならDockerfileの中身を自分で編修すること(Pythonのバージョンとか)。

### macOS / Windows PowerShell

```
cd ex00

# norminette実行
docker run -v $PWD:/code alexandregv/norminette:v3

# 引数を渡してnorminette実行
docker run -v $PWD:/code alexandregv/norminette:v3 -R CheckForbiddenSourceHeader main.c
```

LinuxとWindows PowerShellでも同様に動くかもしれない。

### Windows(MS-DOS的なやつ)

MS-DOS的なやつでは、`$PWD`が使えないので`%cd%`.と置き換えると動くらしい。がんばって。

## エディターの設定

VSCodeしか使ってないので、それの設定だけ書く。次の2つをVSCodeにインストールする。

- [evilcat.norminette-42](https://marketplace.visualstudio.com/items?itemName=evilcat.norminette-42)
- [keyhr.42-c-format](https://pypi.org/project/c-formatter-42/#:~:text=Install-,keyhr.42%2Dc%2Dformat,-extension.)

まず、VSCodeがデフォルトで42指定のNormフォーマットに整形するようにする。
42tokyoに特化するなら[Command]+[Shift]+[P]、「@lang:c defaultFormatter」と打って検索し、


```
{
    "configurations": [
        {
            "name": "Mac",
			(略)
            "editor.defaultFormatter": "keyhr.42-c-format"
        }
    ],
    "version": 4
}
```

みたいに、どこにあるCファイルでも42形式にしちゃうように、すればいいんじゃないでしょうか。フォルダー限定の設定もできるけど、詳しくないんです。C言語で仕事してる人は自分で調べて。

これらは外部にあるnorminetteや42-c-formatを利用している。そこで、このツールを使うためには設定が必要だ。


```
./build_docker_norminette_and_c-formatter-42
./install
```

これで`~/.bin`に`norminette`や`42-c-format`というシェルスクリプトができるので、あとはパスを通す。

```
echo 'export PATH="~/.bin:$PATH"'>>~/.zshrc
source ~/.zshrc
```

一般的なzsh環境だと、これで使えると思われる。evilcat.norminette-42拡張機能は、実行するコマンド(c-format-42やpython)のパスを指定できないので、こういう変則的なことをしている。

## 参考

本レポジトリーは次のレポジトリーをフォークしてちょっと改変したものである。

* [GitHub: alexandregv/norminette-docker)](https://github.com/alexandregv/norminette-docker)
