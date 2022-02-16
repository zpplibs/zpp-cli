#!/bin/sh

set -e

[ -z "$ZIG_BIN" ] && ZIG_BIN=zig

APP="zpp"
OUT_DIR=dist
OPTS="-Drelease-safe"
REL_VERSION=$1
[ -n "$REL_VERSION" ] && OPTS="$OPTS -Dversion=$REL_VERSION"

#TODO add 'aarch64-windows-gnu' when zig has tier1 support for that 
#TARGETS='x86_64-linux-musl aarch64-linux-musl x86_64-linux-gnu.2.23 aarch64-linux-gnu.2.23 x86_64-macos-gnu aarch64-macos-gnu x86_64-windows-gnu'
TARGETS='x86_64-linux-gnu.2.23 aarch64-linux-gnu.2.23 x86_64-macos-gnu aarch64-macos-gnu x86_64-windows-gnu'

cross_compile_target(){
    TARGET=$1
    NAME=${TARGET%%-gnu*}
    TARGET_DIR=$APP-$NAME
    echo "$OUT_DIR/$TARGET_DIR ... -Dtarget=$TARGET $OPTS"
    $ZIG_BIN build -p "$OUT_DIR/$TARGET_DIR" -Dtarget=$TARGET $OPTS
}

archive_target(){
    NAME=${1%%-gnu*}
    TARGET_DIR=$APP-$NAME
    case "$NAME" in
        *-windows-*)
        [ -e "$TARGET_DIR.zip" ] && rm $TARGET_DIR.zip
        rm $TARGET_DIR/bin/$APP.pdb
        zip -r $TARGET_DIR.zip $TARGET_DIR
        ;;
        
        *)
        [ -e "$TARGET_DIR.tar.gz" ] && rm $TARGET_DIR.tar.gz
        tar -cvzf $TARGET_DIR.tar.gz $TARGET_DIR
        ;;
    esac
}

for T in $TARGETS; do
    cross_compile_target $T
done

cd $OUT_DIR

for T in $TARGETS; do
    archive_target $T
done

[ -n "$REL_VERSION" ] || exit 0

REL_TOKEN=$2
[ -n "$REL_TOKEN" ] || { echo "2nd arg (github token) is required for release."; exit 1; }

REL_USER=dyu
REPO_USER=zpplibs
REPO_NAME=zpp-cli

upload_target(){
    NAME=${1%%-gnu*}
    TARGET_DIR=$APP-$NAME
    FILE_SUFFIX='.tar.gz'
    case "$NAME" in
        *-windows-*)
        FILE_SUFFIX='.zip'
        ;;
    esac
    UPLOAD_FILE=$TARGET_DIR$FILE_SUFFIX
    echo "### Uploading $UPLOAD_FILE"
    GITHUB_TOKEN=$REL_TOKEN GITHUB_AUTH_USER=$REL_USER github-release upload \
        --user $REPO_USER \
        --repo $REPO_NAME \
        --tag v$REL_VERSION \
        --name $UPLOAD_FILE \
        --file $UPLOAD_FILE
}

echo "# Tagging v$REL_VERSION"
GITHUB_TOKEN=$REL_TOKEN GITHUB_AUTH_USER=$REL_USER github-release release \
    --user $REPO_USER \
    --repo $REPO_NAME \
    --tag v$REL_VERSION \
    --name "$APP-v$REL_VERSION" \
    --description "$APP binaries for linux/macos/windows"

for T in $TARGETS; do
    upload_target $T
done

echo v$REL_VERSION released!