# users generic .zshrc file for zsh(1)

#"漢のzsh"(http://journal.mycom.co.jp/column/zsh/index.html)第22回を元に改変

###############プロンプトの設定###############

#zshmisc(1)参照
#   %B %b ボールドにする。終了する。
#   %{...%} エスケープ文字列として読み込む。(あやしげな訳。原文はzshmisc(1)のvisual effectsの段落)
#   %/ 現在のディレクトリ。
#   ${fg[color]}文字色の設定。fgの部分をbgにすると背景色の設定。エスケープシークエンスで設定することもできる。

autoload colors
colors
case ${UID} in
0)
    PROMPT="%B%{${fg[red]}%}%/#%{${reset_color}%}%b "
    PROMPT2="%B%{${fg[red]}%}%_#%{${reset_color}%}%b "
    SPROMPT="%B%{${fg[red]}%}%r is correct? [n,y,a,e]:%{${reset_color}%}%b "
    [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] && 
        PROMPT="%{${fg[cyan]}%}$(echo ${HOST%%.*} | tr '[a-z]' '[A-Z]') ${PROMPT}"
    ;;
*)
    PROMPT="%{${fg[red]}%}%/%%%{${reset_color}%} "
    PROMPT2="%{${fg[red]}%}%_%%%{${reset_color}%} "
    SPROMPT="%{${fg[red]}%}%r is correct? [n,y,a,e]:%{${reset_color}%} "
    [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] && 
        PROMPT="%{${fg[cyan]}%}$(echo ${HOST%%.*} | tr '[a-z]' '[A-Z]') ${PROMPT}"
    ;;
esac

###############こまごまとした設定###############

#ディレクトリ名を入力するとそのディレクトリに移動
setopt auto_cd

#cd時に-[tab]で過去の移動先を補完
setopt auto_pushd

#typoを修正
setopt correct

#補完候補を詰めて表示する
setopt list_packed

#スラッシュを削除しない
setopt noautoremoveslash

#beepを鳴らさない
setopt nolistbeep

#キーバインド。vi。emacs風にするなら-e
bindkey -e

#エディタ機能を有効にする
autoload zed

##############履歴と補完###############

#コマンド履歴関係のキーマップ
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end
bindkey "\\ep" history-beginning-search-backward-end
bindkey "\\en" history-beginning-search-forward-end


#履歴の保持数と履歴ファイルの設定
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_dups     # 同じコマンドを重複して記録しない
setopt share_history        # 履歴の共有


#補完設定ファイルのパスと補完機能の初期化
fpath=(~/.zsh/functions/Completion ${fpath})
autoload -U compinit
compinit

#タブを押さなくても補完候補を表示する
#autoload predict-on
#predict-off


##############エイリアスの設定###############
#OSによる切り替えを行う

setopt complete_aliases     #エイリアスを設定したコマンドでも補完機能を使えるようにする
alias where="command -v"
alias j="jobs -l"

#ls
case "${OSTYPE}" in
freebsd*|darwin*)
    alias ls="ls -G -w"
    ;;
linux*)
    alias ls="ls --color"
    ;;
solaris*)
alias ls='gls -F --color=auto ' 
esac

alias la="ls -a"
alias lf="ls -F"
alias ll="ls -l"

alias du="du -h"
alias df="df -h"

alias su="su -l"

#パッケージ管理(macとfreebsd)
case "${OSTYPE}" in
darwin*)
    alias updateports="sudo port selfupdate; sudo port outdated"
    alias portupgrade="sudo port upgrade installed"
    ;;
freebsd*)
    case ${UID} in
    0)
        updateports() 
        {
            if [ -f /usr/ports/.portsnap.INDEX ]
            then
                portsnap fetch update
            else
                portsnap fetch extract update
            fi
            (cd /usr/ports/; make index)

            portversion -v -l \<
        }
        alias appsupgrade='pkgdb -F && BATCH=YES NO_CHECKSUM=YES portupgrade -a'
        ;;
    esac
    ;;
esac


###############色の設定###############

#$TERMを切り替える。($TERMがxtermまたはktermだとカラー表示にならない端末が有るらしいので-colorを設定する。)
#ついでに漢字が通らないっぽい端末使用時にはLANGをunsetしとく。
case "${TERM}" in
xterm)
    export TERM=xterm-color
    ;;
kterm)
    export TERM=kterm-color
    # set BackSpace control character
    stty erase
    ;;
cons25|linux)
    unset LANG
    ;;
esac

#lsとzshの補完に使用する色を設定。

#LSCOLORS    BSD ls用
#前景色と背景色を下記の順番に設定する。
#directory symboliclink socket fifo executable block-special setuid-executable setgid-executable other-dirctory-with-stickybit other-dirctory-without-sticybit
#色(それぞれ大文字にすると太字)
#a-black b-red c-green d-brown e-blue f-mazenda g-cyan h-white x-default

#LS_COLORS   GNU ls用
#自分の使ってるsolarisのglsのバージョンが古いためか、su以降のLS_COLORSを設定するとエラーになるので$OSTYPEがsolaris*の時は設定しない。
#変数=色;効果で設定する。
#di-directory ln-symboliclink so-socket ex-executable bd-block special cd-charactor special su-setuid executable tw-other dirctory with stickybit ow-other dirctory without sticybit
#色と効果
#0-Default Colour 1-Bold 4-Underlined 5-Flashing Text 7-Reverse Field 31-Red 32-Green 33-Orange 34-Blue 35-Purple 36-Cyan 37-Grey 40-Black Background 41-Red Background 42-Green Background 43-Orange Background 44-Blue Background 45-Purple Background 46-Cyan Background 47-Grey Background 90-Dark Grey 91-Light Red 92-Light Green 93-Yellow 94-Light Blue 95-Light Purple 96-Turquoise 100-Dark Grey Background 101-Light Red Background 102-Light Green Background 103-Yellow Background 104-Light Blue Background 105-Light Purple Background 106-Turquoise Background 

#"zstyle ':completion:*' list-colors"   zshの補完時に使用する色設定


unset LSCOLORS
export LSCOLORS=gxfxcxdxbxegedabagacad
zstyle ':completion:*' list-colors 'di=36' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'

case "${OSTYPE}" in
solaris*)
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34'
;;
*)
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
esac

###############ウィンドウタイトル等の設定###############

#エスケープシークエンス
#printf(1),ascii(7)参照。
#<特殊文字>=ascii=printfのエスケープシークエンス
#<esc>=033=\e  <bell>=007=\a  <backslash>=134=\\

#xterm screenの制御文字
#Xterm Control Sequences(http://www.xfree86.org/current/ctlseqs.html),screen(1)参照
#<string terminator>=<esc><backslash>
#<operating system command>=<esc>]

#screenの起動判定
#$TERMでscreenの起動判定をしているが、$STY(screenのセッションを識別する環境変数)がNULLかどうかで判定する方法もある。例:[ -n $STY ] &&  .....
#mac環境(OSX 10.4,PPC)で$TERMをscreenにするとvim7.x実行時にエラーになるため.screenrcにて$TERMをansiにしているので、$TERMがscreenまたはansiの時にscreenのウィンドウのタイトルが設定されるようにしている。(solaris,linuxの.screenrcでは$TERM=screenにしてる。)

#zsh組み込みの関数
#zshmisc(1)を参照
#preexec() 入力されたコマンドが実行される前に実行される。
#precmd() プロンプトが表示される前に実行される。

#xtermのタイトル設定
#Xterm Control Sequences参照
#printf  "<operating system command>0;文字列<bell>"でxtermのウィンドウタイトルを文字列に設定する。終端の<bell>は<string terminator>でも可。
#上記の文字列をプロンプトに含めることによっても設定可能。

#screenのタイトル設定
#screen(1)参照
#printf  "<esc>k文字列<string terminator>"でscreenのウィンドウタイトルを文字列に設定する。
#screenのウィンドウタイトルを動的に変更するには、プロンプトに上記の文字列を含めたり、precmd()やpreexec()内でscreenコマンドを"-t"などのオプションをつけて実行する方法もある。

#その他
#screen(1)参照
#screenに文字列を評価させずにxtermに文字列を渡す(<esc>P文字列<terminator>で渡せる)ことによってxtermのタイトルを変更できる。
#例:printf "<esc>P<operating system command>0;文字列<bell><string terminator>

case "${TERM}" in
kterm*|xterm*)
precmd() {
    printf "\e]0;${USER}@${HOST%%.*}:${PWD}\a"
}
;;
screen*|ansi*)
preexec() {
    #printf "\eP\e]0;!${1%% *}\a\e\\"  #screen使用時にもxtermのタイトルを変更できる。下記のコメントアウトされたprintfも同様。ウィンドウ間の移動をするとコマンドを実行するかEnterを押すまで実際の状態と食い違ってしまうので注意。
    printf "\ek!$1\e\\"
    }
precmd() {
    #printf "\eP\e]0;~$(basename $(pwd))\a\e\\"
    printf "\ek~$(basename $(pwd))\e\\"
    }
    ;;
esac

###############他の設定ファイルを読み込む###############


#文字コード、$PATH,$MANPATH,その他のエイリアスは分離

[ -f ~/.zshrc.mine ] && source ~/.zshrc.mine

