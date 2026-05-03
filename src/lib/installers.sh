install_dnf_package() {
  if $(check_dnf_package "$1"); then
    echo "$1 already installed"
  else
    sudo dnf -y install --skip-unavailable "$1"
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
    echo "${bin_name} already installed"
    return
  fi

  echo "Installing ${bin_name} from ${repo}..."

  local latest_version github_url temp_file
  latest_version=$(curl -sLH 'Accept: application/json' "https://github.com/${repo}/releases/latest" | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')

  # Replace placeholders in asset_pattern
  local asset_name=$(echo "${asset_pattern}" | sed "s/{{VERSION}}/${latest_version//v/}/g" | sed "s/{{V_VERSION}}/${latest_version}/g")
  github_url="https://github.com/${repo}/releases/download/${latest_version}/${asset_name}"
  temp_file=$(mktemp)

  if curl -sSLo "$temp_file" "$github_url"; then
    if [[ "$asset_name" == *.tar.gz ]]; then
      tar xzf "$temp_file" "$bin_name" 2>/dev/null || tar xzf "$temp_file"
      install -Dm 755 "$bin_name" -t "$target_dir"
      rm -f "$bin_name"
    else
      install -Dm 755 "$temp_file" "${target_dir}/${bin_name}"
    fi
    rm -f "$temp_file"
    echo "${bin_name} installed successfully"
  else
    echo "Error downloading ${bin_name}" >&2
    return 1
  fi
}

install_zoxide() {
  if $(check_file "${HOME}/.local/bin/zoxide"); then
    echo "zoxide already installed"
  else
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
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
    echo "code already installed"
  else
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
    dnf check-update
    sudo dnf -y install code
  fi
}

install_docker() {
  if $(check_dnf_package docker-ce); then
    echo "docker already installed"
  else
    sudo dnf -y install dnf-plugins-core dnf5-plugins
    sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker "$USER"
    newgrp docker
    sudo systemctl enable --now docker
  fi
}

install_gh() {
  if $(check_dnf_package gh); then
    echo "gh already installed"
  else
    sudo dnf -y install dnf-plugins-core dnf5-plugins
    sudo dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo
    sudo dnf install gh --repo gh-cli
  fi
}

install_navi() {
  if $(check_file "${HOME}/.local/bin/navi"); then
    echo "navi already installed"
  else
    BIN_DIR="$HOME/.local/bin" bash <(curl -sL https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install)
  fi
}

install_eza() {
  install_github_binary "eza-community/eza" "eza" "eza_x86_64-unknown-linux-gnu.tar.gz"
}

install_jetbrains-toolbox() {
  if $(check_file '/opt/jetbrains-toolbox/bin/jetbrains-toolbox'); then
    echo "jetbrains-toolbox already installed"
  else
    local temp_tar="/tmp/jetbrains-toolbox.tar.gz"
    wget -q --progress=bar:force:noscroll "https://data.services.jetbrains.com/products/download?platform=linux&code=TBA" -O "$temp_tar"
    mkdir -p ~/Downloads/jetbrains-toolbox_tmp
    tar -xf "$temp_tar" -C ~/Downloads/jetbrains-toolbox_tmp --strip-components=1
    sudo mkdir -p /opt/jetbrains-toolbox
    sudo mv ~/Downloads/jetbrains-toolbox_tmp/* /opt/jetbrains-toolbox/
    rm -rf ~/Downloads/jetbrains-toolbox_tmp "$temp_tar"
  fi
}
