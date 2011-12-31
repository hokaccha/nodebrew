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

## ENV

`NODEBREW_ROOT` env var can change nodebrew's home directory. default is `$HOME/.nodebrew`.

    export NODEBREW_ROOT=/path/to/.nodebrew

## Example

Install v0.6.0

    $ nodebrew install v0.6.0
    install ...

    # or
    $ nodebrew install latest # latest version
    $ nodebrew install v0.6.x # v0.6 latest

Switch use version to v0.6.0.

    $ nodebrew use v0.6.0
    $ node -v
    v0.6.0

    # or
    $ nodebrew use latest # latest version
    $ nodebrew use v0.6.x # v0.6 latest

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

Remote version view.

    $ nodebrew ls-remote
    v0.0.1    v0.0.2    v0.0.3    v0.0.4    v0.0.5    v0.0.6    

    v0.1.0    v0.1.1    v0.1.2    v0.1.3    v0.1.4    v0.1.5    v0.1.6    v0.1.7
    v0.1.8    v0.1.9    v0.1.10   v0.1.11   v0.1.12   v0.1.13   v0.1.14   v0.1.15
    v0.1.16   v0.1.17   v0.1.18   v0.1.19   v0.1.20   v0.1.21   v0.1.22   v0.1.23
    v0.1.24   v0.1.25   v0.1.26   v0.1.27   v0.1.28   v0.1.29   v0.1.30   v0.1.31
    v0.1.32   v0.1.33   v0.1.90   v0.1.91   v0.1.92   v0.1.93   v0.1.94   v0.1.95
    v0.1.96   v0.1.97   v0.1.98   v0.1.99   v0.1.100  v0.1.101  v0.1.102  v0.1.103
    v0.1.104  

    v0.2.0    v0.2.1    v0.2.2    v0.2.3    v0.2.4    v0.2.5    v0.2.6    

    v0.3.0    v0.3.1    v0.3.2    v0.3.3    v0.3.4    v0.3.5    v0.3.6    v0.3.7
    v0.3.8    

    v0.4.0    v0.4.1    v0.4.2    v0.4.3    v0.4.4    v0.4.5    v0.4.6    v0.4.7
    v0.4.8    v0.4.9    v0.4.10   v0.4.11   v0.4.12   

    v0.5.0    v0.5.1    v0.5.2    v0.5.3    v0.5.4    v0.5.5    v0.5.6    v0.5.7
    v0.5.8    v0.5.9    v0.5.10   

    v0.6.0    v0.6.1    v0.6.2    v0.6.3    v0.6.4    v0.6.5    v0.6.6

Uninstall v0.6.0

    $ nodebrew v0.6.0
    v0.6.0 uninstalled

## Commands

    $ nodebrew help                    Show this message
    $ nodebrew install <version>       Download and install a <version>
    $ nodebrew uninstall <version>     Uninstall a version
    $ nodebrew use <version>           Modify PATH to use <version>
    $ nodebrew list                    List installed versions
    $ nodebrew ls                      Alias list
    $ nodebrew ls-remote               List remote versions
    $ nodebrew ls-all                  List remote and installed versions
    $ nodebrew clean <version> | all   Remove source file
    $ nodebrew selfupdate              Update nodebrew
