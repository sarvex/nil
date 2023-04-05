#!/usr/bin/env bash
set -eo pipefail

ARGS_REMOVE_BACKUPS=0

declare -r XDG_DATA_HOME="${XDG_DATA_HOME:-"$HOME/.local/share"}"
declare -r XDG_CACHE_HOME="${XDG_CACHE_HOME:-"$HOME/.cache"}"
declare -r XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-"$HOME/.config"}"

declare -r NIL_RUNTIME_DIR="${NIL_RUNTIME_DIR:-"$XDG_DATA_HOME/nil"}"
declare -r NIL_CONFIG_DIR="${NIL_CONFIG_DIR:-"$XDG_CONFIG_HOME/nil"}"
declare -r NIL_CACHE_DIR="${NIL_CACHE_DIR:-"$XDG_CACHE_HOME/nil"}"

declare -a __nil_dirs=(
  "$NIL_CONFIG_DIR"
  "$NIL_RUNTIME_DIR"
  "$NIL_CACHE_DIR"
)

function usage() {
  echo "Usage: uninstall.sh [<options>]"
  echo ""
  echo "Options:"
  echo "    -h, --help                       Print this help message"
  echo "    --remove-backups                 Remove old backup folders as well"
}

function parse_arguments() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --remove-backups)
        ARGS_REMOVE_BACKUPS=1
        ;;
      -h | --help)
        usage
        exit 0
        ;;
    esac
    shift
  done
}

function remove_nil_dirs() {
  for dir in "${__nil_dirs[@]}"; do
    rm -rf "$dir"
    if [ "$ARGS_REMOVE_BACKUPS" -eq 1 ]; then
      rm -rf "$dir.{bak,old}"
    fi
  done
}

function remove_nil_bin() {
  local legacy_bin="/usr/local/bin/nil "
  if [ -x "$legacy_bin" ]; then
    echo "Error! Unable to remove $legacy_bin without elevation. Please remove manually."
    exit 1
  fi

  nil_bin="$(command -v nil 2>/dev/null)"
  rm -f "$nil_bin"
}

function main() {
  parse_arguments "$@"
  echo "Removing LunarVim binary..."
  remove_nil_bin
  echo "Removing LunarVim directories..."
  remove_nil_dirs
  echo "Uninstalled LunarVim!"
}

main "$@"
