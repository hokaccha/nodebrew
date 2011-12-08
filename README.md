# nodebrew

Node.js version manager.

## Install

Using curl one liner.

    $ curl https://raw.github.com/hokaccha/nodebrew/master/nodebrew | perl - setup

Or download and setup.

    $ wget https://raw.github.com/hokaccha/nodebrew/master/nodebrew
    $ perl nodebrew setup

Add PATH setting your shell config file, .bashrc or .zshrc.

    export PATH=$HOME/.nodebrew/current/bin:$PATH

Reload config.

    $ source ~/.bashrc

Confirm.

    $ nodebrew help

## Example

Install v0.6.0

    $ nodebrew install v0.6.0
    install ...

Switch use version to v0.6.0.

    $ nodebrew use v0.6.0
    $ node -v
    v0.6.0

Install v0.4.0

    $ nodebrew install v0.4.0
    install ...

Switch use version to v0.4.0.

    $ nodebrew use v0.4.0
    $ node -v
    v0.4.0

View all installed version list or ls.

    $ nodebrew ls
    v0.4.0
    v0.6.0

    current: v0.4.0

Uninstall v0.6.0

    $ nodebrew v0.6.0
    v0.6.0 uninstalled

## Commands

    $ nodebrew help                    Show help message
    $ nodebrew install <version>       Download and install a <version>
    $ nodebrew uninstall <version>     Uninstall a version
    $ nodebrew use <version>           Modify PATH to use <version>
    $ nodebrew list                    List installed versions
    $ nodebrew ls                      Alias list
    $ nodebrew selfupdate              Update nodebrew
