#!/bin/sh

sdk="${1:-vm-sdk}"

cat <<EOF > $sdk/.zshrc
# local zshrc for easy start of console
# usage: ZDOTDIR=/path/to/vm-sdk zsh
pushd \$ZDOTDIR > /dev/null
# check that all submodules are there, useful for git repos
[[ -r lib/zuper/zuper ]] || git submodule update --init
[[ -r lib/libdevuansdk/LICENSE ]] || git submodule update --init
[[ -r lib/libdevuansdk/extra/debootstrap/debootstrap ]] || {
   pushd lib/libdevuansdk > /dev/null
   git submodule update --init
   popd
}

source sdk
load devuan decode
popd > /dev/null
EOF

ZDOTDIR=$sdk zsh
