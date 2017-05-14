:
################################################################################
## \file      timeit.sh
## \author    SENOO, Ken
## \copyright CC0
## \date      created date: 2016-10-15T16:41+09:00
## \date      updated date: 2017-05-14T15:09+09:00
## \brief     Time commands.
################################################################################


timeit()(
	EXE_NAME='timeit'

	## \brief Initialize POSIX shell environment
	init(){
		PATH="$(command -p getconf PATH 2>&-)${PATH+:$PATH}"
		export PATH="${PATH#:}" LC_ALL='C'
		umask 0022
		set -eu
	}

	is_main()(
		SCRIPT_NAME="$EXE_NAME.sh"
		[ "$SCRIPT_NAME" = "${0##*/}" ]
	)

	main()(
		[ $# = 0 ] && exit 1

		COMMAND="$1"

		if [ $# = 1 ]; then
			TIMES=100
		else
			TIMES="$2"
		fi

		## Time commands
		LOOP_ITEM='$(yes | head -n '"$TIMES"')'
		RESULT=$(time -p sh -c '
			for i in '"$LOOP_ITEM; do
				$COMMAND >/dev/null 2>&1
			done" 2>&1)

		## Save result
		REAL_TIME_S=$(echo "$RESULT" | sed -n /real/p)
		USER_TIME_S=$(echo "$RESULT" | sed -n /user/p)
		SYS_TIME_S=$( echo "$RESULT" | sed -n /sys/p)

		## Print result
		HT=$(printf '\t')
		echo "run $TIMES:'$COMMAND'\t$REAL_TIME_S\t$USER_TIME_S\t$SYS_TIME_S"
	)

	init
	is_main && main ${1+"$@"}
)

timeit ${1+"$@"}
