# sx - Software installer

`sx` manages common software installation to all my Fedora machines

---

- [Usage](#usage)
- [Adding a new program](#adding-a-new-program)
  - [Simple programs](#simple-programs)
  - [Custom programs](#custom-programs)
- [Development](#development)

## Usage

```shell
# List all sofware available to install
sx ls
```

```shell
# List all software available and their installation status
sx ls -s
```

```shell
# Install a specific software
sx install <arg>
```

```shell
# Install all software
sx install-all
```

```shell
# Run remotely: bash ... [subcommand & flags]
bash <(wget -qO - https://raw.githubusercontent.com/Farid-NL/soft/refs/heads/main/sx) install-all
```

## Adding a new program

### Simple programs

> Programs that only need `sudo dnf -y <program-name>` command in order to be installed

Add the program name in `$simple_software` located in `src/lib/checkers.sh`

```shell
simple_software=(
  ...
  new-program
)
```

### Custom programs

> Programs that need more steps in order to be installed

1. See what checker function (`src/lib/checkers.sh`) use the program to check its installation status
2. Add a key-value pair in `$software_checkers` located in `src/list_command.sh`
    ```shell
    software_checkers=(
      [new-program1]="check_dnf_package"
      ...
      [new-program2]="check_file ${HOME}/.local/bin/new-program2"
    )
    ```
3. Add the commmands to install the program in a function named `install_<program-name>` in `src/lib/installers.sh`
    ```shell
    install_new-program1() {
      # Commands
    }

    install_new-program2() {
      # Commands
    }
    ```
4. Add a case for the program in the switch statement located in `src/install_command.sh`
    ```shell
    # Custom programs
    case "${program}" in
      new-program1|\
      new-program2|\
      ...
    esac
    ```
5. Add the function created in step 3 in the _Custom software_ section located in `src/install_all_command.sh`
    ```shell
    # Custom software
    install_new-program1
    install_new-program2
    ...
    ```

## Development

> The script was created with [bashly](https://bashly.dannyb.co/), a Bash framework.

1. Make sure that you have Docker installed
2. Create an alias for the bashly docker image:
    ```shell
    alias bashly='docker run --rm -it --user $(id -u):$(id -g) --volume "$PWD:/app" dannyben/bashly'
    ```
3. Run the following command to watch source changes and regenerate the main script `sx`
    ```shell
    bashly generate -w
    ```
