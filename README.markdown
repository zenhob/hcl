# hcl

HCl is a command-line tool for interacting with Harvest time sheets using the
[Harvest time tracking API][1].

## Quick Start

NOTE This software is nowhere near complete. To try it out:

    $ cp hcl_conf.yml.example hcl_conf.yml
    $ $EDITOR hcl_conf.yml
    $ ./bin/hcl show [date]
    $ ./bin/hcl tasks
    $ ./bin/hcl start <task_id>

### Prerequisites

 * Ruby (tested with 1.8.7)
 * RubyGems
 * Trollop option-parsing library (gem install trollop)
 * Chronic date-parsing library (gem install chronic)

## Usage

NOTE that the only currently implemented commands are show, tasks and start.

    hcl show [date]
    hcl tasks
    hcl start <task_id> [msg]
    hcl add <task_id> <duration> [msg]
    hcl rm [entry_id]
    hcl stop [msg]

### Examples

Dates can be expressed in a variety of ways. See the [Chronic documentation][2]
for more information about available date input formats. The following
commands show the timesheet for the specified day:

    $ hcl show yesterday
    $ hcl show last friday
    $ hcl show 2 days ago
    $ hcl show 1 week ago

## TODO

 * Implement time-tracking API methods:
   - display today's time sheet (done)
   - display any time sheet by date (done)
   - start a timer (done)
   - stop a timer
   - post a time sheet entry
   - delete a time sheet entry
   - update a time sheet entry
 * command-line configuration
 * search ~/.hcl_config for configuration
 * integrate timesheet functionality into aiaio's [harvest gem][3]

[1]: http://www.getharvest.com/api/time_tracking
[2]: http://chronic.rubyforge.org/
[3]: http://github.com/aiaio/harvest/tree/master

