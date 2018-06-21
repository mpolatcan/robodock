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

include default_vars.env

.ONESHELL:
SHELL := /bin/bash

ifndef VERBOSE
.SILENT:
endif

.PHONY: separator
separator:
	@printf "  ############################################################################################################################\n" >> $(COMPOSE_FILE)
	@printf "  #                                    		    $(service)                                                                 \n" >> $(COMPOSE_FILE)
	@printf "  ############################################################################################################################\n" >> $(COMPOSE_FILE)

.PHONY: dc-header-gen
dc-header-gen:
	printf "version: \""$(COMPOSE_FILE_VERSION)"\"\n" > $(COMPOSE_FILE)
	printf "services:\n" >> $(COMPOSE_FILE)

.PHONY: dc-sv-attr-gen
dc-sv-attr-gen:
ifneq ($(service),)
	@printf "  $(service):\n" >> $(COMPOSE_FILE)
endif

ifneq ($(image),)
	@printf "    $(ATTR_IMAGE) $(image)\n" >> $(COMPOSE_FILE)
endif

ifneq ($(build),)
	@printf "    $(ATTR_BUILD) $(build)\n" >> $(COMPOSE_FILE)
endif

ifneq ($(container_name),)
	@printf "    $(ATTR_CONTAINER_NAME) $(container_name)\n" >> $(COMPOSE_FILE)
endif

ifneq ($(restart),)
	@printf "    $(ATTR_RESTART) $(restart)\n" >> $(COMPOSE_FILE)
endif

ifneq ($(hostname),)
	@printf "    $(ATTR_HOSTNAME) $(hostname)\n" >> $(COMPOSE_FILE)
endif

ifneq ($(command),)
	@printf "    $(ATTR_COMMAND) $(command)\n" >> $(COMPOSE_FILE)
endif

ifneq ($(entrypoint),)
	@printf "    $(ATTR_ENTRYPOINT) $(entrypoint)\n" >> $(COMPOSE_FILE)
endif

.PHONY: dc-mv-attr-gen
dc-mv-attr-gen:
ifneq ($(attr_name),)
	printf "    "$(attr_name)"\n" >> $(COMPOSE_FILE)
endif
	for arg in $(args); do \
		printf "      - "$$arg"\n" >> $(COMPOSE_FILE); \
	done

.PHONY: regen-dirs
regen-dirs:
	sudo mkdir robodock/data; \
	sudo mkdir robodock/log; \

	$(MAKE) -C robodock-core -f RobodockGenHelpers.mk dir-gen-helper service=cassandra slave_folder_name=cassandra node=$(cassandra_node)
	$(MAKE) -C robodock-core -f RobodockGenHelpers.mk dir-gen-helper service=storm slave_folder_name=worker node=$(storm_node)
	$(MAKE) -C robodock-core -f RobodockGenHelpers.mk dir-gen-helper service=zookeeper slave_folder_name=zk node=$(zk_node)
	$(MAKE) -C robodock-core -f RobodockGenHelpers.mk dir-gen-helper service=elasticsearch slave_folder_name=es node=$(es_node)
	$(MAKE) -C robodock-core -f RobodockGenHelpers.mk dir-gen-helper service=kafka slave_folder_name=kafka node=$(kafka_node)
	$(MAKE) -C robodock-core -f RobodockGenHelpers.mk dir-gen-helper service=redis slave_folder_name=redis node=$(redis_node)
# *
# * service-port-list-gen
# *
# * REQUIRED ARGUMENTS
# *   - [service (string)]
# *   - [node (integer)]
# *   - [port (integer)]
.PHONY: service-port-list-gen
service-port-list-gen:
	for i in $(shell seq 1 $(node)); do \
		printf "$(service)$$i:$(port)" >> $(COMPOSE_FILE); \
		if [[ $$i != $(node) ]]; then \
			printf "," >> $(COMPOSE_FILE); \
		fi; \
	done; \
	printf "\n" >> $(COMPOSE_FILE)

# *
# * redis-ip-port-list-gen
# *
# * REQUIRED ARGUMENTS
# *   - [ node (integer) ]
.PHONY: redis-ip-port-list-gen
redis-ip-port-list-gen:
	for i in $(shell seq 1 $(node)); do \
		printf "$(REDIS_IP_PREFIX).$$(expr $$i + 1):6379 " >> $(COMPOSE_FILE)
	done; \
	printf "\n" >> $(COMPOSE_FILE)

# *
# * service-list-gen
# *
# * REQUIRED ARGUMENTS
# *   - [service (string)]
# *   - [node (integer)]
# *
.PHONY: zookeeper-servers-helper
service-list-gen:
	for i in $(shell seq 1 $(node)); do \
		printf "\""$(service)$$i"\"" >> $(COMPOSE_FILE); \
		if [[ $$i != $(node) ]]; then \
			printf "," >> $(COMPOSE_FILE); \
		fi; \
	done


# *
# * storm-cmd-gen
# *
# * REQUIRED PARAMETERS
# *   - [node_type (string)]
# *   - [zk_node (integer)]
# *   - [nimbus_node (integer)]
# *   - [data_dir (string)]
# *   - [log_dir  (string)]
# *   - [slot_num (integer)]
# * OPTIONAL PARAMETERS (For supervisor nodes)
# *   - [worker_id (string)]
# *
.PHONY: storm-cmd-gen
storm-cmd-gen:
ifneq ($(node_type),supervisor)
	printf "    $(ATTR_COMMAND) \n" >> $(COMPOSE_FILE)
	printf "      - /bin/bash\n      - -c \n" >> $(COMPOSE_FILE)
	printf "      - |\n" >> $(COMPOSE_FILE)
endif

	printf "          storm $(node_type) -c storm.zookeeper.servers=\'[" >> $(COMPOSE_FILE)
	$(MAKE) -f RobodockGenHelpers.mk service-list-gen service=$(SERVICE_ZOOKEEPER) node=$(zk_node)

ifneq ($(node_type),nimbus)
ifneq ($(node_type),ui)
	printf "]' -c nimbus.seeds='[" >> $(COMPOSE_FILE)
else
	printf "]' -c ui.childopts='"$(UI_CHILDOPTS)"' -c nimbus.seeds='[" >> $(COMPOSE_FILE)
endif
else
	printf "]' -c nimbus.childopts='"$(NIMBUS_CHILDOPTS)"' -c nimbus.thrift.max_buffer_size=104857600 -c nimbus.seeds='[" >> $(COMPOSE_FILE)
endif

	$(MAKE) -f RobodockGenHelpers.mk service-list-gen service=$(SERVICE_STORM_NIMBUS) node=$(nimbus_node)

ifeq ($(node_type),logviewer)
	printf "]' -c storm.local.dir='$(data_dir)' -c storm.log.dir='$(log_dir)' -c storm.local.hostname='$(worker_id)' &\n" >> $(COMPOSE_FILE)
else ifeq ($(node_type),supervisor)
	printf "]' -c storm.local.dir='$(data_dir)/$(worker_id)' -c storm.log.dir='$(log_dir)/$(worker_id)' -c topology.message.timeout.secs='300' -c storm.local.hostname='$(worker_id)'" >> $(COMPOSE_FILE)
	printf " -c supervisor.slots.ports='[" >> $(COMPOSE_FILE)
	for i in $(shell seq 6700 $$(expr 6700 + $(slot_num) - 1)); do \
		printf "$$i" >> $(COMPOSE_FILE); \
		if [[ $$i != $$(expr 6700 + $(slot_num) - 1) ]]; then \
			printf "," >> $(COMPOSE_FILE); \
		fi; \
	done

	printf "]' -c supervisor.childopts='"$(STORM_SUPERVISOR_CHILDOPTS)"' -c worker.childopts='"$(STORM_WORKER_CHILDOPTS)"'\n" >> $(COMPOSE_FILE)
else
	printf "]' -c storm.local.dir='$(data_dir)' -c storm.log.dir='$(log_dir)'\n" >> $(COMPOSE_FILE)
endif

.PHONY: dir-gen-helper
dir-gen-helper:
ifneq ($(node),)
	if [ $(node) -gt 0 ]; then \
		sudo mkdir -p ../robodock/data/$(service)
		sudo mkdir -p ../robodock/log/$(service)

		for i in $(shell seq 1 $(node)); do \
			sudo mkdir -p ../robodock/data/$(service)/$(slave_folder_name)$$i; sudo mkdir -p ../robodock/log/$(service)/$(slave_folder_name)$$i; \
		done
	fi
endif

# *
# * dc-service-network-helper
# *
# * [ip_prefix (string) ]
# * [index (integer) ]
# *
.PHONY: dc-service-network-helper
dc-service-network-helper:
	printf "    $(ATTR_NETWORKS)\n" >> $(COMPOSE_FILE)
	printf "      $(ROBODOCK_NET):\n" >> $(COMPOSE_FILE)
	printf "        $(ATTR_IPV4_ADDRESS) $(ip_prefix).$$(expr $$index + 1)\n" >> $(COMPOSE_FILE)

.PHONY: dc-network-helper
dc-network-helper:
	printf "$(ATTR_NETWORKS)\n" >> $(COMPOSE_FILE)
	printf "  $(ROBODOCK_NET):\n">> $(COMPOSE_FILE)
	printf "    $(ATTR_NAME) $(ROBODOCK_NET)\n" >> $(COMPOSE_FILE)
	printf "    $(ATTR_DRIVER) $(ATTR_NET_DRIVER_OVERLAY)\n" >> $(COMPOSE_FILE)
	printf "    $(ATTR_ATTACHABLE) true\n" >> $(COMPOSE_FILE)
	printf "    $(ATTR_IPAM)\n" >> $(COMPOSE_FILE)
	printf "      $(ATTR_DRIVER) default\n" >> $(COMPOSE_FILE)
	printf "      $(ATTR_CONFIG)\n" >> $(COMPOSE_FILE)
	printf "        -\n" >> $(COMPOSE_FILE)
	printf "          $(ATTR_SUBNET) $(ROBODOCK_SUBNET)" >> $(COMPOSE_FILE)

# *
# *
# * haproxy-config-gen-helper
# * [node_num (integer)]
# * [service (integer)]
# * [port (integer)]
# *
.PHONY: haproxy-config-gen-helper
haproxy-config-gen-helper:
ifneq ($(node),)
	printf "frontend $(service)\n" >> $(HAPROXY_CONFIG_PATH)
	printf "    bind    *:$(port)\n" >> $(HAPROXY_CONFIG_PATH)
	printf "    default_backend    $(service)_nodes\n\n" >> $(HAPROXY_CONFIG_PATH)

	printf "backend $(service)_nodes\n" >> $(HAPROXY_CONFIG_PATH)
	printf "    cookie SERVERID insert\n" >> $(HAPROXY_CONFIG_PATH)
	for i in $(shell seq 1 $(node)); do \
		printf "    server $(service)$$i $(service)$$i:$(port) cookie $(service)$$i check\n" >> $(HAPROXY_CONFIG_PATH)
	done; \
	printf "\n" >> $(HAPROXY_CONFIG_PATH)
endif

# *
# * haproxy-config-gen
# *
# * [grafana (integer)]
# * [kibana (integer)]
# * [storm_ui (integer)]
# *
.PHONY: haproxy-config-gen
haproxy-config-gen:
	cat ../robodock-configs/haproxy_base.cfg > $(HAPROXY_CONFIG_PATH)
	printf "\n\n" >> $(HAPROXY_CONFIG_PATH)

	$(MAKE) -f RobodockGenHelpers.mk haproxy-config-gen-helper node=$(grafana) service=$(SERVICE_GRAFANA) port=$(GRAFANA_UI_CONTAINER_PORT)
	$(MAKE) -f RobodockGenHelpers.mk haproxy-config-gen-helper node=$(kibana) service=$(SERVICE_KIBANA) port=$(KIBANA_UI_CONTAINER_PORT)
	$(MAKE) -f RobodockGenHelpers.mk haproxy-config-gen-helper node=$(storm_ui) service=$(SERVICE_STORM_UI) port=$(UI_CONTAINER_PORT)
