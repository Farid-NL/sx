declare -a simple_software

# Programs that only need `sudo dnf -y install <program>`
# in order to be installed
simple_software=(
  git
  fzf
  git-delta
  bat
  bfs
  neovim
  yakuake
  fd-find
  ripgrep
)

# Programs that need custom installation logic
custom_software=(
  zoxide
  lazygit
  lazydocker
  code
  docker
  gh
  navi
  eza
  jetbrains-toolbox
  zellij
  glow
)

# Paths
LOG_FILE="/tmp/sx.log"

# Initial validations
init_log() {
  # Aseguramos que el log sea escribible si ya existe
  touch "$LOG_FILE" 2>/dev/null || sudo rm -f "$LOG_FILE"
  echo "--- sx log start: $(date) ---" > "$LOG_FILE"
  print_info "Logs are being saved to $LOG_FILE"
}

check_dependencies() {
  local dependencies=(curl wget tar dnf sed mktemp)
  local missing=()

  for dep in "${dependencies[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
      missing+=("$dep")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    print_error "The following dependencies are missing: ${missing[*]}"
    print_error "Please install them before running sx."
    exit 1
  fi
}

check_sudo() {
  if ! sudo -v &> /dev/null; then
    print_error "This script requires sudo privileges to install software."
    print_error "Please make sure your user is in the sudoers group."
    exit 1
  fi

  # Keep-alive: update existing sudo time stamp every 60 seconds.
  ( while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done ) 2>/dev/null &
  SUDO_KEEPALIVE_PID=$!

  # Ensure the keep-alive process is killed when the script exits
  trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null' EXIT
}

validate_environment() {
  check_dependencies
  check_sudo
}

check_dnf_package() {
  if dnf -C list --installed "$1" 2> /dev/null > /dev/null; then
    echo true
  else
    echo false
  fi
}

check_file() {
  if [ -f "$1" ]; then
    echo true
  else
    echo false
  fi
}
