#!/bin/bash
# DB Server Installation
# Author		: Darryl Mendez 
# Date			: 8/28/2020
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

install_oracle_packages() {
  logit INFO "Installing Oracle Required Packages"
  sudo yum-config-manager --enable rhel-7-server-optional-rpms
  sudo yum install -y \
   binutils.x86_64 \
   compat-libcap1.x86_64 \
   gcc.x86_64 gcc-c++.x86_64 \
   glibc.i686 \
   glibc.x86_64 \
   glibc-devel.i686 glibc-devel.x86_64 \
   ksh \
   compat-libstdc++-33 \
   libaio.i686 libaio.x86_64 \
   libaio-devel.i686 libaio-devel.x86_64 \
   libgcc.i686 libgcc.x86_64 \
   libstdc++.i686 libstdc++.x86_64 \
   libstdc++-devel.i686 libstdc++-devel.x86_64 \
   libXi.i686 libXi.x86_64 \
   libXtst.i686 libXtst.x86_64 \
   make.x86_64 \
   sysstat.x86_64 \
   smartmontools
  sudo yum install -y /tmp/deployment/compat-libstdc++-33-3.2.3-72.el7.x86_64.rpm
}
install_utils() {
  sudo yum install -y nvme-cli || logit ERROR "sudo yum install -y nvme-cli"
  sudo yum install -y expect || logit ERROR "sudo yum install expect"
  sudo yum install -y wget zip unzip || logit ERROR "sudo yum install -y wget zip unzip"
  install_oracle_packages
} 
update() {
  sudo yum update -y 
} 
add_users() {
  sudo useradd -u 199 oracle
  sudo passwd -d oracle
  sudo groupadd -g 342 dba
  sudo groupadd -g 343 oinstall 
  sudo usermod -g dba oracle
  sudo usermod -a -G oinstall oracle
}
add_mount_points() {
  sudo mkdir /local
  sudo mkdir /local/oradb1
  sudo mkdir /local/oralg1
  sudo mkdir /local/oralg2
  sudo mkdir /ora_backup_dd_nfs
  sudo mkdir /local/orabck
  sudo mkdir /local/oraarc 
  sudo mkdir /local/orabin
  sudo mkdir /local/oradb1/flash_recovery_area
  #sleep 1
  #logit INFO "sudo chown -R oracle:oinstall"
  #sudo chown -R oracle:oinstall /local/ || logit ERROR "sudo chown -R oracle:oinstall"
  #sudo chown -R oracle:oinstall /local/ || logit ERROR "sudo chown -R oracle:oinstall"
  #logit INFO "sudo chown -R oracle:oinstall /ora_backup_dd_nfs"
  #sleep 1
  #sudo chown -R oracle:oinstall /ora_backup_dd_nfs || logit ERROR "sudo chown -R oracle:oinstall /ora_backup_dd_nfs"
  #ls -lt /ora_backup_dd_nfs
  #ls -lt /
}
kernel_parms() {
  sudo /bin/su -c "echo 'fs.aio-max-nr = 3145728' >> /etc/sysctl.conf"
  sudo /bin/su -c "echo 'fs.file-max = 6815744' >> /etc/sysctl.conf"
  sudo /bin/su -c "echo 'kernel.shmall = 2251799813685247' >> /etc/sysctl.conf"
  sudo /bin/su -c "echo 'kernel.shmmax = 4398046511104' >> /etc/sysctl.conf"
  sudo /bin/su -c "echo 'kernel.shmmni = 4096' >> /etc/sysctl.conf"
  sudo /bin/su -c "echo 'kernel.sem = 250 32000 100 142' >> /etc/sysctl.conf"
  sudo /bin/su -c "echo 'net.ipv4.ip_local_port_range = 9000 65500' >> /etc/sysctl.conf"
  sudo /bin/su -c "echo 'net.core.rmem_default = 262144' >> /etc/sysctl.conf"
  sudo /bin/su -c "echo 'net.core.rmem_max = 4194304' >> /etc/sysctl.conf"
  sudo /bin/su -c "echo 'net.core.wmem_default = 262144' >> /etc/sysctl.conf"
  sudo /bin/su -c "echo 'net.core.wmem_max = 1048576' >> /etc/sysctl.conf"
  sudo /bin/su -c "echo 'net.core.wmem_max = 1048576' >> /etc/sysctl.conf"
  sudo /bin/su -c "echo 'net.core.wmem_max = 1048576' >> /etc/sysctl.conf"
  sudo /bin/su -c "echo 'oracle soft nproc 2048' >> /etc/security/limits.conf"
  sudo /bin/su -c "echo 'oracle soft nofile 1024' >> /etc/security/limits.conf"
  sudo /bin/su -c "echo 'oracle hard nproc 16384' >> /etc/security/limits.conf"
  sudo /bin/su -c "echo 'oracle hard nofile 65536' >> /etc/security/limits.conf"
  sudo sysctl -p
  sudo sysctl -a
}
configure() {
  echo "configure /etc/hosts"
}
{
  ec=0
  logit INFO '-----------------------------------------------'
  logit INFO 'Starting '
  logit INFO '-----------------------------------------------'

  logit INFO '-----------------------------------------------'
  #logit INFO 'Package Update'
  logit INFO '-----------------------------------------------'
  #update
  install_utils
  add_users
  add_mount_points
  kernel_parms
  rc=$?
  if [ $rc = "0" ]; then
    logit INFO '-----------------------------------------------'
    logit INFO 'Package Upgraded'
    logit INFO '-----------------------------------------------'
  else
    ec=1
    logit INFO '-----------------------------------------------'
    logit INFO ' failed'
    logit INFO '-----------------------------------------------'
    exit 1
  fi   
  logit INFO '-----------------------------------------------------'
  #logit INFO 'Adding users'
  logit INFO '-----------------------------------------------------'
  #add_users
  #rc=$?
  if [ $rc = "0" ]; then
    logit INFO '-----------------------------------------------'
    #logit INFO 'Added users'
    logit INFO '-----------------------------------------------'
  else
    ec=1
    logit INFO '-----------------------------------------------'
    #logit INFO 'adding user failed'
    logit INFO '-----------------------------------------------'
    exit 1
  fi 
 
     
  if [ $ec = "0" ]; then  
    logit INFO '-----------------------------------------------'
    logit INFO 'Completed '
    logit INFO '-----------------------------------------------'
    exit 0
  fi  
}
