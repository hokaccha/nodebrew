# nodebrew

Node.js version manager.

## Install

Download script and set.

    $ cd /path/to/bin
    $ curl -O https://raw.github.com/hokaccha/nodebrew/master/nodebrew
    $ chmod +x nodebrew

Add PATH setting your shell config file, .bashrc or .zshrc.

    export PATH=$HOME/.nodebrew/current/bin:$PATH

Reload config.

    $ source ~/.bashrc

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

View all installed version list.

    $ nodebrew list
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
