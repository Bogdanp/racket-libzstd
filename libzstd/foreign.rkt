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

(define ZSTD_CONTENTSIZE_UNKNOWN #xFFFFFFFFFFFFFFFF)
(define ZSTD_CONTENTSIZE_ERROR   #xFFFFFFFFFFFFFFFE)

(define default-compression-level (ZSTD_defaultCLevel))

(define (error? code)
  (= 1 (ZSTD_isError code)))

(define (oops who code)
  (error who (bytes->string/utf-8 (ZSTD_getErrorName code))))

(define (check who len-or-code)
  (begin0 len-or-code
    (when (error? len-or-code)
      (oops who len-or-code))))

(define (get-content-size src)
  (define len
    (ZSTD_getFrameContentSize src (bytes-length src)))
  (cond
    [(= len ZSTD_CONTENTSIZE_UNKNOWN) #f]
    [(= len ZSTD_CONTENTSIZE_ERROR) (check 'ZSTD_getFrameContentSize len)]
    [else len]))

(define (zstd-compress! src dst [level default-compression-level])
  (check 'ZSTD_compress (ZSTD_compress dst (bytes-length dst) src (bytes-length src) level)))

(define (zstd-decompress! src dst)
  (check 'ZSTD_decompress (ZSTD_decompress dst (bytes-length dst) src (bytes-length src))))

(define (zstd-compress src [level default-compression-level])
  (define dst (make-bytes (ZSTD_compressBound (bytes-length src))))
  (subbytes dst 0 (zstd-compress! src dst level)))

(define (zstd-decompress src [max-decompressed-size #f])
  (define len (or (get-content-size src) max-decompressed-size))
  (unless len
    (error 'zstd-decompress "unable to determine decompressed size"))
  (when (and max-decompressed-size (> len max-decompressed-size))
    (error 'zstd-decompress "decompressed length (~a) exceeds max size (~a)" len max-decompressed-size))
  (define dst (make-bytes len))
  (subbytes dst 0 (zstd-decompress! src dst)))
