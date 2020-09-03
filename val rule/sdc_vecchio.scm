(use-modules
 (mtfa error-handler)
 (mtfa utils)
 (mtfa serializer)
 (mtfa unordered-set) ;;unordered set con chiavi (stringhe, numeri o sumimboli: tutto convertito in stringa). Persistente
 (mtfa unordered-map) ;;unordered map con chiavi (stringhe) e valori (qualsiasi cosa). persistente
 (mtfa star-map)      ;;Inserisce stringhe con o senza jolly, la stringa che definisce il jolly e il valore. Cerca le stringhe che matchano!
 (mtfa simple_db)
 (mtfa certs)
 (mtfa eis)
 ;;(mtfa fsm)
 (mtfa va)
 (mtfa extset)  ;;gestisce insiemi i cui elementi sono stringhe! consente operazioni di clone, set, check, get all.... Definisce una macro che consente di creare "al volo" una sottoclasse le cui istanze condividono gli stessi elementi.
 (mtfa umset)   ;;è una unordered map (non persistente) che ha stringhe come chiavi e ha insiemi di stringhe come valori. Ogni insert aggiunge all'insieme corrispondente. Definisce inoltre la mtfa-umap-list che consente di mappare liste come chiavi e qualsiasi valore come valore
 (mtfa web)
 (mtfa brg)
 (mtfa lazy-seq)
 (mtfa domain-fiber-server)
 ;;
 (pfds sets)
 (simple-zmq)
 ;;
;; (gnutls)
 ;;
 ;;i moduli di guile
 ;;((rnrs records syntactic) #:prefix rnrs::)
 (rnrs bytevectors)
 (rnrs arithmetic bitwise)
 ((rnrs io ports)
  #:select (string->bytevector bytevector->string)
  #:prefix ioports:)
 ;;
 (srfi srfi-1)
 (srfi srfi-9)
 (srfi srfi-11)
 ((srfi srfi-18)
  #:prefix srfi-18::) ;;thread e mutex
 ;; date & time rinomina per avere un current time che non si sovrappone
 (srfi srfi-19)
 (srfi srfi-26)
 ;;(srfi srfi-28)
 (srfi srfi-43)
 (srfi srfi-60)
 (web uri)
 (system foreign)
;;
 (ice-9 format)
 (ice-9 ftw)
 (ice-9 rdelim)
 (ice-9 pretty-print)
 (ice-9 regex)
 (ice-9 iconv)
 (ice-9 string-fun)
 (ice-9 peg)
 (ice-9 peg string-peg)
 (ice-9 vlist)
 (ice-9 q)
 (ice-9 binary-ports)
 (ice-9 threads)
 (ice-9 hash-table)
 (ice-9 control)
 (ice-9 match)
 (ice-9 receive)
 (ice-9 eval-string)
 (ice-9 arrays)
 ;;
 (oop goops)
 (oop goops describe)
 ;; (sxml simple)
 ;; (sxml ssax)
 ;; (sxml xpath)
 (json)
 (system syntax)
 (system foreign)
 ;;
 (fibers web server)
 ;;
 (web client)
 ;;
 (ffi blis)
 )

;;
;;Init del generatore di numeri casuali
(mtfa-rand-seed (string->number (TimeStamp)))
;;
;;Initialization terminated. Program started
;;

;;HTTP microservices example
(defun Manage::HTTP-API (actionl pbuf)
  (eis::GiveErrorHTTP401) =>
  (eis::GiveHTTPJSONAnswer '(("answer" . "ok")))
  )

;;Add HOOK
(eis::function-pointer-add "HTTPAPI" Manage::HTTP-API)
;;

;;
;;
;;JSON microservices manager (CmdManager) example
(define (JSON-ANSWER::error msg errid)
  `((success . #f)(message . ,msg) (errorid . ,errid)))
;;
(define (JSON-ANSWER::success msg data_name data)
  `((success . #t)(message . ,msg) (data . ((,data_name . ,data)))))

(defun JSONAPI::add (k v pbuf set-names)
  (eis::GiveHTTPJSONAnswer (JSON-ANSWER::error "General System Error" -1))  =>
  (Show "Got add" v)
  (let ((v1 (assoc-ref v "v1"))
 (v2 (assoc-ref v "v2")))
    (eis::GiveHTTPJSONAnswer (JSON-ANSWER::success "OK" "DATANAME" (+ v1 v2)))
    ))

(define CmdManager (mtfa-web-make-json-requests-manager "JSONAPI"))
;;Si aspetta che le richieste json abbiano sempre la seguente struttura
;;"req1": {k: v, k: v, ...}
;;
;;ESEMPIO CURL: curl http://127.0.0.1:8888/ReqJson --data '{"add": {"v1": 10, "v2": 20}}' -H 'Content-Type:application/json'

;;
(CmdManager 'add-handler "add" JSONAPI::add)