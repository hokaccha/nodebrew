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

### `nodebrew install <version>`

Install Node.js.

```bash
$ nodebrew install v8.9.4

# or
$ nodebrew install latest # latest version
$ nodebrew install stable # stable version
$ nodebrew install v8.9   # v8.9 latest
$ nodebrew install 8.9.4  # without `v`
```

### `nodebrew compile <version>`

If you want to compile from source, you can use `compile` command.

```bash
$ nodebrew compile v8.9.4
```

Pass configure options to Node.js.

```bash
$ nodebrew compile v8.9.4 --v8-options=--harmony
```

### `nodebrew use <version>`

Switch a version to use.

```bash
$ nodebrew use v8.9.4
$ node -v
v8.9.4

# or
$ nodebrew use latest # latest version
$ nodebrew use stable # stable version
$ nodebrew use v8.9   # v8.9 latest
$ nodebrew use 8.9.4  # without `v`
```

### `nodebrew ls` or `nodebrew list`

List all installed versions.

```bash
$ nodebrew ls
v8.9.9
v8.9.4

current: v8.9.4
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
v8.9.0
v8.9.4

current: v8.9.4
```

### `nodebrew alias`

Set alias.

```bash
$ nodebrew alias default v8.9.4
default -> v8.9.4

$ nodebrew use default
use v8.9.4

$ nodebrew unalias default
remove default
```

### `nodebrew uninstall <version>`

Uninstall Node.js.

```bash
$ nodebrew uninstall v8.9.4
v8.9.4 uninstalled
```

### `nodebrew selfupdate`

Update nodebrew itself.

```bash
$ nodebrew selfupdate
```

### `nodebrew exec <version>`

Execute other version temporary.

```bash
$ nodebrew exec v8.9.4 -- node app.js
```

## All commands

```bash
$ nodebrew help                         Show this message
$ nodebrew install <version>            Download and install <version> (from binary)
$ nodebrew compile <version>            Download and install <version> (from source)
$ nodebrew install-binary <version>     Alias of `install` (For backward compatibility)
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

## Uninstall nodebrew

```
$ rm -rf $HOME/.nodebrew
```

That's all.

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
