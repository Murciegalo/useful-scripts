#!/bin/bash

LIFERAY_CDN_URL="https://cdn.lfrs.sl/releases.liferay.com/portal/"

#TODO da migliorare le varie versione dei bundles devono poter essere presi dinamicamente dal CDN liferay
LR_BUNDLES=('7.0.1-ga2' '7.0.2-ga3' '7.0.3-ga4' '7.0.4-ga5' '7.0.5-ga6' '7.0.6-ga7' '7.1.0-ga1' '7.1.1-ga2')
LR_BUNDLES_VERSION_NUMBER=('7.0-ga2-20160610113014153.zip' '7.0-ga3-20160804222206210.zip' '7.0-ga4-20170613175008905.zip' '7.0-ga5-20171018150113838.zip' '7.0-ga6-20180320170724974.zip' '7.0-ga7-20180507111753223.zip' '7.1-ga1-20180703012531655.zip' '7.1-ga2-20181112144637000.tar.gz')

PROJECT_HOME=${pwd}
LR_BUNDLES_REPOSITORY="/work/bundles/liferay/"
LR_BUNDLE_PREFIX="liferay-ce-portal-tomcat-"

setup() {

#  local version_page=$(curl --location --silent $LIFERAY_CDN_URL)
#  echo $version_page

  echo "Select Liferay bundle version (Lifera CE 7.0 ga7):"
  for i in "${!LR_BUNDLES[@]}"; do
    echo "$i: ${LR_BUNDLES[$i]}" 
  done
  read LR_BUNDLE_SELECTED_INDEX

  if [ -e "$lr_bundle_index" ]; then
    LR_BUNDLE_SELECTED_INDEX='5'
  fi

  LR_SELECTED_BUNDLE="$LR_BUNDLE_PREFIX${LR_BUNDLES_VERSION_NUMBER[$LR_BUNDLE_SELECTED_INDEX]}"
  LR_SELECTED_BUNDLE_PATH=$LR_BUNDLES_REPOSITORY$LR_SELECTED_BUNDLE

  mkdir -p bundles
  
  if [ ! -e "$LR_SELECTED_BUNDLE_PATH" ]; then
    LR_SELECTED_BUNDLE_URL="$LIFERAY_CDN_URL${LR_BUNDLES[$LR_BUNDLE_SELECTED_INDEX]}/$LR_SELECTED_BUNDLE"    
    wget -O $LR_SELECTED_BUNDLE_PATH $LR_SELECTED_BUNDLE_URL \
      && cp $LR_SELECTED_BUNDLE_PATH bundles/ \
      && local LR_BASE_DIR_NAME=$(unzip -Z -1 "bundles/$LR_SELECTED_BUNDLE" | head -1)
  else 
    cp $LR_SELECTED_BUNDLE_PATH bundles/ \
      && local LR_BASE_DIR_NAME=$(unzip -Z -1 "bundles/$LR_SELECTED_BUNDLE" | head -1)
  fi

  unzip "bundles/$LR_SELECTED_BUNDLE" -d bundles &> /dev/null && rm "bundles/$LR_SELECTED_BUNDLE"

  LR_HOME="bundles/$LR_BASE_DIR_NAME"

  echo $LR_HOME
}

case "$1" in
  info)
#      echo "Liferay location: $liferay_location"
#      echo "Tomcat location: $tomcat_location"
#      echo "Inferred DB name: $dbname"
#      return 0
    ;;
  license)
#      cp "${LICENSE_FILE}" "${origin}/${lfr}/deploy"
#      return 0
    ;;
  start)
#      $tomcat_location/bin/startup.sh
#      liferay "log" $2
#      return 0
    ;;
  process)
#      local processes="$(ps -ef)"
#      local filtered="$(echo "$processes" | grep "catalina.home=$tomcat_location")"
#      if [ -z "$filtered" ]; then
#        echo ""
#      else
#        local the_pid="$(echo "$filtered" | tr -s " " | cut -f 3 -d " ")"
#        echo "$the_pid"
#      fi
#      return 0
    ;;
  status)
#      local the_pid="$(liferay process "$env_name")"
#      if [ -z "$the_pid" ]; then
#        echo "Liferay is not running"
#      else
#        echo "Liferay is running with PID $the_pid"
#      fi
#      return 0
    ;;
  kill)
#      echo "Not implemented"
#      return 0
    ;;
  log)
#      tail -n 0 -f "${tomcat_location}/logs/catalina.out"
#      return 0
    ;;
  stop)
#      $tomcat_location/bin/shutdown.sh
#      return 0
    ;;
  watch)
#      watch --no-title --interval 1 liferay status "$env_name"
#     return 0
    ;;
  idea)
#     open -a "$IDEA_APP" "$origin/workspace" 1>&2 &>/dev/null 1>&2 &>/dev/null &
#    "$IDEA_APP" "$origin/workspace" 1>&2 &>/dev/null 1>&2 &>/dev/null &
#
#      if [[ "$LFR_ENV" != "$env_name" ]]; then
#        liferay "explore" "$env_name"
#      fi
#
#      return 0
    ;;
  setup)

    setup
#     open -a "$IDEA_APP" "$origin/workspace" 1>&2 &>/dev/null 1>&2 &>/dev/null &
#    "$IDEA_APP" "$origin/workspace" 1>&2 &>/dev/null 1>&2 &>/dev/null &
#
#      if [[ "$LFR_ENV" != "$env_name" ]]; then
#        liferay "explore" "$env_name"
#      fi
#
#      return 0
    ;;      
  gogo)
    telnet localhost 11311
    return 0
    ;;
  *)
    if [ "$0" != "bash" ]; then
      echo "No such command \"$1\"!"
    fi
  ;;
esac