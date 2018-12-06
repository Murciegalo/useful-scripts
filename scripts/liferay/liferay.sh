#!/bin/bash

LIFERAY_CDN_URL="https://cdn.lfrs.sl/releases.liferay.com/portal/"

#TODO da migliorare le varie versione dei bundles devono poter essere presi dinamicamente dal CDN liferay
LR_BUNDLES=('7.0.1-ga2' '7.0.2-ga3' '7.0.3-ga4' '7.0.4-ga5' '7.0.5-ga6' '7.0.6-ga7' '7.1.0-ga1' '7.1.1-ga2')
LR_BUNDLES_VERSION_NUMBER=('7.0-ga2-20160610113014153.zip' '7.0-ga3-20160804222206210.zip' '7.0-ga4-20170613175008905.zip' '7.0-ga5-20171018150113838.zip' '7.0-ga6-20180320170724974.zip' '7.0-ga7-20180507111753223.zip' '7.1-ga1-20180703012531655.zip' '7.1-ga2-20181112144637000.tar.gz')

PROJECT_HOME=$(pwd)
LR_BUNDLES_REPOSITORY="/work/bundles/liferay/"
LR_BUNDLE_PREFIX="liferay-ce-portal-tomcat-"

ACTION=""
PROJECT_NAME=${PWD##*/}
CREATE_DATABASE=0
DATABASE_NAME=$PROJECT_NAME
DATABASE_USERNAME=$PROJECT_NAME
DATABASE_USER_PASSWORD="test"

function setLiferayHomeVariabiles() {

  if [ ! -e "./bundles" ]; then
    echo "There aren't any liferay bundles setted up"
    exit 1
  fi

  local BUNDLES_COUNT=$(find bundles/* -maxdepth 1 -type d -name 'liferay[^.]?*' | wc -l )

  if [ "$BUNDLES_COUNT" -eq 1 ]; then
    BUNDLE_NAME=$(find bundles/* -maxdepth 1 -type d -name 'liferay[^.]?*')
    LIFERAY_HOME="$PROJECT_HOME/$BUNDLE_NAME"
  # elif [ "$BUNDLES_COUNT" -gt 1 ]; then
    # TODO da implementare
  fi

  LIFERAY_TOMCAT_HOME=$(find $LIFERAY_HOME/* -maxdepth 1 -type d -name 'tomcat[^.]?*')
}

function show_spinner()
 {
   local -r pid="${1}"
   local -r delay='0.75'
   local spinstr='\|/-'
   local temp
   
   while ps a | awk '{print $1}' | grep -q "${pid}"; do
     temp="${spinstr#?}"     
     printf " %c  " "${spinstr}"
     spinstr=${temp}${spinstr%"${temp}"}
     sleep "${delay}"
     printf "\b\b\b\b\b\b"
   done
   printf "    \b\b\b\b"
 }

function createPortalExtFile() {

cat > $LR_HOME/portal-ext.properties << _EOF_
include-and-override=$LR_HOME/portal-developer.properties
include-and-override=$LR_HOME/portal-database.properties
_EOF_
}

function createPortalDatabaseFile() {

cat > $LR_HOME/portal-database.properties << _EOF_
jdbc.default.driverClassName=org.postgresql.Driver
jdbc.default.url=jdbc:postgresql://localhost:5432/$DATABASE_NAME
jdbc.default.username=$DATABASE_USERNAME
jdbc.default.password=$DATABASE_USER_PASSWORD
_EOF_
}

function createPortalDelevoerFile() {

cat > $LR_HOME/portal-developer.properties << _EOF_
theme.css.fast.load=false
theme.css.fast.load.check.request.parameter=true
theme.images.fast.load=false
theme.images.fast.load.check.request.parameter=true

javascript.fast.load=false
javascript.log.enabled=false

layout.template.cache.enabled=false

browser.launcher.url=

combo.check.timestamp=true

freemarker.engine.cache.storage=soft:1
freemarker.engine.resource.modification.check.interval=0

minifier.enabled=true

openoffice.cache.enabled=false

velocity.engine.resource.modification.check.interval=0

com.liferay.portal.servlet.filters.cache.CacheFilter=false
com.liferay.portal.servlet.filters.etag.ETagFilter=false
com.liferay.portal.servlet.filters.header.HeaderFilter=false
com.liferay.portal.servlet.filters.themepreview.ThemePreviewFilter=true

module.framework.properties.lpkg.index.validator.enabled=false
_EOF_

}

function setupBundleDebugAndTunning() {

cat > $LR_HOME/setenv.sh << _EOF_
REMOTE_DEBUG="-Xdebug -Xrunjdwp:transport=dt_socket,address=8002,server=y,suspend=n"
CATALINA_OPTS="$CATALINA_OPTS -Dfile.encoding=UTF8 -Djava.net.preferIPv4Stack=true -Dorg.apache.catalina.loader.WebappClassLoader.ENABLE_CLEAR_REFERENCES=false -Duser.timezone=GMT -Xmx4096m $REMOTE_DEBUG"
_EOF_
}

setupDatabase() {

  echo $CREATE_DATABASE

  if [ "$CREATE_DATABASE" -eq "1" ]; then
    echo "Creating database: $DATABASE_NAME"
    
    sudo -i -u postgres psql -c "create database $DATABASE_NAME;"
    sudo -i -u postgres psql -c "create user $DATABASE_USERNAME with encrypted password '$DATABASE_USER_PASSWORD'; \
                                 grant all privileges on database $DATABASE_NAME to $DATABASE_USERNAME;" 

    createPortalDatabaseFile

  fi

}

setup() {

#  local version_page=$(curl --location --silent $LIFERAY_CDN_URL)
#  echo $version_page

  local LR_SELECTED_BUNDLE="$LR_BUNDLE_PREFIX${LR_BUNDLES_VERSION_NUMBER[$LR_BUNDLE_SELECTED_INDEX]}"
  local LR_SELECTED_BUNDLE_PATH=$LR_BUNDLES_REPOSITORY$LR_SELECTED_BUNDLE

  mkdir -p bundles
  
  if [ ! -e "$LR_SELECTED_BUNDLE_PATH" ]; then
    local LR_SELECTED_BUNDLE_URL="$LIFERAY_CDN_URL${LR_BUNDLES[$LR_BUNDLE_SELECTED_INDEX]}/$LR_SELECTED_BUNDLE"    
    wget -O $LR_SELECTED_BUNDLE_PATH $LR_SELECTED_BUNDLE_URL \
      && cp $LR_SELECTED_BUNDLE_PATH bundles/ \
      && local LR_BASE_DIR_NAME=$(unzip -Z -1 "bundles/$LR_SELECTED_BUNDLE" | head -1)
  else 
    cp $LR_SELECTED_BUNDLE_PATH bundles/ \
      && local LR_BASE_DIR_NAME=$(unzip -Z -1 "bundles/$LR_SELECTED_BUNDLE" | head -1)
  fi

  LR_HOME="$PROJECT_HOME/bundles/$LR_BASE_DIR_NAME"

  if [ -e "$LR_HOME" ]; then
    echo "Selected liferay bundle already setted up"
    rm "bundles/$LR_SELECTED_BUNDLE"
    exit 1
  fi

  unzip "bundles/$LR_SELECTED_BUNDLE" -d bundles &> /dev/null && rm "bundles/$LR_SELECTED_BUNDLE"

  createPortalExtFile
  createPortalDelevoerFile
  setupBundleDebugAndTunning

  setupDatabase

}

function start() {

  setLiferayHomeVariabiles
  $LIFERAY_TOMCAT_HOME/bin/startup.sh

}

function stop() {

  setLiferayHomeVariabiles
  $LIFERAY_TOMCAT_HOME/bin/shutdown.sh

}

function log() {

  setLiferayHomeVariabiles
  tail -f $LIFERAY_TOMCAT_HOME/logs/catalina.out

}

function process() {

  setLiferayHomeVariabiles

  local PROCESSES="$(ps -ef)"
  local FILTERED="$(echo "$PROCESSES" | grep "catalina.home=$LIFERAY_TOMCAT_HOME")"
  if [ -n "$FILTERED" ]; then    
    LIFERAY_PID="$(echo "$FILTERED" | tr -s " " | cut -f 2 -d " ")"    
  fi      

}

function info() {

  setLiferayHomeVariabiles
  echo "Project Home: $PROJECT_HOME"
  echo "Liferay Home: $LIFERAY_HOME"
  echo "Tomcat Home: $LIFERAY_TOMCAT_HOME"
  process
  echo "Liferay Pid: $LIFERAY_PID"

}

function status() {
  
  process

  if [ -z "$LIFERAY_PID" ]; then
     echo "Liferay is not running"
  else
    echo "Liferay is running with PID $LIFERAY_PID"
  fi  
}

function killLiferay() {
  process
  kill $LIFERAY_PID
}

while (( "$#" )); do
  case "$1" in
    info)    
      ACTION="info"
      shift 1
      ;;
    start)
      ACTION="start"
      shift 1
      ;;
    process)
      ACTION="process"
      shift 1
      ;;
    status)
      ACTION="status"
      shift 1
      ;;
    kill)
      ACTION="kill"
      shift 1
      ;;
    log)
      ACTION="log"
      shift 1
      ;;
    stop)
      ACTION="stop"
      shift 1
      ;;
    setup)
      ACTION="setup"
      shift 1
      ;;      
    gogo)
      ACTION="gogo"
      shift 1
      ;;
    --project-name)
      PROJECT_NAME=$2
      DATABASE_NAME=$PROJECT_NAME
      DATABASE_USERNAME=$PROJECT_NAME
      shift 2
      ;;
    --create-database)
      CREATE_DATABASE=1
      shift 1
      ;;
    --database-name)
      DATABASE_NAME=$2
      DATABASE_USERNAME=$DATABASE_NAME
      shift 2
      ;;
    --database-username)
      DATABASE_USERNAME=$2
      shift 2
      ;;
    --database-user-password)
      DATABASE_USER_PASSWORD=$2
      shift 2
      ;;
    -*|--*=)
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *)
      if [ "$0" != "bash" ]; then
        echo "No such command \"$1\"!"
        exit 1
      fi
    ;;
  esac
done

case "$ACTION" in
    info)    
      info
      ;;
    start)
      start      
      ;;
    process)
      process
      echo "$LIFERAY_PID"
      ;;
    status)
      status
      ;;
    kill)
      killLiferay
      ;;
    log)
      log
      ;;
    stop)
      stop
      ;;   
    idea)
      #open -a "$IDEA_APP" "$origin/workspace" 1>&2 &>/dev/null 1>&2 &>/dev/null &
      #"$IDEA_APP" "$origin/workspace" 1>&2 &>/dev/null 1>&2 &>/dev/null &
      #
      #if [[ "$LFR_ENV" != "$env_name" ]]; then
      # liferay "explore" "$env_name"
      #fi
      #
      #return 0
      ;;
    setup)
    
      echo "############# SETUP LIFERAY BUNDLE ###############"
      echo "Select Liferay bundle version (Lifera CE 7.0 ga7):"
      for i in "${!LR_BUNDLES[@]}"; do
        echo "$i: ${LR_BUNDLES[$i]}" 
      done
      read LR_BUNDLE_SELECTED_INDEX

      if [ -e "$lr_bundle_index" ]; then
        LR_BUNDLE_SELECTED_INDEX='5'
      fi

      setup #& show_spinner "$!"
      shift 1
      ;;      
    gogo)
      telnet localhost 11311
      return 0
      shift 1
      ;;
  esac