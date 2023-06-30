#lang racket/base

(require racket/contract
         "foreign.rkt")

(provide
 (contract-out
  [zstd-compress! (->* (bytes? bytes?) (level/c) exact-nonnegative-integer?)]
  [zstd-decompress! (-> bytes? bytes? exact-nonnegative-integer?)]
  [zstd-compress (->* (bytes?) (level/c) bytes?)]
  [zstd-decompress (->* (bytes?) ((or/c #f exact-positive-integer?)) bytes?)]))

(define level/c
  (integer-in #x-80000000 #x7FFFFFFF))
