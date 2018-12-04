#!/bin/bash

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
      #open -a "$IDEA_APP" "$origin/workspace" 1>&2 &>/dev/null 1>&2 &>/dev/null &
#    "$IDEA_APP" "$origin/workspace" 1>&2 &>/dev/null 1>&2 &>/dev/null &

#      if [[ "$LFR_ENV" != "$env_name" ]]; then
#        liferay "explore" "$env_name"
#      fi

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
}
