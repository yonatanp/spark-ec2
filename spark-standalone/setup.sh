#!/bin/bash

BIN_FOLDER="/root/spark/sbin"

if [[ "0.7.3 0.8.0 0.8.1" =~ $SPARK_VERSION ]]; then
  BIN_FOLDER="/root/spark/bin"
fi

# Copy the slaves to spark conf
cp /root/spark-ec2/slaves /root/spark/conf/
/root/spark-ec2/copy-dir /root/spark/conf

# Set cluster-url to standalone master
echo "spark://""`cat /root/spark-ec2/masters`"":7077" > /root/spark-ec2/cluster-url
/root/spark-ec2/copy-dir /root/spark-ec2

# The Spark master seems to take time to start and workers crash if
# they start before the master. So start the master first, sleep and then start
# workers.

# Stop anything that is running
$BIN_FOLDER/stop-all.sh

sleep 2

# Start Master
# YP: we don't have to provide SPARK_MASTER_HOST here, but for consistency, we will
SPARK_MASTER_HOST=$(cat /root/spark-ec2/masters) \
    $BIN_FOLDER/start-master.sh

# Pause
sleep 20

# Start Workers
# YP: we must provide SPARK_MASTER_HOST because the default is `hostname` and this doesn't work with private IPs (or at all)
SPARK_MASTER_HOST=$(cat /root/spark-ec2/masters) \
    $BIN_FOLDER/start-slaves.sh

