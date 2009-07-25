# hcl

HCl is a command-line tool for interacting with Harvest time sheets using the
[Harvest time tracking API][htt].

[htt]: http://www.getharvest.com/api/time_tracking

## Quick Start

NOTE This software is nowhere near complete. To try it out:

    $ cp hcl_conf.yml.example hcl_conf.yml
    $ $EDITOR hcl_conf.yml
    $ ./bin/hcl show [date]

### Prerequisites

 * Ruby (tested with 1.8.7)
 * Ruby OpenSSL support (in debian/ubuntu: apt-get install libopenssl-ruby)
 * RubyGems
 * Trollop option-parsing library (gem install trollop)
 * Chronic date-parsing library (gem install chronic)
 * HighLine console input library (gem install highline)

## Usage

NOTE that *add* and *rm* are not yet implemented.

    hcl show [date]
    hcl tasks
    hcl set <key> <value ...>
    hcl unset <key>
    hcl start (<task_alias> | <project_id> <task_id>) [msg ...]
    hcl note <msg ...>
    hcl stop
    hcl add (<task_alias> | <project_id> <task_id>) <duration> [msg ...]
    hcl rm [entry_id]

### Starting a Timer

To start a new timer you need to identify the project and task. After you've
used the show command you can use the tasks command to view a cached list of
available tasks. The first two numbers in each row are the project and task
IDs. You need both values to start a timer:

    $ hcl show
    -------------
    0:00    total
    $ hcl tasks
    1234 5678   ClientX Software Development
    1234 9876   ClientX Admin
    $ hcl start 1234 5678 adding a new feature

### Task Aliases

Since it's not practical to enter two long numbers every time you want to
identify a task, HCl supports task aliases:

    $ hcl set task.xdev 1234 5678
    $ hcl start xdev adding a new feature

### Adding Notes to a Running Task

While a task is running you can append strings to the note for that task:

    $ hcl note Found a good time
    $ hcl note or not, whatever...

### Stopping a Timer

The following command will stop a running timer (currently only one timer at
a time is supported):

    $ hcl stop

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

[Zack Hobson][zgh], [OpenSourcery LLC][os]

See LICENSE for copyright details.

[zgh]: mailto:zack@opensourcery.com
[os]: http://www.opensourcery.com/

