#!/bin/bash
# Author		: Darryl Mendez 
# Date			: 5/8/2020
# Description	        : Initial Revision
error_exit()
{
  echo "$1" 1>&2
  exit 1
}
logit() {
  local LOG_LEVEL=$1
  shift 
  MSG=$@ 
  TIMESTAMP=`date`
  logger -s "${TIMESTAMP} ${HOST} ${PROGRAM_NAME} [$PID]: ${LOG_LEVEL} ${MSG}"
  if [ ${LOG_LEVEL} = "ERROR" ]; then
    error_exit $MSG
  fi 
 }
update() {
  logit INFO 'Starting Package Update'
  sudo yum update -y || logit ERROR "sudo yum update - y"
  logit INFO 'Package Successfully Updated'
  logit INFO 'Installing expect'
  sudo yum install -y expect || logit ERROR "sudo yum install expect"
  sudo yum install -y nvme-cli || logit ERROR "sudo yum install -y nvme-cli"
  #logit INFO 'Rebooting....'
  #sudo reboot
} 
add_users() {
 #sudo useradd -s /sbin/nologin oracle
 sudo adduser oracle
 #sudo adduser mendedx
 #sudo adduser urbantw
 #sudo mkdir /home/urbantw/.ssh
 #sudo mkdir /home/mendedx/.ssh
 
 #sudo cp /home/ec2-user/.ssh/authorized_keys /home/oracle/.ssh/*
 sudo cp /home/ec2-user/.ssh/authorized_keys /home/mendedx/.ssh/*
 sudo cp /home/ec2-user/.ssh/authorized_keys /home/urbantw/.ssh/*
 sudo usermod -aG wheel mendedx
 sudo usermod -aG wheel urbantw
 #sudo chmod 700 /home/oracle/.ssh
 #sudo chmod 600 /home/oracle/.ssh/authorized_keys
 #sudo chown -R oracle:oracle /home/oracle/*
 #sudo chmod 700 /home/mendedx/.ssh
 ##sudo chmod 600 /home/mendedx/.ssh/authorized_keys
 #sudo chmod 700 /home/urbantw/.ssh
 #sudo chmod 600 /home/urbantw/.ssh/authorized_keys

}


{
  ec=0
  logit INFO '-----------------------------------------------'
  logit INFO 'Starting GXP Watson Server Install'
  logit INFO '-----------------------------------------------'

  logit INFO '-----------------------------------------------'
  logit INFO 'Package Update'
  logit INFO '-----------------------------------------------'
  update
  rc=$?
  if [ $rc = "0" ]; then
    logit INFO '-----------------------------------------------'
    logit INFO 'Package Upgraded'
    logit INFO '-----------------------------------------------'
  else
    ec=1
    logit INFO '-----------------------------------------------'
    logit INFO 'Package Upgrade failed'
    logit INFO '-----------------------------------------------'
    exit 1
  fi   
  logit INFO '-----------------------------------------------------'
  logit INFO 'Adding users'
  logit INFO '-----------------------------------------------------'
  add_users
  rc=$?
  if [ $rc = "0" ]; then
    logit INFO '-----------------------------------------------'
    logit INFO 'Added users'
    logit INFO '-----------------------------------------------'
  else
    ec=1
    logit INFO '-----------------------------------------------'
    logit INFO 'adding user failed'
    logit INFO '-----------------------------------------------'
    exit 1
  fi 
 
     
  if [ $ec = "0" ]; then  
    logit INFO '-----------------------------------------------'
    logit INFO 'Completed Watson DB Server Install'
    logit INFO '-----------------------------------------------'
    exit 0
  fi  
}
