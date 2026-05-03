# Colors
COLOR_RESTORE='\033[0m'
COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'
COLOR_BOLD='\033[1m'

print_info() {
  printf "${COLOR_BLUE}${COLOR_BOLD}🔹${COLOR_RESTORE} %s\n" "$1"
}

print_step() {
  printf "${COLOR_BLUE}${COLOR_BOLD}⚙️${COLOR_RESTORE} %s\n" "$1"
}

print_success() {
  printf "${COLOR_GREEN}✅ %s${COLOR_RESTORE}\n" "$1"
}

print_warning() {
  printf "${COLOR_YELLOW}⚠️  %s${COLOR_RESTORE}\n" "$1"
}

print_error() {
  printf "${COLOR_RED}❌ %s${COLOR_RESTORE}\n" "$1"
}

print_header() {
  printf "\n${COLOR_BLUE}${COLOR_BOLD}==> %s${COLOR_RESTORE}\n" "$1"
}
