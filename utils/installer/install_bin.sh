#!/usr/bin/env bash
set -eo pipefail

INSTALL_PREFIX="${INSTALL_PREFIX:-"$HOME/.local"}"

XDG_DATA_HOME="${XDG_DATA_HOME:-"$HOME/.local/share"}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-"$HOME/.cache"}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-"$HOME/.config"}"

NIL_RUNTIME_DIR="${NIL_RUNTIME_DIR:-"$XDG_DATA_HOME/nil"}"
NIL_BASE16_DIR="${NIL_BASE16_DIR:-"$XDG_DATA_HOME/nil/site/pack/packer/start/base16/lua/base16/highlight"}"
NIL_CONFIG_DIR="${NIL_CONFIG_DIR:-"$XDG_CONFIG_HOME/nil"}"
NIL_CACHE_DIR="${NIL_CACHE_DIR:-"$XDG_CACHE_HOME/nil"}"

NIL_BASE_DIR="${NIL_BASE_DIR:-"$NIL_RUNTIME_DIR/nil"}"

function setup_shim() {
  local src="$NIL_BASE_DIR/utils/bin/nil.template"
  local dst="$INSTALL_PREFIX/bin/nil"

  [ ! -d "$INSTALL_PREFIX/bin" ] && mkdir -p "$INSTALL_PREFIX/bin"

  # remove outdated installation so that `cp` doesn't complain
  rm -f "$dst"

  cp "$src" "$dst"

  sed -e s"#RUNTIME_DIR_VAR#\"${NIL_RUNTIME_DIR}\"#"g \
    -e s"#BASE16_DIR_VAR#\"${NIL_BASE16_DIR}\"#"g \
    -e s"#CONFIG_DIR_VAR#\"${NIL_CONFIG_DIR}\"#"g \
    -e s"#CACHE_DIR_VAR#\"${NIL_CACHE_DIR}\"#"g "$src" \
    | tee "$dst" >/dev/null

  chmod u+x "$dst"
}

setup_shim "$@"

echo "You can start NIL by running: $INSTALL_PREFIX/bin/nil"
