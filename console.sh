#!/bin/sh

sdk="${1:-vm-sdk}"

cat <<EOF > $sdk/.zshrc
# local zshrc for easy start of console
# usage: ZDOTDIR=/path/to/vm-sdk zsh
pushd \$ZDOTDIR > /dev/null
# check that all submodules are there, useful for git repos
[[ -r lib/zuper/zuper ]] || git submodule update --init
source sdk
popd > /dev/null
EOF

ZDOTDIR=$sdk zsh
