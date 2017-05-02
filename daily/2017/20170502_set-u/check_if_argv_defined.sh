: ## \file check_if_argv_defined.sh
## x: ash (Busybox), dash, zsh yash
## o: ksh88, ksh93, pdksh, mksh, posh, ash (FreeBSD sh), bash, HP-UX sh

SHS='sh ksh ksh93 pdksh mksh posh ash dash bash zsh yash'
for sh in $SHS; do
	command -v $sh || continue
	$sh <<-'EOT'
	f()(echo "#:$#, ${@+@:  defined}${@-@:undefined}, ${*+*:  defined}${*-*:undefined}, ${1+1:  defined}${1-1:undefined}.")
	printf 'A. f,      #:0, undefined | '; f
	printf "A. f '',   #:1,   defined | "; f ''
	printf 'A. f "$@", #:0, undefined | '; f "$@"
	printf 'A. f "$*", #:1,   defined | '; f "$*"
	EOT
done
