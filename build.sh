#!/bin/sh

set -e

APP=zpp
OPTS='-Drelease-safe'

[ -z "$ZIG_BIN" ] && ZIG_BIN=zig
[ "$1" != 'dist' ] && $ZIG_BIN build $OPTS && exit 0

DIST_DIR=dist
DIST_VERSION=$2
[ -n "$DIST_VERSION" ] && OPTS="$OPTS -Dversion=$DIST_VERSION"

#TODO add 'aarch64-windows-gnu' when zig has tier1 support for that 
TARGETS='x86_64-linux-gnu.2.23 aarch64-linux-gnu.2.23 x86_64-macos-gnu aarch64-macos-gnu x86_64-windows-gnu'

cross_compile_target(){
    TARGET=$1
    NAME=${TARGET%%-gnu*}
    TARGET_DIR=$APP-$NAME
    echo "$DIST_DIR/$TARGET_DIR ... -Dtarget=$TARGET $OPTS"
    $ZIG_BIN build -p "$DIST_DIR/$TARGET_DIR" -Dtarget=$TARGET $OPTS
}

archive_target(){
    NAME=${1%%-gnu*}
    TARGET_DIR=$APP-$NAME
    case "$NAME" in
        *-windows*)
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

cd $DIST_DIR

for T in $TARGETS; do
    archive_target $T
done

[ -n "$DIST_VERSION" ] || exit 0

REPO_USER=zpplibs
REPO_NAME=zpp-cli
AUTH_USER=dyu
AUTH_TOKEN=$3
[ -n "$AUTH_TOKEN" ] || { echo "3rd arg (github auth token) is required for release."; exit 1; }

upload_target(){
    NAME=${1%%-gnu*}
    TARGET_DIR=$APP-$NAME
    FILE_SUFFIX='.tar.gz'
    case "$NAME" in
        *-windows*)
        FILE_SUFFIX='.zip'
        ;;
    esac
    UPLOAD_FILE=$TARGET_DIR$FILE_SUFFIX
    echo "### Uploading $UPLOAD_FILE"
    GITHUB_TOKEN=$AUTH_TOKEN GITHUB_AUTH_USER=$AUTH_USER github-release upload \
        --user $REPO_USER \
        --repo $REPO_NAME \
        --tag v$DIST_VERSION \
        --name $UPLOAD_FILE \
        --file $UPLOAD_FILE
}

echo "# Tagging v$DIST_VERSION"
GITHUB_TOKEN=$AUTH_TOKEN GITHUB_AUTH_USER=$AUTH_USER github-release release \
    --user $REPO_USER \
    --repo $REPO_NAME \
    --tag v$DIST_VERSION \
    --name "$APP-v$DIST_VERSION" \
    --description "$APP binaries for linux/macos/windows"

for T in $TARGETS; do
    upload_target $T
done

echo v$DIST_VERSION released!
