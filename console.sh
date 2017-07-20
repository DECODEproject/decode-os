#!/bin/sh

if ! [ -r vm-sdk ]; then git submodule update --init --recursive; fi

sdk="${1:-vm-sdk}"

cat <<EOF > $sdk/.zshrc
# local zshrc for easy start of console
# usage: ZDOTDIR=/path/to/vm-sdk zsh
pushd \$ZDOTDIR > /dev/null

source sdk
load devuan decode
popd > /dev/null
EOF

ZDOTDIR=$sdk zsh
