install_dnf_package() {
  if $(check_dnf_package "$1"); then
    print_info "$1 already installed"
  else
    print_step "Installing $1 via DNF..."
    if sudo dnf -y install --skip-unavailable "$1" >> "$LOG_FILE" 2>&1; then
      print_success "$1 installed successfully"
    else
      print_error "Failed to install $1. Check $LOG_FILE for details."
      return 1
    fi
  fi
}

# Helper to install binaries from GitHub releases
# Usage: install_github_binary <repo> <binary_name> <asset_pattern>
#
# <asset_pattern> can use two placeholders for versioning:
#   {{VERSION}}   - The version number WITHOUT the leading 'v' (e.g., 0.40.2)
#   {{V_VERSION}} - The version number WITH the leading 'v' (e.g., v0.40.2)
#
# Example:
#   install_github_binary "jesseduffield/lazygit" "lazygit" "lazygit_{{VERSION}}_Linux_x86_64.tar.gz"
install_github_binary() {
  local repo=$1
  local bin_name=$2
  local asset_pattern=$3
  local target_dir="${HOME}/.local/bin"

  if $(check_file "${target_dir}/${bin_name}"); then
    print_info "${bin_name} already installed"
    return
  fi

  print_step "Fetching latest version for ${bin_name}..."

  local latest_version github_url temp_file
  latest_version=$(curl -sLH 'Accept: application/json' "https://github.com/${repo}/releases/latest" | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')

  # Replace placeholders in asset_pattern
  local asset_name=$(echo "${asset_pattern}" | sed "s/{{VERSION}}/${latest_version//v/}/g" | sed "s/{{V_VERSION}}/${latest_version}/g")
  github_url="https://github.com/${repo}/releases/download/${latest_version}/${asset_name}"
  temp_file=$(mktemp)

  print_step "Downloading ${bin_name} (${latest_version})..."
  if curl -sSLo "$temp_file" "$github_url" 2>> "$LOG_FILE"; then
    print_step "Extracting ${bin_name}..."
    {
      if [[ "$asset_name" == *.tar.gz ]]; then
        tar xzf "$temp_file" "$bin_name" 2>/dev/null || tar xzf "$temp_file"
        install -Dm 755 "$bin_name" -t "$target_dir"
        rm -f "$bin_name"
      else
        install -Dm 755 "$temp_file" "${target_dir}/${bin_name}"
      fi
    } >> "$LOG_FILE" 2>&1

    rm -f "$temp_file"
    print_success "${bin_name} installed successfully"
  else
    print_error "Error downloading ${bin_name}. Check $LOG_FILE"
    rm -f "$temp_file"
    return 1
  fi
}

install_zoxide() {
  if $(check_file "${HOME}/.local/bin/zoxide"); then
    print_info "zoxide already installed"
  else
    print_step "Installing zoxide..."
    if curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh >> "$LOG_FILE" 2>&1; then
      print_success "zoxide installed successfully"
    else
      print_error "Failed to install zoxide. Check $LOG_FILE"
      return 1
    fi
  fi
}

install_lazygit() {
  install_github_binary "jesseduffield/lazygit" "lazygit" "lazygit_{{VERSION}}_Linux_x86_64.tar.gz"
}

install_lazydocker() {
  install_github_binary "jesseduffield/lazydocker" "lazydocker" "lazydocker_{{VERSION}}_Linux_x86_64.tar.gz"
}

install_code() {
  if $(check_dnf_package code); then
    print_info "code already installed"
  else
    print_step "Adding VS Code repository..."
    {
      sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
      echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo
      dnf check-update || true
    } >> "$LOG_FILE" 2>&1
    
    print_step "Installing VS Code..."
    if sudo dnf -y install code >> "$LOG_FILE" 2>&1; then
      print_success "VS Code installed successfully"
    else
      print_error "Failed to install VS Code. Check $LOG_FILE"
      return 1
    fi
  fi
}

install_docker() {
  if $(check_dnf_package docker-ce); then
    print_info "docker already installed"
  else
    print_step "Installing Docker Engine..."
    {
      sudo dnf -y install dnf-plugins-core dnf5-plugins
      sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
      sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
      sudo usermod -aG docker "$USER"
      sudo systemctl enable --now docker
    } >> "$LOG_FILE" 2>&1
    
    if $(check_dnf_package docker-ce); then
      print_success "Docker installed successfully"
      print_warning "To use docker without sudo RIGHT NOW, run this command manually:"
      printf "  ${COLOR_BOLD}newgrp docker${COLOR_RESTORE}\n"
    else
      print_error "Failed to install Docker. Check $LOG_FILE"
      return 1
    fi
  fi
}

install_gh() {
  if $(check_dnf_package gh); then
    print_info "gh already installed"
  else
    print_step "Adding GitHub CLI repository..."
    {
      sudo dnf -y install dnf-plugins-core dnf5-plugins
      sudo dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo
    } >> "$LOG_FILE" 2>&1

    print_step "Installing GitHub CLI..."
    if sudo dnf install -y gh --repo gh-cli >> "$LOG_FILE" 2>&1; then
      print_success "GitHub CLI installed successfully"
    else
      print_error "Failed to install GitHub CLI. Check $LOG_FILE"
      return 1
    fi
  fi
}

install_navi() {
  if $(check_file "${HOME}/.local/bin/navi"); then
    print_info "navi already installed"
  else
    print_step "Installing navi..."
    if BIN_DIR="$HOME/.local/bin" bash <(curl -sL https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install) >> "$LOG_FILE" 2>&1; then
      print_success "navi installed successfully"
    else
      print_error "Failed to install navi. Check $LOG_FILE"
      return 1
    fi
  fi
}

install_eza() {
  install_github_binary "eza-community/eza" "eza" "eza_x86_64-unknown-linux-gnu.tar.gz"
}

install_jetbrains-toolbox() {
  if $(check_file '/opt/jetbrains-toolbox/bin/jetbrains-toolbox'); then
    print_info "jetbrains-toolbox already installed"
  else
    print_step "Downloading JetBrains Toolbox..."
    local temp_tar="/tmp/jetbrains-toolbox.tar.gz"
    {
      wget -q --progress=bar:force:noscroll "https://data.services.jetbrains.com/products/download?platform=linux&code=TBA" -O "$temp_tar"
      mkdir -p ~/Downloads/jetbrains-toolbox_tmp
      tar -xf "$temp_tar" -C ~/Downloads/jetbrains-toolbox_tmp --strip-components=1
      sudo mkdir -p /opt/jetbrains-toolbox
      sudo mv ~/Downloads/jetbrains-toolbox_tmp/* /opt/jetbrains-toolbox/
    } >> "$LOG_FILE" 2>&1
    
    rm -rf ~/Downloads/jetbrains-toolbox_tmp "$temp_tar"
    
    if $(check_file '/opt/jetbrains-toolbox/bin/jetbrains-toolbox'); then
      print_success "JetBrains Toolbox installed in /opt/jetbrains-toolbox"
    else
      print_error "Failed to install JetBrains Toolbox. Check $LOG_FILE"
      return 1
    fi
  fi
}
