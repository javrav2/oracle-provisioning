#!/bin/bash
# DB Server Installation
# Author		: Darryl Mendez (mendedx) 
# Email			: darryl.mendez@abbvie.com
# Date			: 9/1/2020
# Description	        : Initial Revision
export ORACLE_ZIP="LINUX.X64_193000_db_home.zip"
export BIN_DIR=/local/orabin
export ORACLE_HOST="localhost"
export ORACLE_HOME="/local/orabin"
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
unzip(){
  cd $BIN_DIR
  sudo cp -p /tmp/deployment/"$ORACLE_ZIP" $BIN_DIR || logit ERROR "sudo cp -p /tmp/deployment/"$ORACLE_ZIP" $BIN_DIR"
  sudo unzip "$ORACLE_ZIP" || logit ERROR "sudo unzip "$ORACLE_ZIP"" 
  sudo chown -R oracle:oinstall /local || logit ERROR "sudo chown -R oracle:oinstall /local"
  sleep 1
}
installer(){
  cd $BIN_DIR
  sudo -u oracle ./runInstaller -waitForCompletion -silent -loglevel finest -responseFile /tmp/deployment/db_install.rsp || logit ERROR "sudo -u oracle ./runInstaller -waitForCompletion -silent -loglevel finest -responseFile /tmp/deployment/db_install.rsp"
}
orainstRoot() {
  logit INFO "Setting up orainstRoot.sh"
  sudo $BIN_DIR/oraInventory/orainstRoot.sh || logit ERROR "sudo $BIN_DIR/oraInventory/orainstRoot.sh"
  sudo $BIN_DIR/root.sh || logit ERROR "sudo $BIN_DIR/root.sh"
}
set_bash_profile() {
  logit INFO "Setting BASH Profile"
  sudo cp /home/oracle/.bash_profile /tmp/.bash_profile
  echo "export ORACLE_HOSTNAME=localhost" >> /tmp/.bash_profile
  echo "export ORACLE_UNQNAME=ORA19C" >> /tmp/.bash_profile
  echo "export ORACLE_BASE=$BIN_DIR" >> /tmp/.bash_profile
  echo "export ORACLE_HOME=$BIN_DIR" >> /tmp/.bash_profile
  echo "export ORACLE_SID=ORCL" >> /tmp/.bash_profile
  echo "export PATH=$ORACLE_HOME/bin:$PATH" >> /tmp/.bash_profile
  echo "export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH" >> /tmp/.bash_profile
  echo "export CLASSPATH=ORACLE_HOME/jlib:ORACLE_HOME/rdbms/jlib;" >> /tmp/.bash_profile
  sudo cp /tmp/.bash_profile /home/oracle/.bash_profile
  sudo chown oracle:oinstall /home/oracle/.bash_profile
  echo "export ORACLE_HOSTNAME=localhost" >> /home/ec2-user/.bash_profile
  echo "export ORACLE_UNQNAME=ORA19C" >> /home/ec2-user/.bash_profile
  echo "export ORACLE_BASE=$BIN_DIR" >> /home/ec2-user/.bash_profile
  echo "export ORACLE_HOME=$BIN_DIR" >> /home/ec2-user/.bash_profile
  echo "export ORACLE_SID=ORCL" >> /home/ec2-user/.bash_profile
  echo "export PATH=$ORACLE_HOME/bin:$PATH" >> /home/ec2-user/.bash_profile
  echo "export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH" >> /home/ec2-user/.bash_profile
  echo "export CLASSPATH=ORACLE_HOME/jlib:ORACLE_HOME/rdbms/jlib;" >> /home/ec2-user/.bash_profile
  source /home/ec2-user/.bash_profile
  env
 }
install_listener() {
  sudo -u oracle $BIN_DIR/bin/netca -silent -responseFile $BIN_DIR/assistants/netca/netca.rsp
  su -c "$BIN_DIR/bin/lsnrctl stop" -s /bin/bash oracle
  su -c "$BIN_DIR/bin/lsnrctl start" -s /bin/bash oracle
  su -c "$BIN_DIR/bin/lsnrctl status" -s /bin/bash oracle
}
create_database() {
  su -c "dbca \
  -silent \
  -createDatabase \
  -templateName General_Purpose.dbc   \
  -gdbName ORCL \
  -pdbadminPassword OraPasswd123 \
  -SysPassword OraPasswd123 \
  -SystemPassword OraPasswd123 \
  -emConfiguration NONE \
  -datafileDestination /local/oradb1 \
  -asmSysPassword OraPasswd123 \
  -characterSet AL32UTF8 \
  -totalMemory 1024 \
  -recoveryAreaDestination /local/oradb1/flash_recovery_area" -s /bin/bash oracle
  orainstRoot
}
connect() {
  su -c "sqlplus /nolog <<EOF
  whenever sqlerror exit sql.sqlcode;
  connect / as sysdba;
  show user
  select sysdate from dual;
  quit
EOF" -s /bin/bash oracle
}
add_sudo_policies() {
  sudo /bin/su -c "echo 'User_Alias DBA = darryl,mendedx,urbantw,gabeljx' >> /etc/sudoers"
  sudo /bin/su -c "echo 'DBA ALL = (oracle:oinstall) ALL' >> /etc/sudoers"
  sudo cat /etc/sudoers
}
cleanup() {
  sudo rm -rf /tmp/scripts
  sudo rm -rf /tmp/deployment
}
{
  ec=0
  logit INFO '-----------------------------------------------'
  logit INFO 'Starting Oracle Install '
  logit INFO '-----------------------------------------------'
  unzip
  rc=$?
  if [ $rc = "0" ]; then
    logit INFO '-----------------------------------------------'
    logit INFO 'Unzip Successful'
    logit INFO '-----------------------------------------------'
  else
    ec=1
    logit INFO '-----------------------------------------------'
    logit INFO 'Unzip Failed'
    logit INFO '-----------------------------------------------'
    exit 1
  fi   
  logit INFO '-----------------------------------------------'
  logit INFO 'Starting Oracle Installer '
  logit INFO '-----------------------------------------------'
  installer
  rc=$?
  if [ $rc = "0" ]; then
    logit INFO '-----------------------------------------------'
    logit INFO 'Oracle Installer Completed Successfully'
    logit INFO '-----------------------------------------------'
  else
    ec=1
    logit INFO '-----------------------------------------------'
    logit INFO 'Oracle Installer Failed'
    logit INFO '-----------------------------------------------'
    exit 1
  fi   
  logit INFO '-----------------------------------------------'
  logit INFO 'Setting Bash Profile '
  logit INFO '-----------------------------------------------'
  set_bash_profile
  rc=$?
  if [ $rc = "0" ]; then
    logit INFO '-----------------------------------------------'
    logit INFO 'Bash Profile Configured'
    logit INFO '-----------------------------------------------'
  else
    ec=1
    logit INFO '-----------------------------------------------'
    logit INFO 'Bash Profile Configuration failed'
    logit INFO '-----------------------------------------------'
    exit 1
  fi   
  install_listener
  rc=$?
  if [ $rc = "0" ]; then
    logit INFO '-----------------------------------------------'
    logit INFO 'Listener Installed Successfully'
    logit INFO '-----------------------------------------------'
  else
    ec=1
    logit INFO '-----------------------------------------------'
    logit INFO 'Listener Installation Failed'
    logit INFO '-----------------------------------------------'
    exit 1
  fi   
  create_database
  rc=$?
  if [ $rc = "0" ]; then
    logit INFO '-----------------------------------------------'
    logit INFO 'Oracle Database Creation Successful'
    logit INFO '-----------------------------------------------'
  else
    ec=1
    logit INFO '-----------------------------------------------'
    logit INFO 'Oracle Database Creation Failed'
    logit INFO '-----------------------------------------------'
    exit 1
  fi   
  connect
  rc=$?
  if [ $rc = "0" ]; then
    logit INFO '-----------------------------------------------'
    logit INFO 'Oracle Connection Successful'
    logit INFO '-----------------------------------------------'
  else
    ec=1
    logit INFO '-----------------------------------------------'
    logit INFO 'Oracle Connection Failed'
    logit INFO '-----------------------------------------------'
    exit 1
  fi   
  add_sudo_policies
  rc=$?
  if [ $rc = "0" ]; then
    logit INFO '-----------------------------------------------'
    logit INFO 'Added sudo policies'
    logit INFO '-----------------------------------------------'
  else
    ec=1
    logit INFO '-----------------------------------------------'
    logit INFO 'sudo policies configuration failed'
    logit INFO '-----------------------------------------------'
    exit 1
  fi   
  cleanup
  rc=$?
  if [ $rc = "0" ]; then
    logit INFO '-----------------------------------------------'
    logit INFO 'Cleanup completed'
    logit INFO '-----------------------------------------------'
  else
    ec=1
    logit INFO '-----------------------------------------------'
    logit INFO 'Cleanup failed'
    logit INFO '-----------------------------------------------'
    exit 1
  fi   
  
  if [ $ec = "0" ]; then  
    logit INFO '-----------------------------------------------'
    logit INFO 'Completed Oracle DB Server Install'
    logit INFO '-----------------------------------------------'
    exit 0
  fi  
}