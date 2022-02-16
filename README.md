# zpp
a build tool for c/c++ with seamless cross-compilation via the zig toolchain

## Quick start
Download the release binaries [here](https://github.com/zpplibs/zpp-cli/releases)


## Building

### Requirements
- zig (the compiler/toolchain)

You can download zig via https://ziglang.org/download/

Alternatively, you can use [zigup](https://github.com/marler8997/zigup) which downloads the binaries for you and allows you to conveniently switch versions when a new version of zig is released. https://github.com/dyu/zigup/releases
```sh
zigup 0.9.1
```

### Once you have zig installed, run:
```sh
./bootstrap.sh
```

### Build
```sh
./build.sh
```
### Run
```sh
./build.sh run -- version
```
### Usage
```sh
./zig-out/bin/zpp help
```
Help text:
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

### Dist (cross-compilation)
```sh
./build.sh dist
```

### Release
```sh
./build.sh dist VERSION GITHUB_TOKEN
```

### Clean
```sh
./build.sh clean
```
