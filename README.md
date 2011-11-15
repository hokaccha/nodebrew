# nodebrew

Node.js version manager.

## Install

    $ cd /path/to/bin
    $ curl -O https://raw.github.com/hokaccha/nodebrew/master/nodebrew
    $ chmod +x nodebrew
    $ export PATH=$HOME/.nodebrew/current/bin:$PATH

## Example

    $ nodebrew install v0.6.0
    install ...

    $ nodebrew use v0.6.0
    $ node -v
    v0.6.0

    $ nodebrew install v0.4.0
    install ...

    $ nodebrew use v0.4.0
    $ node -v
    v0.4.0

    $ nodebrew list
    v0.4.0
    v0.6.0

    current: v0.4.0

## Commands

    $ nodebrew help                    Show help message
    $ nodebrew install <version>       Download and install a <version>
    $ nodebrew uninstall <version>     Uninstall a version
    $ nodebrew use <version>           Modify PATH to use <version>
    $ nodebrew list                    List installed versions
