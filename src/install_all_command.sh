print_header "Installing Standard Packages (DNF)"
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

print_header "Installing Custom Packages"
for software in "${custom_software[@]}"; do
  "install_${software}"
done

echo -e "\n${COLOR_GREEN}${COLOR_BOLD}✨ All installations finished!${COLOR_RESTORE}\n"

