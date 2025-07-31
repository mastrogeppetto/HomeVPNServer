### VPN di casa
Installazione di un server WireGuard wg-easy per realizzare una VPN
personale.

## Architettura
E' un docker-compose autocontenuto: dovrebbe installare tutto da solo.
Contiene il server wiseguard (wg-easy) (172.28.5.101:51821 per la
dashboard e 172.28.5.101:51820 per il server VPN), un DNS (dnsmasq) e un proxy nginx
(172.28.5.100:80) che viene anche utilizzato come web server.
Per rendere il tutto più sicuro si configura un firewall dell'host,
facendo in modo che passino tramite la VPN possano essere raggiunti
solo determinati servizi sulla rete locale.
Il file di configurazione è in wg-firewall.sh. Per configurare le
porte TCP aperte si usa l'array ALLOWED_LIST nel file. Ogni elemento
nella lista apre una porta sull'host definito. Il resto non dovrebbe essere toccato.
Per avviare il server si usa il comando `make run`. Per fermarlo
`make stop`.

Quando avrò superato il beta-test e avrò trovato il PC dove metterlo
renderò il tutto automatico al boot, magari rinominando wg-firewall.sh e
mettendoci anche il `docker compose up`. Si usa `sudo systemctl enable wg-firewall.service`.
   	 

## Modalità d'uso

# Lato server

Prerequisito: Docker

Editare la paginetta nginx/index.html per configurare la pagina di accesso web.

Per aggiungere nuovi servizi:
- aggiungere il server (<ip>:<porta>) nel file di configurazione del firewall
- aggiungere la mappatura del dominio verso l'IP del proxy nella configurazione
del dns (file `dnmasq.com)
- aggiungere un file per la gestione del servizio in nginx/conf.d

Configurare la password della dashboard di wg-easy (sul server VPN, porta
51821).

Lanciare il `docker compose up` eventualmente `-d` e monitorare gli
accessi tramite la dashboard, in modo molto poco preciso. Tramite la dashboard
si creano anche nuovi utenti, generando un QR code oppure un file di configurazione.

Avviare il firewall con systemctl `restart wg-firewall.service`

Per chiudere la VPN `docker compose down`, oppure CRTL-C se lanciato
senza `-v`. Un po' piu drastico `sudo docker compose down -v
--remove-orphans`, e poi eventualmente disttivare il firewall (ma
non nuoce).

Comunque `make run|stop` fanno già tutto.

# Lato client (smartphone)

E' necesssario installare la App Wireguard, e ricevere il QR-code
oppure il file di configurazione con le credenziali.

Nella App si preme il tasto `+`, si seleziona la modalità per QR-code
e poi si punta la telecamera sul QR-code.

Per attivare/disattivare la VPN si sposta il cursore rispettivamente
a destra o sinistra.

# Lato client (Ubuntu)

Si installa il pacchetto wireguard-tools, poi si copiano le credenziali
nella directory /etc/wireguard in un file <nomevpn>.conf. <nomevpn> è
l'identicatore che il client associa alla VPN.

Per aprire la VPN si digita il comando `sudo wg-quick up <nomevpn>`, e
per chiuderlo `sudo wg-quick down <nomevpn>`.

### Schema concettuale

La VPN è un tunnel crittografato tra due nodi, il client e il server.
Il client ottiene dal server un indirizzo IP nella sottorete dei clienti.

Il Server mette a disposizione del Client l'accesso alla sottorete del Server
(172.28.5.0/24) e le altre reti collegate a questo (192.168.113.0/24). Per
risolvere domini interni nella rete del Server il cliente trova un server DNS
ad un indirizzo IP noto. Il server DNS dirotta tutto il traffico sulla porta
80 sul proxy.

Il proxy smista il traffico sulla base del dominio indicato nelle richieste
HTTP, risolvendo il dominio in un indirizzo IP e una porta. Il proxy integra,
se necessario, lo header dei pacchetti.

Per vincolare l'accesso tramite VPN ai soli server che si desidera accedere
dall'esterno si configura un firewal sull'host che ospita i container.
Viene scartato tutto il traffico in ingresso alla rete Docker (172.28.5.0/24),
ad eccezione di quello al DNS (porta 53), e quello in uscita destinato ai
servizi esportati nella sottorete fisica (192.168.113.0/24), e quello
relativo a connessioni già negoziate con i server.
