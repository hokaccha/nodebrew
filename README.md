# nodebrew

[![Build Status](https://travis-ci.org/hokaccha/nodebrew.png?branch=master)](https://travis-ci.org/hokaccha/nodebrew)

Node.js version manager.

## Install

One liner curl install.

    $ curl -L git.io/nodebrew | perl - setup

Or, download and setup.

    $ wget git.io/nodebrew
    $ perl nodebrew setup

Add `PATH` setting your shell config file (`.bashrc` or `.zshrc)`.

    export PATH=$HOME/.nodebrew/current/bin:$PATH

Reload config.

    $ source ~/.bashrc

Confirm.

    $ nodebrew help

## ENV

`NODEBREW_ROOT` environment variable can change nodebrew's home directory. 
The default is `$HOME/.nodebrew`.

    export NODEBREW_ROOT=/path/to/.nodebrew

## Example

Install.

    $ nodebrew install-binary v0.10.29
    install ...

    # or
    $ nodebrew install-binary latest # latest version
    $ nodebrew install-binary stable # stable version
    $ nodebrew install-binary v0.10.x # v0.10 latest
    $ nodebrew install-binary 0.10.29  # without `v`

Switch use version.

    $ nodebrew use v0.10.29
    $ node -v
    v0.10.29

    # or
    $ nodebrew use latest # latest version
    $ nodebrew use stable # stable version
    $ nodebrew use v0.6.x # v0.6 latest
    $ nodebrew use 0.10.29  # without `v`

View all installed versions: `list` or `ls`.

    $ nodebrew ls
    v0.8.28
    v0.10.29

    current: v0.10.29

Remote version view.

    $ nodebrew ls-remote
    v0.0.1    v0.0.2    v0.0.3    v0.0.4    v0.0.5    v0.0.6    
    ...

Remote and local version view.

    $ nodebrew ls-all
    Remote:
    v0.0.1    v0.0.2    v0.0.3    v0.0.4    v0.0.5    v0.0.6    
    ...

    Local:
    v0.8.28
    v0.10.29

    current: v0.10.29

Set alias.

    $ nodebrew alias default v0.8.28
    default -> v0.8.28

    $ nodebrew use default
    use v0.8.28

    $ nodebrew unalias default
    remove default

Uninstall.

    $ nodebrew uninstall v0.10.29
    v0.10.29 uninstalled

Update nodebrew.

    $ nodebrew selfupdate

Execute other version temporary.

    $ nodebrew exec v0.10.29 -- node app.js

## Install from source

We recommend to use the `install-binary` command to install. 
If you want to compile from source, you can use `install` command.

    $ nodebrew install v0.10.29

Pass configure options to Node.js.

    $ nodebrew install v0.11.14 --v8-options=--harmony

## io.js

    $ nodebrew install-binary io@v1.0.0
    $ nodebrew use io@v1.0.0
    $ nodebrew ls
    v0.10.33
    io@v1.0.0

    current: io@v1.0.0

## Commands

    $ nodebrew help                         Show this message
    $ nodebrew install <version>            Download and install a <version> (compile from source)
    $ nodebrew install-binary <version>     Download and install a <version> (binary file)
    $ nodebrew uninstall <version>          Uninstall a version
    $ nodebrew use <version>                Use <version>
    $ nodebrew list                         List installed versions
    $ nodebrew ls                           Alias for `list`
    $ nodebrew ls-remote                    List remote versions
    $ nodebrew ls-all                       List remote and installed versions
    $ nodebrew alias <key> <version>        Set alias to version
    $ nodebrew unalias <key>                Remove alias
    $ nodebrew clean <version> | all        Remove source file
    $ nodebrew selfupdate                   Update nodebrew
    $ nodebrew migrate-package <version>    Install global NPM packages contained in <version> to current version
    $ nodebrew exec <version> -- <command>  Execute <command> specified <version>

## Development

Install module for testing.

    $ carton install

Run test.

    $ carton exec -- prove -lvr
