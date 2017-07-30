:
################################################################################
## \file      time-macro.sh
## \author    SENOO, Ken
## \copyright CC0
################################################################################

## \brief Compare macro for readable code.
## 0. none
## 1. variable
## 2. eval
## 3. alias
## 4. function(){}
## 5. function()()
## 6. {}
## 7. ()

main(){
	init
	echo "Execution time[s] for $N times"
	echo "only body"
	run_body
	echo "including definition"
	run_total
}

## \brief Initialize POSIX shell environment
init(){
	PATH="$(command -p getconf PATH 2>&-):${PATH:-.}"
	export PATH="${PATH#:}" LC_ALL='C'
	umask 0022
	set -eu

	is_exe_enabled shopt && shopt -s expand_aliases
	export N=100000
	TAB=$(printf '\t')
	N_TEST=$(( 8 + 1 ))
	EXE=':'
	MACRO_N="MACRO_N='$EXE'"
	MACRO_E="MACRO_E='eval $EXE'"
	MACRO_A="alias MACRO_A='$EXE'"
	MACRO_B="MACRO_B(){ $EXE; }"
	MACRO_P="MACRO_P()( $EXE  )"
	BRACE="{ $EXE; }"
	PAREN="( $EXE )"
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

run_body(){
	{
		printf 'Command\nReal\nUser\nSys\n'
		timeit_body '$EXE' "$EXE"
		timeit_body '$MACRO_N' "$MACRO_N"
		timeit_body '$MACRO_E' "$MACRO_E"
		timeit_body  'MACRO_A' "$MACRO_A"
		timeit_body  'MACRO_B' "$MACRO_B"
		timeit_body  'MACRO_P' "$MACRO_P"
		timeit_body  "$BRACE" "$BRACE"
		timeit_body  "$PAREN" "$PAREN"
	} 2>&1 | format
}

## \brief Time exe only body
timeit_body(){
	EXE_STR="$1"; EXE_VAR="$2"
	echo "$EXE_VAR"

	\time -p sh <<-EOT
		eval "$EXE_VAR"
		for i in \$(yes | head -n $N); do
			$EXE_STR
		done
	EOT
}

run_total(){
	{
		printf 'Command\nReal\nUser\nSys\n'
		timeit_total '$EXE'     "$EXE"
		timeit_total '$MACRO_N' "$MACRO_N"
		timeit_total '$MACRO_E' "$MACRO_E"
		timeit_total  'MACRO_A' "$MACRO_A"
		timeit_total  'MACRO_B' "$MACRO_B"
		timeit_total  'MACRO_P' "$MACRO_P"
		timeit_total  "$BRACE" "$BRACE"
		timeit_total  "$PAREN" "$PAREN"
	} 2>&1 | format
}

## \brief Time exe including definition
timeit_total(){
	EXE_STR="$1"; EXE_VAR="$2"
	echo "$EXE_VAR"

	\time -p sh <<-EOT
		eval "$EXE_VAR"  ## for alias
		for i in \$(yes | head -n $N); do
			eval "$EXE_VAR"  ## run definition
			$EXE_STR
		done
	EOT
}

format(){
	pr -t"$N_TEST"s"$TAB" | sed -e 's/real *//g' -e 's/user *//g' -e 's/sys *//g'
}

main
