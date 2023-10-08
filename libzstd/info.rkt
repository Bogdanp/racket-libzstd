#lang info

(define license 'BSD-3-Clause)
(define collection "libzstd")
(define version "1.5.5")
(define deps
  '("base"
    ["libzstd-aarch64-macosx" #:platform #rx"aarch64-macosx"]
    ["libzstd-x86_64-linux" #:platform #rx"x86_64-linux"]
    ["libzstd-x86_64-macosx" #:platform #rx"x86_64-macosx"]
    ["libzstd-i386-win32" #:platform #rx"win32.i386"]
    ["libzstd-x86_64-win32" #:platform #rx"win32.x86_64"]))
