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

# *
# * zookeeper-gen
# *
# * REQUIRED ARGUMENTS
# *  - [zk_index (integer)]
# *  - [total_zk_node (integer)]
# *  - [zk_type (string)]
# *
# TODO Confluent Zookeeper will be fixed (volume dirs, configs etc.)
.PHONY: zookeeper-gen
zookeeper-gen:
	if [[ $(zk_type) == confluent ]]; then \
		$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_ZOOKEEPER)$$zk_index image=$(CONFLUENT_ZOOKEEPER_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_ZOOKEEPER)$$zk_index hostname=$(SERVICE_ZOOKEEPER)$$zk_index restart="always"; \
	else \
		$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_ZOOKEEPER)$$zk_index image=$(ZOOKEEPER_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_ZOOKEEPER)$$zk_index hostname=$(SERVICE_ZOOKEEPER)$$zk_index restart="always"; \
	fi; \

	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_ENVIRONMENT) args="ZOO_AUTOPURGE_PURGE_INTERVAL="$(ZOOKEEPER_AUTOPURGE_PURGE_INTERVAL)" ZOO_AUTOPURGE_SNAP_RETAIN_COUNT="$(ZOOKEEPER_AUTOPURGE_SNAP_RETAIN_COUNT); \
	printf "      - ZOO_MY_ID="$$(expr $(ZOOKEEPER_MY_ID_BEGINNING) + $$zk_index - 1)"\n" >> $(COMPOSE_FILE); \
	printf "      - ZOO_SERVERS=" >> $(COMPOSE_FILE); \
	for j in $(shell seq 1 $(total_zk_node)); do \
		printf "server."$$j"="$(SERVICE_ZOOKEEPER)$$j":2888:3888 " >> $(COMPOSE_FILE); \
	done; \

	if [[ $(zk_type) == confluent ]]; then \
		printf "\n      - ZOOKEEPER_CLIENT_PORT=2181" >> $(COMPOSE_FILE); \
	fi; \
	printf "\n" >> $(COMPOSE_FILE); \

	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$$(expr $(ZOOKEEPER_HOST_PORT_BEGINNING) + $$zk_index - 1)":"$(ZOOKEEPER_CONTAINER_PORT)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_VOLUMES) args=$(ROBODOCK_VOLUME)" "$(ZOOKEEPER_DATA_VOLUME_PREFIX)$$zk_index$(ZOOKEEPER_DATA_VOLUME_POSTFIX)" "$(ZOOKEEPER_DATA_VOLUME_PREFIX)$$zk_index$(ZOOKEEPER_DATALOG_VOLUME_POSTFIX); \
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(ZOOKEEPER_IP_PREFIX) index=$$zk_index
	printf "\n" >> $(COMPOSE_FILE); \

# *
# * zookeeper-gen
# *
# * REQUIRED ARGUMENTS
# *  - [cs_index (integer)]
# *
.PHONY: cassandra-gen
cassandra-gen:
	 $(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_CASSANDRA)$$cs_index image=$(CASSANDRA_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_CASSANDRA)$$cs_index hostname=$(SERVICE_CASSANDRA)$$cs_index restart="always"; \
	 printf "    $(ATTR_COMMAND) " >> $(COMPOSE_FILE); \
	 printf "bash -c 'if [[ -z \"\$$\$$(ls -A /var/lib/cassandra/)\" ]]; then sleep "$$(expr $(CASSANDRA_SLAVE_SLEEP_TIME_BEGINNING) '*' $$cs_index - $(CASSANDRA_SLAVE_SLEEP_TIME_BEGINNING))"; fi && /docker-entrypoint.sh cassandra -f'\n" >> $(COMPOSE_FILE); \
	 $(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_ENVIRONMENT) args="CASSANDRA_CLUSTER_NAME="$(CASSANDRA_CLUSTER_NAME)" CASSANDRA_SEEDS="$(CASSANDRA_SEEDS)" CASSANDRA_START_RPC=\""$(CASSANDRA_START_RPC)"\" CASSANDRA_NUM_TOKENS="$(CASSANDRA_NUM_TOKENS)" CASSANDRA_DC="$(CASSANDRA_DC)" CASSANDRA_RACK="$(CASSANDRA_RACK)" CASSANDRA_ENDPOINT_SNITCH="$(CASSANDRA_ENDPOINT_SNITCH)" MAX_HEAP_SIZE="$(MAX_HEAP_SIZE)" HEAP_NEWSIZE="$(HEAP_NEWSIZE); \
	 $(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$$(expr $(CASSANDRA_HOST_PORT_BEGINNING) + $$cs_index - 1)":"$(CASSANDRA_CONTAINER_PORT) ; \
	 $(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_VOLUMES) args=$(CASSANDRA_HOST_DATA_VOLUME)/$(SERVICE_CASSANDRA)$$cs_index:$(CASSANDRA_CONTAINER_DATA_VOLUME)" "$(CASSANDRA_HOST_LOG_VOLUME)/$(SERVICE_CASSANDRA)$$cs_index":"$(CASSANDRA_CONTAINER_LOG_VOLUME)" "$(LOCALTIME_VOLUME)" "$(TIMEZONE_VOLUME); \
	 $(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(CASSANDRA_IP_PREFIX) index=$$cs_index
	 printf "\n" >> $(COMPOSE_FILE); \

# *
# * redis-gen
# *
# * REQUIRED ARGUMENTS
# * - [redis_index (integer)]
# *
# *
.PHONY: redis-gen
redis-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_REDIS)$$redis_index image=$(REDIS_IMAGE_OR_DOCKERFILE) restart="always" hostname=$(SERVICE_REDIS)$$redis_index container_name=$(SERVICE_REDIS)$$redis_index command=$(REDIS_COMMAND)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_VOLUMES) args=$(REDIS_HOST_DATA_VOLUME)$$redis_index:$(REDIS_CONTAINER_DATA_VOLUME)
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(REDIS_IP_PREFIX) index=$$redis_index
	printf "\n" >> $(COMPOSE_FILE)

# *
# * redis-cluster-gen
# *
# * REQUIRED ARGUMENTS
# * - [redis_node (integer)]
# *
.PHONY: redis-cluster-gen
redis-cluster-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_REDIS_CLUSTER) image=$(REDIS_CLUSTER_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_REDIS_CLUSTER) hostname=$(SERVICE_REDIS_CLUSTER) command=$(REDIS_CLUSTER_COMMAND)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_VOLUMES) args=$(DOCKER_SOCK_VOLUME)" "$(LOCALTIME_VOLUME)" "$(TIMEZONE_VOLUME)
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(REDIS_IP_PREFIX) index=$$(expr $$redis_node + 1)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_ENVIRONMENT) args="REDIS_REPLICAS="$(REDIS_REPLICAS)
	printf "      - REDIS_CONTAINERS=" >> $(COMPOSE_FILE)
	$(MAKE) -f RobodockGenHelpers.mk redis-ip-port-list-gen node=$(redis_node)
	printf "\n" >> $(COMPOSE_FILE)

# * storm-gen
# *
# * REQUIRED ARGUMENTS
# *   - [node (integer)]
# *   - [zk_node (integer)]
.PHONY: storm-gen
storm-gen:
# Nimbus node
	$(MAKE) -f RobodockGen.mk storm-nimbus-gen zk_node=$(zk_node)

# UI node
	$(MAKE) -f RobodockGen.mk storm-ui-gen zk_node=$(zk_node)

# Worker nodes
	$(MAKE) -f RobodockGen.mk storm-worker-gen node=$(node) zk_node=$(zk_node)


# * storm-nimbus-gen
# *
# * REQUIRED ARGUMENTS
# *   - [zk_node (integer)]
# *   - [nimbus_index (integer)]
# *   - [nimbus_node (integer) ]
# *s
.PHONY: storm-nimbus-gen
storm-nimbus-gen: 
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_STORM_NIMBUS)$(nimbus_index) image=$(STORM_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_STORM_NIMBUS)$(nimbus_index) hostname=$(SERVICE_STORM_NIMBUS)$(nimbus_index) restart="always"
	$(MAKE) -f RobodockGenHelpers.mk storm-cmd-gen nimbus_node=$(nimbus_node) node_type="nimbus" data_dir=$(STORM_CONTAINER_LOCAL_DIR) log_dir=$(STORM_CONTAINER_LOG_DIR)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$$(expr $(NIMBUS_HOST_PORT_BEGINNING) + $$nimbus_index - 1)":"$(NIMBUS_CONTAINER_PORT)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_VOLUMES) args=$(ROBODOCK_VOLUME)" "$(ROBODOCK_PROJECTS_VOLUME)" "$(LOCALTIME_VOLUME)" "$(TIMEZONE_VOLUME)
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(STORM_NIMBUS_IP_PREFIX) index=$$(expr $$nimbus_index)
	printf "\n" >> $(COMPOSE_FILE)

# * storm-ui-gen
# *
# * REQUIRED ARGUMENTS
# *   - [zk_node (integer)]
# *   - [storm_ui_index (integer)]
# *   - [nimbus_node (integer) ]
# *
.PHONY: storm-ui-gen 
storm-ui-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_STORM_UI)$(storm_ui_index) image=$(STORM_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_STORM_UI)$(storm_ui_index) hostname=$(SERVICE_STORM_UI)$(storm_ui_index) restart="always"
	$(MAKE) -f RobodockGenHelpers.mk storm-cmd-gen nimbus_node=$(nimbus_node) node_type="ui" data_dir=$(STORM_CONTAINER_LOCAL_DIR) log_dir=$(STORM_CONTAINER_LOG_DIR)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$$(expr $(UI_HOST_PORT_BEGINNING) + $(storm_ui_index) - 1)":"$(UI_CONTAINER_PORT)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_VOLUMES) args=$(ROBODOCK_VOLUME)" "$(LOCALTIME_VOLUME)" "$(TIMEZONE_VOLUME)
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(STORM_UI_IP_PREFIX) index=$$(expr $$storm_ui_index)
	printf "\n" >> $(COMPOSE_FILE)

# * storm-worker-gen
# *
# * REQUIRED ARGUMENTS
# *   - [storm_index (integer)]
# *   - [zk_node (integer)]
# *   - [nimbus_node (integer) ]
# *
.PHONY: storm-worker-gen
storm-worker-gen: 
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_STORM_WORKER)$$storm_index image=$(STORM_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_STORM_WORKER)$$storm_index hostname=$(SERVICE_STORM_WORKER)$$storm_index restart="always"; \
	$(MAKE) -f RobodockGenHelpers.mk storm-cmd-gen nimbus_node=$(nimbus_node) node_type="logviewer" worker_id=$(SERVICE_STORM_WORKER)$$storm_index data_dir=$(STORM_CONTAINER_LOCAL_DIR) log_dir=$(STORM_CONTAINER_LOG_DIR)
	$(MAKE) -f RobodockGenHelpers.mk storm-cmd-gen slot_num=$(STORM_WORKER_SLOTS_NUM) nimbus_node=$(nimbus_node) node_type="supervisor" worker_id=$(SERVICE_STORM_WORKER)$$storm_index data_dir=$(STORM_CONTAINER_LOCAL_DIR) log_dir=$(STORM_CONTAINER_LOG_DIR)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_ENVIRONMENT) args="WORKER_ID="$(SERVICE_STORM_WORKER)$$storm_index; \
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_VOLUMES) args=$(ROBODOCK_PROJECTS_VOLUME)" "$(STORM_WORKER_HOST_DATA_VOLUME)$$storm_index":"$(STORM_WORKER_CONTAINER_DATA_VOLUME)$$storm_index" "$(STORM_WORKER_HOST_LOG_VOLUME)$$storm_index":"$(STORM_WORKER_CONTAINER_LOG_VOLUME)$$storm_index" "$(LOCALTIME_VOLUME)" "$(TIMEZONE_VOLUME); \
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(STORM_WORKER_IP_PREFIX) index=$$storm_index
	printf "\n" >> $(COMPOSE_FILE)

# TODO Confluent Kafka will be fixed (volume dirs etc.)
# * kafka-gen
# *
# * REQUIRED ARGUMENTS
# *   - [kafka_index (integer)]
# *   - [zk_node (integer)]
# *   - [kafka_type (string)]
# *
.PHONY: kafka-gen
kafka-gen:
	if [[ $(kafka_type) == confluent ]]; then \
		$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_KAFKA)$$kafka_index image=$(CONFLUENT_KAFKA_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_KAFKA)$$kafka_index hostname=$(SERVICE_KAFKA)$$kafka_index restart="always"; \
	else \
		$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_KAFKA)$$kafka_index image=$(KAFKA_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_KAFKA)$$kafka_index hostname=$(SERVICE_KAFKA)$$kafka_index restart="always"; \
	fi; \

	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$$(expr $(KAFKA_HOST_PORT_BEGINNING) + $$kafka_index - 1)":"$(KAFKA_HOST_PORT_BEGINNING)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_ENVIRONMENT) args="KAFKA_BROKER_ID="$$kafka_index" KAFKA_AUTO_CREATE_TOPICS_ENABLE="$(KAFKA_AUTO_CREATE_TOPICS_ENABLE)" KAFKA_DELETE_TOPIC_ENABLE="$(KAFKA_DELETE_TOPIC_ENABLE)

	if [[ $(kafka_type) == confluent ]]; then \
		$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen args="KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://"$(SERVICE_KAFKA)$$kafka_index":"$(KAFKA_HOST_PORT_BEGINNING)" KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR="$(KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR); \
	else \
		$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen args="KAFKA_ADVERTISED_HOST_NAME="$(SERVICE_KAFKA)$$kafka_index" KAFKA_ADVERTISED_PORT="$(KAFKA_ADVERTISED_PORT)" MIN_INSYNC_REPLICASE="$(MIN_INSYNC_REPLICASE)" DEFAULT_REPLICATION_FACTOR="$(DEFAULT_REPLICATION_FACTOR); \
	fi; \

	printf "      - KAFKA_HEAP_OPTS="$(KAFKA_HEAP_OPTS)"\n" >> $(COMPOSE_FILE)
	printf "      - KAFKA_ZOOKEEPER_CONNECT=" >> $(COMPOSE_FILE)
	$(MAKE) -f RobodockGenHelpers.mk service-port-list-gen node=$(zk_node) service=$(SERVICE_ZOOKEEPER) port=2181
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(KAFKA_IP_PREFIX) index=$$kafka_index
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_VOLUMES) args=$(KAFKA_HOST_DATA_VOLUME)/kafka$$kafka_index":"$(KAFKA_CONTAINER_DATA_VOLUME)" "$(KAFKA_HOST_LOG_VOLUME)/kafka$$kafka_index":"$(KAFKA_CONTAINER_LOG_VOLUME)
	printf "\n" >> $(COMPOSE_FILE)

# * elasticsearch-gen
# *
# * REQUIRED ARGUMENTS
# *  - [es_index (integer)]
# *  - [node (integer)]
# *
.PHONY: elasticsearch-gen
elasticsearch-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_ELASTICSEARCH)$$es_index image=$(ELASTICSEARCH_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_ELASTICSEARCH)$$es_index hostname=$(SERVICE_ELASTICSEARCH)$$es_index restart="always"; \

	if [[ $(es_index) == 1 ]]; then \
		$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_ENVIRONMENT) args="cluster.name=$(ELASTICSEARCH_CLUSTER_NAME) boostrap_memory_lock=\'$(ELASTICSEARCH_BOOTSTRAP_MEMORY_LOCK)\' xpack.security.enabled="$(ELASTICSEARCH_XPACK_SECURITY_ENABLED); \
		printf "      - ES_JAVA_OPTS="$(ELASTICSEARCH_JAVA_OPTS)"\n" >> $(COMPOSE_FILE); \
		$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$(ELASTICSEARCH_HOST_PORT)":"$(ELASTICSEARCH_CONTAINER_PORT); \
	else \
		$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_ENVIRONMENT) args="cluster.name=$(ELASTICSEARCH_CLUSTER_NAME) boostrap_memory_lock=\'$(ELASTICSEARCH_BOOTSTRAP_MEMORY_LOCK)\' discovery.zen.ping.unicast.hosts=elasticsearch1 xpack.security.enabled="$(ELASTICSEARCH_XPACK_SECURITY_ENABLED); \
		printf "      - ES_JAVA_OPTS="$(ELASTICSEARCH_JAVA_OPTS)"\n" >> $(COMPOSE_FILE); \
	fi; \

	printf "    $(ATTR_ULIMITS)\n" >> $(COMPOSE_FILE); \
	printf "      $(ATTR_MEMLOCK)\n" >> $(COMPOSE_FILE); \
	printf "        $(ATTR_SOFT) -1\n" >> $(COMPOSE_FILE); \
	printf "        $(ATTR_HARD) -1\n" >> $(COMPOSE_FILE); \

	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_VOLUMES) args=$(ELASTICSEARCH_HOST_DATA_VOLUME)/es$$es_index":"$(ELASTICSEARCH_CONTAINER_DATA_VOLUME)" "$(ELASTICSEARCH_HOST_LOG_VOLUME)/es$$es_index:$(ELASTICSEARCH_CONTAINER_LOG_VOLUME)" "$(LOCALTIME_VOLUME)" "$(TIMEZONE_VOLUME)
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(ELASTICSEARCH_IP_PREFIX) index=$$es_index
	printf "\n" >> $(COMPOSE_FILE)

# *
# * kibana-gen
# *
# * REQUIRED ARGUMENTS
# *  - [kibana_index (integer)]
# *
# *
.PHONY: kibana-gen
kibana-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_KIBANA)$(kibana_index) image=$(KIBANA_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_KIBANA)$(kibana_index) hostname=$(SERVICE_KIBANA)$(kibana_index) restart="always"
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$$(expr $(KIBANA_UI_HOST_PORT_BEGINNING) + $$kibana_index - 1)":"$(KIBANA_UI_CONTAINER_PORT)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_ENVIRONMENT) args="ELASTICSEARCH_URL="$(ELASTICSEARCH_URL)
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(KIBANA_IP_PREFIX) index=$$kibana_index
	printf "\n" >> $(COMPOSE_FILE)

# *
# * grafana-gen
# *
# * REQUIRED ARGUMENTS
# *  - [grafana_index (integer)]
# *
.PHONY: grafana-gen
grafana-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_GRAFANA)$(grafana_index) image=$(GRAFANA_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_GRAFANA)$(grafana_index) hostname=$(SERVICE_GRAFANA)$(grafana_index) restart="always"
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$$(expr $(GRAFANA_UI_HOST_PORT_BEGINNING) + $$grafana_index - 1)":"$(GRAFANA_UI_CONTAINER_PORT)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_VOLUMES) args=$(GRAFANA_HOST_LOG_VOLUME):$(GRAFANA_CONTAINER_LOG_VOLUME)" "$(LOCALTIME_VOLUME)" "$(TIMEZONE_VOLUME)
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(GRAFANA_IP_PREFIX) index=$$grafana_index
	printf "\n" >> $(COMPOSE_FILE)

# *
# * jenkins-gen
# *
# * REQUIRED ARGUMENTS
# *  - [jenkins_index (integer)]
# *
.PHONY: jenkins-gen
jenkins-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_JENKINS)$(jenkins_index) image=$(JENKINS_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_JENKINS)$(jenkins_index) hostname=$(SERVICE_JENKINS)$(jenkins_index) restart="always"
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$(JENKINS_HOST_UI_PORT_BEGINNING)":"$(JENKINS_CONTAINER_UI_PORT)" "$(JENKINS_HOST_JNLP_PORT_BEGINNING)":"$(JENKINS_CONTAINER_JNLP_PORT)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_VOLUMES) args=$(ROBODOCK_CI_VOLUME)" "$(DOCKER_SOCK_VOLUME)" "$(ROBODOCK_PROJECTS_VOLUME)" "$(LOCALTIME_VOLUME)" "$(TIMEZONE_VOLUME)
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(JENKINS_IP_PREFIX) index=$$jenkins_index
	printf "\n" >> $(COMPOSE_FILE)


# *
# * prophet-gen
# *
# * REQUIRED ARGUMENTS
# *  - [prophet_index (integer)]
# *
.PHONY: prophet-gen
prophet-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_PROPHET)$(prophet_index) image=$(PROPHET_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_PROPHET)$(prophet_index) restart="always" hostname=$(SERVICE_PROPHET)$(prophet_index) command="tail -f /dev/null"
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_VOLUMES) args=$(ROBODOCK_MODELS_VOLUME)" "$(ROBODOCK_DATASETS_VOLUME)" "$(LOCALTIME_VOLUME)" "$(TIMEZONE_VOLUME)
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(PROPHET_IP_PREFIX) index=$$prophet_index
	printf "\n" >> $(COMPOSE_FILE)

# *
# * beakerx-gen
# *
# * REQUIRED ARGUMENTS
# *  - [beakerx_index (integer)]
# *
# *
.PHONY: beakerx-gen
beakerx-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_BEAKERX)$(beakerx_index) image=$(BEAKERX_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_BEAKERX)$(beakerx_index) restart="always" hostname=$(SERVICE_BEAKERX)$(beakerx_index)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_VOLUMES) args=$(BEAKERX_NOTEBOOKS_VOLUME)" "$(BEAKERX_DATASETS_VOLUME)" "$(LOCALTIME_VOLUME)" "$(TIMEZONE_VOLUME)
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(BEAKERX_IP_PREFIX) index=$$beakerx_index
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$$(expr $(BEAKERX_HOST_PORT_BEGINNING) + $(beakerx_index) - 1)":"$(BEAKERX_CONTAINER_PORT)
	printf "\n" >> $(COMPOSE_FILE)

# *
# * postgres-gen
# *
# * REQUIRED ARGUMENTS
# *  - [pg_index (integer)]
# *
.PHONY: postgres-gen
postgres-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_POSTGRES)$(pg_index) image=$(POSTGRES_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_POSTGRES)$(pg_index) restart="always" hostname=$(SERVICE_POSTGRES)$(pg_index)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_ENVIRONMENT) args="POSTGRES_PASSWORD="$(POSTGRES_PASSWORD)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_VOLUMES) args=$(POSTGRES_HOST_DATA_VOLUME)/pg$$pg_index":"$(POSTGRES_CONTAINER_DATA_VOLUME)" "$(POSTGRES_HOST_LOG_VOLUME)/pg$$pg_index":"$(POSTGRES_CONTAINER_LOG_VOLUME)" "$(ROBODOCK_DATASETS_VOLUME)" "$(LOCALTIME_VOLUME)" "$(TIMEZONE_VOLUME)
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(POSTGRES_IP_PREFIX) index=$$pg_index
	printf "\n" >> $(COMPOSE_FILE)

# *
# * pgadmin-gen
# *
# * REQUIRED ARGUMENTS
# *  - [pgadmin_index (integer)]
# *
.PHONY: pgadmin-gen
pgadmin-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_PGADMIN)$(pgadmin_index) image=$(PGADMIN_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_PGADMIN)$(pgadmin_index) restart="always" hostname=$(SERVICE_PGADMIN)$(pgadmin_index)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$$(expr $(PGADMIN_HOST_PORT_BEGINNING) + $$pgadmin_index - 1)":"$(PGADMIN_CONTAINER_PORT)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_VOLUMES) args=$(ROBODOCK_DATASETS_VOLUME)" "$(LOCALTIME_VOLUME)" "$(TIMEZONE_VOLUME)
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(PGADMIN_IP_PREFIX) index=$$pgadmin_index
	printf "\n" >> $(COMPOSE_FILE)

# *
# * data-streamer-gen
# *
# * REQUIRED ARGUMENTS
# *  - [ds_index (integer)]
# *
.PHONY: data-streamer-gen
data-streamer-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_DATA_STREAMER)$(ds_index) image=$(DATA_STREAMER_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_DATA_STREAMER)$(ds_index) hostname=$(SERVICE_DATA_STREAMER)$(ds_index) restart="always" command="tail -f /dev/null"
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_VOLUMES) args=$(ROBODOCK_STREAMERS_VOLUME)" "$(ROBODOCK_DATASETS_VOLUME)" "$(LOCALTIME_VOLUME)" "$(TIMEZONE_VOLUME)
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(DATA_STREAMER_IP_PREFIX) index=$$ds_index
	printf "\n" >> $(COMPOSE_FILE); \

# *
# * portainer-gen
# *
# * REQUIRED ARGUMENTS
# *  - [ds_index (integer)]
# *
.PHONY: portainer-gen
portainer-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_PORTAINER)$(portainer_index) image=$(PORTAINER_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_PORTAINER)$(portainer_index) hostname=$(SERVICE_PORTAINER)$(portainer_index) restart="always" command=$(PORTAINER_COMMAND); \
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$$(expr $(PORTAINER_HOST_PORT_BEGINNING) + $$portainer_index - 1)":"$(PORTAINER_CONTAINER_PORT)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_VOLUMES) args=$(PORTAINER_ENDPOINTS_VOLUME)
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(PORTAINER_IP_PREFIX) index=$$portainer_index
	printf "\n" >> $(COMPOSE_FILE);

# *
# * healthchecker-gen
# *
# * REQUIRED ARGUMENTS
# *  - [ds_index (integer)]
# *
.PHONY: healthchecker-gen
healthchecker-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_HEALTHCHECKER)$(healthchecker_index) image=$(HEALTHCHECKER_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_HEALTHCHECKER)$(healthchecker_index) hostname=$(SERVICE_HEALTHCHECKER)$(healthchecker_index) restart="always" command="tail -f /dev/null"; \
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(HEALTHCHECKER_IP_PREFIX) index=$$healthchecker_index
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_VOLUMES) args=$(HEALTHCHECKER_NODES_CONFIG_VOLUME)
	printf "\n" >> $(COMPOSE_FILE)

# *
# * vector-gen
# *
# * REQUIRED ARGUMENTS
# * - [vector_index (integer)]
# *
.PHONY: vector-gen
vector-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_VECTOR)$(vector_index) image=$(VECTOR_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_VECTOR)$(vector_index) hostname=$(SERVICE_VECTOR)$(vector_index) restart="always"; \
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$$(expr $(VECTOR_HOST_PORT_BEGINNING) + $$vector_index - 1)":"$(VECTOR_CONTAINER_PORT)
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(VECTOR_IP_PREFIX) index=$$vector_index
	printf "\n" >> $(COMPOSE_FILE)

.PHONY: presto-coordinator-gen
presto-coordinator-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_PRESTO_COORDINATOR) image=$(PRESTO_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_PRESTO_COORDINATOR) hostname=$(SERVICE_PRESTO_COORDINATOR) restart="always"; \
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_ENVIRONMENT) args="PRESTO_KAFKA_NODES=$(PRESTO_KAFKA_NODES) PRESTO_KAFKA_TABLE_NAMES=$(PRESTO_KAFKA_TABLE_NAMES) PRESTO_KAFKA_HIDE_INTERNAL_COLUMNS=$(PRESTO_KAFKA_HIDE_INTERNAL_COLUMNS) PRESTO_COORDINATOR=$(PRESTO_COORDINATOR) PRESTO_NODE_SCHEDULER_INCLUDE_COORDINATOR=$(PRESTO_NODE_SCHEDULER_INCLUDE_COORDINATOR) PRESTO_QUERY_MAX_MEMORY=$(PRESTO_QUERY_MAX_MEMORY) PRESTO_QUERY_MAX_MEMORY_PER_NODE=$(PRESTO_QUERY_MAX_MEMORY_PER_NODE) PRESTO_DISCOVERY_SERVER_ENABLED=$(PRESTO_DISCOVERY_SERVER_ENABLED) PRESTO_DISCOVERY_URI=$(PRESTO_COORDINATOR_DISCOVERY_URI) PRESTO_HTTP_SERVER_HTTP_PORT=$(PRESTO_HTTP_SERVER_HTTP_CONTAINER_PORT) PRESTO_NODE_ENVIRONMENT=$(PRESTO_NODE_ENVIRONMENT)"
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$(PRESTO_HTTP_SERVER_HTTP_HOST_PORT):$(PRESTO_HTTP_SERVER_HTTP_CONTAINER_PORT)
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(PRESTO_COORDINATOR_IP_PREFIX) index=1
	printf "\n" >> $(COMPOSE_FILE)

# *
# * presto-worker-gen
# *
# * REQUIRED ARGUMENTS
# * - [worker_index (integer)]
.PHONY: presto-worker-gen
presto-worker-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_PRESTO_WORKER)$(worker_index) image=$(PRESTO_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_PRESTO_WORKER)$(worker_index) hostname=$(SERVICE_PRESTO_WORKER)$(worker_index) restart="always"; \
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_ENVIRONMENT) args="PRESTO_KAFKA_NODES=$(PRESTO_KAFKA_NODES) PRESTO_KAFKA_TABLE_NAMES=$(PRESTO_KAFKA_TABLE_NAMES) PRESTO_KAFKA_HIDE_INTERNAL_COLUMNS=$(PRESTO_KAFKA_HIDE_INTERNAL_COLUMNS) PRESTO_QUERY_MAX_MEMORY=$(PRESTO_QUERY_MAX_MEMORY) PRESTO_QUERY_MAX_MEMORY_PER_NODE=$(PRESTO_QUERY_MAX_MEMORY_PER_NODE) PRESTO_DISCOVERY_SERVER_ENABLED=$(PRESTO_DISCOVERY_SERVER_ENABLED) PRESTO_DISCOVERY_URI=$(PRESTO_WORKER_DISCOVERY_URI) PRESTO_HTTP_SERVER_HTTP_PORT=$(PRESTO_HTTP_SERVER_HTTP_CONTAINER_PORT) PRESTO_NODE_ENVIRONMENT=$(PRESTO_NODE_ENVIRONMENT)"
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(PRESTO_WORKER_IP_PREFIX) index=$$worker_index
	printf "\n" >> $(COMPOSE_FILE)

# *
# * clickhouse-server-gen
# *
# * REQUIRED ARGUMENTS
# * - [ch_server_index (integer)]
.PHONY: clickhouse-server-gen
clickhouse-server-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_CLICKHOUSE_SERVER)$(ch_server_index) image=$(CLICKHOUSE_SERVER_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_CLICKHOUSE_SERVER)$(ch_server_index) hostname=$(SERVICE_CLICKHOUSE_SERVER)$(ch_server_index) restart="always"; \
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$$(expr $(CLICKHOUSE_SERVER_HOST_PORT_BEGINNING) + $$ch_server_index - 1)":"$(CLICKHOUSE_SERVER_CONTAINER_PORT)
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(CLICKHOUSE_SERVER_IP_PREFIX) index=$$ch_server_index
	printf "\n" >> $(COMPOSE_FILE)

# *
# * clickhouse-client-gen
# *
# * REQUIRED ARGUMENTS
# * - [ch_client_index (integer)]
.PHONY: clickhouse-client-gen
clickhouse-client-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_CLICKHOUSE_CLIENT)$(ch_client_index) image=$(CLICKHOUSE_CLIENT_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_CLICKHOUSE_CLIENT)$(ch_client_index) hostname=$(SERVICE_CLICKHOUSE_CLIENT)$(ch_client_index) restart="always"; \
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(CLICKHOUSE_CLIENT_IP_PREFIX) index=$$ch_client_index
	printf "\n" >> $(COMPOSE_FILE)

# *
# * timescaledb-gen
# *
# * REQUIRED ARGUMENTS
# * - [tsdb_index (integer)]
.PHONY: timescaledb-gen
timescaledb-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_TIMESCALEDB)$(tsdb_index) image=$(TIMESCALEDB_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_TIMESCALEDB)$(tsdb_index) hostname=$(SERVICE_TIMESCALEDB)$(tsdb_index) restart="always"; \
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(TIMESCALEDB_IP_PREFIX) index=$$tsdb_index
	printf "\n" >> $(COMPOSE_FILE)

# *
# * influxdb-gen
# *
# * REQUIRED ARGUMENTS
# * - [influxdb_index (integer)]
.PHONY: influxdb-gen
influxdb-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_INFLUXDB)$(influxdb_index) image=$(INFLUXDB_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_INFLUXDB)$(influxdb_index) hostname=$(SERVICE_INFLUXDB)$(influxdb_index) restart="always"; \
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_ENVIRONMENT) args="INFLUXDB_DB="$(INFLUXDB_DB)" INFLUXDB_HTTP_AUTH_ENABLED="$(INFLUXDB_HTTP_AUTH_ENABLED)" INFLUXDB_ADMIN_USER="$(INFLUXDB_ADMIN_USER)" INFLUXDB_ADMIN_PASSWORD="$(INFLUXDB_ADMIN_PASSWORD)" INFLUXDB_USER="$(INFLUXDB_USER)" INFLUXDB_USER_PASSWORD="$(INFLUXDB_USER_PASSWORD)" INFLUXDB_READ_USER="$(INFLUXDB_READ_USER)" INFLUXDB_READ_USER_PASSWORD="$(INFLUXDB_READ_USER_PASSWORD)" INFLUXDB_WRITE_USER="$(INFLUXDB_WRITE_USER)" INFLUXDB_WRITE_USER_PASSWORD="$(INFLUXDB_WRITE_USER_PASSWORD)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$$(expr $(INFLUXDB_HTTP_PORT_HOST_BEGINNING) + $$influxdb_index - 1)":"$(INFLUXDB_HTTP_PORT_CONTAINER)
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(INFLUXDB_IP_PREFIX) index=$$influxdb_index
	printf "\n" >> $(COMPOSE_FILE)

# *
# * tensorflow-gen
# *
# * REQUIRED ARGUMENTS
# * - [tf_index (integer)]
.PHONY: tensorflow-gen
tensorflow-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_TENSORFLOW)$(tf_index) image=$(TENSORFLOW_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_TENSORFLOW)$(tf_index) hostname=$(SERVICE_TENSORFLOW)$(tf_index) restart="always"; \
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$$(expr $(TENSORFLOW_HOST_PORT_BEGINNING) + $$tf_index - 1)":"$(TENSORFLOW_CONTAINER_PORT)
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(TENSORFLOW_IP_PREFIX) index=$$tf_index
	printf "\n" >> $(COMPOSE_FILE)

# *
# * superset-gen
# *
# * REQUIRED ARGUMENTS
# * - [ss_index (integer)]
.PHONY: superset-gen
superset-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_SUPERSET)$(ss_index) image=$(SUPERSET_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_SUPERSET)$(ss_index) hostname=$(SERVICE_SUPERSET)$(ss_index) restart="always"; \
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$$(expr $(SUPERSET_HOST_PORT_BEGINNING) + $$ss_index - 1)":"$(SUPERSET_CONTAINER_PORT)
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(SUPERSET_IP_PREFIX) index=$$ss_index
	printf "\n" >> $(COMPOSE_FILE)

# *
# * h2o-gen
# *
# * REQUIRED ARGUMENTS
# * - [h2o_index (integer)]
.PHONY: h2o-gen
h2o-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_H2O)$(h2o_index) image=$(H2O_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_H2O)$(h2o_index) hostname=$(SERVICE_H2O)$(h2o_index) restart="always"; \
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$$(expr $(H2O_HOST_PORT_BEGINNING) + $$h2o_index - 1)":"$(H2O_CONTAINER_PORT)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_ENVIRONMENT) args="NETWORK_SUBNET="$(ROBODOCK_SUBNET)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_VOLUMES) args=$(H2O_NODES_CONFIG_VOLUME)
	$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(H2O_IP_PREFIX) index=$$h2o_index
	printf "\n" >> $(COMPOSE_FILE)

# * kafka-rest-gen
# *
# * REQUIRED ARGUMENTS
# *    - [zk_node (integer)]
# *    - [kafka_node (integer)]
# *
.PHONY: kafka-rest-gen
kafka-rest-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_KAFKA_REST) image=$(KAFKA_REST_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_KAFKA_REST) hostname=$(SERVICE_KAFKA_REST) restart="always"
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_ENVIRONMENT) args="ACCESS_CONTROL_ALLOW_ORIGIN_DEFAULT=\'"$(ACCESS_CONTROL_ALLOW_ORIGIN_DEFAULT)"\' KAFKA_REST_HOST_NAME="$(KAFKA_REST_HOST_NAME)" KAFKA_REST_LISTENERS="$(KAFKA_REST_LISTENERS)" KAFKA_REST_CONSUMER_REQUEST_TIMEOUT_MS="$(KAFKA_REST_CONSUMER_REQUEST_TIMEOUT_MS)
	printf "      - KAFKA_REST_ZOOKEEPER_CONNECT=" >> $(COMPOSE_FILE); \
	$(MAKE) -f RobodockGenHelpers.mk service-port-list-gen node=$(zk_node) service=$(SERVICE_ZOOKEEPER) port=2181; \
	printf "      - KAFKA_REST_BOOTSTRAP_SERVERS=" >> $(COMPOSE_FILE); \
	$(MAKE) -f RobodockGenHelpers.mk service-port-list-gen node=$(kafka_node) service=$(SERVICE_KAFKA) port=9092; \
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_NETWORKS) args=$(ROBODOCK_NET); \
	printf "\n" >> $(COMPOSE_FILE); \

 # *
 # * kafka-connect-gen
 # *
 # * REQUIRED ARGUMENTS
 # *    - [zk_node (integer)]
 # *    - [kafka_node (integer)]
 # *
.PHONY: kafka-connect-gen
kafka-connect-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_KAFKA_CONNECT) image=$(KAFKA_CONNECT_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_KAFKA_CONNECT) hostname=$(SERVICE_KAFKA_CONNECT) restart="always"; \
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$(KAFKA_CONNECT_HOST_PORT)":"$(KAFKA_CONNECT_CONTAINER_PORT)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_ENVIRONMENT) args="CONNECT_GROUP_ID="$(KAFKA_CONNECT_GROUP_ID)" CONNECT_CONFIG_STORAGE_TOPIC="$(KAFKA_CONNECT_CONFIG_STORAGE_TOPIC)" CONNECT_OFFSET_STORAGE_TOPIC="$(KAFKA_CONNECT_OFFSET_STORAGE_TOPIC)" CONNECT_STATUS_STORAGE_TOPIC="$(KAFKA_CONNECT_STATUS_STORAGE_TOPIC)" CONNECT_KEY_CONVERTER="$(KAFKA_CONNECT_KEY_CONVERTER)" CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL="$(KAFKA_CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL)" CONNECT_VALUE_CONVERTER="$(KAFKA_CONNECT_VALUE_CONVERTER)" CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL="$(KAFKA_CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL)" CONNECT_INTERNAL_KEY_CONVERTER="$(KAFKA_CONNECT_INTERNAL_KEY_CONVERTER)" CONNECT_INTERNAL_VALUE_CONVERTER="$(KAFKA_CONNECT_INTERNAL_VALUE_CONVERTER)" CONNECT_REST_ADVERTISED_HOST_NAME="$(KAFKA_CONNECT_REST_ADVERTISED_HOST_NAME)" CONNECT_LOG4J_ROOT_LOGLEVEL="$(KAFKA_CONNECT_LOG4J_ROOT_LOGLEVEL)" CONNECT_LOG4J_LOGGERS="$(KAFKA_CONNECT_LOG4J_LOGGERS)" CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR="$(KAFKA_CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR)" CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR="$(KAFKA_CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR)" CONNECT_STATUS_STORAGE_REPLICATION_FACTOR="$(KAFKA_CONNECT_STATUS_STORAGE_REPLICATION_FACTOR)
	printf "      - CONNECT_BOOTSTRAP_SERVERS=" >> $(COMPOSE_FILE)
	$(MAKE) -f RobodockGenHelpers.mk service-port-list-gen node=$(kafka_node) service=$(SERVICE_KAFKA) port=9092
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_NETWORKS) args=$(ROBODOCK_NET)
	printf "\n" >> $(COMPOSE_FILE); \

# *
# * kafka-schema-registry-gen
# *
# * REQUIRED ARGUMENTS
# *    - [zk_node (integer)]
# *
.PHONY: kafka-schema-registry-gen
kafka-schema-registry-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_KAFKA_SCHEMA_REGISTRY) image=$(KAFKA_SCHEMA_REGISTRY_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_KAFKA_SCHEMA_REGISTRY) hostname=$(SERVICE_KAFKA_SCHEMA_REGISTRY) restart="always"; \
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$(KAFKA_SCHEMA_REGISTRY_HOST_PORT)":"$(KAFKA_SCHEMA_REGISTRY_CONTAINER_PORT); \
	$(MAKE)	-f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_ENVIRONMENT) args="SCHEMA_REGISTRY_HOST_NAME="$(KAFKA_SCHEMA_REGISTRY_HOST_NAME)" KAFKA_SCHEMA_REGISTRY_LISTENERS="$(KAFKA_SCHEMA_REGISTRY_LISTENERS); \
	printf "      - SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL=" >> $(COMPOSE_FILE); \
	$(MAKE) -f RobodockGenHelpers.mk service-port-list-gen node=$(zk_node) service=$(SERVICE_ZOOKEEPER) port=2181; \
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$(KAFKA_SCHEMA_REGISTRY_HOST_PORT)":"$(KAFKA_SCHEMA_REGISTRY_CONTAINER_PORT); \
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_NETWORKS) args=$(ROBODOCK_NET)
	printf "\n" >> $(COMPOSE_FILE); \

.PHONY: kafka-topic-ui-gen
kafka-topic-ui-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_KAFKA_TOPIC_UI) image=$(KAFKA_TOPIC_UI_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_KAFKA_TOPIC_UI) hostname=$(SERVICE_KAFKA_TOPIC_UI) restart="always"; \
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_ENVIRONMENT) args="KAFKA_REST_PROXY_URL="$(KAFKA_REST_PROXY_URL)" PROXY="$(KAFKA_TOPIC_UI_PROXY); \
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$(KAFKA_TOPIC_UI_HOST_PORT)":"$(KAFKA_TOPIC_UI_CONTAINER_PORT); \
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_NETWORKS) args=$(ROBODOCK_NET)
	printf "\n" >> $(COMPOSE_FILE); \

.PHONY: kafka-connect-ui-gen
kafka-connect-ui-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_KAFKA_CONNECT_UI) image=$(KAFKA_CONNECT_UI_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_KAFKA_CONNECT_UI) hostname=$(SERVICE_KAFKA_CONNECT_UI) restart="always"; \
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$(KAFKA_CONNECT_UI_HOST_PORT)":"$(KAFKA_CONNECT_UI_CONTAINER_PORT)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_ENVIRONMENT) args="CONNECT_URL="$(KAFKA_CONNECT_URL)" PROXY="$(KAFKA_CONNECT_UI_PROXY)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_NETWORKS) args=$(ROBODOCK_NET)
	printf "\n" >> $(COMPOSE_FILE); \

.PHONY: kafka-schema-registry-ui-gen
kafka-schema-registry-ui-gen:
	$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_KAFKA_SCHEMA_REGISTRY_UI) image=$(KAFKA_SCHEMA_REGISTRY_UI_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_KAFKA_SCHEMA_REGISTRY_UI) hostname=$(SERVICE_KAFKA_SCHEMA_REGISTRY_UI) restart="always"; \
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$(KAFKA_SCHEMA_REGISTRY_UI_HOST_PORT)":"$(KAFKA_SCHEMA_REGISTRY_UI_CONTAINER_PORT)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_ENVIRONMENT) args="SCHEMAREGISTRY_URL="$(KAFKA_SCHEMA_REGISTRY_URL)" PROXY="$(KAFKA_SCHEMA_REGISTRY_UI_PROXY)" SCHEMA_REGISTRY_HOST_NAME="$(KAFKA_SCHEMA_REGISTRY_HOST_NAME)
	$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_NETWORKS) args=$(ROBODOCK_NET)
	printf "\n" >> $(COMPOSE_FILE);