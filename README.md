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
$ docker-compuse up -d
$ ./init.sh
```

This will start the Docker container, download all external dependencies, and run a couple of Spark jobs. This will output two files: `./output/era.txt` and `./output/inningsPitched.txt`.
