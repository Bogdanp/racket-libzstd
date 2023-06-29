# racket-libzstd

[![build](https://github.com/Bogdanp/racket-libzstd/actions/workflows/push.yml/badge.svg)](https://github.com/Bogdanp/racket-libzstd/actions/workflows/push.yml)

This package distributes [libzstd] as a Racket package for Linux and
macOS.

The dynamic libraries are built on the following systems:

| Package                | OS/Version   | Compatibility                           |
|------------------------|--------------|-----------------------------------------|
| libztd-x86_64-linux    | Debian 10.0  | Ubuntu 18.04 and up, Debian 10.0 and up |
| libzstd-aarch64-macosx | macOS 13     | macOS 13 (Ventura) and up               |
| libzstd-x86_64-macosx  | macOS 11     | macOS 11 (Big Sur) and up               |


[libzstd]: https://github.com/facebook/zstd