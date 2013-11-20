# HCl

HCl is a command-line tool for interacting with Harvest time sheets using the
[Harvest time tracking API][htt].

[htt]: http://www.getharvest.com/api/time_tracking

## Quick Start

You can install hcl directly from rubygems.org:

    $ gem install hcl

or you can install from source:

    $ rake install

If you're using HCl for the first time, the show command sets up your
Harvest credentials:

    $ hcl show

## Usage

    hcl [start] @<task_alias> [+<time>] [<message>]
    hcl note <message>
    hcl stop [message]
    hcl resume [@<task_alias>]
    hcl log @<task_alias> [+<time>] [<message>]
    hcl show [date]
    hcl tasks
    hcl alias <task_alias> <project_id> <task_id>
    hcl aliases
    hcl (cancel | nvm | oops)

### Available Projects and Tasks

To start a new timer you need to identify the project and task. After you've
used the show command you can use the tasks command to view a cached list of
available tasks.

    $ hcl tasks

### Starting a Timer

Since it's not practical to enter two long numbers every time you want to
identify a task, HCl supports task aliases:

    $ hcl alias tacodev 1234 5678
    $ hcl @tacodev Adding a new feature

### Starting a Timer with Initial Time

You can also provide an initial time when starting a new timer.
This can be expressed in floating-point or HH:MM. The following two
commands are equivalent:

    $ hcl @tacodev +0:15 Doing some stuff
    $ hcl +.25 @tacodev Doing some stuff

### Adding Notes to a Running Task

While a task is running you can append lines to the task notes:

    $ hcl note Then I did something else

### Stopping a Timer

The following command will stop a running timer (currently only one timer at
a time is supported). You can provide a message when stopping a timer as
well:

    $ hcl stop All done doing things

### Resuming a Timer

You can resume a stopped timer. Specify a task to resume the last timer
for that task:

    $ hcl resume
    $ hcl resume @xdev

### Canceling a Timer

If you accidentally started a timer that you didn't mean to, you can cancel
it:

    $ hcl cancel

This will delete the running timer, or the last-updated timer if one isn't
running. You can also use `nvm` or `oops` instead of `cancel`.

### Logging without Starting a Timer

You can log time and notes without leaving a timer running. It takes
the same arguments as start:

    $ hcl log @xdev +1 Worked for an hour.

The above starts and immediately stops a one-hour timer with the given note.

### Bash Auto-completion of Task Aliases

You can enable auto-completion of task aliases by adding this to your bashrc:

    eval `hcl completion`

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



