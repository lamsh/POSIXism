: ## \file print_argv_hyphen.sh
set -u
print_argv()(echo "#:$#, 1:${1-}, 2:${2-}, @:${@-}.")

[ $# = 0 ] && set -- -
printf '"$@"\t'; print_argv "$@"
printf '"$*"\t'; print_argv "$*"
