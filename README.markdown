# hcl

HCl is a command-line tool for interacting with Harvest time sheets using the
[Harvest time tracking API][1].

## Quick Start

NOTE This software is nowhere near complete. Currently the only implemented
feature is a simple view of today's timesheet. To try it out:

    $ cp hcl_conf.yml.example hcl_conf.yml
    $ $EDITOR hcl_conf.yml
    $ ./bin/hcl show

### Prerequisites

 * Ruby (tested with 1.8.7)
 * RubyGems
 * Curb curl library (gem install curb)

## Usage

NOTE only the first command is implemented, and arguments are ignored.

    hcl [opts] show [date]
    hcl [opts] add <project> <task> <duration> [msg]
    hcl [opts] rm [entry_id]
    hcl [opts] start <project> <task> [msg]
    hcl [opts] stop [msg]

## TODO

 * Implement time-tracking API methods:
   - display today's time sheet (done)
   - display any time sheet by date
   - get time sheet entry
   - toggle a timer
   - post a time sheet entry
   - delete a time sheet entry
   - update a time sheet entry
 * command-line configuration
 * search ~/.hcl_config for configuration
 * integrate timesheet functionality into aiaio's [harvest gem][2]

[1]: http://www.getharvest.com/api/time_tracking
[2]: http://github.com/aiaio/harvest/tree/master

