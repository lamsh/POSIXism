:
################################################################################
## \file      shver.sh
## \author    SENOO, Ken
## \copyright CC0
## \date      created date: 2017-04-30T00:41+09:00
## \date      updated date: 2017-07-29T12:17+09:00
################################################################################

## Policy
## if --version option enabled, then search this output.
## sh --version
## if --version option disabled, then search man output.
## ver=$(man $sh 2>&1 | tail -n 1)
## if ksh like shell, then use KSH_VERSION.

## Sample of --version
## bash --version
## GNU bash, version 4.3.46(1)-release (x86_64-pc-linux-gnu)
## zsh --version
## zsh 5.1.1 (x86_64-ubuntu-linux-gnu)
## ksh93 --version
##   version         sh (AT&T Research) 93u+ 2012-08-01

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

	is_exe_enabled(){
		IS_ENABLED_SET_E=$( case "$-" in (*e*) echo true;; (*) echo false;; esac )
		is_command_enabled(){ command -v : >/dev/null 2>&1; }

		$IS_ENABLED_SET_E && set +e
		if is_command_enabled; then
			$IS_ENABLED_SET_E && set -e
			command -v ${1+"$@"} >/dev/null 2>&1 && return || return
		fi
		$IS_ENABLED_SET_E && set -e

		IFS=:
		for path in $PATH; do
			unset IFS
			command -p [ -x "$path/"${1+"$@"} ] && return
		done
	}

	main(){
		SHS='sh ksh ksh93 pdksh oksh lksh mksh posh ash dash bash zsh yash fish csh tcsh busybox'
		for sh in $SHS; do
			is_exe_enabled $sh || continue
			[ $sh = 'busybox' ] && sh='busybox ash'

			## ksh88以外はKSH_VERSION変数を優先
			case "$sh" in
				'busybox ash')  ver=$($sh --help 2>&1 | head -n 1);;
				ksh|dash|csh|sh)
					ver=$(man $sh 2>&1 | tail -n 1 |
						sed -e 's/^[A-Z1-9()]* *//' -e 's/ *[A-Z1-9()]*$//');;
				*ksh*) ver="$($sh -c 'echo $KSH_VERSION')";;  # ksh93, pdksh, mksh
				bash|zsh|fish|tcsh|yash) ver=$($sh --version 2>&1 | head -n 1);;
				posh) ver="$($sh -c 'echo $POSH_VERSION')";;  # posh
			esac

			ver=$(echo "$ver"  | sed -e 's/^BSD *//' -e 's/ *BSD$//' )
			printf '%s\t%s\n' "$sh" "$ver"
		done
	}

	init
	main
)

is_main && shver
