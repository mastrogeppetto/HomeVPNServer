run:
	make install
	sudo docker compose up -d
	sudo systemctl daemon-reexec
	sudo systemctl daemon-reload
	sudo systemctl restart wg-firewall.service
install:
	sudo cp wg-firewall.service /etc/systemd/system/wg-firewall.service
	sudo cp wg-firewall.sh /usr/local/bin/wg-firewall.sh
stop:
	sudo docker compose down -v --remove-orphans
	sudo iptables -F DOCKER-USER
