# nodebrew

Node.js version manager.

## Install

Using curl one liner.

    $ curl -L git.io/nodebrew | perl - setup

Or download and setup.

    $ wget git.io/nodebrew
    $ perl nodebrew setup

Add PATH setting your shell config file, .bashrc or .zshrc.

    export PATH=$HOME/.nodebrew/current/bin:$PATH

Reload config.

    $ source ~/.bashrc

Confirm.

    $ nodebrew help

## ENV

`NODEBREW_ROOT` env var can change nodebrew's home directory. default is `$HOME/.nodebrew`.

    export NODEBREW_ROOT=/path/to/.nodebrew

## Example

Install.

    $ nodebrew install v0.6.0
    install ...

    # or
    $ nodebrew install latest # latest version
    $ nodebrew install stable # stable version
    $ nodebrew install v0.6.x # v0.6 latest
    $ nodebrew install 0.6.0  # without `v`

Switch use version.

    $ nodebrew use v0.6.0
    $ node -v
    v0.6.0

    # or
    $ nodebrew use latest # latest version
    $ nodebrew use stable # stable version
    $ nodebrew use v0.6.x # v0.6 latest
    $ nodebrew use 0.6.0  # without `v`

View all installed version list or ls.

    $ nodebrew ls
    v0.4.0
    v0.6.0

    current: v0.6.0

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
    v0.4.0
    v0.6.0

    current: v0.6.0

Set alias.

    $ nodebrew alias default v0.4.7
    default -> v0.4.7

    $ nodebrew use default
    use v0.4.7

    $ nodebrew unalias default
    remove default

Uninstall.

    $ nodebrew uninstall v0.6.0
    v0.6.0 uninstalled

Update nodebrew.

    $ nodebrew selfupdate

## Commands

    $ nodebrew help                       Show this message
    $ nodebrew install <version>          Download and install a <version> (compile from source)
    $ nodebrew install-binary <version>   Download and install a <version> (binary file)
    $ nodebrew uninstall <version>        Uninstall a version
    $ nodebrew use <version>              Use <version>
    $ nodebrew list                       List installed versions
    $ nodebrew ls                         Alias for `list`
    $ nodebrew ls-remote                  List remote versions
    $ nodebrew ls-all                     List remote and installed versions
    $ nodebrew alias <key> <version>      Set alias to version
    $ nodebrew unalias <key>              Remove alias
    $ nodebrew clean <version> | all      Remove source file
    $ nodebrew selfupdate                 Update nodebrew
    $ nodebrew migrate-package <version>  Install global NPM packages contained in <version> to current version

## Development

Install module for testing.

    $ cpanm --installdeps .

Run test.

    $ prove -lvr
