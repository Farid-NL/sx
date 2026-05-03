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

Add the program name to the `simple_software` array located in `src/lib/checkers.sh`.

```shell
simple_software=(
  ...
  new-program
)
```

### Custom programs

> Programs that need more steps or custom logic (e.g., GitHub binaries) in order to be installed

1. **Register the program**: Add the program name to the `custom_software` array in `src/lib/checkers.sh`.
2. **Implement the installer**: Create a function named `install_<program-name>` in `src/lib/installers.sh`.
    *   **Pro Tip**: Use the `install_github_binary` helper if the software is hosted on GitHub.
    ```shell
    install_new-program() {
      install_github_binary "author/repo" "bin-name" "asset-pattern_{{VERSION}}_Linux.tar.gz"
    }
    ```
3. **Add status checker (Optional)**: If you want the program to show up correctly in `sx ls -s`, add its check rule in the `populate_checkers` function within `src/list_command.sh`.
    ```shell
    software_checkers+=(
      [new-program]="check_file ${HOME}/.local/bin/new-program"
    )
    ```

*Note: You no longer need to update `install_command.sh` or `install_all_command.sh` manually, as they now handle the lists dynamically.*

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
