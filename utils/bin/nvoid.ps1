#Requires -Version 7.1
$ErrorActionPreference = "Stop" # exit when command fails

$env:XDG_DATA_HOME = $env:XDG_DATA_HOME ?? $env:APPDATA
$env:XDG_CONFIG_HOME = $env:XDG_CONFIG_HOME ?? $env:LOCALAPPDATA
$env:XDG_CACHE_HOME = $env:XDG_CACHE_HOME ?? $env:TEMP

$env:NIL_RUNTIME_DIR = $env:NIL_RUNTIME_DIR ?? "$env:XDG_DATA_HOME\nil"
$env:NIL_CONFIG_DIR = $env:NIL_CONFIG_DIR ?? "$env:XDG_CONFIG_HOME\nil"
$env:NIL_CACHE_DIR = $env:NIL_CACHE_DIR ?? "$env:XDG_CACHE_HOME\nil"
$env:NIL_BASE_DIR = $env:NIL_BASE_DIR ?? "$env:NIL_RUNTIME_DIR\nil"

nvim -u "$env:NIL_BASE_DIR\init.lua" @args