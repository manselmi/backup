# vim: set ft=zsh :


typeset -U path
path=(
  "${HOME}/.prefix/bin"
  "${HOME}/.prefix/sw/homebrew/bin"
  '/usr/local/bin'
  "${path[@]}"
)


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

  launchctl kickstart -- "gui/$(id -u)/com.manselmi.resticprofile.${PROFILE}.backup" && bkl "${PROFILE}"
}

# Tail the backup log (default profile "nidoking").
bkl() {
  local PROFILE
  _rp-profile "${@}"

  less +F --follow-name -- "${HOME}/.config/resticprofile/log/${PROFILE}/backup.log"
}

# Log current backup progress.
# https://restic.readthedocs.io/en/latest/manual_rest.html?highlight=SIGUSR1
bkp() {
  bksig USR1
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

# Signal restic processes with the specified signal.
bksig() {
  local SIGNAL

  if [[ -z "${1-}" ]]; then
    printf '%s\n' 'ERROR: bksig expects the name of a signal to send to restic processes' >&2
    return 1
  fi
  SIGNAL="${1}"

  sudo -n -- /usr/bin/pkill -"${SIGNAL}" -xu "0,$(id -u)" -- restic
}

_rclone-mount() {
  local REMOTE

  if [[ -z "${1-}" ]]; then
    printf '%s\n' 'ERROR: _rclone-mount expects the name of an rclone remote' >&2
    return 1
  fi
  REMOTE="${1}"

  # https://rclone.org/commands/rclone_mount/#fuse-t-limitations-caveats-and-notes
  # https://github.com/winfsp/cgofuse/blob/f87f5db493b56c5f4ebe482a1b7d02c7e5d572fa/fuse/host_cgo.go#L176
  exec-rclone mount "${REMOTE}:" "/opt/manselmi/rclone/mnt/${REMOTE}/" \
    --read-only \
    --volname="${REMOTE}"
}

# Mount rclone remote "gdrive" to /opt/manselmi/rclone/mnt/gdrive/
mnt-gdrive() {
  _rclone-mount gdrive
}

# Start backup of rclone remote "gdrive" and tail the backup log.
bk-gdrive() {
  bk gdrive
}

# Mount rclone remote "onedrive" to /opt/manselmi/rclone/mnt/onedrive/
mnt-onedrive() {
  _rclone-mount onedrive
}

# Start backup of rclone remote "onedrive" and tail the backup log.
bk-onedrive() {
  bk onedrive
}
