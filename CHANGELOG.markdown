# Recent Changes in HCl

## v0.4.16 2017-02-12

* improved bash completion (from chet0xhenry)
* fix deprecated `respond_to?` impls, closes #72 (charneykaye)
* fix manpage installation, closes #75 (thanks to lukehatfield)

## v0.4.15 2015-06-12

* fix `status` command, closes #59

## v0.4.14 2014-04-21

* remove the non-SSL option as it's no longer needed, closes #57
* add a dependency on `gem-man` and instructions for use

## v0.4.13 2014-02-04

* oops, fixed a syntax error that was accidentally committed before release!

## v0.4.12 2014-02-04

* fixed crash when caching tasks for the first time, closes #56
* fixed crash when stopping a timer the next day
* added --changelog option
* remove completion command, cache aliases in a file instead, closes #51
* confirm timer deletion/cancellation, closes #47
* added `status` command to query Harvest service status

## v0.4.11 2014-01-25

* more detailed gem dependencies, prevents unexpected failures
* added a UNIX manual page for hcl(1)

## v0.4.10 2014-01-06

* added `config` command to display current credentials
* added `console` command for exploring the Harvest API

## v0.4.9 2013-12-21

* MacOS X: store password in default keychain
* abort log command when a timer is running

## v0.4.8 2013-11-30

* more fixes for 1.9.3

## v0.4.7 2013-11-30

* added --reauth option to refresh credentials
* added support for retrying on API throttle
* note command without args now displays all notes for a running timer
* fixed a crash on ruby 1.9.3

## v0.4.6 2013-11-21

* automatically request credentials on auth-failure
* fix user-entered credentials

## v0.4.5 2013-11-21

* allow filtering of tasks by project code
* eliminate shoulda from development dependencies

## v0.4.4 2013-11-20

* added completion command to output a Bash auto-complete script, closes #34
* removed jeweler dependency

## v0.4.3 2013-11-19

* added cancel command to delete the last running timer, closes #13
* properly unescape string from Harvest API, closes #24
* stop command now checks for running timers from yesterday, closes #35
* added log command to log time/notes without leaving a timer running, closes #30

## v0.4.2 2013-11-19

* resume command now accepts an optional task

## v0.4.1 2013-11-18

* update dependencies

## v0.4.0 2013-11-18

* start a timer or add a note without having to specify the sub-command
* aliases can be specified with "@" anywhere on the command line
* added alias and unalias to simplify setting task aliases

## v0.3.2 2011-12-30

* fixed support for modern Rubies
* it's now possible to provide a message with the stop command

## v0.3.1 2011-07-13

* use STDERR instead of STDOUT for error reporting
* sort tasks before viewing tasks (brian@madebyrocket.com)
* resume command to resume the most recently active timer (brian@madebyrocket.com)
* show current time when on 'start', 'stop', and 'show' commands (scharfie@gmail.com)
* include client name in tasks list (scharfie@gmail.com)

## v0.3.0 2010-04-02

* added support for free accounts

## v0.2.3 2009-08-23

* Allow decimal time offset without a dot, closes #29.
* Reverted and re-fixed: Adding note fails when task is started without notes, #26.
* Reinstate the --version option

## v0.2.2 2009-08-09

* Support installation via rip, closes #27.
* Fixed: Adding note fails when task is started without notes, closes #26.
* Avoid stack trace on missing XML root node, closes #25.

## v0.2.1 2009-07-30

* Fixed: Creating timers without starting them.

## v0.2.0 2009-07-30

* Allow an initial time to be specified when starting a timer, closes #9.
* Always display hours as HH:MM, closes #22.
* Do not write empty task cache, closes #23.

## v0.1.3 2009-07-28

* Add a note about ruby-dev for debian/ubuntu users, closes #20.
* Friendlier error message on unrecognized task, closes #18, #21.

## v0.1.2 2009-07-27

* Automatically include rubygems in bin/hcl.

## v0.1.1 2009-07-24

* Mention gem in README, read version from file.
    
## v0.1.0 2009-07-24

* Initial public release

