#!/bin/sh

################################################################################
#
# Globals and convenience functions
#
################################################################################

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Convenience functions to make horrible errors less frightening
info () {
  printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

user () {
  printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

################################################################################
#
# Check for dependencies
#
################################################################################

hasPython3=$(which python3)
if [ $? -eq 1 ]; then
  fail "Are you sure you have Python3 installed?"
fi

hasWget=$(which wget)
if [ $? -eq 1 ]; then
  fail "Are you sure you have wget installed?"
fi

hasUnzip=$(which unzip)
if [$? -eq 1 ]; then
  fail "Are you sure you have unzip installed?"
fi

if [ ! -d "${SCRIPT_DIR}/data" ]; then
  mkdir ${SCRIPT_DIR}/data
fi

if [ ! -d "${SCRIPT_DIR}/externals" ]; then
  mkdir ${SCRIPT_DIR}/externals
fi

################################################################################
#
# Download data and some other fun
# mysteries to surprise and delight
# users
#
################################################################################

wget http://seanlahman.com/files/database/lahman2012-csv.zip \
  -O ${SCRIPT_DIR}/data/baseball.zip

unzip ${SCRIPT_DIR}/data/baseball.zip \
  -d ${SCRIPT_DIR}/data

# Download Avro
wget http://www.gtlib.gatech.edu/pub/apache/avro/avro-1.8.1/py3/avro-python3-1.8.1.tar.gz \
  -O ${SCRIPT_DIR}/externals/avro.tar.gz

if [ ! -d "${SCRIPT_DIR}/externals/avro" ]; then
 mkdir ${SCRIPT_DIR}/externals/avro
fi

tar -xzvf ${SCRIPT_DIR}/externals/avro.tar.gz \
  -C ${SCRIPT_DIR}/externals/avro \
  --strip-components=1

# Install Avro
sudo python3 ${SCRIPT_DIR}/externals/avro/setup.py install
