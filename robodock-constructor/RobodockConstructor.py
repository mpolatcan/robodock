#!/usr/bin/python

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

# TODO Add new services to Robodock

import os
import sys
import json
from Config import Config
from Constants import *


class RobodockConstructor:
    def __init__(self, config_filename):
        self.config = Config(config_filename=config_filename)
        self.server_node_num = self.config.get(attr_name=ROBODOCK_SERVERS_HOSTS).__len__()
        self.zk_node_num = self.config.count(attr_name=SERVICE_ZOOKEEPER)
        self.kafka_node_num = self.config.count(attr_name=SERVICE_KAFKA)
        self.storm_nimbus_node_num = self.config.count(attr_name=SERVICE_STORM_NIMBUS)
        self.storm_ui_node_num = self.config.count(attr_name=SERVICE_STORM_UI)
        self.storm_worker_node_num = self.config.count(attr_name=SERVICE_STORM_WORKER)
        self.kibana_node_num = self.config.count(attr_name=SERVICE_KIBANA)
        self.elasticsearch_node_num = self.config.count(attr_name=SERVICE_ELASTICSEARCH)
        self.redis_node_num = self.config.count(attr_name=SERVICE_REDIS)
        self.cassandra_node_num = self.config.count(attr_name=SERVICE_CASSANDRA)
        self.postgres_node_num = self.config.count(attr_name=SERVICE_POSTGRES)
        self.pgadmin_node_num = self.config.count(attr_name=SERVICE_PGADMIN)
        self.grafana_node_num = self.config.count(attr_name=SERVICE_GRAFANA)
        self.jenkins_node_num = self.config.count(attr_name=SERVICE_JENKINS)
        self.beakerx_node_num = self.config.count(attr_name=SERVICE_BEAKERX)
        self.prophet_node_num = self.config.count(attr_name=SERVICE_PROPHET)
        self.data_streamer_node_num = self.config.count(attr_name=SERVICE_DATA_STREAMER)
        self.portainer_node_num = self.config.count(attr_name=SERVICE_PORTAINER)
        self.healtchecker_node_num = self.config.count(attr_name=SERVICE_HEALTHCHECKER)
        self.presto_worker_node_num = self.config.count(attr_name=SERVICE_PRESTO_WORKER)
        self.clickhouse_server_node_num = self.config.count(attr_name=SERVICE_CLICKHOUSE_SERVER)
        self.clickhouse_client_node_num = self.config.count(attr_name=SERVICE_CLICKHOUSE_CLIENT)
        self.timescaledb_node_num = self.config.count(attr_name=SERVICE_TIMESCALEDB)
        self.h2o_node_num = self.config.count(attr_name=SERVICE_H2O)

    def construct(self):
        for i in range(1, self.server_node_num + 1):
            self.__exec_makefile_cmd(
                cmd="dc-header", args=self.__args({"file": "dc_node_" + str(i) + ".yml"}))

        # --------------------------------------------- High Available Services ----------------------------------------
        self.create_service(
            service=SERVICE_ZOOKEEPER,
            extras=self.__args({"total_zk_node": self.zk_node_num, "configs": self.__configs(SERVICE_ZOOKEEPER)}),
            ha=True
        )
        self.create_service(
            service=SERVICE_KAFKA,
            extras=self.__args({"zk_node": self.zk_node_num, "configs": self.__configs(SERVICE_KAFKA)}),
            ha=True
        )
        self.create_service(
            service=SERVICE_STORM_NIMBUS,
            extras=self.__args(
                {
                    "zk_node": self.zk_node_num,
                    "nimbus_node": self.storm_nimbus_node_num,
                    "configs": self.__configs(SERVICE_STORM_NIMBUS)}
            ),
            ha=True
        )
        self.create_service(
            service=SERVICE_STORM_UI,
            extras=self.__args(
                {
                    "zk_node": self.zk_node_num,
                    "nimbus_node": self.storm_nimbus_node_num,
                    "configs": self.__configs(SERVICE_STORM_UI)
                }
            ),
            ha=True
        )
        self.create_service(
            service=SERVICE_STORM_WORKER,
            extras=self.__args(
                {
                    "zk_node": self.zk_node_num,
                    "nimbus_node": self.storm_nimbus_node_num,
                    "configs": self.__configs(SERVICE_STORM_WORKER)
                }
            ),
            ha=True
        )
        self.create_service(
            service=SERVICE_CASSANDRA,
            extras=self.__args({"configs": self.__configs(SERVICE_CASSANDRA)}),
            ha=True
        )
        self.create_service(
            service=SERVICE_ELASTICSEARCH,
            extras=self.__args({"configs": self.__configs(SERVICE_ELASTICSEARCH)}),
            ha=True
        )
        self.create_service(
            service=SERVICE_KIBANA,
            extras=self.__args({"configs": self.__configs(SERVICE_KIBANA)}),
            ha=True
        )
        self.create_service(
            service=SERVICE_REDIS,
            extras=self.__args({"configs": self.__configs(SERVICE_REDIS)}),
            ha=True
        )
        self.create_service(
            service=SERVICE_GRAFANA,
            extras=self.__args({"configs": self.__configs(SERVICE_GRAFANA)}),
            ha=True
        )
        self.create_service(
            service=SERVICE_JENKINS,
            extras=self.__args({"configs": self.__configs(SERVICE_JENKINS)}),
            ha=True
        )
        self.create_service(
            service=SERVICE_BEAKERX,
            extras=self.__args({"configs": self.__configs(SERVICE_BEAKERX)}),
            ha=True
        )
        self.create_service(
            service=SERVICE_DATA_STREAMER,
            extras=self.__args({"configs": self.__configs(SERVICE_DATA_STREAMER)}),
            ha=True
        )
        self.create_service(
            service=SERVICE_POSTGRES,
            extras=self.__args({"configs": self.__configs(SERVICE_POSTGRES)}),
            ha=True
        )
        self.create_service(
            service=SERVICE_PROPHET,
            extras=self.__args({"configs": self.__configs(SERVICE_PROPHET)}),
            ha=True
        )
        self.create_service(
            service=SERVICE_PORTAINER,
            extras=self.__args({"configs": self.__configs(SERVICE_PORTAINER)}),
            ha=True
        )
        self.create_service(
            service=SERVICE_HEALTHCHECKER,
            extras=self.__args({"configs": self.__configs(SERVICE_HEALTHCHECKER)}),
            ha=True
        )
        self.create_service(
            service=SERVICE_VECTOR,
            extras=self.__args({"configs": self.__configs(SERVICE_VECTOR)}),
            ha=True
        )
        self.create_service(
            service=SERVICE_PRESTO_WORKER,
            extras=self.__args({"configs": self.__configs(SERVICE_PRESTO_WORKER)}),
            ha=True
        )
        self.create_service(
            service=SERVICE_CLICKHOUSE_SERVER,
            extras=self.__args({"configs": self.__configs(SERVICE_CLICKHOUSE_SERVER)}),
            ha=True
        )
        self.create_service(
            service=SERVICE_CLICKHOUSE_CLIENT,
            extras=self.__args({"configs": self.__configs(SERVICE_CLICKHOUSE_CLIENT)}),
            ha=True
        )
        self.create_service(
            service=SERVICE_TIMESCALEDB,
            extras=self.__args({"configs": self.__configs(SERVICE_TIMESCALEDB)}),
            ha=True
        )
        self.create_service(
            service=SERVICE_INFLUXDB,
            extras=self.__args({"configs": self.__configs(SERVICE_INFLUXDB)}),
            ha=True
        )
        self.create_service(
            service=SERVICE_TENSORFLOW,
            extras=self.__args({"configs": self.__configs(SERVICE_TENSORFLOW)}),
            ha=True
        )
        self.create_service(
            service=SERVICE_SUPERSET,
            extras=self.__args({"configs": self.__configs(SERVICE_SUPERSET)}),
            ha=True
        )
        self.create_service(
            service=SERVICE_H2O,
            extras=self.__args({"configs": self.__configs(SERVICE_H2O)}),
            ha=True
        )

        # --------------------------------------------- Standalone Services --------------------------------------------
        self.create_service(
            service=SERVICE_KAFKA_REST,
            extras=self.__args(
                {
                    "zk_node": self.zk_node_num,
                    "kafka_node": self.kafka_node_num,
                    "configs": self.__configs(SERVICE_KAFKA_REST)
                }
            )
        )
        self.create_service(
            service=SERVICE_KAFKA_CONNECT,
            extras=self.__args(
                {
                    "zk_node": self.zk_node_num,
                    "kafka_node": self.kafka_node_num,
                    "configs": self.__configs(SERVICE_KAFKA_CONNECT)
                }
            )
        )
        self.create_service(
            service=SERVICE_KAFKA_SCHEMA_REGISTRY,
            extras=self.__args({"zk_node": self.zk_node_num, "configs": self.__configs(SERVICE_KAFKA_SCHEMA_REGISTRY)})
        )
        self.create_service(
            service=SERVICE_KAFKA_TOPIC_UI,
            extras=self.__args({"configs": self.__configs(SERVICE_KAFKA_TOPIC_UI)})
        )
        self.create_service(
            service=SERVICE_KAFKA_CONNECT_UI,
            extras=self.__args({"configs": self.__configs(SERVICE_KAFKA_CONNECT_UI)})
        )
        self.create_service(
            service=SERVICE_KAFKA_SCHEMA_REGISTRY_UI,
            extras=self.__args({"configs": self.__configs(SERVICE_KAFKA_SCHEMA_REGISTRY_UI)})
        )
        self.create_service(
            service=SERVICE_REDIS_CLUSTER,
            extras=self.__args({"redis_node": self.redis_node_num, "configs": self.__configs(SERVICE_REDIS_CLUSTER)})
        )
        self.create_service(
            service=SERVICE_PRESTO_COORDINATOR,
            extras=self.__args({"configs": self.__configs(SERVICE_PRESTO_COORDINATOR)})
        )

        for i in range(1, self.server_node_num + 1):
            self.__exec_makefile_cmd(cmd="dc-network", args=self.__args({"file": "dc_node_" + str(i) + ".yml"}))

        # Initialize robodock
        self.__exec_makefile_cmd(cmd="robodock-init")

        # Generate directories according to config.yml
        self.__exec_makefile_cmd(
            cmd="wipe-data",
            args=self.__args(
                {
                    "zk_node": self.zk_node_num,
                    "es_node": self.elasticsearch_node_num,
                    "cassandra_node": self.cassandra_node_num,
                    "storm_node": self.storm_worker_node_num,
                    "kafka_node": self.kafka_node_num,
                    "redis_node": self.redis_node_num,
                    "pg_node": self.postgres_node_num
                }
            ))

        # Generate endpoints for Robodock Healthchecker, Portainer and H2O
        self.__gen_healthchecker_endpoints()
        self.__gen_portainer_endpoints()
        self.__gen_h2o_endpoints()

        # Generate HAProxy config
        self.__exec_makefile_cmd(
            cmd="haproxy-config",
            args=self.__args(
                {
                    "grafana": self.grafana_node_num,
                    "kibana": self.kibana_node_num,
                    "storm_ui": self.storm_ui_node_num
                }
            ))

    def create_service(self, service, extras=None, ha=False):
        if ha:
            self.__multi_node_service(service=service, extras=extras)
        else:
            self.__single_node_service(service=service, extras=extras)

    def __multi_node_service(self, service, extras):
        self.__gen_multi_node_service_config(
            attr_name=service,
            cmd=lambda node_index, service_index: os.system(self.__gen_service_makefile_cmd(service=service, node_index=node_index, service_index=service_index,extras=extras))
        )

    def __single_node_service(self, service, extras):
        self.__gen_single_node_service_config(
            attr_name=service,
            cmd=lambda node_index: os.system(self.__gen_service_makefile_cmd(service=service, node_index=node_index, extras=extras))
        )

    def __gen_multi_node_service_config(self, attr_name, cmd):
        if self.config.count(attr_name=attr_name) > 0:
            index = 1
            for i in self.config.nodes(attr_name=attr_name):
                if self.__check_node_index(int(i)):
                    cmd(i, index)
                    index += 1
                else:
                    raise Exception("Node index exceeds server number. There is a " + str(self.server_node_num) +
                                    " servers but you are trying up " + attr_name + " container on " + i + "th server :(")

    def __gen_single_node_service_config(self, attr_name, cmd):
        if self.config.count(attr_name=attr_name) == 1 and self.__check_node_index(int(self.config.nodes(attr_name=attr_name)[0])):
            cmd(self.config.nodes(attr_name=attr_name)[0])
        elif self.config.count(attr_name=attr_name) > 1:
            raise Exception(attr_name + " container must be single !")

    def __check_node_index(self, index):
        return True if (0 < index <= self.server_node_num) else False

    def __gen_service_makefile_cmd(self, service, node_index, extras, service_index=None):
        if service_index is not None:
            makefile_cmd_str = self.__gen_makefile_cmd(
                cmd=service,
                args=self.__args(
                    {
                        "file": "dc_node_" + str(node_index) + ".yml",
                        str(service) + "_index": service_index
                    }
                ))
        else:
            makefile_cmd_str = self.__gen_makefile_cmd(
                cmd=service,
                args=self.__args({"file": "dc_node_" + str(node_index) + ".yml"})
            )

        if extras is not None:
            makefile_cmd_str += str(extras)

        return makefile_cmd_str

    def __gen_makefile_cmd(self, cmd, args):
        if args is not None:
            return "make -C ./robodock-constructor " + cmd + " " + args
        else:
            return "make -C ./robodock-constructor " + cmd

    def __exec_makefile_cmd(self, cmd, args=None):
        os.system(self.__gen_makefile_cmd(cmd=cmd, args=args))

    def __args(self, args):
        arg_list_str = ""

        for arg_key, arg_value in args.items():
            arg_list_str += arg_key + "=\"" + str(arg_value) + "\" "

        return arg_list_str

    def __configs(self, service):
        config_list_str = ""

        for config in self.config.configs(attr_name=service):
            config_tokens = config.split('=')
            config_list_str += config_tokens[0] + "=\\\"'" + config_tokens[1] + "'\\\" "

        return config_list_str

    def __gen_portainer_endpoints(self):
        endpoints_file = open("robodock-configs/portainer/endpoints.json", "w+")
        endpoints_data = self.config.get(ROBODOCK_SERVERS_HOSTS)

        for endpoint in endpoints_data:
            endpoint["Name"] = endpoint.pop("name")
            endpoint["URL"] = endpoint.pop("hostname_or_ip")
            endpoint["URL"] = "tcp://" + endpoint["URL"] + ":2375"

        json.dump(endpoints_data, endpoints_file, indent=2, sort_keys=True)
        endpoints_file.close()

    def __gen_h2o_endpoints(self):
        endpoints_file = open("robodock-configs/h2o/flatfile.txt", "w+")

        for i in range(1, self.h2o_node_num + 1):
            endpoints_file.write("h2o" + str(i) + ":54321\n")

        endpoints_file.close()

    def __gen_healthchecker_endpoints(self):
        endpoints_file = open("robodock-configs/healthchecker/config.yml", "w+")
        endpoints_data = self.config.get(ROBODOCK_SERVERS_HOSTS)

        endpoints_file.write("robodock.healthchecker.nodes:\n")

        for endpoint in endpoints_data:
            endpoints_file.write("  - " + endpoint["hostname_or_ip"] + "\n")

        endpoints_file.close()


if __name__ == "__main__":
    RobodockConstructor(config_filename=sys.argv[1]).construct()
