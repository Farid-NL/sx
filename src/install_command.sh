program=${args[program]}

print_header "Installing ${program}"

# Check in simple software
if [[ " ${simple_software[*]} " == *" ${program} "* ]]; then
  install_dnf_package "${program}"
  return
fi

# Check in custom software
if [[ " ${custom_software[*]} " == *" ${program} "* ]]; then
  "install_${program}"
  return
fi

print_error "Program '${program}' not found in the list."
exit 1
