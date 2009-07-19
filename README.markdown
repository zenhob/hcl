# hcl

HCl is a command-line tool for interacting with Harvest time sheets using the
[Harvest time tracking API][1].

## Quick Start

NOTE This software is nowhere near complete. Currently the only implemented
feature is a simple view of any daily timesheet. To try it out:

    $ cp hcl_conf.yml.example hcl_conf.yml
    $ $EDITOR hcl_conf.yml
    $ ./bin/hcl show [date]

### Prerequisites

 * Ruby (tested with 1.8.7)
 * RubyGems
 * Curb curl library (gem install curb)
 * Chronic date-parsing library (gem install chronic)

## Usage

NOTE only the show command is implemented

    hcl show [date]
    hcl add <project> <task> <duration> [msg]
    hcl rm [entry_id]
    hcl start <project> <task> [msg]
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
   - get time sheet entry
   - toggle a timer
   - post a time sheet entry
   - delete a time sheet entry
   - update a time sheet entry
 * command-line configuration
 * search ~/.hcl_config for configuration
 * integrate timesheet functionality into aiaio's [harvest gem][3]

[1]: http://www.getharvest.com/api/time_tracking
[2]: http://chronic.rubyforge.org/
[3]: http://github.com/aiaio/harvest/tree/master

