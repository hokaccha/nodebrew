# nodebrew

[![Build Status](https://travis-ci.org/hokaccha/nodebrew.svg?branch=master)](https://travis-ci.org/hokaccha/nodebrew)

Node.js version manager.

## Install

Install with curl.

```bash
$ curl -L git.io/nodebrew | perl - setup
```

Or, download and setup.

```bash
$ wget git.io/nodebrew
$ perl nodebrew setup
```

Add `PATH` setting your shell config file (`.bashrc` or `.zshrc`).

```
export PATH=$HOME/.nodebrew/current/bin:$PATH
```

Reload config.

```bash
$ source ~/.bashrc
```

Confirm.

```bash
$ nodebrew help
```

`NODEBREW_ROOT` (which indicates nodebrew's home directory) is configurable.
If you want to install nodebrew manually, please configure such as follows.

```
export NODEBREW_ROOT=/path/to/.nodebrew
```

The default value is `$HOME/.nodebrew`.

## Usage

### `nodebrew install-binary <version>`

Install Node.js.

```bash
$ nodebrew install-binary v0.10.29
install ...

# or
$ nodebrew install-binary latest # latest version
$ nodebrew install-binary stable # stable version
$ nodebrew install-binary v0.10.x # v0.10 latest
$ nodebrew install-binary 0.10.29  # without `v`
$ nodebrew install-binary io@v1.0.0 # io.js
```

### `nodebrew install <version>`

We recommend you to use `install-binary` command to install.
If you want to compile from source, you can use `install` command.

```bash
$ nodebrew install v0.10.29
```

Pass configure options to Node.js.

```bash
$ nodebrew install v0.11.14 --v8-options=--harmony
```

### `nodebrew use <version>`

Switch a version to use.

```bash
$ nodebrew use v0.10.29
$ node -v
v0.10.29

# or
$ nodebrew use latest # latest version
$ nodebrew use stable # stable version
$ nodebrew use v0.6.x # v0.6 latest
$ nodebrew use 0.10.29  # without `v`
```

### `nodebrew ls` or `nodebrew list`

List all installed versions.

```bash
$ nodebrew ls
v0.8.28
v0.10.29

current: v0.10.29
```

### `nodebrew ls-remote`

List remote versions.

```bash
$ nodebrew ls-remote
v0.0.1    v0.0.2    v0.0.3    v0.0.4    v0.0.5    v0.0.6    
...
```

### `nodebrew ls-all`

List installed and remote versions.

```bash
$ nodebrew ls-all
Remote:
v0.0.1    v0.0.2    v0.0.3    v0.0.4    v0.0.5    v0.0.6    
...

Local:
v0.8.28
v0.10.29

current: v0.10.29
```

### `nodebrew alias`

Set alias.

```bash
$ nodebrew alias default v0.8.28
default -> v0.8.28

$ nodebrew use default
use v0.8.28

$ nodebrew unalias default
remove default
```

### `nodebrew uninstall <version>`

Uninstall Node.js.

```bash
$ nodebrew uninstall v0.10.29
v0.10.29 uninstalled
```

### `nodebrew selfupdate`

Update nodebrew itself.

```bash
$ nodebrew selfupdate
```

### `nodebrew exec <version>`

Execute other version temporary.

```bash
$ nodebrew exec v0.10.29 -- node app.js
```

## All commands

```bash
$ nodebrew help                         Show this message
$ nodebrew install <version>            Download and install <version> (compile from source)
$ nodebrew install-binary <version>     Download and install <version> (binary file)
$ nodebrew uninstall <version>          Uninstall <version>
$ nodebrew use <version>                Use <version>
$ nodebrew list                         List installed versions
$ nodebrew ls                           Alias for `list`
$ nodebrew ls-remote                    List remote versions
$ nodebrew ls-all                       List remote and installed versions
$ nodebrew alias <key> <value>          Set alias
$ nodebrew unalias <key>                Remove alias
$ nodebrew clean <version> | all        Remove source file
$ nodebrew selfupdate                   Update nodebrew
$ nodebrew migrate-package <version>    Install global NPM packages contained in <version> to current version
$ nodebrew exec <version> -- <command>  Execute <command> using specified <version>
```

## Development

Install dependencies for testing.

```bash
$ carton install
```

Run test.

```bash
$ carton exec -- prove -lvr
```

## License

MIT © [Kazuhito Hokamura](https://github.com/hokaccha)
