# Simple software
for software in "${simple_software[@]}"; do
  install_dnf_package "${software}"
done

# Custom software
install_zoxide
install_lazygit
install_lazydocker
install_code
install_docker
install_gh
install_navi
install_jetbrains-toolbox
