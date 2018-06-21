send:
	scp consul-config.json consul.service Makefile robodock@consul01:/home/robodock
	scp consul-config.json consul.service Makefile robodock@consul02:/home/robodock
	scp consul-config.json consul.service Makefile robodock@consul03:/home/robodock

install:
	sudo apt-get update && sudo apt-get install -y unzip make
	curl -o consul.zip https://releases.hashicorp.com/consul/1.0.6/consul_1.0.6_linux_amd64.zip
	sudo unzip consul.zip -d /usr/local/bin; rm consul.zip
	sudo cp consul.service /etc/systemd/system
	sudo systemctl daemon-reload
	sudo service consul start