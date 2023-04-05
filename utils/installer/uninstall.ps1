#Requires -Version 7.1
$ErrorActionPreference = "Stop" # exit when command fails

# set script variables
$LV_BRANCH = $LV_BRANCH ?? "master"
$LV_REMOTE = $LV_REMOTE ?? "lunarvim/lunarvim.git"
$INSTALL_PREFIX = $INSTALL_PREFIX ?? "$HOME\.local"

$env:XDG_DATA_HOME = $env:XDG_DATA_HOME ?? $env:APPDATA
$env:XDG_CONFIG_HOME = $env:XDG_CONFIG_HOME ?? $env:LOCALAPPDATA
$env:XDG_CACHE_HOME = $env:XDG_CACHE_HOME ?? $env:TEMP

$env:NIL_RUNTIME_DIR = $env:NIL_RUNTIME_DIR ?? "$env:XDG_DATA_HOME\nil"
$env:NIL_BASE16_DIR = $env:NIL_BASE16_DIR ?? "$XDG_DATA_HOME/nil/site/pack/packer/start/base16/lua/base16/highlight"
$env:NIL_CONFIG_DIR = $env:NIL_CONFIG_DIR ?? "$env:XDG_CONFIG_HOME\nil"
$env:NIL_CACHE_DIR = $env:NIL_CACHE_DIR ?? "$env:XDG_CACHE_HOME\nil"
$env:NIL_BASE_DIR = $env:NIL_BASE_DIR ?? "$env:NIL_RUNTIME_DIR\nil"

$__nil_dirs = (
  $env:NIL_BASE_DIR,
  $env:NIL_BASE16_DIR,
  $env:NIL_RUNTIME_DIR,
  $env:NIL_CONFIG_DIR,
  $env:NIL_CACHE_DIR
)

function main($cliargs) {
  Write-Output "Removing Nil binary..."
  remove_nil_bin
  Write-Output "Removing Nil directories..."
  $force = $false
  if ($cliargs.Contains("--remove-backups")) {
    $force = $true
  }
  remove_nil_dirs $force
  Write-Output "Uninstalled Nil!"
}

function remove_nil_bin() {
  $nil_bin = "$INSTALL_PREFIX\bin\nil"
  if (Test-Path $nil_bin) {
    Remove-Item -Force $nil_bin
  }
  if (Test-Path alias:nil) {
    Write-Warning "Please make sure to remove the 'nil' alias from your `$PROFILE`: $PROFILE"
  }
}

function remove_nil_dirs($force) {
  foreach ($dir in $__nil_dirs) {
    if (Test-Path $dir) {
      Remove-Item -Force -Recurse $dir
    }
    if ($force -eq $true) {
      if (Test-Path "$dir.bak") {
        Remove-Item -Force -Recurse "$dir.bak"
      }
      if (Test-Path "$dir.old") {
        Remove-Item -Force -Recurse "$dir.old"
      }
    }
  }
}

main($args)
