0.9.8  / 2017-04-17
====================

* Fix behavior of stable keyword, fix to #65

0.9.7  / 2017-04-17
====================

* Add checking "HTTP/2 200" for curl #64 (@msfm)

0.9.6  / 2016-05-11
====================

* Exec command exit with external command's exit code #56 (@hiyamamo)

0.9.5  / 2016-03-07
====================

* Change to using protocol https on access to nodejs.org #42 (@hirose504)

0.9.4  / 2016-02-19
====================

* Escaped left brace in regex #52 (@iwaim)

0.9.3  / 2015-12-22
====================

* show versions more compactly #49 (@1000ch)

0.9.2  / 2015-10-25
====================

* Change behavior of stable keyword

0.9.1  / 2015-10-03
====================

* Fix `install-binary` on armv6l and armv7l #44

0.9.0  / 2015-06-25
====================

* Add nightly & next-nightly install #38 (@yosuke-furukawa)

0.8.2  / 2015-06-25
====================

* Fix migrate-package #37 (@kysnm)

0.8.1  / 2015-01-26
====================

* Update shell completions, support iojs
* Fix install-binary iojs in x86 linux #34

0.8.0  / 2015-01-14
====================

* io.js support

0.7.5  / 2014-11-09
====================

* Add configure options

0.7.4  / 2014-06-02
====================

* Add _cmd_setup_dirs function for homebrew installation (@oinume)

0.7.3  / 2014-04-28
====================

* Add `-L` option to curl
* Fixed github base_url #27 (@tanabee)

0.7.2  / 2014-01-13
====================

* Add completion functions installable (@yasuyk)

0.7.1  / 2013-12-01
====================

* Fix bug dereference array ref (for perl 5.12 and under)

0.7.0  / 2013-11-30
====================

* Add subcommand `exec`

0.6.4  / 2013-10-01
====================

* Add showing error message when not supported machine.
* Fix select $arch when i386.

0.6.3  / 2013-06-13
====================

* Add Solaris support with `install-binary` (@onopm)

0.6.2  / 2013-01-17
====================

* Add raspberry pi support with `install-binary` (@nulltask)

0.6.1  / 2012-12-29
====================

* Fix not exist `Archive::Tar`. fix #22

0.6.0  / 2012-12-10
====================

* Add subcommand `install-package`.
* Update src directory structure.
* Update tar extract using perl module `Archive::Tar`
* Update error handling
* Update `migrate-package`, not install already installed package.

0.5.2  / 2012-11-04
====================

* Fix `migrate-package` command dose not work old npm. Closes #20

0.5.1  / 2012-11-04
====================

* Add subcommand `migrate-package` (hideo55)

0.5.0  / 2012-03-12
====================

* Add subcommand `alias`
* Add subcommand `unalias`

0.4.3  / 2012-03-09
====================

* Add find version `stable`. Closes #13

0.4.2  / 2012-01-01
====================

* Bug fix

0.4.1  / 2012-01-01
====================

* Fix version args without `v`
* Bug fix

0.4.0  / 2012-01-01
====================

* Add auto verison find. like `install v0.6.x`, `use latest` Closes #3

0.3.2 / 2011-12-31
====================

* Add subcommand `ls-clean`
* Fix when install use cache

0.3.1 / 2011-12-31
====================

* Add subcommand `ls-remote`
* Add subcommand `ls-all`

0.3.0 / 2011-12-30
====================

* Add test
* Separate package

0.2.0 / 2011-12-08
====================

* Add subcommand `selfupdate`
* Add subcommand `setup`
* Add nodebrew path $NODEBREW_ROOT/current/bin/nodebrew Closes #2
* Fix uninstalled current version, use default
* Fix bug, can't `use` command, if symlink dir removed
* Add support, change able nodebrew root dir. using $NODEBREW_ROOT
* Add subcommand `ls`
* Add wget support Closes #1

0.1.0 / 2011-11-15
====================

* Initial release
