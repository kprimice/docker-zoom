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

grant_access_to_video_devices() {
  for device in /dev/video*
  do
    if [[ -c $device ]]; then
      VIDEO_GID=$(stat -c %g $device)
      VIDEO_GROUP=$(stat -c %G $device)
      if [[ ${VIDEO_GROUP} == "UNKNOWN" ]]; then
        VIDEO_GROUP=skypevideo
        echo $VIDEO_GID
        sudo groupadd -g ${VIDEO_GID} ${VIDEO_GROUP}
      fi
      usermod -a -G ${VIDEO_GROUP} ${UNAME}
      break
    fi
  done
}

launch_zoom() {
  cd /home/${UNAME}
  exec sudo -HEu ${UNAME} QT_GRAPHICSSYSTEM="native" $@
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
    grant_access_to_video_devices
    launch_zoom $@
    ;;
  *)
    exec $@
    ;;
esac
