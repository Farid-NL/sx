# Simple software
for software in "${simple_software[@]}"; do
  install_dnf_package "${software}"
done

# Custom software
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
)

for software in "${custom_software[@]}"; do
  "install_${software}"
done

