:
################################################################################
## \file      shver.sh
## \author    SENOO, Ken
## \copyright CC0
## \date      first created date: 2017-04-30T00:41+09:00
## \date      last  updated date: 2017-05-06T20:16+09:00
################################################################################

: <<-EOT
方針
--versionオプションがあればこの出力から検索
sh --version
なかったら，manコマンドの出力結果から確認？
ksh系はバージョン情報の入った変数があるのでそれを使う
EOT

: <<-EOT
--versionの表示例
bash --version
GNU bash, version 4.3.46(1)-release (x86_64-pc-linux-gnu)
zsh --version
zsh 5.1.1 (x86_64-ubuntu-linux-gnu)
ksh93 --version
  version         sh (AT&T Research) 93u+ 2012-08-01
EOT

is_main()(
	EXE_NAME='shver.sh'
	[ "$EXE_NAME" = "${0##*/}" ]
)

shver()(
	## \brief Initialize POSIX shell environment
	init(){
		set -eu
		umask 0022
		PATH="$(command -p getconf PATH 2>&- || :)${PATH+:$PATH}"
		export PATH="${PATH#:}" LC_ALL='C'
	}

	is_exe_enabled()(command -v ${1+"$@"} >/dev/null)

	main()(
		SHS='sh ksh ksh93 pdksh mksh posh ash dash bash zsh yash fish csh tcsh busybox'
		for sh in $SHS; do
			is_exe_enabled $sh || continue
			[ $sh = 'busybox' ] && sh='busybox ash'
			# echo $sh
			## Busyboxのashはここで終了
			## x: --help: Bourne sh, sh (ash FreeBSD, NetBSD), dash, ksh88, mksh, pdksh, csh
			# ver=$($sh --help 2>&1 | head -n 1);;

			## x: --version: Bourne sh, sh (ash FreeBSD), ash (Busybox), dash, mksh,  pdksh, ksh88, csh
			# $sh --version >/dev/null 2>&1 && ver=$($sh --version | head -n 1)

			## helpまたはversionのないコマンドはmanの最終行の日時を使う
			## x: ash (Busybox)
			## For Bourne sh, sh (ash FreeBSD), dash, csh
			# : ${ver:=$( (man $sh 2>&- | tail -n 1) || :)}
			# echo "$ver"

			## ksh88以外はKSH_VERSION変数を優先
			case "$sh" in
				'busybox ash')  ver=$($sh --help 2>&1 | head -n 1);;
				ksh|dash|csh|sh) ver=$(man $sh 2>&1 | tail -n 1);;
				*ksh*) ver="$($sh -c 'echo $KSH_VERSION')";;  # ksh93, pdksh, mksh
				bash|zsh|fish|tcsh|yash) ver=$($sh --version 2>&1 | head -n 1);;
				posh) ver="$($sh -c 'echo $POSH_VERSION')";;  # posh
			esac

			printf '%s\t%s\n' "$sh" "$ver"
		done
	)

	init
	main
)

is_main && shver
