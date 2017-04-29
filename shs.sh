:
################################################################################
## \file      shs.sh
## \author    SENOO, Ken
## \copyright CC0
## \date      first created date: 2017-04-30T00:41+09:00
## \date      last  updated date: 2017-04-30T04:25+09:00
################################################################################

is_main()(
	EXE_NAME='shs.sh'
	[ "$EXE_NAME" = "${0##*/}" ]
)

shs()(
	## \brief Initialize POSIX shell environment
	init(){
		set -eu
		umask 0022
		PATH="$(command -p getconf PATH || :)${PATH+:$PATH}"
		export PATH="${PATH#:}" LC_ALL='C'
	}

	is_exe_enabled()(command -v ${@+"$@"} >/dev/null)

	run_sh()(
		SH="$1"
		shift
		echo "$SH"
		$SH ${@+"$@"}
	)

	main()(
		SHS='sh ksh ksh93 pdksh mksh posh ash dash bash zsh yash'
		for sh in $SHS; do
			eval 'is_exe_enabled $sh' && eval 'run_sh $sh ${@+"$@"} || :'
		done
	)

	init
	main ${@+"$@"}
)

is_main && shs ${@+"$@"}
