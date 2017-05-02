: ## \file print_argv_1.sh
set -u
print_argv()(echo "#:$#, 1:${1-}, 2:${2-}, @:${@-}.")
printf '${1+"$@"}\t'; print_argv ${1+"$@"}
printf '${1+"$*"}\t'; print_argv ${1+"$*"}
