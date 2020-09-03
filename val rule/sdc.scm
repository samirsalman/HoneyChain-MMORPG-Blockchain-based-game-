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

;;  ********************
;;      PROGETTO SDC
;;  VALIDATION AUTHORITY
;;  ********************


(defun Manage::HASHPASS (actionl pbuf)
  (eis::GiveErrorHTTP401) =>
  (Show "Calculating password hash...")
  ;; Prelevo dalla GET i campi email e password
  (define mail (mtfa-eis-get-value-current-query pbuf "email"))
  (define pass (mtfa-eis-get-value-current-query pbuf "password"))
  (define name (mtfa-eis-get-value-current-query pbuf "name"))
  (define years (mtfa-eis-get-value-current-query pbuf "years"))
  (define rand (number->string (mtfa-strong-random 256) 16))
  ;;  Calcolo l'hash della password
  (system (string-append "echo -n " pass " | sha256sum | cut -d ' ' -f 1 > " rand))
  (define hash (read-line (open-file rand "r")))
  (system (string-append "rm " rand))
  ;; Effettuo la redirect verso la pagina "fittizia" della VA con query email password e hash della password
  (eis::Redirect (string-append "/user/hashregister?email=" mail "&password=" hash "&name=" name "&years=" years ))
  )

(defun Manage::LOGIN (actionl pbuf)
  (eis::GiveErrorHTTP401) =>
  (Show "Calculating password hash...")
  ;; Prelevo dalla GET i campi email e password
  (define mail (mtfa-eis-get-value-current-query pbuf "email"))
  (define pass (mtfa-eis-get-value-current-query pbuf "password"))
  (define rand (number->string (mtfa-strong-random 256) 16))
  ;;  Calcolo l'hash della password
  (system (string-append "echo -n " pass " | sha256sum | cut -d ' ' -f 1 > " rand))
  (define hash (read-line (open-file rand "r")))
  (system (string-append "rm " rand))
  ;; Effettuo la redirect verso la pagina "fittizia" della VA con query email password e hash della password
  (eis::Redirect (string-append "/controllo?email=" mail "&password=" hash ))
  )

(defun Manage::COOKIE_LOG (actionl pbuf)
  (eis::GiveErrorHTTP401) =>
  (Show "Setting login cookie...")
  ;; Prelevo dalla GET i campi email, password e hash della password
  (define mail (mtfa-eis-get-value-current-query pbuf "email"))
  (define pass (mtfa-eis-get-value-current-query pbuf "password"))
  (define hash (mtfa-eis-get-value-current-query pbuf "password"))
  (define rand (number->string (mtfa-strong-random 256) 16))
  ;;  Controllo se l'hash della password corrisponde all'hash passato in query
  (system (string-append "echo -n " pass " | sha256sum | cut -d ' ' -f 1 > " rand))
  (define hashPass (read-line (open-file rand "r")))
  (system (string-append "rm " rand))
  ;; Creo un cookie di login con il seguente formato RAND*EMAIL*HASH
  (define x (number->string (mtfa-strong-random 5) 16))
  (define cookie (string-append x "*" mail "*" hash))
    ;; Codifico il cookie in base64
  (define rand2 (number->string (mtfa-strong-random 256) 16))
  (system (string-append "echo -n " cookie " | base64 -w 0 | sed s/=/@/g > " rand2))
  (define cookieB64 (read-line (open-file rand2 "r")))
  (system (string-append "rm " rand2))
  ;;  Imposto la validità del cookie a 30 minuti
  (define time (strftime "%c" (localtime (+ (time-second (current-time)) 180))))
  ;;(define redirect (string-append "Set-Cookie: login=" cookieB64 "; expires=" time))
 ;; (define redirect (string-append "Set-Cookie: login=" cookieB64 "; expires=" time))
  ;; Se l'hash della password nella query corrisponde all'hash calcolato della password
  ;;    effettuo una redirect su /controllo settando il cookie di login
  ;;    altrimenti effettuo una redirect su /login.html
  (eis::Redirect (string-append "/controllore?email=" mail "&password=" pass "&cookie=" cookieB64))
  )

  
  (defun Manage::SENDDATAREG (actionl pbuf)
  (eis::GiveErrorHTTP401) =>
  ;; Prelevo dalla GET i campi email e password
  (define mail (mtfa-eis-get-value-current-query pbuf "email"))
  ;; Effettuo la redirect verso la pagina "fittizia" della VA con query email password e hash della password
  (eis::Redirect (string-append "http://192.168.1.2:3000/response/registration/success?email=" mail))
  )

  (defun Manage::DATA (actionl pbuf)
  (eis::GiveErrorHTTP401) =>
  (eis::Redirect (string-append "http://192.168.1.2:3000/response/loginCookie/success"))
  )
  
    (defun Manage::REDIRECT_SERVER (actionl pbuf)
  (eis::GiveErrorHTTP401) =>
   (define mail (mtfa-eis-get-value-current-query pbuf "email"))
  (eis::Redirect (string-append "http://192.168.1.2:3001/query?username=" mail))
  )
  
      (defun Manage::LOGIN_SUCCESS (actionl pbuf)
  (eis::GiveErrorHTTP401) =>
  (Show "Login con cookie")
   (define cookieLogin (mtfa-eis-get-value-current-query pbuf "cookie"))
  (eis::Redirect (string-append "http://192.168.1.2:3000/response/login/success?cookie=" cookieLogin))
  )
  
        (defun Manage::LOGIN_ERROR_MAIL (actionl pbuf)
  (eis::GiveErrorHTTP401) =>
  (Show "Email non trovata")
  (eis::Redirect (string-append "http://192.168.1.2:3000/response/login/error?error=Email_non_trovata"))
  )
  
         (defun Manage::REGISTRATION_ERROR_MAIL (actionl pbuf)
  (eis::GiveErrorHTTP401) =>
  (Show "Email non disponibile")
  (eis::Redirect (string-append "http://192.168.1.2:3000/response/registration/error?error=Email_non_disponibile"))
  )
  
         (defun Manage::COOKIE_ERROR(actionl pbuf)
  (eis::GiveErrorHTTP401) =>
  (Show "Cookie non valido")
  (eis::Redirect (string-append "http://192.168.1.2:3000/response/login/error?error=Cookie_non_valido"))
  )
  
          (defun Manage::TRANSACTION(actionl pbuf)
  (eis::GiveErrorHTTP401) =>
  (Show "Transazione")
    (define mail (mtfa-eis-get-value-current-query pbuf "email"))
	(define id (mtfa-eis-get-value-current-query pbuf "id"))
  (eis::Redirect (string-append "http://192.168.1.2:3001/query/transaction?id=" id "&email=" mail))
  )


;;Add HOOK
(eis::function-pointer-add "LOGIN" Manage::LOGIN)
(eis::function-pointer-add "TRANSACTION" Manage::TRANSACTION)
(eis::function-pointer-add "LOGIN_ERROR_MAIL" Manage::LOGIN_ERROR_MAIL)
(eis::function-pointer-add "REGISTRATION_ERROR_MAIL" Manage::REGISTRATION_ERROR_MAIL)
(eis::function-pointer-add "COOKIE_ERROR" Manage::COOKIE_ERROR)
(eis::function-pointer-add "LOGIN_SUCCESS" Manage::LOGIN_SUCCESS)
(eis::function-pointer-add "COOKIE_LOG" Manage::COOKIE_LOG)
(eis::function-pointer-add "SENDDATAREG" Manage::SENDDATAREG)
(eis::function-pointer-add "HASHPASS" Manage::HASHPASS)
(eis::function-pointer-add "DATA" Manage::DATA)
(eis::function-pointer-add "REDIRECT_SERVER" Manage::REDIRECT_SERVER)
