:
################################################################################
## \file      run-time-macro.sh
## \author    SENOO, Ken
## \copyright CC0
################################################################################

main(){
	init
	SHS='sh ksh ksh93 pdksh oksh lksh mksh posh ash dash bash zsh yash busybox'
	for sh in $SHS; do
		case $sh in busybox) sh='busybox ash'; esac
		is_exe_enabled $sh || continue
		printf "$sh: "
		$sh time-macro.sh
	done
}

## \brief Initialize POSIX shell environment
init(){
	PATH="$(command -p getconf PATH 2>&-):${PATH:-.}"
	export PATH="${PATH#:}" LC_ALL='C'
	umask 0022
	set -eu
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

main
