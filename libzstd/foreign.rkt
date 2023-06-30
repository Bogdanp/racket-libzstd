#lang racket/base

(require (for-syntax racket/base)
         ffi/unsafe
         ffi/unsafe/define
         racket/runtime-path)

(provide
 zstd-compress!
 zstd-decompress!
 zstd-compress
 zstd-decompress)

(define-runtime-path libzstd.so
  '(so "libzstd"))

(define-ffi-definer define-zstd (ffi-lib libzstd.so))

(define-zstd ZSTD_compress (_fun _bytes _size _bytes _size _int -> _size))
(define-zstd ZSTD_compressBound (_fun _size -> _size))
(define-zstd ZSTD_decompress (_fun _bytes _size _bytes _size -> _size))
(define-zstd ZSTD_getFrameContentSize (_fun _bytes _size -> _size))
(define-zstd ZSTD_getErrorName (_fun _size -> _bytes/nul-terminated))
(define-zstd ZSTD_isError (_fun _size -> _int))
(define-zstd ZSTD_defaultCLevel (_fun -> _int))

(define default-compression-level (ZSTD_defaultCLevel))

(define (error? code)
  (= 1 (ZSTD_isError code)))

(define (oops who code)
  (error who (bytes->string/utf-8 (ZSTD_getErrorName code))))

(define (zstd-compress! src dst [level default-compression-level])
  (define len (ZSTD_compress dst (bytes-length dst) src (bytes-length src) level))
  (begin0 len
    (when (error? len)
      (oops 'ZSTD_compress len))))

(define (zstd-decompress! src dst)
  (define len (ZSTD_decompress dst (bytes-length dst) src (bytes-length src)))
  (begin0 len
    (when (error? len)
      (oops 'ZSTD_decompress len))))

(define (zstd-compress src [level default-compression-level])
  (define dst (make-bytes (ZSTD_compressBound (bytes-length src))))
  (subbytes dst 0 (zstd-compress! src dst level)))

(define (zstd-decompress src)
  (define dst (make-bytes (ZSTD_getFrameContentSize src (bytes-length src))))
  (subbytes dst 0 (zstd-decompress! src dst)))
