#!/bin/bash -xe

REPO_URL="https://raw.githubusercontent.com/vinicelms/emr-monitoring-prometheus-grafana/master"
NODE_EXPORTER_VERSION="1.0.1"
JMX_EXPORTER_VERSION="0.14.0"

#set up node_exporter for pushing OS level metrics
sudo useradd --no-create-home --shell /bin/false node_exporter
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
tar -xvzf node_exporter-1.0.1.linux-amd64.tar.gz
cd node_exporter-1.0.1.linux-amd64
sudo cp node_exporter /usr/local/bin/
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

cd /tmp
wget https://raw.githubusercontent.com/vinicelms/emr-monitoring-prometheus-grafana/master/prometheus/config_files/node_exporter.service
sudo cp node_exporter.service /etc/systemd/system/node_exporter.service
sudo chown node_exporter:node_exporter /etc/systemd/system/node_exporter.service
sudo systemctl daemon-reload && \
sudo systemctl start node_exporter && \
sudo systemctl status node_exporter && \
sudo systemctl enable node_exporter

#set up jmx_exporter for pushing application metrics
wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.14.0/jmx_prometheus_javaagent-0.14.0.jar
sudo mkdir -p /etc/prometheus/textfiles
sudo cp jmx_prometheus_javaagent-0.14.0.jar /etc/prometheus

wget https://raw.githubusercontent.com/vinicelms/emr-monitoring-prometheus-grafana/master/prometheus/config_files/hdfs_jmx_config_namenode.yaml
wget https://raw.githubusercontent.com/vinicelms/emr-monitoring-prometheus-grafana/master/prometheus/config_files/hdfs_jmx_config_datanode.yaml
wget https://raw.githubusercontent.com/vinicelms/emr-monitoring-prometheus-grafana/master/prometheus/config_files/yarn_jmx_config_resource_manager.yaml
wget https://raw.githubusercontent.com/vinicelms/emr-monitoring-prometheus-grafana/master/prometheus/config_files/yarn_jmx_config_node_manager.yaml
wget https://raw.githubusercontent.com/vinicelms/emr-monitoring-prometheus-grafana/master/prometheus/textfiles/emr_node_info.sh

HADOOP_CONF='/etc/hadoop/conf'
sudo mkdir -p /etc/hadoop/conf
sudo cp hdfs_jmx_config_namenode.yaml /etc/hadoop/conf
sudo cp hdfs_jmx_config_datanode.yaml /etc/hadoop/conf
sudo cp yarn_jmx_config_resource_manager.yaml /etc/hadoop/conf
sudo cp yarn_jmx_config_node_manager.yaml /etc/hadoop/conf
sudo cp emr_node_info.sh /etc/prometheus/textfiles
sudo /etc/prometheus/textfiles/emr_node_info.sh


# Yarn configuration setup
wget https://raw.githubusercontent.com/vinicelms/emr-monitoring-prometheus-grafana/master/prometheus/config_files/yarn_jmx_env_setup.txt
sed -i "s/__JMX_EXPORTER_VERSION__/0.14.0/g" /tmp/yarn_jmx_env_setup.txt
cat /tmp/yarn_jmx_env_setup.txt | sudo tee -a /etc/hadoop/conf/yarn-env.sh > /dev/null

exit 0
