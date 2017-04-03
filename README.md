Requirements
============

  - Docker
  - Python 3
  - wget
  - unzip
  - git
  - Java

To Run
=====

To run,
```
$ cd path/to/aver-spark
$ docker-compose up -d
$ docker exec -it averspark_master_1 /bin/bash
$ /code/init.sh
$ python /code/csvToAvro \
    -f /data/Pitching.csv \
    -s /code/era.avsc
    -o /output/era.avro
$ /usr/spark-2.1.0/bin/pyspark \
    /code/queryData.py \
    --packages com.databricks:spark-avro_2.11:3.2.0
```

This will start the Docker container, download all external dependencies, and run a couple of Spark jobs. This will output two files: `./output/era.txt` and `./output/inningsPitched.txt`.
