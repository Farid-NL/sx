declare -a simple_software

# Programs that only need `sudo dnf -y install <program>`
# in order to be installed
simple_software=(
  git
  fzf
  eza
  git-delta
  bat
  bfs
  neovim
  yakuake
  fd-find
  ripgrep
)

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
