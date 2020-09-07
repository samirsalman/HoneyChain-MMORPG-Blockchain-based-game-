# Honey-Chain-MMORPG-Blockchain-based-game


<img src="https://github.com/samirsalman/-Honey-Chain-MMORPG-Blockchain-based-game-/blob/master/honeychain%402x.png"/>
An MMORPG Blockchain based game

## Descrizione progetto

Il progetto consiste nel design e lo sviluppo di un **videogame** che permette agli utenti lo scambio e l'acquisto di oggetti di gioco. Il videogioco appartiene alla categoria dei **Online Role-Playing Game**. Lo scambio e l'acquisto di oggetti saranno tracciati da una Hyperledger Fabric mediante il **World State e Transaction Logs** della stessa.
Inoltre ogni client comunicherà con il server tramite servizi nodeJS e il ruolo dei vari giocatori (che equivale al loro livello nel gioco e/o admin permission) verrà gestito tramite **Validation Authority** in ambiente **LISP**, la quale inoltre si occuperà di effetturà il logging degli utenti all'interno della rete.

## Glossario

- **Online Role-Playing Game**: Videogioco online nel quale i giocatori interagiscono tra loro tramite rete.

- **World State**: Componente della Hyperledger Fabric. Tiene conto del valore corrente di un attributo appartenente ad un oggetto del mondo, come se fosse uno stato Ledger unico.

- **Transaction Log**: Componente della Hyperledger Fabric. Contiene tutte le transazioni effettuate dagli utenti.

- **Servizi NodeJS**: API che modellano la comunicazione client-server, codificate in NodeJS

- **Unity**: Game Engine basato sullo scripting (C#).

- **Permissioned**: Sono dei network di blockchain nelle quali l'accesso è protetto.

- **JWT**: É uno standard open (RFC 7519) che definisce uno schema in formato JSON per lo scambio di informazioni tra vari servizi.

<div style="page-break-after: always;"></div>

## Architettura
Il client GAME corrisponde all'istanza di videogame (**Unity**), comunica mediante API HTTP con la validation authority (invisibile al client), che si occuperà di verificare il **ruolo** dell'utente e lo reindirizzerà al server.Infine utilizzeremo Hyperledger Fabric per registrare e verificare le transazioni e gli smart contract per la gestione degli oggetti di gioco.
Il client APP è un'applicazione Android/IOS realizzata in Flutter che permette il login/registrazione/logout dell'utente, con o senza cookie e permette di consultare l'elenco degli oggetti raccolti dal giocatore nel gioco, la possibilità di effettuare **donazioni di oggetti** e di visionare le varie transizioni dei propri oggetti di gioco. La registrazione in APP equivale anche alla creazione di un wallett nella blockchain associato all'indirizzo email dell'utente.

<img src="https://github.com/samirsalman/HoneyChain-MMORPG-Blockchain-based-game-/blob/master/images/2020/05/structure.png"/>

<img src="https://github.com/samirsalman/HoneyChain-MMORPG-Blockchain-based-game-/blob/master/images/2020/05/home@2x.png"/>

<div style="page-break-after: always;"></div>

## Scenario di Gioco

<img src="https://github.com/samirsalman/HoneyChain-MMORPG-Blockchain-based-game-/blob/master/images/2020/05/scenario.png"/>



Ogni giocatore avrà un proprio stato costituito da:
- **Honeys**: ognuno avrà un proprio valore in base alla rarità
- **Vita**: ogni giocatore avrà un proprio livello di vita
- **Monete**: rappresentano la moneta all'interno del gioco, per l'acquisto e lo scambio di armi



### Scambio di oggetti tra utenti

Gli utenti potranno inoltre scambiare tra loro gli oggetti collezionati durante il gioco,tramite l'app,  per farlo verranno utilizzate le **transazioni su channel privato**, in modo da creare una strategia di alleanza invisibile agli altri utenti.

### Accesso alle aree protette

Nel **World Game** ci saranno delle aree nelle quali l'accesso è consentito solo ad utenti di un determinato livello (o > di un livello), gestiremo l'accesso alle aree protette mediante i ruoli nella Validation Authority.

<div style="page-break-after: always;"></div>

# Sotto Progetti

## SDC

La parte di SDC sarà quella di progettare e realizzare una Validation Authority che si interporra trà Client e Server e si occuperà della gestione degli accessi alle aree protette mediante le Access e le Validation Rules. Ogni giocatore avrà un ruolo diverso in base al proprio livello di gioco. La parte Client sarà quindi un videogame realizzato tramite Unity, mentre la parte Server sarà realizzata in NodeJS e gestirà l'autenticazione degli utenti tramite **JWT**. Ad ogni client corrisponderà un nodo all'interno di Hyperledger Fabric Network.

## SCRS

La parte di progetto di SCRS consisterà nella gestione di una rete Hyperledger Fabric che ci permetterà di gestire il concetto di acquisto e scambio di oggetti di gioco tramite transazioni, inoltre ci permetterà di avere un utenza trusted grazie alla caratteristica **Permissioned** di Hyperledger Fabric. Ogni utente costituisce un nodo all'interno della rete.
Ogni azione dei client avviene mediante degli **smart contract** scritti ad-hoc.


## Creators


**Marcello Politi**,
**Samir Salman**,
**Simone Giorgioni**
