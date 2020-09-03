;; -*- external-format: utf-8; -*-

;;; MySQL native driver for Lispworks
;;; ver: 20130529

;;; Based on http://dev.mysql.com/doc/internals/en/client-server-protocol.html

;;; Copyright (c) 2009-2013, Art Obrezan
;;; All rights reserved.
;;;
;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions are met:
;;;
;;; 1. Redistributions of source code must retain the above copyright
;;;    notice, this list of conditions and the following disclaimer.
;;; 2. Redistributions in binary form must reproduce the above copyright
;;;    notice, this list of conditions and the following disclaimer in the
;;;    documentation and/or other materials provided with the distribution.
;;; 3. Use in source and binary forms are not permitted in projects under
;;;    GNU General Public Licenses and its derivatives.
;;;
;;; THIS SOFTWARE IS PROVIDED BY ART OBREZAN ''AS IS'' AND ANY
;;; EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;;; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;;; DISCLAIMED. IN NO EVENT SHALL ART OBREZAN BE LIABLE FOR ANY
;;; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
;;; (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
;;; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
;;; ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;;; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;;; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


(in-package "CL-USER")

(defpackage "MYSQL"
  (:add-use-defaults t)
  (:export connect
           disconnect
           query
           pquery
           last-insert-id
           escape-string
           quote-string
           with-connection
           with-transaction))

(in-package "MYSQL")

(require "comm")

;;-----------------------------------------------------------------------------

(defstruct mysqlcon
  stream
  host
  port
  connection-id
  server-capabilities
  last-insert-id)


;; See http://dev.mysql.com/doc/internals/en/connection-phase.html#capability-flags

(defconstant +capabilities+
  `((:client-long-password . #x1)
    (:client-found-rows . #x2)
    (:client-long-flag . #x4)
    (:client-connect-with-db . #x8)
    (:client-no-schema . #x10)
    (:client-compress . #x20)
    (:client-odbc . #x40)
    (:client-local-files . #x80)
    (:client-ignore-space . #x100)
    (:client-protocol-41 . #x200)
    (:client-interactive . #x400)
    (:client-ssl . #x800)
    (:client-ignore-sigpipe . #x1000)
    (:client-transactions . #x2000)
    (:client-reserved . #x4000)
    (:client-secure-connection . #x8000)
    (:client-multi-statements . #x10000)
    (:client-multi-results . #x20000)
    (:client-ps-multi-results . #x40000)
    (:client-plugin-auth . #x80000)
    (:client-connect-attrs . #x100000)
    (:client-plugin-auth-lenenc-client-data . #x200000)))

(defconstant +client-capabilities+
  '(:client-protocol-41
    :client-secure-connection ; Authentication::Native41
    :client-ignore-space
    :client-transactions))


;;-----------------------------------------------------------------------------
;; CONNECT
;;-----------------------------------------------------------------------------

(defconstant +max-packet-size+ (* 1024 1024)) ;; in bytes
(defconstant +utf8-general-ci+ 33)

(defun connect (&key host (port 3306) user (password nil) (database nil))
  (let* ((stream (open-stream host port))
         (packet (read-packet stream)))
    (if (error-packet-p packet)
        (raise-mysql-error packet)
      (let* ((server-info (parse-handshake-packet packet))
             (scramble (getf server-info :scramble)))
        (send-authorization-packet stream user password database scramble)
        (let ((packet (read-packet stream))
              (connection nil))
          (cond ((ok-packet-p packet)
                 (setq connection (initialize-connection stream host port server-info)))
                ((error-packet-p packet)
                 (close stream)
                 (raise-mysql-error packet))
                (t
                 (close stream)
                 (raise-mysql-error "Unknown error during connection.")))
          (query connection "SET NAMES 'utf8'")
          connection)))))

(defun open-stream (host port)
  (let ((stream (comm:open-tcp-stream host port
                                      :direction :io
                                      :timeout 3
                                      :element-type '(unsigned-byte 8))))
    (unless stream
      (raise-mysql-error (format nil "Cannot connect to ~a:~a" host port)))
    stream))

(defun initialize-connection (stream host port server-info)
  (make-mysqlcon :stream stream
                 :host host
                 :port port
                 :connection-id (getf server-info :thread-id)
                 :server-capabilities (getf server-info :server-capabilities)
                 :last-insert-id nil))


(defun parse-handshake-packet (buf)
  (let* ((protocol-version (aref buf 0))
         (pos (position 0 buf)) ;;; end position of a c-line (zero)
         (server-version (decode-string buf :start 1 :end pos :format :latin1))
         (thread-id (+ (aref buf (+ pos 1))
                       (ash (aref buf (+ pos 2)) 8)
                       (ash (aref buf (+ pos 3)) 16)
                       (ash (aref buf (+ pos 4)) 24)))
         (server-capabilities (number-to-capabilities
                               (+ (aref buf (+ pos 14))
                                  (ash (aref buf (+ pos 15)) 8))))
         (server-language (aref buf (+ pos 16)))
         (server-status (+ (aref buf (+ pos 17))
                           (ash (aref buf (+ pos 18)) 8)))
         (scramble (make-array 20 :element-type '(unsigned-byte 8))))
    (dotimes (i 8)
      (setf (aref scramble i) (aref buf (+ pos i 5))))
    (dotimes (i 12)
      (setf (aref scramble (+ i 8)) (aref buf (+ pos i 32))))
    (list :protocol-version protocol-version
          :server-version server-version
          :thread-id thread-id
          :server-capabilities server-capabilities
          :server-language server-language
          :server-status server-status
          :scramble scramble)))


(defun send-authorization-packet (stream user password database scramble)
  (write-packet
   (prepare-auth-packet user
                        (if (and (stringp password) (zerop (length password)))
                            nil password)
                        (if (and (stringp database) (zerop (length database)))
                            nil database)
                        scramble)
   stream
   :packet-number 1))

(defun prepare-auth-packet (user password database scramble)
  (let ((buf (make-array 32 :element-type '(unsigned-byte 8) :initial-element 0))
        (client-flags (capabilities-to-number
                       (if database
                           (cons :client-connect-with-db +client-capabilities+)
                         +client-capabilities+)))
        (database-buf (if database
                          (encode-string database :format :cstring)
                        #()))
        (user-buf (encode-string user :format :cstring))
        (auth-buf (if password
                      (let ((scramble-buf (password-to-token password scramble)))
                        (concatenate 'vector
                                     (vector (length scramble-buf))
                                     scramble-buf))
                    #(0))))
    (put-int32-to-array client-flags      buf :position 0) ;; capability flags
    (put-int32-to-array +max-packet-size+ buf :position 4) ;; max-packet size
    (put-int8-to-array  +utf8-general-ci+ buf :position 8) ;; character set
    (concatenate 'vector
                 buf
                 user-buf
                 auth-buf
                 database-buf)))

(defun password-to-token (password scramble)
  (let* ((pwd (encode-string password :format :latin1))
         (stage1-hash (sha1-digest pwd))
         (stage2-hash (sha1-digest stage1-hash))
         (digest (sha1-digest (concatenate 'vector scramble stage2-hash)))
         (token (make-array 20 :element-type '(unsigned-byte 8))))
    (dotimes (i (length token))
      (setf (aref token i)
            (logxor (aref digest i)
                    (aref stage1-hash i))))
    token))


(defun number-to-capabilities (num)
  (remove nil (mapcar #'(lambda (cons)
                          (if (zerop (logand (cdr cons) num))
                              nil
                            (car cons)))
                      +capabilities+)))

(defun capabilities-to-number (capabilities-list)
  (let ((num 0))
    (dolist (option capabilities-list)
      (incf num (cdr (assoc option +capabilities+))))
    num))


;;-----------------------------------------------------------------------------
;; DISCONNECT
;;-----------------------------------------------------------------------------

(defconstant +com-quit+ 1)

(defun disconnect (connection)
  (when (mysqlcon-stream connection)
    (send-quit connection)
    (close (mysqlcon-stream connection))
    (setf (mysqlcon-stream connection) nil)))

(defun send-quit (connection)
  (write-packet `#(,+com-quit+) (mysqlcon-stream connection)
                :packet-number 0))


;;-----------------------------------------------------------------------------
;; QUERY
;;-----------------------------------------------------------------------------

(defconstant +com-query+ 3)

(defun query (connection &rest args)
  (let ((query-string (append-query-arguments args)))
    (doquery connection query-string nil)))

(defun pquery (connection &rest args)
  (let ((query-string (append-query-arguments args)))
    (doquery connection query-string t)))

(defun append-query-arguments (args)
  (apply #'string-append
         (mapcar #'(lambda (arg)
                     (string-append " " (if (stringp arg)
                                            arg
                                          (write-to-string arg))))
                 args)))

(defun doquery (connection query-string named-fileds-p)
  (let ((stream (mysqlcon-stream connection)))
    (unless stream
      (raise-mysql-error "No database connection"))
    (send-query-string query-string stream)
    (let ((packet (read-packet stream)))
      (cond ((error-packet-p packet)
             (raise-mysql-error packet))
            ((ok-packet-p packet)
             (update-connection-data connection packet))
            (t
             (parse-data-packets packet stream named-fileds-p))))))

(defun send-query-string (str stream)
  (write-packet
   (concatenate 'vector `#(,+com-query+) (encode-string str :format :utf8))
   stream
   :packet-number 0))

(defun update-connection-data (connection packet)
  (let* ((ok (parse-ok-packet packet))
         (last-insert-id (getf ok :last-insert-id)))
    (setf (mysqlcon-last-insert-id connection) last-insert-id))
  nil)

(defun parse-data-packets (packet stream named-fileds-p)
  (let ((num (decode-length-coded-binary packet 0)) ; number of columns
        (column-names-list nil))
    ;; read mysql field packets
    (dotimes (i num)
      (let ((buf (read-packet stream)))
        (when named-fileds-p
          (multiple-value-bind (start len) (nth-field-packet-entry 5 buf)
            (push (intern-to-keyword
                   (decode-string buf :start start :end (+ start len) :format :utf8))
                  column-names-list)))))
    (setq column-names-list (nreverse column-names-list))
    ;; read eof packet
    (read-packet stream)
    ;; read row packets data
    (let (result)
      (do ((packet (read-packet stream) (read-packet stream)))
          ((eof-packet-p packet))
        (push (parse-row-packet packet column-names-list)
              result))
      (nreverse result))))

(defun intern-to-keyword (str)
  (intern (string-upcase str) "KEYWORD"))

(defun nth-field-packet-entry (n buf)
  (let ((pos 0) (len 0) (offset 0))
    (dotimes (i n)
      (incf pos (+ offset len))
      (multiple-value-bind (l o)
          (decode-length-coded-binary buf pos)
       (setq len l)
       (setq offset o)))
    (values (+ pos offset) len)))     

(defun parse-row-packet (buf column-names-list)
  (let ((buf-len (length buf))
        (pos 0)
        (list nil))
    (loop
     (multiple-value-bind (len start) (decode-length-coded-binary buf pos)
       (if (= len -1) ;column value = NULL
           (progn
             (when column-names-list
               (push (pop column-names-list) list))
             (push "NULL" list)
             (setq pos (+ start pos)))
         (progn
           (when column-names-list
             (push (pop column-names-list) list))
           (push (decode-string buf :start (+ start pos) :end (+ start pos len) :format :utf8)
                 list)
           (setq pos (+ start pos len))))
       (when (>= pos buf-len) (return))))
     (nreverse list)))


;;-----------------------------------------------------------------------------
;; MYSQL ADDON FUNTIONS/MACROS
;;-----------------------------------------------------------------------------

(defun last-insert-id (connection)
  (mysqlcon-last-insert-id connection))

;; Escape string to insert into a string column
(defun escape-string (str)
  (let ((escaped-string (make-array (length str)
                                    :element-type 'lw:simple-char
                                    :adjustable t
                                    :fill-pointer 0)))
    (dotimes (i (length str))
      (let ((ch (char str i)))
        (when (member ch '(#\' #\" #\\))
          (vector-push-extend #\\ escaped-string))
        (vector-push-extend ch escaped-string)))
    escaped-string))

(defun quote-string (str)
  (string-append "'" (escape-string str) "'"))

(defmacro with-connection ((db credentials) &body body)
  `(let ((,db (apply #'mysql:connect ,credentials)))
     (unwind-protect (progn ,@body)
       (when ,db (mysql:disconnect ,db)))))

(defmacro with-transaction ((db) &body body)
  (with-unique-names (res)
    `(let ((,res nil))
       (unwind-protect
           (prog2
                (mysql:query ,db "START TRANSACTION")
                (progn ,@body)
             (setf ,res t))
         (mysql:query ,db (if ,res "COMMIT" "ROLLBACK"))))))


;;-----------------------------------------------------------------------------
;; READ/WRITE/PARSE PACKETS
;;-----------------------------------------------------------------------------

(defun read-packet (stream)
  (multiple-value-bind (packet-length packet-number)
      (read-packet-header stream) ; TODO: return packet-number as a value?
    (declare (ignore packet-number))
    (let ((buf (make-array packet-length
                           :element-type '(unsigned-byte 8))))
      (read-sequence buf stream)
      buf)))

(defun read-packet-header (stream)
  (let ((len 0)
        (num 0))
    (setq len (+ (read-byte stream)
                 (ash (read-byte stream) 8)
                 (ash (read-byte stream) 16)))
    (setq num (read-byte stream))
    (values len num)))


(defun write-packet (data stream &key packet-number)
  (write-packet-header (length data) packet-number stream)
  (write-sequence data stream)
  (force-output stream))

(defun write-packet-header (len packet-number stream)
  (write-byte (logand #xff len) stream)
  (write-byte (logand #xff (ash len -8)) stream)
  (write-byte (logand #xff (ash len -16)) stream)
  (write-byte (logand #xff packet-number) stream))


(defun error-packet-p (buf)
  (= #xFF (aref buf 0)))

(defun parse-error-packet (buf)
  (let ((error (+ (aref buf 1)
                  (ash (aref buf 2) 8)))
        (sqlstate nil)
        (message nil))
    (if (char/= #\# (code-char (aref buf 3)))
        (setq message (decode-string buf :start 3 :format :utf8))
      (progn
        (setq sqlstate (decode-string buf :start 4 :end 8 :format :latin1))
        (setq message (decode-string buf :start 9 :format :utf8))))
    (list :error error
          :sqlstat sqlstate
          :message message)))


(defun ok-packet-p (buf)
  (zerop (aref buf 0)))

(defun parse-ok-packet (buf)
  (multiple-value-bind (affected-rows len)
      (decode-length-coded-binary buf 1)
    (multiple-value-bind (last-insert-id len2)
        (decode-length-coded-binary buf (+ 1 len))
      (let ((pos (+ 1 len len2)))
        (let ((server-status (+ (aref buf pos)
                                (ash (aref buf (+ pos 1)) 8)))
              (warning-count (+ (aref buf (+ pos 2))
                                (ash (aref buf (+ pos 3)) 8)))
              (message (when (< (+ pos 4) (length buf))
                         (decode-string buf
                                        :start (+ pos 4) :end (length buf)
                                        :format :utf8))))
          (list :affected-rows affected-rows
                :last-insert-id last-insert-id
                :server-status server-status
                :warning-count warning-count
                :message message))))))


(defun eof-packet-p (buf)
  (and (= #xFE (aref buf 0))
       (= 5 (length buf))))

(defun parse-eof-packet (buf)
  (let ((warning-count (+ (aref buf 1)
                          (ash (aref buf 2) 8)))
        (status (+ (aref buf 3)
                   (ash (aref buf 4) 8))))
    (list :warning-count warning-count
          :status status)))

;;-----------------------------------------------------------------------------
;; BYTE UTILS
;;-----------------------------------------------------------------------------

(defun put-int8-to-array (int array &key position)
  (setf (aref array position) (logand #xFF int)))

(defun put-int32-to-array (int array &key position)
  (setf (aref array position) (logand #xFF int))
  (setf (aref array (+ position 1)) (logand #xFF (ash int -8)))
  (setf (aref array (+ position 2)) (logand #xFF (ash int -16)))
  (setf (aref array (+ position 3)) (logand #xFF (ash int -24))))

(defun decode-length-coded-binary (buf pos)
  (declare (optimize (speed 3) (debug 0) (float 0)))
  (let ((val (aref buf pos)))
    (cond ((< val 251) (values val 1))
          ((= val 251) (values -1 1)) ;column value = NULL (only appropriate in a Row Data Packet)
          ((= val 252) (values (get-length-coded-int16 buf pos) 3))
          ((= val 253) (values (get-length-coded-int24 buf pos) 4))
          ((= val 254) (values (get-length-coded-int64 buf pos) 9)))))

(defun get-length-coded-int16 (buf pos)
  (+ (aref buf (+ 1 pos))
     (ash (aref buf (+ 2 pos)) 8)))

(defun get-length-coded-int24 (buf pos)
  (+ (aref buf (+ 1 pos))
     (ash (aref buf (+ 2 pos)) 8)
     (ash (aref buf (+ 3 pos)) 16)))

(defun get-length-coded-int64 (buf pos)
  (+ (aref buf (+ 1 pos))
     (ash (aref buf (+ 2 pos)) 8)
     (ash (aref buf (+ 3 pos)) 16)
     (ash (aref buf (+ 4 pos)) 24)
     (ash (aref buf (+ 5 pos)) 32)
     (ash (aref buf (+ 6 pos)) 40)
     (ash (aref buf (+ 7 pos)) 48)
     (ash (aref buf (+ 8 pos)) 56)))


;;-----------------------------------------------------------------------------
;; STRING UTILS
;;-----------------------------------------------------------------------------

(defun encode-string (str &key format)
  (ecase format
    (:latin1 (strutils-encode-latin1 str))
    (:cstring (strutils-encode-cstring str))
    (:utf8 (strutils-encode-utf8 str))))

(defun decode-string (buf &key format (start 0) (end (length buf)))
  (ecase format
    (:latin1 (strutils-decode-latin1 buf start end))
    (:utf8 (strutils-decode-utf8 buf start end))))


(defun strutils-encode-latin1 (str)
  (let ((buf (make-array (length str) :element-type '(unsigned-byte 8))))
    (dotimes (i (length str))
      (let ((code (char-code (char str i))))
        (if (< code 256)
            (setf (aref buf i) code)
          (error "~S is not a valid latin1 character" (char str i)))))
    buf))

(defun strutils-decode-latin1 (buf start end)
  (let ((str (make-array (- end start) :element-type 'lw:simple-char)))
    (dotimes (i (- end start))
      (setf (char str i) (code-char (aref buf (+ i start)))))
    str))

(defun strutils-encode-cstring (str)
  (let ((buf (make-array (1+ (length str))
                         :element-type '(unsigned-byte 8)
                         :initial-element 0)))
    (dotimes (i (length str))
      (let ((code (char-code (char str i))))
        (if (< code 256)
            (setf (aref buf i) code)
          (error "~S is not a valid latin1 character" (char str i)))))
    buf))

(defun strutils-encode-utf8 (str)
  (declare (optimize (speed 3) (debug 0) (safety 0) (float 0)))
  (let ((buf (make-array (* 3 (length str)) :element-type '(unsigned-byte 8)))
        (pos 0))
    (declare (type fixnum pos))
    (declare (type (vector (unsigned-byte 8) *) buf))
    (dotimes (i (length str))
      (let ((code (char-code (schar str i))))
        (cond
         ((< code #x80)
          (setf (aref buf pos) code)
          (incf pos))
         ((< code #x800)
          (setf (aref buf pos) (logior 192 (ash (logand 1984 code) -6)))
          (incf pos)
          (setf (aref buf pos) (logior 128 (logand 63 code)))
          (incf pos))
         ((< code #x10000)
          (setf (aref buf pos) (logior 224 (ash (logand 61440 code) -12)))
          (incf pos)
          (setf (aref buf pos) (logior 128 (ash (logand 4032 code) -6)))
          (incf pos)
          (setf (aref buf pos) (logior 128 (logand 63 code)))
          (incf pos))
         (t (error "Character is out of the ucs-2 range")))))
    (subseq buf 0 pos)))

(defconstant +utf8-sequence-length+
  (vector
    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
    3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3
    4 4 4 4 4 4 4 4 5 5 5 5 6 6 1 1))

(defun strutils-decode-utf8 (buf start end)
  (declare (optimize (speed 3) (debug 0) (safety 0) (float 0) (system:interruptable 0)))
  (declare (type fixnum start end))
  (declare (type (vector (unsigned-byte 8) *) buf))
  (let ((pos start)
        (i 0)
        (str (make-array (the fixnum (- end start)) :element-type 'lw:simple-char)))
    (declare (type fixnum pos i))
    (loop (when (>= pos end)
            (return (subseq str 0 i)))
          (let* ((byte1 (aref buf pos))
                 (sequence-length (svref +utf8-sequence-length+ byte1)))
            (declare (type fixnum byte1 sequence-length))
            (cond
             ((= 1 sequence-length)
              (setf (schar str i) (code-char byte1)))
             ((= 2 sequence-length)
              (let* ((byte2 (aref buf (the fixnum (1+ pos))))
                     (code  (logior (the fixnum (ash (the fixnum (logand #b00011111 byte1)) 6))
                                    (the fixnum (logand #b00111111 byte2)))))
                (declare (type fixnum byte2 code))
                (setf (schar str i) (code-char code))))
             ((= 3 sequence-length)
              (let* ((byte2 (aref buf (the fixnum (1+ pos))))
                     (byte3 (aref buf (the fixnum (1+ (the fixnum (1+ pos))))))
                     (code  (logior (the fixnum (ash (logand #b00001111 byte1) 12))
                                    (the fixnum (logior (the fixnum (ash (the fixnum (logand #b00111111 byte2)) 6))
                                                        (the fixnum (logand #b00111111 byte3)))))))
                (declare (type fixnum byte2 byte3 code))
                (setf (schar str i) (code-char code))))
             (t
              (setf (schar str i) #\Space)))
            (incf i)
            (incf pos sequence-length)))))


;;-----------------------------------------------------------------------------
;; ERRORS
;;-----------------------------------------------------------------------------

(define-condition mysql-error (error)
  ((number  :initarg :number  :initform nil :reader mysql-error-number)
   (message :initarg :message :initform nil :reader mysql-error-message))
  (:report (lambda (condition stream)
             (format stream "MySQL~:[~;~:*(~A)~]: ~a~%"
                     (mysql-error-number condition)
                     (mysql-error-message condition)))))

(defun raise-mysql-error (obj)
  (typecase obj
    (string
     (error 'mysql-error
            :message obj))
    (vector
     (let ((error-info (parse-error-packet obj)))
       (error 'mysql-error
              :number (getf error-info :error)
              :message (getf error-info :message))))
    (t
     (error 'mysql-error))))


;;-----------------------------------------------------------------------------
;;; SHA-1
;;; http://csrc.nist.gov/publications/fips/fips180-2/fips180-2.pdf
;;; implemented for byte messages
;;-----------------------------------------------------------------------------

(declaim (inline to-32bit-word))
(defun to-32bit-word (int)
  (logand #xFFFFFFFF int))

(declaim (inline sha1-rotl))
(defun sha1-rotl (n shift)
  (logior (to-32bit-word (ash n shift))
	  (ash n (- shift 32))))

(defun sha1-padding-size (n)
  (let ((x (mod (- 56 (rem n 64)) 64)))
    (if (zerop x) 64 x)))

(defun sha1-pad-message (message)
  (let* ((message-len (length message))
         (message-len-in-bits (* message-len 8))
         (buffer-len (+ message-len 8 (sha1-padding-size message-len)))
         (buffer (make-array buffer-len :initial-element 0)))
    (dotimes (i message-len)
      (setf (aref buffer i) (aref message i)))
    (setf (aref buffer message-len) #b10000000)
    (dotimes (i 8)
      (setf (aref buffer (- buffer-len (1+ i)))
            (logand #xFF (ash message-len-in-bits (* i -8)))))
    buffer))

(defun sha1-prepare-message-block (n data)
  (let ((message-block (make-array 80))
        (offset (* n 64)))
    (do ((i 0 (1+ i)))
        ((> i 15))
      (setf (aref message-block i)
            (+ (ash (aref data (+ offset   (* i 4))) 24)
               (ash (aref data (+ offset 1 (* i 4))) 16)
               (ash (aref data (+ offset 2 (* i 4))) 8)
               (aref data (+ offset 3 (* i 4))))))
    (do ((i 16 (1+ i)))
        ((> i 79))
      (setf (aref message-block i) 
            (to-32bit-word
             (sha1-rotl (logxor (aref message-block (- i 3))
                           (aref message-block (- i 8))
                           (aref message-block (- i 14))
                           (aref message-block (- i 16))) 1))))
    message-block))

(defun sha1-f (n x y z)
  (cond ((<= 0 n 19)
         (to-32bit-word (logior (logand x y)
                                (logand (lognot x) z))))
        ((or (<= 20 n 39) (<= 60 n 79))
         (to-32bit-word (logxor x y z)))
        ((<= 40 n 59)
         (to-32bit-word (logior (logand x y)
                                (logand x z)
                                (logand y z))))))

(defun sha1-k (n)
  (cond ((<=  0 n 19) #x5A827999)
        ((<= 20 n 39) #x6ED9EBA1)
        ((<= 40 n 59) #x8F1BBCDC)
        ((<= 60 n 79) #xCA62C1D6)))
  
(defun sha1-digest (message)
  "Make a SHA1 digest from a vector of bytes"
  (let* ((h0 #x67452301)
         (h1 #xEFCDAB89)
         (h2 #x98BADCFE)
         (h3 #x10325476)
         (h4 #xC3D2E1F0)
         (padded-message (sha1-pad-message message))
         (n (/ (length padded-message) 64)))
    (dotimes (i n)
      (let ((a h0) (b h1) (c h2) (d h3) (e h4) (temp 0)
            (message-block (sha1-prepare-message-block i padded-message)))
        (dotimes (i 80)
          (setq temp (to-32bit-word (+ (sha1-rotl a 5)
                                       (sha1-f i b c d)
                                       e
                                       (sha1-k i)
                                       (aref message-block i))))
          (setq e d)
          (setq d c)
          (setq c (to-32bit-word (sha1-rotl b 30)))
          (setq b a)
          (setq a temp))  
        (setq h0 (to-32bit-word (+ h0 a)))
        (setq h1 (to-32bit-word (+ h1 b)))
        (setq h2 (to-32bit-word (+ h2 c)))
        (setq h3 (to-32bit-word (+ h3 d)))
        (setq h4 (to-32bit-word (+ h4 e)))))
    (vector 
     (logand #xFF (ash h0 -24))
     (logand #xFF (ash h0 -16))
     (logand #xFF (ash h0 -8))
     (logand #xFF h0)
     (logand #xFF (ash h1 -24))
     (logand #xFF (ash h1 -16))
     (logand #xFF (ash h1 -8))
     (logand #xFF h1)
     (logand #xFF (ash h2 -24))
     (logand #xFF (ash h2 -16))
     (logand #xFF (ash h2 -8))
     (logand #xFF h2)
     (logand #xFF (ash h3 -24))
     (logand #xFF (ash h3 -16))
     (logand #xFF (ash h3 -8))
     (logand #xFF h3)
     (logand #xFF (ash h4 -24))
     (logand #xFF (ash h4 -16))
     (logand #xFF (ash h4 -8))
     (logand #xFF h4))))