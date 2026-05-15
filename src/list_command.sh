status=${args[--status]}

# Store the way a program status is checked
declare -A software_checkers

# Store the installation status of every program
declare -A software_status


populate_checkers() {
  # Add the 'custom software' checkers manually as they have specific file paths
  software_checkers=(
    [zoxide]="check_file ${HOME}/.local/bin/zoxide"
    [lazygit]="check_file ${HOME}/.local/bin/lazygit"
    [lazydocker]="check_file ${HOME}/.local/bin/lazydocker"
    [code]="check_dnf_package"
    [docker-ce]="check_dnf_package"
    [gh]="check_dnf_package"
    [navi]="check_file ${HOME}/.local/bin/navi"
    [eza]="check_file ${HOME}/.local/bin/eza"
    [jetbrains-toolbox]="check_file /opt/jetbrains-toolbox/bin/jetbrains-toolbox"
    [zellij]="check_file ${HOME}/.local/bin/zellij"
    [glow]="check_dnf_package"
    [brave-browser]="check_dnf_package"
    [vicinae]="check_dnf_package"
  )

  # Check if all software in custom_software is in software_checkers
  # If not (and it's not a special case like docker/docker-ce), we could add it here
  # For now, we keep the manual mapping for files and automatic for DNF

  # Add the 'simple software' to $software_checkers automatically
  for software in "${simple_software[@]}"; do
    software_checkers[$software]="check_dnf_package"
  done
}

populate_status() {
  populate_checkers

  for software in "${!software_checkers[@]}"; do
    local checker="${software_checkers[$software]}"

    if [[ "${checker}" != "check_dnf_package" ]]; then
      software_status["${software}"]=$(eval "${checker}")
    else
      software_status["${software}"]=$(eval "${checker}" "${software}")
    fi
  done
}

is_installed() {
  if "$1"; then
    echo "✅"
  else
    echo "❌"
  fi
}

if [[ "${status}" ]]; then
  populate_status

  printf "┌───────────────────┬────┐\n"
  for software in "${!software_status[@]}"; do
    local status="${software_status[$software]}"
    printf "│ %17s │ %s │\n" "${software}" "$(is_installed ${status})"
  done
  printf "└───────────────────┴────┘\n"

else
  populate_checkers

  for software in "${!software_checkers[@]}"; do
    print_info "${software}"
  done
fi
