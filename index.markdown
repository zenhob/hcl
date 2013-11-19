---
layout: main
---
# HCl

HCl is a command-line tool for interacting with Harvest time sheets using the
[Harvest time tracking API][htt].

[htt]: http://www.getharvest.com/api/time_tracking

## Quick Start

You can install hcl directly from rubygems.org:

    $ gem install hcl
    $ hcl show [date]

or you can install from source using jeweler:

    $ gem install jeweler
    $ rake install

### Prerequisites

 * Ruby (tested with 1.8.7)
 * Ruby OpenSSL support (in debian/ubuntu: apt-get install libopenssl-ruby)
 * Ruby extension building support (in debian/ubuntu: apt-get install ruby-dev)
 * RubyGems 1.3.3
 * Trollop option-parsing library (gem install trollop)
 * Chronic date-parsing library (gem install chronic)
 * HighLine console input library (gem install highline)
 * Jeweler packaging tool (needed to build the gem)

## Usage

    hcl (@<task_alias> | <project_id> <task_id>) [+time] [message]
    hcl note <message>
    hcl stop [message]
    hcl resume [@<task_alias>]
    hcl show [date]
    hcl tasks
    hcl alias <task_alias> <project_id> <task_id>
    hcl aliases

### Available Projects and Tasks

To start a new timer you need to identify the project and task. After you've
used the show command you can use the tasks command to view a cached list of
available tasks.

    $ hcl tasks

### Starting a Timer

Since it's not practical to enter two long numbers every time you want to
identify a task, HCl supports task aliases:

    $ hcl alias xdev 1234 5678
    $ hcl @xdev Adding a new feature!

### Starting a Timer with Initial Time

You can also provide an initial time when starting a new timer.
This can be expressed in floating-point or HH:MM. The following two
commands are equivalent:

    $ hcl @xdev +0:15 Adding a new feature!
    $ hcl +.25 @xdev Adding a new feature!

### Adding Notes to a Running Task

While a task is running you can append lines to the task notes:

    $ hcl note Found a good time!

### Stopping a Timer

The following command will stop a running timer (currently only one timer at
a time is supported). You can provide a message when stopping a timer as
well:

    $ hcl stop All done!

### Resuming a Timer

You can resume a stopped timer. Specify a task to resume the last timer
for that task:

    $ hcl resume
    $ hcl resume @xdev

### Date Formats

Dates can be expressed in a variety of ways. See the [Chronic documentation][cd]
for more information about available date input formats. The following
commands show the timesheet for the specified day:

    $ hcl show yesterday
    $ hcl show last friday
    $ hcl show 2 days ago
    $ hcl show 1 week ago

[cd]: http://chronic.rubyforge.org/

## Author

HCl was designed and implemented by [Zack Hobson][zgh].

* Non-SSL support by [Michael Bleigh][mbleigh].
* Resume command by [Brian Cooke][bricooke].
* UI improvements by [Chris Scharf][scharfie].

See LICENSE for copyright details.

[zgh]: http://github.com/zenhob
[mbleigh]: http://github.com/mbleigh
[bricooke]: http://github.com/bricooke
[scharfie]: http://github.com/scharfie


