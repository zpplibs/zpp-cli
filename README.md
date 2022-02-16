# zpp - a build tool for c/c++ with seamlessss cross-compilation via the zig toolchain

## Prepare build
```sh
./boostrap.sh
```

## Build
```sh
./build.sh
```
### Usage
```sh
./zig-out/bin/zpp help
```
### Help text
```
The available commands are:
  - help
  - version
  - mod fetch
  - mod init
  - mod sum
  - mod license

zpp 0.1.0 macos aarch64
```

## Dist (cross-compilation)
```sh
./build.sh dist
```

## Release
```sh
./build.sh dist VERSION GITHUB_TOKEN
```
