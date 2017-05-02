: ## \file print_argv_eval.sh
set -u
print_argv()(echo "$#, ${1-}, ${2-}, ${@-}.")

[ $# = 0 ] && EXPAND_ARGV='eval' || EXPAND_ARGV=''
printf '"${@-}"\t'; $EXPAND_ARGV print_argv "${@-}"
printf '"${*-}"\t'; $EXPAND_ARGV print_argv "${*-}"
