# vim: set ft=zsh :


typeset -U path
path=(
  "${HOME}/.prefix/bin"
  "${HOME}/.prefix/sw/homebrew/bin"
  '/usr/local/bin'
  "${path[@]}"
)
export PATH


# Run resticprofile with our config file.
rp() {
  exec-resticprofile "${@}"
}

_rp-profile() {
  PROFILE="${1-"nidoking"}"
}

# Manually start backup (default profile "nidoking") and tail the backup log.
bk() {
  local PROFILE
  _rp-profile "${@}"

  launchctl kickstart "gui/${UID}/com.manselmi.resticprofile.${PROFILE}.backup" && bkl "${PROFILE}"
}

# Tail the backup log (default profile "nidoking").
bkl() {
  local PROFILE
  _rp-profile "${@}"

  tail -F -- "${HOME}/.config/resticprofile/log/${PROFILE}/backup.log"
}

# Log current backup progress.
# https://restic.readthedocs.io/en/latest/manual_rest.html?highlight=SIGUSR1
bkp() {
  pkill -USR1 -xu "${UID}" -- restic
}

# Pretty-print backup status file (default profile "nidoking").
bks() {
  local PROFILE
  _rp-profile "${@}"

  jq \
    --arg PROFILE "${PROFILE}" \
    '.profiles[$PROFILE]' \
    -- \
    "${HOME}/.config/resticprofile/status/${PROFILE}.json"
}

_rclone-mount() {
  local REMOTE

  if [[ -z "${1-}" ]]; then
    printf '%s\n' 'ERROR: _rclone-mount expects the name of an rclone remote' >&2
    return 1
  fi
  REMOTE="${1}"

  # https://rclone.org/commands/rclone_mount/#fuse-t-limitations-caveats-and-notes
  exec-rclone mount "${REMOTE}:" "/opt/rclone/mnt/${REMOTE}/" --read-only --volname="${REMOTE}"
}

# Mount rclone remote "gdrive" to /opt/rclone/mnt/gdrive/
mnt-gdrive() {
  _rclone-mount gdrive
}

# Start backup of rclone remote "gdrive" and tail the backup log.
bk-gdrive() {
  bk gdrive
}

# Mount rclone remote "onedrive" to /opt/rclone/mnt/onedrive/
mnt-onedrive() {
  _rclone-mount onedrive
}

# Start backup of rclone remote "onedrive" and tail the backup log.
bk-onedrive() {
  bk onedrive
}
