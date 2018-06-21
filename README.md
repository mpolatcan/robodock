# Robodock

**Robodock** is a dynamic Docker cluster installer. **Robodock** uses multi-host networking with
Docker Overlay network driver and **Consul** key-value store for service discovery.

## Services
#### High Available Services 
- **Apache ZooKeeper (Apache or Confluent)**
- **Apache Kafka (Apache or Confluent)**
- **Apache Storm (Storm UI with support HAProxy load balancer)**
- **Apache Cassandra**
- **Elasticsearch**
- **Redis**
- **Grafana (with support HAProxy load balancer)**
- **Kibana (with support HAProxy load balancer**
- **NodeJS (used by DataStreamer)**
- **PostgreSQL and PgAdmin4**
- **BeakerX Notebook (with Prophet etc.)**
- **Prophet (Standalone)**
- **Portainer**
- **HealthChecker**
- **Vector**
- **Presto**
- **Clickhouse (Server and Client)**
- **TimescaleDB**
- **InfluxDB**
- **Tensorflow**
- **Superset**
- **H2O**

#### Standalone Services
 - **Kafka REST**
 - **Kafka Connect**
 - **Kafka Schema Registry**
 - **Landoop Kafka Topic UI**
 - **Landoop Kafka Connect UI** 
 - **Landoop Kafka Schema Registry UI**

## Architecture
Robodock uses overlay network with Consul which is a highly available and distributed service discovery and KV store designed 
with support for the modern data center to make distributed systems and configuration easy. Consul is responsible from service discovery,
store network information and sharing network information between nodes.
    
![Robodock Cluster Architecture with Single Node Consul KV Store](https://github.com/mpolatcan/dceu_tutorials/raw/master/images/tut6-step1.png)

## Project Folders and Files

### Folders
- **robodock-configs:** Includes Docker configs for multi host networking in Docker with overlay network. 
- **robodock-installers:** Includes Consul cluster installer, HAProxy installer and Performance Co-Pilot
installer. 
- **robodock-core:** Includes core of Robodock, generator Makefiles and environment variables file default_vars.env.

### Files
- **Makefile:** This Makefile includes basic commands to use Robodock.
- **config.yml:** Configuration file to setting cluster services.
- **GCloudHostSaver.py:** Save IPs of your instances on Google Cloud. This script uses gcloud tool so you need to install
gcloud into your machine.
- **docker-latest.sh:** Installation script of Docker. It will be install latest version of Docker and docker-compose.

## Installation

### VM Servers
In this guide, I have used to **Google Cloud Compute Engine**. Machine properties are at below:

- Consul Cluster:
    * **Machine type**: f1-micro
    * **CPU**: 1 vCPU
    * **RAM**: 1 GB RAM
    * **Size**: 3 Nodes

- Robodock Cluster:
    * **Machine type**: custom
    * **CPU**: 2 vCPU
    * **RAM**: 8 GB RAM
    * **Size**: 3 Nodes

### Consul Cluster Installation
Firstly, you need to prepare **Consul** cluster to run **Robodock** cluster. You need to install **Consul** to each node and run **Consul**
agents on each node. 

- Firstly, send files in **robodock-installers/consul-cluster** directory which is in [**Robodock**](https://bitbucket.org/mpolatcan/robodock)
 repository using *scp* command line tool to **Consul** cluster nodes:

    scp -r robodock-consul-cluster-installer [your-username]@[server-username-or-ip]:[destination-directory]

- After sending file, enter into files' directory and run this command:

        sudo make install 
        
    This command will be download, install **Consul** and load configurations for **Consul** service.
  
- Repeat all steps before you have made it for all servers in your **Consul** cluster.

### Robodock Cluster Installation
After, you have prepared **Consul** cluster, you need to install **Robodock** dependencies and set configurations to all nodes of Robodock
cluster. So that, you need to follow these:
    
- Firstly, clone the [**Robodock**](https://bitbucket.org/mpolatcan/robodock) repository to current node using this command:
        
        git clone https://[your-username]@bitbucket.org/mpolatcan/robodock.git
        
- Enter into **robodock** folder and run this command. This command installs Docker and docker-compose. Also load configurations in corresponding
files. After computer will be restarted to activate new configurations.
        
        cd robodock
        sudo make robodock-install

- After that you need to modify **config.yml** to place services to cluster's nodes according to your preferences. **config.yml** is such like that:

```yaml
servers.hosts:
  -
    name: "hadoop-dist-docker-2"
    hostname_or_ip: hadoop-dist-docker-2
  -
    name: "hadoop-dist-docker-3"
    hostname_or_ip: hadoop-dist-docker-3
  -
    name: "hadoop-dist-docker-4"
    hostname_or_ip: hadoop-dist-docker-4

# -------------- High Available Services --------------
zookeeper:
  nodes: "1,2,3"
  configs:
    - ZOOKEEPER_IMAGE_OR_DOCKERFILE=zookeeper:3.4.12
kafka:
  nodes: "1,2,3"
  configs:
    - KAFKA_HEAP_OPTS=-Xms512m -Xmx512m
storm_worker:
  nodes: "1,2,3"
storm_ui:
  nodes: "2"
storm_nimbus:
  nodes: "1"
redis:
  nodes: "1,2,3,2,3,1"

# --------------- Monitoring Services ------------------
portainer:
  nodes: "1"
healthchecker:
  nodes: "1"

# -------------- Standalone Services --------------
redis_cluster:
  nodes: "1"
```

This configuration file includes two type attributes. These are **servers** and **\[service-name\]** (for example **vector**).

**servers.hosts**: List of your cluster's servers infos. Info includes name and ip or hostname.

**\[service-name\]**: Service attributes . This attributes, takes two inner attributes which they are **nodes**
 and **configs**

**nodes**: This attribute takes node indices of services. For example, if you want to place **Vector**
service into nodes 1,2 and 3, configuration must be like below:

```yaml
vector:
    nodes: "1,2,3"
```

**configs**: This attribute takes service configurations which overrides default configurations. For example, if you
want to change host port beginning of **Vector**, you need to add that config to **configs** attribute of **Vector**
service:

```yaml
vector:
    nodes: "1,2,3"
    configs:
        - VECTOR_HOST_PORT_BEGINNING=5555
```

- After you have modified **config.yml**, you need to run this command:
    
        make format file=config.yml

    This will generates docker-compose files for each nodes according to **config.yml** preferences. This files are named as 
    **dc_node_\[node_index\]**.yml (node_index is a index of machine. For the first machine of your cluster, docker-compose file's name for
    that machine is dc_node_1.yml)

- Then run **make up-all node=\[node_index\]** to run containers for current server. If you are in first server currently, you need to make up command for the first node. This will up all containers for the first node.

        /* For the first server of cluster */
        make up-all node=1

- Repeat all steps before you have made it for all servers in your **Robodock** cluster.

### HAProxy Installation (Load Balancer Support)
After you have installed the Robodock cluster, if you want to add load balancer node, you need to add new node to cluster. To do this
, there will be files under the **robodock-installers/haproxy** directory to install load balancer to this node. You need to send that files
to this node via **scp** cli tool and run this command:

    sudo docker-compose up --build -d

NOTE!! **haproxy.cfg** file generated automatically according to your **config.yml** which have used to install **Robodock**
cluster.

Currently, **Grafana**, **Kibana** and **Storm Ui** services has load balancer support.

### Vector Installation (Node Monitoring)
If you want to monitor your nodes, you can set up **Vector (by Netflix OSS)**. To do this,
there will be files under the **robodock-installers/pcp** directory to install **Performance Co Pilot (PCP)**.
**Vector** depends on **Performance Co-Pilot (PCP)** to collect metrics on each host you plan to monitor.
Send files in **robodock-installers/pcp** to each host which you want to monitor and run this command:

    sudo make

After install pcp on each host, modify your **config.yml** to add **Vector** container to nodes and use
**Vector** UI from *\[**node-ip**\]:7070*.

## Scaling Cluster and Services
 
If you want to increase cluster size or services, you need to reconfigure the system. There is no option dynamically 
scale the system. (like Kubernetes). So that you need to apply again installation steps with different configurations.

NOTE !! When you scale the service, you need to add new machine indexes or you can scale the service on the same machine by add 
same machine index several times such like that:
    
        redis:"1,2,3,2,3,1"
        
  According to this indexes, there is 6 Redis nodes and their distribution such like that:
    
    - 2 Redis nodes on Node 1
    - 2 Redis nodes on Node 2
    - 2 Redis nodes on Node 3
  
  Also, container indices are begins from 1 and distributed sequentially.
  
        redis:                    "1,     2,      3,     2,    3,     1"
                                   |      |       |      |     |      |
                                   |      |       |      |     |      |
                                   v      v       v      v     v      v
        container names       : "redis1,redis2,redis3,redis4,redis5,redis6"

## Monitoring and Health Checks

You can use the **Portainer** service to monitoring your cluster from single point or you can use our health checker.

For use the health checker, run this command:
    
    make health-check index=[node-index]
    
    /* For example, Run health check on node 1 */
    make health-check index=1

## Key Points and Problems
### Kernel Parameters
---
This parameters are required by **Elasticsearch** and **Redis**:

**/etc/sys.conf**:

- *vm.max_map_count=262144*
- *net.core.somaxconn=65535*

### Open File Handle Increase
---

**/etc/pam.d/common-session**:

- *session required pam_limits.so*

**/etc/pam.d/common-session-noninteractive**:

- *session required pam_limits.so*

**/etc/security/limits.conf**:

- *soft nofile 200000*
- *hard nofile 200000*

### Redis
---
 When you place the Redis nodes to clusters, you need to apply this pattern for availability:
     If you have 3 servers and you want to place 6 Redis nodes to servers. But there is a critical problems 
 here. If you hadn't place correct the 6 Redis nodes to 3 servers, Redis master and slave maybe will placed on
 the same server. 
 
 For example, if you have placed Redis node using this configuration below, Redis masters and/or slave will placed on
 the same server:
 
    redis: "1,1,2,2,3,3"
    
First 3 numbers are the server indexes of Redis master nodes. And last 3 numbers are the server indexes of Redis slave nodes.

    redis-trib.rb --create --replicas 1 10.10.5.2:6379 10.10.5.3:6379 10.10.5.4:6379 10.10.5.5:6379 10.10.5.6:6379 10.10.5.7:6379
        
                               Masters                      Slaves
                        ----------------------     -------------------------
                        redis1 IP -> 10.10.5.2      redis4 IP -> 10.10.5.5
                        redis2 IP -> 10.10.5.3      redis5 IP -> 10.10.5.6
                        redis3 IP -> 10.10.5.4      redis5 IP -> 10.10.5.7
   
                   _____________           _____________          _____________
                  |   redis1    |         |   redis3    |        |   redis5    |
                  |_____________|         |_____________|        |_____________|
                  |   redis2    |         |   redis4    |        |   redis6    |
                  |_____________|         |_____________|        |_____________|
                     (Server 1)              (Server 2)             (Server 6)
    
    redis1 and redis2 is master and they are in same node :(  
        
 To prevent this, you need to shuffle last 3 numbers to according to below this rule:
                               
                               |  1,2,3 -> Redis master indexes
        1,2,3,2,3,1 ---------> |  | | |   
                               |  v v v
                                  2 3 1 -> Redis slave indexes
     
     Master and slave indexes must not be matched !!
          
 So when you apply this placement on Robodock clusters, container placement is at below:
    
    redis: "1,2,3,2,3,1"

    redis-trib.rb --create --replicas 1 10.10.5.2:6379 10.10.5.3:6379 10.10.5.4:6379 10.10.5.5:6379 10.10.5.6:6379 10.10.5.7:6379
         
                                Masters                      Slaves
                         ----------------------     -------------------------
                         redis1 IP -> 10.10.5.2      redis4 IP -> 10.10.5.5
                         redis2 IP -> 10.10.5.3      redis5 IP -> 10.10.5.6
                         redis3 IP -> 10.10.5.4      redis6 IP -> 10.10.5.7
 
                  _____________           _____________          _____________
                 |   redis1    |         |   redis2    |        |   redis3    |
                 |_____________|         |_____________|        |_____________|
                 |   redis6    |         |   redis4    |        |   redis5    |
                 |_____________|         |_____________|        |_____________|
                    (Server 1)              (Server 2)             (Server 6)
 
    All masters and slaves are in separate nodes. :)
    
 Replications such like that:
     
     redis1 (master) | redis4 (slave - replica of redis1)
     redis2 (master) | redis5 (slave - replica of redis2)
     redis3 (master) | redis6 (slave - replica of redis3)
     
## Makefile Commands and Usage
In this project, there is an **Makefile** for installation and managing the cluster. Usage of this Makefile like below:
    
    make <command>

### Commands
- **robodock-install**: Install Docker and docker-compose and load configurations on machines.

- **robodock-destroy**: Removes folders required by Robodock.

- **format** *file*=\[**config-file**\]: Generates docker-compose files according to config file (ex. config.yml)
   and recreates all data and logs folders.
- **stop** *c*="\[**container_name1** **container_name2** ...\]": Stops specified Docker containers.
    
        Example:
        make stop c="kafka1 redis1 zookeeper1"
        
- **rm** *c*="\[**container_name1** **container_name2** ...\]": Removes specified Docker containers.

        Example:
        make rm c="kafka1 redis1 zookeeper1"
        
- **restart** *c*="\[**container_name1** **container_name2** ...\]": Restarts specified Docker containers.

        Example:
        make restart c="kafka1 redis1 zookeeper1"
        
- **up-all** *node*=\[**machine_index**\]: Runs all Docker containers which specified by docker-compose file for the
specified node index.
    
        Example:
        /* Run all containers on first machine */
        make up-all node=1
    
- **stop-all** *node*=\[**machine_index**\]: Stops all Docker containers which specified by docker-compose file for the
specified node index.
    
        Example:
        /* Stops all containers on first machine */
        make stop-all node=1
    
- **rm-all** *node*=\[**machine_index**\]: Removes all Docker containers which specified by docker-compose file for the
specified node index.
    
         Example:
         /* Run all containers on first machine */
         make rm-all node=1
        
- **restart-all** *node*=\[**machine_index**\]: Restarts all Docker containers which specified by  docker-compose file for the
specified node index.
    
        Example:
        /* Restarts all containers on first machine */
        make restart-all node=1
    
- **log** *c*=\[**container_name**\]: Shows log of specified Docker container.
        
        Example:
        /* Look logs of zookeeper1 container */
        make log c=zookeeeper1
        
- **exec** *c*=\[**container_name**\] *cmd*="\[**command_string**]: Execute specified command on specified Docker container.
        
        Example:
        /* Execute bash of nimbus1 container */
        make exec c=nimbus1 cmd=bash
        
- **kafka-topic-consume** *index*=\[**kafka_index**\] *topic*=\[**topic-name**\]: *Consumes given Kafka topic (topic-name) from index specified Kafka container*
    
        Example:
        /* Consume topic from kafka1 container */
        make kafka-consume index=1 topic=nyc-taxi-yellow-01
        
- **kafka-topic-list** *index*=\[**kafka_index**\]: *List available topics on Kafka cluster from index specified Kafka container*
        
        Example:
        /* List Kafka topics from kafka1 container */
        make kafka-topic-list index=1

- **kafka-topic-delete** *index*=\[**kafka_index**\] *topic*=\[**topic-name**\]: *Deletes given Kafka topic from index specified Kafka container*

        Example:
        /* Delete topic from kafka1 container */
        make kafka-topic-delete index=1 topic=nyc-taxi-yellow-01
        
- **streamer-run** *index*=\[**streamer_index**\] *path*=\[**path**\] *file*=\[**file-name**\]: *Starts streamer in given path from index specified DataStreamer*

        Example:
        /* Run streamer from data_streamer1 container */
        make streamer-run index=1 path=streamers/nyctaxi-streamer file=nyctaxi-streamer.js
        
- **health-check** *index*=\[**hc_index**\]: *Runs health check for monitoring cluster status on index specified HealthChecker container.*
        
        Example:
        /*  Run health-check from healthchecker1 */
        make health-check node=1
        
- **network-info**: *Get network info of Robodock cluster*.

## Service Integration to Robodock

For adding new services, you need to modify these files:
    
- Environment variables of Robodock -> **robodock-core/default_vars.env**
- Generator Makefile for generating your service's configs -> **robodock-core/RobodockGen.mk**
- Constructor Makefile which is used by RobodockConstructor -> **robodock-constructor/Makefile**
- Some constants for reading yaml attributes -> **robodock-constructor/Constants.py**
- Generates compose files according to config.yml -> **robodock-constructor/RobodockConstructor.py**

### Environment Variables File (robodock-core/default_vars.env)

This file includes all environment variables and configurations for specified services. You can add your service's
configs to here and you can use in generator Makefile (robodock-core/RobodockGen.mk) to generate service with that
configs. 

Example for Vector service: 

```dotenv
VECTOR_HOST_PORT=7070
VECTOR_CONTAINER_PORT=80
```
    
### Generator Makefile (robodock-core/RobodockGen.mk)

This Makefile generates all specified services' configs. For example Vector service's generator
something like this:
  
```makefile
.PHONY: vector-gen
vector-gen:
    $(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_VECTOR)$(vector_index) image=$(VECTOR_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_VECTOR)$(vector_index) hostname=$(SERVICE_VECTOR)$(vector_index) restart="always"; \
    $(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$(VECTOR_HOST_PORT):$(VECTOR_CONTAINER_PORT)
    $(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(VECTOR_IP_PREFIX) index=$$vector_index
    printf "\n" >> $(COMPOSE_FILE)
```  
    

According to your choices, your service can write high available or standalone service. Vector service
is high available so you need to take index parameter. 

Some utility methods are used here. These are **dc-sv-attr-gen**, **dc-mv-attr-gen**, **dc-service-network-helper**.
    
**dc-sv-attr-gen**: This method takes parameters for generating single value attributes of containers. These attributes are 
**service**, **container_name**, **build**, **image**, **hostname**, **restart**, **command** and **entrypoint**.

Example for Vector service:

```makefile
$(MAKE) -f RobodockGenHelpers.mk dc-sv-attr-gen service=$(SERVICE_VECTOR)$(vector_index) image=$(VECTOR_IMAGE_OR_DOCKERFILE) container_name=$(SERVICE_VECTOR)$(vector_index) hostname=$(SERVICE_VECTOR)$(vector_index) restart="always"; \
```
    
This command generates this: 
    
```yaml
vector1:
    image: netflixoss/vector
    container_name: vector1
    restart: always
    hostname: vector1
```
  
**dc-mv-attr-gen**: This method takes parameters for generating multi value attributes of containers. These are **attr_name** and
**args**. These multi value attributes are **ports**, **environment** and **volumes**

Example for Vector service:
 
```makefile   
$(MAKE) -f RobodockGenHelpers.mk dc-mv-attr-gen attr_name=$(ATTR_PORTS) args=$(VECTOR_HOST_PORT):$(VECTOR_CONTAINER_PORT)
```

This command generates this:
    
```yaml
ports:
  - 7070:80 
```
    
**dc-service-network-helper**: Generates network configs for specified container.

Example for Vector service:
    
```makefile
$(MAKE) -f RobodockGenHelpers.mk dc-service-network-helper ip_prefix=$(VECTOR_IP_PREFIX) index=$$vector_index
```

This command generates this:
    
```yaml
networks:
  robodock-net:
    ipv4_address: 10.10.20.2
```
 
Final result of Vector service's config:

```yaml
vector1:
    image: netflixoss/vector
    container_name: vector1
    restart: always
    hostname: vector1
    ports:
      - 7070:80
    networks:
      robodock-net:
        ipv4_address: 10.10.20.2
```

### Constructor Makefile (robodock-constructor/Makefile)

This Makefile includes all functionality which is used by RobodockConstructor. So, after writing the generator
of your service, you need to add as function to Makefile.

Example for Vector service:

```makefile
.PHONY: vector
vector:
ifneq ($(file),)
    $(MAKE) -C robodock-core -f RobodockGen.mk vector-gen vector_index=$(vector_index) $(configs) COMPOSE_FILE=../$(file)
else
    $(MAKE) -C robodock-core -f RobodockGen.mk vector-gen vector_index=$(vector_index) $(configs)
endif
```
    
In there, you need to take index parameter to make your service high available, so that generator can generate vector1,vector2,.. and 
so on.

### Robodock Constants (robodock-constructor/Constants.py)

This file includes config.yml attribute names for each services. So, if you are adding new service, you need to add
attribute name to this file.

Example for attribute names:
    
```dotenv
SERVICE_PROPHET = "prophet"
SERVICE_PORTAINER = "portainer"
SERVICE_HEALTHCHECKER = "healthchecker"
SERVICE_SYNCSINK = "syncsink"
SERVICE_HTTPSINK = "httpsink"
SERVICE_VECTOR = "vector"
```
   
### Robodock Constructor (robodock-constructor/RobodockConstructor.py)

Last step is add this service to RobodockConstructor to automate generation of this service. To generate config of
specified service you need to add some method calls to this file:

Example for Vector service:

```python
self.create_service(
    service=SERVICE_ZOOKEEPER,
    extras=self.__args({"total_zk_node": self.zk_node_num, "configs": self.__configs(SERVICE_ZOOKEEPER)}),
    ha=True
)
```

This is for high available services. Also this method can be used to create standalone services:

```python
self.create_service(
    service=SERVICE_PRESTO_COORDINATOR,
    extras=self.__args({"configs": self.__configs(SERVICE_PRESTO_COORDINATOR)})
)
```

**create_service** method takes **service**, **extras** and **ha** (default **False**) parameters.

**service**: Name of the service.

**extras**: If your service needs extra arguments, you can give it by that parameter.

**ha**: If your service is high available, you need to change that parameter to **True**

## Shutdown Robodock
Before shutdown machines, run this command:
    
    /* Example for first server */
    make stop-all node=1

## Service Ports

### High Available Services
- **Storm UI** -> 8080 (for n nodes, 8080,8081,... and so on)
- **Jenkins** -> 4040 (for n nodes 4040,4041,... and so on)
- **Grafana** -> 3000 (for n nodes 3000,3001,... and so on)
- **Kibana** -> 5601 (for n nodes 5601,5602,... and so on)
- **PGAdmin** -> 3030 (for n nodes 3030,3031,... and so on)
- **BeakerX** Notebook -> 6000 (for n nodes 6000,6001,... and so on)
- **Portainer** -> 9000 (for n nodes 9000,9001,... and so on)
- **Vector** -> 7070 (for n nodes, 7070,7071,... and so on)
- **Clickhouse** -> 8123 (for n nodes, 8123,8124,... and so on)
- **InfluxDB** -> 5000 (for n nodes, 5000,5001,... and so on)
- **Tensorflow** -> 8888 (for n nodes 8888,8889,... and so on)
- **Superset** -> 10000 (for n nodes 10000, 10001,... and so on)
- **H2O** -> 1234 (for n nodes 1234, 1235,... and so on)

### Standalone Services
- **Kafka Topic UI** -> 8001
- **Kafka Schema Registry UI** -> 8002 
- **Kafka Connect UI** -> 8003
- **Presto Coordinator UI** -> 2020
