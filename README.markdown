# hcl

HCl is a command-line tool for interacting with Harvest time sheets using the
[Harvest time tracking API][1].

## Usage

    hcl [opts] add <project> <task> <duration> [msg]
    hcl [opts] rm [entry_id]
    hcl [opts] start <project> <task> [msg]
    hcl [opts] stop [msg]
    hcl [opts] show [date]

## TODO

 * Implement time-tracking API methods:
   - get daily time sheet
   - get time sheet entry
   - toggle a timer
   - post a time sheet entry
   - delete a time sheet entry
   - update a time sheet entry

[1]: http://www.getharvest.com/api/time_tracking

