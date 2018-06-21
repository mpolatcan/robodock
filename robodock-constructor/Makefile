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

include ../robodock-core/default_vars.env

.ONESHELL:
SHELL := /bin/bash

ifndef VERBOSE
.SILENT:
endif

.PHONY: dc-header
dc-header:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGenHelpers.mk dc-header-gen COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGenHelpers.mk dc-header-gen
endif

.PHONY: dc-network
dc-network:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGenHelpers.mk dc-network-helper COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGenHelpers.mk dc-network-helper
endif

.PHONY: zookeeper
zookeeper:
ifneq ($(file),)
ifneq ($(zk_type),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk zookeeper-gen zk_type=$(zk_type) node=$(zk_node) total_zk_node=$(total_zk_node) zk_index=$(zookeeper_index) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk zookeeper-gen zk_type=apache node=$(zk_node) total_zk_node=$(total_zk_node) zk_index=$(zookeeper_index) $(configs) COMPOSE_FILE=../$(file)
endif
else
ifneq ($(zk_type),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk zookeeper-gen zk_type=$(zk_type) node=$(zk_node) total_zk_node=$(total_zk_node) zk_index=$(zookeeper_index) $(configs)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk zookeeper-gen zk_type=apache node=$(zk_node) total_zk_node=$(total_zk_node) zk_index=$(zookeeper_index) $(configs)
endif
endif

.PHONY: redis
redis:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk redis-gen node=$(redis_node) redis_index=$(redis_index) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk redis-gen node=$(redis_node) redis_index=$(redis_index) $(configs)
endif

.PHONY: redis_cluster
redis_cluster:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk redis-cluster-gen redis_node=$(redis_node) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk redis-cluster-gen redis_node=$(redis_node) $(configs)
endif

.PHONY: cassandra
cassandra:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk cassandra-gen node=$(cs_node) cs_index=$(cassandra_index) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk cassandra-gen node=$(cs_node) cs_index=$(cassandra_index) $(configs)
endif

.PHONY: storm-ui
storm_ui:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk storm-ui-gen zk_node=$(zk_node) storm_ui_index=$(storm_ui_index) nimbus_node=$(nimbus_node) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk storm-ui-gen zk_node=$(zk_node) storm_ui_index=$(storm_ui_index) nimbus_node=$(nimbus_node) $(configs)
endif

.PHONY: storm_nimbus
storm_nimbus:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk storm-nimbus-gen zk_node=$(zk_node) nimbus_node=$(nimbus_node) nimbus_index=$(storm_nimbus_index) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk storm-nimbus-gen zk_node=$(zk_node) nimbus_node=$(nimbus_node) nimbus_index=$(storm_nimbus_index) $(configs)
endif

.PHONY: storm_worker
storm_worker:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk storm-worker-gen storm_index=$(storm_worker_index) node=$(storm_node) zk_node=$(zk_node) nimbus_node=$(nimbus_node) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk storm-worker-gen storm_index=$(storm_worker_index) node=$(storm_node) zk_node=$(zk_node) nimbus_node=$(nimbus_node) $(configs)
endif

.PHONY: elasticsearch
elasticsearch:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk elasticsearch-gen node=$(es_node) es_index=$(elasticsearch_index) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk elasticsearch-gen node=$(es_node) es_index=$(elasticsearch_index) $(configs)
endif

.PHONY: postgres
postgres:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk postgres-gen pg_index=$(postgres_index) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk postgres-gen pg_index=$(postgres_index) $(configs)
endif

.PHONY: pgadmin
pgadmin:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk pgadmin-gen pgadmin_index=$(pgadmin_index) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk pgadmin-gen pgadmin_index=$(pgadmin_index) $(configs)
endif

.PHONY: beakerx
beakerx:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk beakerx-gen beakerx_index=$(beakerx_index) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk beakerx-gen beakerx_index=$(beakerx_index) $(configs)
endif

.PHONY: kibana
kibana:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk kibana-gen kibana_index=$(kibana_index) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk kibana-gen kibana_index=$(kibana_index) $(configs)
endif

.PHONY: grafana
grafana:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk grafana-gen grafana_index=$(grafana_index) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk grafana-gen grafana_index=$(grafana_index) $(configs)
endif

.PHONY: prophet
prophet:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk prophet-gen prophet_index=$(prophet_index) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk prophet-gen prophet_index=$(prophet_index) $(configs)
endif

.PHONY: jenkins
jenkins:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk jenkins-gen jenkins_index=$(jenkins_index) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk jenkins-gen jenkins_index=$(jenkins_index) $(configs)
endif

.PHONY: kafka
kafka:
ifneq ($(file),)
ifneq ($(kafka_type),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk kafka-gen kafka_type=$(kafka_type) node=$(kafka_node) kafka_index=$(kafka_index) zk_node=$(zk_node) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk kafka-gen kafka_type=apache node=$(kafka_node) kafka_index=$(kafka_index) zk_node=$(zk_node) $(configs) COMPOSE_FILE=../$(file)
endif
else
ifneq ($(kafka_type),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk kafka-gen kafka_type=$(kafka_type) node=$(kafka_node) kafka_index=$(kafka_index) zk_node=$(zk_node) $(configs)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk kafka-gen kafka_type=apache node=$(kafka_node) kafka_index=$(kafka_index) zk_node=$(zk_node) $(configs)
endif
endif

.PHONY: kafka_rest
kafka_rest:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk kafka-rest-gen zk_node=$(zk_node) kafka_node=$(kafka_node) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk kafka-rest-gen zk_node=$(zk_node) kafka_node=$(kafka_node) $(configs)
endif

.PHONY: kafka_connect
kafka_connect:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk kafka-connect-gen zk_node=$(zk_node) kafka_node=$(kafka_node) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk kafka-connect-gen zk_node=$(zk_node) kafka_node=$(kafka_node) $(configs)
endif

.PHONY: kafka_schema_registry
kafka_schema_registry:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk kafka-schema-registry-gen zk_node=$(zk_node) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk kafka-schema-registry-gen zk_node=$(zk_node) $(configs)
endif

.PHONY: kafka_connect_ui
kafka_connect_ui:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk kafka-connect-ui-gen $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk kafka-connect-ui-gen $(configs)
endif

.PHONY: kafka_topic_ui
kafka_topic_ui:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk kafka-topic-ui-gen $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk kafka-topic-ui-gen $(configs)
endif

.PHONY: kafka_schema_registry_ui
kafka_schema_registry_ui:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk kafka-schema-registry-ui-gen $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk kafka-schema-registry-ui-gen $(configs)
endif

.PHONY: data_streamer
data_streamer:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk data-streamer-gen ds_index=$(data_streamer) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk data-streamer-gen ds_index=$(data_streamer) $(configs)
endif

.PHONY: portainer
portainer:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk portainer-gen portainer_index=$(portainer_index) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk portainer-gen portainer_index=$(portainer_index) $(configs)
endif

.PHONY: healthchecker
healthchecker:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk healthchecker-gen healthchecker_index=$(healthchecker_index) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk healthchecker-gen healthchecker_index=$(healthchecker_index) $(configs)
endif


.PHONY: vector
vector:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk vector-gen vector_index=$(vector_index) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk vector-gen vector_index=$(vector_index) $(configs)
endif

.PHONY: presto_coordinator
presto_coordinator:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk presto-coordinator-gen $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk presto-coordinator-gen $(configs)
endif

.PHONY: presto_worker
presto_worker:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk presto-worker-gen worker_index=$(presto_worker_index) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk presto-worker-gen worker_index=$(presto_worker_index) $(configs)
endif

.PHONY: clickhouse_server
clickhouse_server:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk clickhouse-server-gen ch_server_index=$(clickhouse_server_index) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk clickhouse-server-gen ch_server_index=$(clickhouse_server_index) $(configs)
endif

.PHONY: clickhouse_client
clickhouse_client:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk clickhouse-client-gen ch_client_index=$(clickhouse_client_index) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk clickhouse-client-gen ch_client_index=$(clickhouse_client_index) $(configs)
endif

.PHONY: timescaledb
timescaledb:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk timescaledb-gen tsdb_index=$(timescaledb_index) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk timescaledb-gen tsdb_index=$(timescaledb_index) $(configs)
endif

.PHONY: influxdb
influxdb:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk influxdb-gen influxdb_index=$(influxdb_index) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk influxdb-gen influxdb_index=$(influxdb_index) $(configs)
endif

.PHONY: tensorflow
tensorflow:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk tensorflow-gen tf_index=$(tensorflow_index) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk tensorflow-gen tf_index=$(tensorflow_index) $(configs)
endif

.PHONY: superset
superset:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk superset-gen ss_index=$(superset_index) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk superset-gen ss_index=$(superset_index) $(configs)
endif

.PHONY: h2o
h2o:
ifneq ($(file),)
	$(MAKE) -C ../robodock-core -f RobodockGen.mk h2o-gen h2o_index=$(h2o_index) $(configs) COMPOSE_FILE=../$(file)
else
	$(MAKE) -C ../robodock-core -f RobodockGen.mk h2o-gen h2o_index=$(h2o_index) $(configs)
endif

.PHONY: haproxy-config
haproxy-config:
	$(MAKE) -C ../robodock-core -f RobodockGenHelpers.mk haproxy-config-gen grafana=$(grafana) kibana=$(kibana) storm_ui=$(storm_ui)

.PHONY: robodock-init
robodock-init:
	if [ ! -d ../robodock ]; then \
		mkdir ../robodock
		mkdir ../robodock/projects
		mkdir ../robodock/datasets
		mkdir ../robodock/notebooks
		mkdir ../robodock/streamers
		mkdir ../robodock/models
	fi

.PHONY: wipe
wipe-data:
	if [ -d ../robodock/data ]; then \
		sudo rm -r ../robodock/data
	fi

	if [ -d ../robodock/log ]; then \
		sudo rm -r ../robodock/log
	fi

	$(MAKE) regen-dirs zk_node=$(zk_node) es_node=$(es_node) cassandra_node=$(cassandra_node) storm_node=$(storm_node) kafka_node=$(kafka_node) redis_node=$(redis_node) pg_node=$(pg_node)
	sudo chmod 777 -R ../robodock

.PHONY: regen-dirs
regen-dirs:
	mkdir ../robodock/data; \
	mkdir ../robodock/log; \

	$(MAKE) -C ../robodock-core -f RobodockGenHelpers.mk dir-gen-helper service=cassandra slave_folder_name=cassandra node=$(cassandra_node)
	$(MAKE) -C ../robodock-core -f RobodockGenHelpers.mk dir-gen-helper service=storm slave_folder_name=worker node=$(storm_node)
	$(MAKE) -C ../robodock-core -f RobodockGenHelpers.mk dir-gen-helper service=zookeeper slave_folder_name=zk node=$(zk_node)
	$(MAKE) -C ../robodock-core -f RobodockGenHelpers.mk dir-gen-helper service=elasticsearch slave_folder_name=es node=$(es_node)
	$(MAKE) -C ../robodock-core -f RobodockGenHelpers.mk dir-gen-helper service=kafka slave_folder_name=kafka node=$(kafka_node)
	$(MAKE) -C ../robodock-core -f RobodockGenHelpers.mk dir-gen-helper service=redis slave_folder_name=redis node=$(redis_node)
	$(MAKE) -C ../robodock-core -f RobodockGenHelpers.mk dir-gen-helper service=postgres slave_folder_name=pg node=$(pg_node)