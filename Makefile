#
#      ______     ____    ______     ____    _____     ____     _____    __   __
#     | ___  \  / ___ \  | ___  \  / ___ \  | ___ \  / ___ \  / _____\  |  | / /
#    | |__| /  | |  | | | |__| /  | |  | | | |  | | | |  | | | |       |  |/ /
#   |      \  | |  | | |  ___ \  | |  | | | |  | | | |  | | | |       |    /
#  |  |\   \ | |__| | |  |__| | | |__| | | |__| | | |__| | | |_____  |  |\ \
# |__|  \__\ \_____/ |_______/  \_____/ |______/  \_____/  \______/ |__| \__\
#

# Written by Mutlu Polatcan
# 21.06.2018

include robodock-core/default_vars.env

.ONESHELL:
SHELL := /bin/bash

ifndef VERBOSE
.SILENT:
endif 


.PHONY: robodock-install
robodock-install:
# If user is not root, get root permissions
	if [[ $$(whoami) != "root" ]]; then \
		echo "ERROR ! Please run \"sudo make robodock-install\" to get root permissions"
	else
		# Install docker
		echo "Installing Docker..."
		./docker-latest.sh

		# Copy configuration files
		echo "Copying configuration files..."
		cp ./robodock-configs/docker /etc/default/docker
		cp ./robodock-configs/docker.service /etc/systemd/system/docker.service

		# Restart daemon and docker service
		echo "Restarting daemons and Docker service..."
		systemctl daemon-reload
		service docker restart

		# Save backup of initial sysctl.conf and load new configs
		echo "Save backups of old configs..."
		if [ ! -e /etc/sysctl.conf.bak ]; then \
			cat /etc/sysctl.conf > /etc/sysctl.conf.bak
		fi

		cat /etc/sysctl.conf.bak > /etc/sysctl.conf
		echo "vm.max_map_count=262144" >> /etc/sysctl.conf
		echo "net.core.somaxconn=65535" >> /etc/sysctl.conf

		# Save backup of initial common-session, common-session-noninteractive and limits.conf. Then load new configs.
		if [ ! -e /etc/pam.d/common-session.bak ]; then \
			cat /etc/pam.d/common-session > /etc/pam.d/common-session.bak
		fi

		if [ ! -e /etc/pam.d/common-session-noninteractive.bak ]; then \
			cat /etc/pam.d/common-session-noninteractive > /etc/pam.d/common-session-noninteractive.bak
		fi

		if [ ! -e /etc/security/limits.conf.bak ]; then \
			cat /etc/security/limits.conf > /etc/security/limits.conf.bak
		fi

		cat /etc/pam.d/common-session.bak > /etc/pam.d/common-session
		cat /etc/pam.d/common-session-noninteractive.bak > /etc/pam.d/common-session-noninteractive
		cat /etc/security/limits.conf.bak > /etc/security/limits.conf

		echo "session required pam_limits.so" >> /etc/pam.d/common-session
		echo "session required pam_limits.so" >> /etc/pam.d/common-session-noninteractive
		echo "* soft nofile 200000" >> /etc/security/limits.conf
		echo "* hard nofile 200000" >> /etc/security/limits.conf

		# Restart the machine
		echo "Restarting the machine..."
		reboot
	fi

.PHONY: robodock-destroy
robodock-destroy:
	sudo rm -r robodock

.PHONY: stop
stop:
	sudo docker stop $(c)

.PHONY: rm
rm:
	sudo docker rm $(c)

.PHONY: restart
restart:
	sudo docker restart $(c)

.PHONY: log
log:
	sudo docker logs $(c)

.PHONY: up-all
up-all:
	sudo docker-compose -f dc_node_$(node).yml up -d

.PHONY: format
format:
	./robodock-constructor/RobodockConstructor.py $(file)

.PHONY: stop-all
stop-all:
	sudo docker-compose -f dc_node_$(node).yml stop

.PHONY: rm-all
rm-all:
	sudo docker-compose -f dc_node_$(node).yml rm --force

.PHONY: restart-all
restart-all:
	sudo docker-compose -f dc_node_$(node).yml restart

.PHONY: exec
exec:
	sudo docker exec -it $(c) "$(cmd)"

.PHONY: ps
ps:
	sudo docker-compose -f dc_node_$(node).yml ps

.PHONY: network-info
network-info:
	sudo docker network inspect $(ROBODOCK_NET)

.PHONY: streamer-run
streamer-run:
	sudo docker exec -d data_streamer$(index) /bin/bash -c "cd /streamers/$(streamer); npm install; node $(file)"

.PHONY: kafka-topic-list
kafka-topic-list:
	sudo docker exec -it kafka$(index) /bin/bash -c "kafka-topics.sh --zookeeper \$$KAFKA_ZOOKEEPER_CONNECT --list"

.PHONY: kafka-topic-delete
kafka-topic-delete:
	sudo docker exec -it kafka$(index) /bin/bash -c "kafka-topics.sh --zookeeper \$$KAFKA_ZOOKEEPER_CONNECT --topic $(topic) --delete"

.PHONY: kafka-topic-consume
kafka-topic-consume:
	sudo docker exec -it kafka$(index) /bin/bash -c "kafka-console-consumer.sh --zookeeper \$$KAFKA_ZOOKEEPER_CONNECT --topic $(topic) --from-beginning"

.PHONY: health-check
health-check:
	sudo docker exec -it healthchecker$(index) python RobodockHealthChecker.py /hc-conf/config.yml
