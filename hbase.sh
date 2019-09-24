#!/bin/sh

hive_site_path="/data/azkaban-hadoop/command-home/spark-offline/conf/hive-site.xml"

if [ -z "${SPARK_HOME}" ]; then
  source "$(dirname "$0")"/find-spark-home
fi

hadoop fs -rmr /tmp/bulkload

echo "begin to write"
export HADOOP_USER_NAME=hbase
spark-submit --class com.mobvista.sparkOnHBase.HiveToHBase \
	--conf spark.sql.shuffle.partitions=10 \
	--conf spark.default.parallelism=10 \
	--name "hbase_write_test" \
	--files ${hive_site_path} \
	--master yarn \
	--queue "dataplatform" \
	--deploy-mode cluster \
	--executor-memory 2G \
	--driver-memory 1G \
	--executor-cores 1 \
	--num-executors 2 \
	--jars ${SPARK_HOME}/auxlib/Common-SerDe-1.0-SNAPSHOT.jar,s3://mob-emr-test/dataplatform/DataWareHouse/offline/myjar/hbase-client-2.1.4.jar,s3://mob-emr-test/dataplatform/DataWareHouse/offline/myjar/hbase-common-2.1.4.jar,s3://mob-emr-test/dataplatform/DataWareHouse/offline/myjar/hbase-server-2.1.4.jar,s3://mob-emr-test/dataplatform/DataWareHouse/offline/myjar/hbase-spark-1.0.0.jar \
	./hbase-spark-upsert-1.0-SNAPSHOT.jar
