#lang racket

(require readline/pread
         data/maybe
         (prefix-in f: data/functor)
         data/applicative
         data/monad
         threading

         racket/function
         racket/port)

(provide prompt-f)

(define (maybe-regexp-match* regexp str)
  (define res (regexp-match* regexp str #:match-select cadr))
  (if (empty? res) nothing (just (car res))))

(define (mfilter proc m)
  (chain (lambda (x) (if (proc x) m nothing)) m))

(define (run-cmd cmd . args)
  (define exe (find-executable-path cmd))
  (define proc (apply process* exe args))
  ((fifth proc) 'wait)
  (define output (port->string (first proc)))
  (close-input-port (first proc))
  (close-output-port (second proc))
  (close-input-port (fourth proc))
  output)

(define (prompt-f #:last-return-value [last-ret #f])
  ; TODO: Patch rash so that it throws an error without the need to parse the error message
  (define last-code
    (~>> (just last-ret)
         (mfilter exn:fail?)
         (f:map exn-message)
         (chain (lambda~>> (maybe-regexp-match* #rx"terminated with code ([0-9]+)")))))

  ; TODO: Don't show last-ret if it's this error ^^^^^^^^^^^^^^^
  (when (and last-ret (not (void? last-ret)))
    (display last-ret))
  (define prompt
    (run-cmd "starship"
      "prompt"
      ; TODO: Set status to 1 if last-ret was some other exn
      (format "--status=~a" (from-just "0" last-code))))
  (readline-prompt (string->bytes/utf-8 prompt)))
