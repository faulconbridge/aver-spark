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
$ python /code/csvToAvro.py \
    -f /tmp/data/Pitching.csv \
    -s /code/era.avsc
    -o /output/era.avro
$ /usr/spark-2.1.0/bin/spark-submit \
    /code/queryData.py \
    --packages com.databricks:spark-avro_2.11:3.2.0
```

This will start the Docker container, download all external dependencies, and run a couple of Spark jobs. This will output two files: `./output/era.txt` and `./output/inningsPitched.txt`.

Sources Consulted
=================

  - https://docs.python.org/3.5/
  - http://spark.apache.org/docs/latest/sql-programming-guide.html
  - http://spark.apache.org/docs/latest/api/python/pyspark.sql.html
  - https://docs.docker.com/machine/
  - https://github.com/databricks/spark-avro
  - https://www.supergloo.com/fieldnotes/spark-sql-csv-examples-python/
  - https://google.github.io/styleguide/pyguide.html
  - https://docs.python.org/2/howto/argparse.html
  - https://www.cloudera.com/documentation/enterprise/5-6-x/topics/spark_avro.html
  - http://avro.apache.org/docs/1.8.1/gettingstartedpython.html
  - https://github.com/gstaubli/csv2avro/blob/master/src/csv2avro.py
  - http://stackoverflow.com/questions/6141581/detect-python-version-in-shell-script
  - http://stackoverflow.com/questions/2953646/how-to-declare-and-use-boolean-variables-in-shell-script
  - http://stackoverflow.com/questions/17444679/reading-a-huge-csv-file
  - http://stackoverflow.com/questions/35712601/avro-io-avrotypeexception-the-datum-avro-data-is-not-an-example-of-the-schema
  - http://stackoverflow.com/questions/29759893/how-to-read-avro-file-in-pyspark
  - http://stackoverflow.com/questions/19670061/bash-if-false-returns-true
  - http://stackoverflow.com/questions/1614236/in-python-how-do-i-convert-all-of-the-items-in-a-list-to-floats
