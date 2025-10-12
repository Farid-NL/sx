install_dnf_package() {
  if $(check_dnf_package "$1"); then
    echo "$1 already installed"
  else
    sudo dnf -y install --skip-unavailable "$1"
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
  if $(check_file "${HOME}/.local/bin/lazygit"); then
    echo "lazygit already installed"
  else
    local latest_version compressed_file github_url
    latest_version=$(curl -sLH 'Accept: application/json' https://github.com/jesseduffield/lazygit/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
    compressed_file="lazygit_${latest_version//v/}_Linux_x86_64.tar.gz"
    github_url="https://github.com/jesseduffield/lazygit/releases/download/${latest_version}/${compressed_file}"

    curl -sSLo lazygit.tar.gz "$github_url"
    tar xzf lazygit.tar.gz lazygit
    install -Dm 755 lazygit -t "${HOME}/.local/bin"
    rm lazygit lazygit.tar.gz
  fi
}

install_lazydocker() {
  if $(check_file "${HOME}/.local/bin/lazydocker"); then
    echo "lazydocker already installed"
  else
    local latest_version compressed_file github_url
    latest_version=$(curl -sLH 'Accept: application/json' https://github.com/jesseduffield/lazydocker/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
    compressed_file="lazydocker_${latest_version//v/}_Linux_x86_64.tar.gz"
    github_url="https://github.com/jesseduffield/lazydocker/releases/download/${latest_version}/${compressed_file}"

    curl -sSLo lazydocker.tar.gz "$github_url"
    tar xzf lazydocker.tar.gz lazydocker
    install -Dm 755 lazydocker -t "${HOME}/.local/bin"
    rm lazydocker lazydocker.tar.gz
  fi
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

install_jetbrains-toolbox() {
  if $(check_file "${HOME}/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox"); then
    echo "jetbrains-toolbox already installed"
  else
    wget -q --progress=bar:force:noscroll "https://data.services.jetbrains.com/products/download?platform=linux&code=TBA" -O /tmp/jetbrains-toolbox.tar.gz
    tar -xf /tmp/jetbrains-toolbox.tar.gz -C ~/Downloads --strip-components=1
    echo -e "\nAppimage extracted in ${HOME}/Downloads"
  fi
}
