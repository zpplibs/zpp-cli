#!/bin/sh

set -e

[ -z "$ZIG_BIN" ] && ZIG_BIN=zig

OPTS="-Drelease-safe"

[ -e zigmod/libs/yaml/src ] || git submodule update --init --recursive

cd zigmod

BIN=./zig-out/bin/zigmod
[ -e "$BIN" ] || $ZIG_BIN build -Dbootstrap $OPTS

FETCH="fetch"
[ -e .zigmod ] && FETCH="fetch --no-update"
$BIN $FETCH

cat deps.zig | sed 's/pub const cache = "/pub const cache = "zigmod\//' | sed 's/"\."/"zigmod"/' > ../deps.zig

