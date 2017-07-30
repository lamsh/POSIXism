:
################################################################################
## \file      alias.sh
## \author    SENOO, Ken
## \copyright CC0
################################################################################

: <<-EOT
	aliasが使えないことがあるのでその検証。
	複合コマンド内でaliasを定義と実行を同時にできない。
	リストもダメなようだ
EOT

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


echo_alias_result(){
	EXIT_STATUS=$?
	STR=${1+"$@"}
	if [ $EXIT_STATUS = 0 ]; then
		echo "Alias run success: $STR"
	else
		echo "Alias run failure: $STR"
	fi
}

EXE=':'
SHS='sh ksh ksh93 pdksh oksh lksh mksh posh ash dash bash zsh yash busybox'

TMP_ALIAS_FILE1='tmp-alias1.sh'
cat <<-EOT >$TMP_ALIAS_FILE1
	alias c=:
	c 2>&-
EOT

TMP_ALIAS_FILE2='tmp-alias2.sh'
cat <<-EOT >$TMP_ALIAS_FILE2
	{ alias c=:; }
	c 2>&-
EOT

for sh in $SHS; do
	is_exe_enabled $sh || continue
	case $sh in busybox) sh='busybox ash'; esac
	$sh -c "shopt -q 2>&-" && sh="$sh -O expand_aliases"
	echo "$sh"
	$sh -c 'alias >/dev/null 2>&-' || continue

	## Expected Success
	$sh <<-EOT; echo_alias_result 'Normal'
		alias c=$EXE
		c
	EOT
	$sh <<-EOT; echo_alias_result 'Define inside, run outside'
		{ alias c=$EXE; }
		c
	EOT
	$sh <<-EOT; echo_alias_result 'Define outside, run inside'
		alias c=$EXE
		{ c; }
	EOT
	$sh <<-EOT; echo_alias_result 'Include1'
		{ . ./$TMP_ALIAS_FILE1; }
	EOT
	$sh <<-EOT; echo_alias_result 'Include2'
		{ . ./$TMP_ALIAS_FILE2; }
	EOT
	$sh <<-EOT 2>&-; echo_alias_result 'func(){}'
		func(){
			alias c=$EXE
		}
		func
		c
	EOT

	## Expected Failure
	$sh -c 'alias c=$EXE | c'    2>&-; echo_alias_result '|'
	$sh -c 'alias c=$EXE & c'    2>&-; echo_alias_result '&'
	$sh -c 'alias c=$EXE; c'     2>&-; echo_alias_result ';'
	$sh -c 'alias c=$EXE && c'   2>&-; echo_alias_result '&&'
	$sh -c '! alias c=$EXE || c' 2>&-; echo_alias_result '||'

	$sh <<-EOT 2>&-; echo_alias_result 'if'
		if true
		then
			alias c=$EXE
			c
		fi
	EOT

	$sh <<-EOT 2>&-; echo_alias_result 'for'
		for i in 0
		do
			alias c=$EXE
			c
		done
	EOT

	$sh <<-EOT 2>&-; echo_alias_result 'case'
		case '' in *)
			alias c=$EXE
			c
		esac
	EOT

	$sh <<-EOT 2>&-; echo_alias_result 'while'
		i=0
		while [ \$((i+=1)) = 1 ]
		do
			alias c=$EXE
			c
		done
	EOT

	$sh <<-EOT 2>&-; echo_alias_result 'until'
		i=0
		until [ \$((i+=1)) = 2 ]
		do
			alias c=$EXE
			c
		done
	EOT

	$sh <<-EOT 2>&-; echo_alias_result '()'
		(
			alias c=$EXE
			c
		)
	EOT

	$sh <<-EOT 2>&-; echo_alias_result '{}'
		{
			alias c=$EXE
			c
		}
	EOT
	$sh <<-EOT 2>&-; echo_alias_result 'func(){}'
		func1(){
			alias c=$EXE
		}
		func2(){
			c
		}
		func1
		func2
	EOT
done
