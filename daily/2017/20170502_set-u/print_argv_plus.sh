: ## \file print_argv_plus.sh
set -u
print_argv()(echo "#:$#, 1:${1-}, 2:${2-}, @:${@-}.")

printf '${@+"$@"}\t'; print_argv ${@+"$@"}
printf '${*+"$*"}\t'; print_argv ${*+"$*"}
