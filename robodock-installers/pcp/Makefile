.ONESHELL:
SHELL := /bin/bash

ifndef VERBOSE
.SILENT:
endif

all:
	# If user is not root, get root permissions
	if [[ $$(whoami) != "root" ]]; then \
		echo "ERROR ! Please run \"sudo make\" to get root permissions"
	else
		if [ ! -e /etc/apt/sources.list.bak ]; then \
			cat /etc/apt/sources.list > /etc/apt/sources.list.bak
		fi

		curl 'https://bintray.com/user/downloadSubjectPublicKey?username=pcp' | sudo apt-key add -
		cat /etc/apt/sources.list.bak > /etc/apt/sources.list
		echo "deb https://dl.bintray.com/pcp/"$(shell lsb_release -cs)" "$(shell lsb_release -cs)" main" >> /etc/apt/sources.list
		apt-get update
		# Install Performance Co-Pilot
		apt-get install -y pcp pcp-webapi
		# Enable Performance Co-Pilot services
		systemctl enable pmcd.service && sudo systemctl start pmcd.service
		systemctl enable pmlogger.service && sudo systemctl start pmlogger.service
		systemctl enable pmwebd.service && sudo systemctl start pmwebd.service
	fi