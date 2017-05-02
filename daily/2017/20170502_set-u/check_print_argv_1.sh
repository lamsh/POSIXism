: ## \file check_print_argv_1.sh
set -u
SHS='sh ksh ksh93 pdksh mksh posh ash dash bash zsh yash'
for sh in $SHS; do
	command -v $sh || continue
	$sh <<-EOT
	print_argv()(echo "#:$#, 1:${1-}, 2:${2-}, @:${@-}.")
	printf '\${1+"\$@"}\t'; print_argv ${1+"$@"}
	printf '\${1+"\$*"}\t'; print_argv ${1+"$*"}
	EOT
done
