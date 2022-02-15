## Build
```sh
./boostrap.sh
zig build -Drelease-safe
```

## Usage
```sh
./zig-out/bin/zpp help
```

Help text
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
./dist.sh
```

## Release
```sh
./dist.sh VERSION GITHUB_TOKEN
```