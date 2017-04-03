#!/bin/sh

################################################################################
#
# Globals and convenience functions
#
################################################################################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Convenience functions to make horrible errors less frightening
# Shamelessly lifted from the always-wonderful Zach Holman at
# https://github.com/holman/dotfiles/blob/master/script/bootstrap

# The four convenience functions below are licensed as follows:

# The MIT License
#
# Copyright (c) Zach Holman, http://zachholman.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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

##########
# PYTHON
##########

info "Checking whether Python3 is installed..."
noPy3Alias=false
hasPython3=$(which python3 &> /dev/null)

if [ $? -eq 1 ]; then
  hasPython3=$(python -c "import sys;t='{v[0]}'.format(v=list(sys.version_info[:2]));sys.stdout.write(t)";)

  if [ ${hasPython3} -eq 3 ]; then
    noPy3Alias=true
    success "Found Python3!"
  else
    fail "Are you sure you have Python3 installed?"
  fi
else
  success "Found Python3!"
fi

##########
# WGET / CURL
##########

useCurl=false
info "Checking whether wget is installed..."
hasWget=$(which wget &> /dev/null)
if [ $? -eq 1 ]; then
  info "Hmm... we couldn't find wget."
  info "We'll try to use curl instead..."
  hasCurl=$(which curl &> /dev/null)

  if [ $? -eq 1 ]; then
    fail "Are you sure you have wget or curl installed?"
  else
    success "Found curl!"
    useCurl=true
  fi
else
  success "Found wget!"
fi

##########
# UNZIP
##########

info "Checking whether unzip is installed..."
hasUnzip=$(which unzip &> /dev/null)
if [ $? -eq 1 ]; then
  fail "Are you sure you have unzip installed?"
else
  success "Found unzip!"
fi

##########
# TAR
##########

info "Checking whether tar is installed..."
hasTar=$(which tar &> /dev/null)
if [ $? -eq 1 ]; then
  fail "Are you sure you have tar installed?"
else
  success "Found tar!"
fi

##########
# Required directories
##########

info "Creating your data directory..."
if [ ! -d "${SCRIPT_DIR}/data" ]; then
  mkdir ${SCRIPT_DIR}/data
fi

info "Creating your externals directory..."
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

##########
# Download data
##########

info "Downloading and extracting your datasets..."
if [ "$useCurl" = true ]; then
  curl http://seanlahman.com/files/database/lahman2012-csv.zip \
    -o ${SCRIPT_DIR}/data/baseball.zip
else
  wget http://seanlahman.com/files/database/lahman2012-csv.zip \
    -O ${SCRIPT_DIR}/data/baseball.zip
fi

unzip ${SCRIPT_DIR}/data/baseball.zip \
  -d ${SCRIPT_DIR}/data
success "Datasets successfully downloaded and unzipped!"

##########
# Download Avro
##########

info "Downloading external dependencies..."
# Download Avro
if [ "$useCurl" = true ]; then
  curl http://www.gtlib.gatech.edu/pub/apache/avro/avro-1.8.1/py3/avro-python3-1.8.1.tar.gz \
    -o ${SCRIPT_DIR}/externals/avro.tar.gz
else
  wget http://www.gtlib.gatech.edu/pub/apache/avro/avro-1.8.1/py3/avro-python3-1.8.1.tar.gz \
    -O ${SCRIPT_DIR}/externals/avro.tar.gz
fi

if [ ! -d "${SCRIPT_DIR}/externals/avro" ]; then
 mkdir ${SCRIPT_DIR}/externals/avro
fi

tar -xzvf ${SCRIPT_DIR}/externals/avro.tar.gz \
  -C ${SCRIPT_DIR}/externals/avro \
  --strip-components=1

##########
# Install Avro
##########

if [ "$noPy3Alias" = true ]; then
  sudo python ${SCRIPT_DIR}/externals/avro/setup.py install
else
  sudo python3 ${SCRIPT_DIR}/externals/avro/setup.py install
fi

success "Successfully downloaded and installed Avro!"