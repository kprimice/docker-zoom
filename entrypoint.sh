#!/bin/bash
set -e

USER_UID=${USER_UID:-1000}
USER_GID=${USER_GID:-1000}

install_zoom() {
  echo "Installing zoom-wrapper..."
  install -m 0755 /var/cache/zoom/zoom-wrapper /target/
  echo "Installing zoom..."
  ln -sf zoom-wrapper /target/zoom
}

uninstall_zoom() {
  echo "Uninstalling zoom-wrapper..."
  rm -rf /target/zoom-wrapper
  echo "Uninstalling zoom..."
  rm -rf /target/zoom
}

create_user() {
  # create group with USER_GID
  if ! getent group ${APP_USER} >/dev/null; then
    groupadd -f -g ${USER_GID} ${APP_USER} >/dev/null 2>&1
  fi

  # create user with USER_UID
  if ! getent passwd ${APP_USER} >/dev/null; then
    adduser --disabled-login --uid ${USER_UID} --gid ${USER_GID} \
      --gecos 'Slack' ${APP_USER} >/dev/null 2>&1
  fi
  chown ${APP_USER}:${APP_USER} -R /home/${APP_USER}
}

grant_access_to_video_devices() {
  for device in /dev/video*
  do
    if [[ -c $device ]]; then
      VIDEO_GID=$(stat -c %g $device)
      VIDEO_GROUP=$(stat -c %G $device)
      if [[ ${VIDEO_GROUP} == "UNKNOWN" ]]; then
        VIDEO_GROUP=skypevideo
        groupadd -g ${VIDEO_GID} ${VIDEO_GROUP}
      fi
      usermod -a -G ${VIDEO_GROUP} ${APP_USER}
      break
    fi
  done
}

launch_zoom() {
  cd /home/${APP_USER}
  PULSE_SERVER=/run/pulse/native QT_GRAPHICSSYSTEM="native" $@
}

case "$1" in
  install)
    # create_user
    install_zoom
    ;;
  uninstall)
    uninstall_zoom
    ;;
	zoom)
    # create_user
    # grant_access_to_video_devices
    launch_zoom $@
    ;;
  *)
    exec $@
    ;;
esac
