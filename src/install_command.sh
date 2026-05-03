program=${args[program]}

print_header "Installing ${program}"

# Simple programs
if [[ " ${simple_software[*]} " == *" ${program} "* ]]; then
  install_dnf_package "${program}"
  return
fi

# Custom programs
case "${program}" in
  zoxide|\
  lazygit|\
  lazydocker|\
  code|\
  docker|\
  gh|\
  navi|\
  eza|\
  jetbrains-toolbox)
    eval "install_${program}"
    ;;

  *)
    echo "Program not in the list" >&2
    exit 1
    ;;
esac
