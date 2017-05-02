: ## \file print_argv_IFS.sh
set -u
print_argv()(echo "#:$#, 1:${1-}, 2:${2-}, @:${@-}.")

IFS='' # assing null to IFS
printf '${@-}\t'; print_argv ${@-}
printf '${*-}\t'; print_argv ${*-}
unset IFS # reset IFS
