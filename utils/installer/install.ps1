#Requires -Version 7.1
$ErrorActionPreference = "Stop" # exit when command fails

# set script variables
$NIL_BRANCH = $NIL_BRANCH ?? "main"
$NIL_REMOTE = $NIL_REMOTE ?? "nil-lua/nil.git"
$INSTALL_PREFIX = $INSTALL_PREFIX ?? "$HOME\.local"

$env:XDG_DATA_HOME = $env:XDG_DATA_HOME ?? $env:APPDATA
$env:XDG_CONFIG_HOME = $env:XDG_CONFIG_HOME ?? $env:LOCALAPPDATA
$env:XDG_CACHE_HOME = $env:XDG_CACHE_HOME ?? $env:TEMP

$env:NIL_RUNTIME_DIR = $env:NIL_RUNTIME_DIR ?? "$env:XDG_DATA_HOME/nil"
$env:NIL_BASE16_DIR= $env:NIL_BASE16_DIR ?? "$XDG_DATA_HOME/nil/site/pack/packer/start/base16/lua/base16/highlight"
$env:NIL_CONFIG_DIR = $env:NIL_CONFIG_DIR ?? "$env:XDG_CONFIG_HOME/nil"
$env:NIL_CACHE_DIR = $env:NIL_CACHE_DIR ?? "$env:XDG_CACHE_HOME/nil"
$env:NIL_BASE_DIR = $env:NIL_BASE_DIR ?? "$env:NIL_RUNTIME_DIR/nil"

$env:NIL_LOG_LEVEL= $env:NIL_LOG_LEVEL ?? "warn"

$__nil_dirs = (
  $env:NIL_BASE_DIR,
  $env:NIL_RUNTIME_DIR,
  $env:NIL_BASE16_DIR,
  $env:NIL_CONFIG_DIR,
  $env:NIL_CACHE_DIR
)

function __add_separator($div_width) {
  "-" * $div_width
  Write-Output ""
}

function msg($text) {
  Write-Output $text
  __add_separator "80"
}

function main($cliargs) {

  print_logo

  verify_nil_dirs

  if ($cliargs.Contains("--overwrite")) {
    Write-Output "!!Warning!! -> Removing all nil related config because of the --overwrite flag"
    $answer = Read-Host "Would you like to continue? [y]es or [n]o "
    if ("$answer" -ne "y" -and "$answer" -ne "Y") {
      exit 1
    }
    uninstall_nil
  }
  if ($cliargs.Contains("--local") -or $cliargs.Contains("--testing")) {
    msg "Using local Nil installation"
    local_install
    exit
  }

  msg "Checking dependencies.."
  check_system_deps

  $answer = Read-Host "Would you like to check Nil's NodeJS dependencies? [y]es or [n]o (default: no) "
  if ("$answer" -eq "y" -or "$answer" -eq "Y") {
    install_nodejs_deps
  }

  $answer = Read-Host "Would you like to check Nil's Python dependencies? [y]es or [n]o (default: no) "
  if ("$answer" -eq "y" -or "$answer" -eq "Y") {
    install_python_deps
  }

  $answer = Read-Host "Would you like to check Nil's Rust dependencies? [y]es or [n]o (default: no) "
  if ("$answer" -eq "y" -or "$answer" -eq "Y") {
    install_rust_deps
  }


  if (Test-Path "$env:NIL_BASE_DIR\init.lua" ) {
    msg "Updating Nil"
    validate_nil_files
  }
  else {
    msg "Cloning Nil"
    clone_nil
    setup_nil
  }
}

function print_missing_dep_msg($dep) {
  Write-Output "[ERROR]: Unable to find dependency [$dep]"
  Write-Output "Please install it first and re-run the installer."
}

$winget_package_matrix = @{"git" = "Git.Git"; "nvim" = "Neovim.Neovim"; "make" = "GnuWin32.Make"; "node" = "OpenJS.NodeJS"; "pip" = "Python.Python.3" }
$scoop_package_matrix = @{"git" = "git"; "nvim" = "neovim-nightly"; "make" = "make"; "node" = "nodejs"; "pip" = "python3" }

function install_system_package($dep) {
  if (Get-Command -Name "winget" -ErrorAction SilentlyContinue) {
    Write-Output "Attempting to install dependency [$dep] with winget"
    $install_cmd = "winget install --interactive $winget_package_matrix[$dep]"
  }
  elseif (Get-Command -Name "scoop" -ErrorAction SilentlyContinue) {
    Write-Output "Attempting to install dependency [$dep] with scoop"
    # TODO: check if it's fine to not run it with --global
    $install_cmd = "scoop install $scoop_package_matrix[$dep]"
  }
  else {
    print_missing_dep_msg "$dep"
    exit 1
  }

  try {
    Invoke-Command $install_cmd -ErrorAction Stop
  }
  catch {
    print_missing_dep_msg "$dep"
    exit 1
  }
}

function check_system_dep($dep) {
  try {
    Get-Command -Name $dep -ErrorAction Stop | Out-Null
  }
  catch {
    install_system_package "$dep"
  }
}

function check_system_deps() {
  check_system_dep "git"
  check_system_dep "nvim"
  check_system_dep "make"
}

function install_nodejs_deps() {
  $dep = "node"
  try {
    check_system_dep "$dep"
    Invoke-Command -ScriptBlock { npm install --global neovim tree-sitter-cli } -ErrorAction Break
  }
  catch {
    print_missing_dep_msg "$dep"
  }
}

function install_python_deps() {
  $dep = "pip"
  try {
    check_system_dep "$dep"
    Invoke-Command -ScriptBlock { python -m pip install --user pynvim } -ErrorAction Break
  }
  catch {
    print_missing_dep_msg "$dep"
  }
}
function install_rust_deps() {
  $dep = "cargo"
  try {
    check_system_dep "$dep"
    Invoke-Command -ScriptBlock { cargo install fd::fd-find rg::ripgrep } -ErrorAction Break
  }
  catch {
    print_missing_dep_msg "$dep"
  }
}

function backup_old_config() {
  $src = "$env:NIL_CONFIG_DIR"
  if (Test-Path $src) {
    New-Item "$src.old" -ItemType Directory -Force | Out-Null
    Copy-Item -Force -Recurse "$src\*" "$src.old\." | Out-Null
  }
  msg "Backup operation complete"
}


function local_install() {
  verify_nil_dirs
  $repoDir = git rev-parse --show-toplevel
  $gitLocalCloneCmd = git clone --progress "$repoDir" "$env:NIL_BASE_DIR"
  Invoke-Command -ErrorAction Stop -ScriptBlock { $gitLocalCloneCmd; setup_nil }
}

function clone_nil() {
  try {
    $gitCloneCmd = git clone --progress --depth 1 --branch "$NIL_BRANCH" `
      "https://github.com/$NIL_REMOTE" `
      "$env:NIL_BASE_DIR"
    Invoke-Command -ErrorAction Stop -ScriptBlock { $gitCloneCmd }
  }
  catch {
    msg "Failed to clone repository. Installation failed."
    exit 1		
  }
}

function setup_shim() {
  if ((Test-Path "$INSTALL_PREFIX\bin") -eq $false) {
    New-Item "$INSTALL_PREFIX\bin" -ItemType Directory | Out-Null
  }

  Copy-Item -Force "$env:NIL_BASE_DIR\utils\bin\nil.ps1" "$INSTALL_PREFIX\bin\nil.ps1"
}

function uninstall_nil() {
  foreach ($dir in $__nil_dirs) {
    if (Test-Path "$dir") {
      Remove-Item -Force -Recurse "$dir"
    }
  }
}

function verify_nil_dirs() {
  foreach ($dir in $__nil_dirs) {
    if ((Test-Path "$dir") -eq $false) {
      New-Item "$dir" -ItemType Directory | Out-Null
    }
  }
  backup_old_config
}


function setup_nil() {
  msg "Installing Nil shim"
  setup_shim

  msg "Installing sample configuration"

  if (Test-Path "$env:NIL_CONFIG_DIR\config.lua") {
    Move-Item "$env:NIL_CONFIG_DIR\config.lua" "$env:NIL_CONFIG_DIR\config.lua.old"
  }

  New-Item -ItemType File -Path "$env:NIL_CONFIG_DIR\config.lua" | Out-Null

  $exampleConfig = "$env:NIL_BASE_DIR\utils\installer\config_win.example.lua"
  Copy-Item -Force "$exampleConfig" "$env:NIL_CONFIG_DIR\config.lua"

  Write-Host "Make sure to run `:PackerSync` at first launch" -ForegroundColor Green

  create_alias

  msg "Thank you for installing Nil!!"

  Write-Output "You can start it by running: $INSTALL_PREFIX\bin\nil.ps1"
  Write-Output "Do not forget to use a font with glyphs (icons) support [https://github.com/ryanoasis/nerd-fonts]"
}


function validate_nil_files() {
  Set-Alias nil "$INSTALL_PREFIX\bin\nil.ps1"
  try {
    $verify_version_cmd = "if v:errmsg != \`"\`" | cquit | else | quit | endif"
    Invoke-Command -ScriptBlock { nil --headless -c 'NilUpdate' -c "$verify_version_cmd" } -ErrorAction SilentlyContinue
  }
  catch {
    Write-Output "Unable to guarantee data integrity while updating. Please run `:NilUpdate` manually instead."
    exit 1
  }
  Write-Output "Your Nil installation is now up to date!"
}

function create_alias {
  try {
    $answer = Read-Host $(`
        "Would you like to create an alias inside your Powershell profile?`n" + `
        "(This enables you to start nil with the command 'nil') [y]es or [n]o (default: no)" )
  }
  catch {
    msg "Non-interactive mode detected. Skipping alias creation"
    return
  }

  if ("$answer" -ne "y" -or "$answer" -ne "Y") {
    return
  }

  $nil_bin = "$INSTALL_PREFIX\bin\nil.ps1"
  $nil_alias = Get-Alias nil -ErrorAction SilentlyContinue

  if ($nil_alias.Definition -eq $nil_bin) {
    Write-Output "Alias is already set and will not be reset."
    return
  }

  try {
    Get-Content $PROFILE -ErrorAction Stop
  }
  catch {
    New-Item -Path $PROFILE -ItemType "file" -Force
  }

  Add-Content -Path $PROFILE -Value $("`r`nSet-Alias nil '$nil_bin'")

  Write-Host 'To use the new alias in this window reload your profile with: `. $PROFILE`' -ForegroundColor Green
}

function print_logo() {
  Write-Output "

⠘⢵⢕⢽⡸⣕⢵⢝⡄⠀⠑⡽⡸⡄⠹⡜⣝⡄⠀⠀⠀⠀⠀⡔⡽⡸⠁
⠀⠈⣗⡳⣉⠈⠸⣕⢝⣄⠀⠘⣝⢮⣂⠙⣜⢮⢆⠀⠀⢀⢜⡎⡗⠁ 
⠀⠀⠐⢝⢼⢄⠀⠘⡵⣕⢆⠀⠘⣎⢮⢆⠘⡎⡗⡧⡀⣎⢧⡫⠀  
   ⠈⢳⡹⣢⠀⠘⢮⢝⢦⠀⠈⢮⢳⡱⡈⢗⡕⣗⢕⠇⠀⠀  
   ⠀⠀⢫⢮⣢⠀⠈⢮⢳⢕⡀⠈⢧⢳⢕⡀⢯⢪⠋⠀    
   ⠀⠀⠀⢣⡳⣕⡀⠈⢣⢗⢵⡀⠈⢮⢳⡱⡀⠋⠀     
    ⠀⠀⠀⠱⡵⣱⡀⠀⢫⣣⢳⢄⢠⡳⣹⠕⠀      
   ⠀⠀⠀⠀⠀⠹⣜⢼⡀⠀⠪⡳⡕⣗⢝⠊⠀       
         ⠘⡮⡺⡄⠀⠙⡼⣪⠃         
         ⠀⠘⡵⡝⣆⠀⠘⠁          
         ⠀⠀⠘⡺⡜⣆⠀           
            ⠈⢞⠁            

  "
}

main "$args"
