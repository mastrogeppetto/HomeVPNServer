### VPN di casa
Installazione di un server WireGuard wg-easy per realizzare una VPN
personale.

## Architettura
E' un docker-compose autocontenuto: dovrebbe installare tutto da solo.
Contiene il server wiseguard (wg-easy) (172.28.5.101:51821 per la
dashboard e 172.28.5.101:51820 per il server VPN) e un webserver nginx
(172.28.5.100:80).
Per rendere il tutto più robusto ho irrobustito il firewall dell'host,
facendo in modo che passino attraverso la VPN solo alcune connessioni.
Il file di configurazione è in wg-firewall.sh. Per configurare le
porte TCP aperte si usa l'array ALLOWED_LIST nel file. Ogni elemento
nella lista apre una porta sull'host definito.
Per far partire il tutto si usa il comando `make run`. Per fermarlo
`make stop`. Quando sarò tranquillo potrò rendere il tutto automatico
al boot, magari rinominando wg-firewall.sh e mettendoci anche il
`docker compose up`. Si usa `sudo systemctl enable wg-firewall.service`.
   	 

## Modalità d'uso

# Lato server

Prerequisito: Docker

Editare la paginetta site/index.html con sudoedit per configurare
la pagina di accesso web.

Configurare la password della dashboard di wg-easy (sul server VPN, porta
51821).

Lanciare il `docker compose up` eventualmente `-d` e monitorare gli
accessi tramite la dashboard, in modo molto poco preciso. Tramite la dashboard si creano anche nuovi
utenti, generando un QR code oppure un file di configurazione.

Per chiudere la VPN `docker compose down`, oppure CRTL-C se lanciato
senza `-v`. Un po' piu drastico `sudo docker compose down -v
--remove-orphans`

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
