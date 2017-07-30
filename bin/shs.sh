:
################################################################################
## \file      shs.sh
## \author    SENOO, Ken
## \copyright CC0
## \date      first created date: 2017-04-30T00:41+09:00
## \date      last  updated date: 2017-07-23T22:30+09:00
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
		PATH="$(command -p getconf PATH 2>&- || :)${PATH+:$PATH}"
		export PATH="${PATH#:}" LC_ALL='C'
	}

	is_exe_enabled()(command -v ${@+"$@"} >/dev/null)

	main()(
		SHS='sh ksh ksh93 pdksh olsh lksh mksh posh ash dash bash zsh yash busybox'
		#SHS=' csh tcsh fish'
		for sh in $SHS; do
			# is_exe_enabled $sh || continue
			command -v $sh || continue
			[ $sh = 'busybox' ] && sh='busybox ash'
			$sh ${1+"$@"} || :
		done
	)

	init
	main ${1+"$@"}
)

is_main && shs ${1+"$@"}
