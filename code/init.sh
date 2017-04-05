#!/bin/bash

################################################################################
#
# Globals and convenience functions
#
################################################################################

# I was originally going to use the same directory
# as the init script for everything, but then things
# got weird with Docker mounts not corresponding to
# the actual file hierarchy here in the repo, so I
# nixed it, tucked the init script into /code and
# 
# SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_DIR="/tmp"

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
  printf "\r  [ \033[0;33m??\033[0m ] $1 "
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

info "Creating an output directory..."
if [ ! -d "${SCRIPT_DIR}/output" ]; then
  mkdir ${SCRIPT_DIR}/output
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
    -o ${SCRIPT_DIR}/data/baseball.zip &> ${SCRIPT_DIR}/init.log
else
  wget http://seanlahman.com/files/database/lahman2012-csv.zip \
    -O ${SCRIPT_DIR}/data/baseball.zip &> ${SCRIPT_DIR}/init.log
fi

unzip -u ${SCRIPT_DIR}/data/baseball.zip \
  -d ${SCRIPT_DIR}/data &> /dev/null
success "Datasets successfully downloaded and unzipped!"

##########
# Download Avro
##########

info "Downloading external dependencies..."
# Download Avro
if [ "$useCurl" = true ]; then
  curl http://www.gtlib.gatech.edu/pub/apache/avro/avro-1.8.1/py3/avro-python3-1.8.1.tar.gz \
    -o ${SCRIPT_DIR}/externals/avro.tar.gz &> ${SCRIPT_DIR}/init.log
else
  wget http://www.gtlib.gatech.edu/pub/apache/avro/avro-1.8.1/py3/avro-python3-1.8.1.tar.gz \
    -O ${SCRIPT_DIR}/externals/avro.tar.gz &> ${SCRIPT_DIR}/init.log
fi

if [ ! -d "${SCRIPT_DIR}/externals/avro" ]; then
 mkdir ${SCRIPT_DIR}/externals/avro
fi

tar -xzvf ${SCRIPT_DIR}/externals/avro.tar.gz \
  -C ${SCRIPT_DIR}/externals/avro \
  --strip-components=1 &> ${SCRIPT_DIR}/init.log

##########
# Install Avro
##########

# info "We're going to install Avro locally now. To do this,"
# info "we need to run a command with elevated privileges."
# info "If you don't trust us, that's totally fine and you"
# info "can inspect the script and choose whether to run"
# info "the command manually or not."
# user "Would you like to proceed with elevated privileges? [Y/n]"
# read -r -e proceedWithSudo

# if [[ ! -z "${proceedWithSudo}" ]]; then
#   proceedWithSudo=$(echo -e ${proceedWithSudo} | tr '[:upper:]' '[:lower:]')

#   # Basic error checking; continue to prompt while
#   # user input length > 0 and != either y or n
#   while [[ "${proceedWithSudo}" != "y" ]] &&
#         [[ "${proceedWithSudo}" != "n" ]] &&
#         [[ ! -z "${proceedWithSudo}" ]]; do
#     user "Please enter a valid value or press Enter for Yes"
#     read -r -e proceedWithSudo
#     proceedWithSudo=$(echo -e ${proceedWithSudo} | tr '[:upper:]' '[:lower:]')
#   done
# fi

# if [[ "${proceedWithSudo}" == "n" ]]; then
#   fail "You have aborted script execution"
# else
  cd ${SCRIPT_DIR}/externals/avro

  if [ "$noPy3Alias" = true ]; then
    python ./setup.py install &> ${SCRIPT_DIR}/init.log
  else
    python3 ./setup.py install &> ${SCRIPT_DIR}/init.log
  fi

  success "Successfully downloaded and installed Avro!"
# fi
