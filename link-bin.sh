:
################################################################################
## \file      link-bin.sh
## \author    SENOO, Ken
## \copyright CC0
## \date      first created date: 2017-05-01T14:32+09:00
## \date      last  updated date: 2017-05-01T14:33+09:00
################################################################################

## \brief link ./bin/* to "$HOME/.local/bin/"

## \brief Initialize POSIX shell environment
init(){
	set -eu
	umask 0022
	PATH="$(command -p getconf PATH || :)${PATH+:$PATH}"
	export PATH="${PATH#:}" LC_ALL='C'
}

init
DST="$HOME/.local/bin"
cd ./bin/
for exe in *; do
	ln -fs "$PWD/$exe" "$DST/"
done
