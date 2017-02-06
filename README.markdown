# Harvest Command Line

HCl is a command-line tool for interacting with Harvest time sheets using the
[Harvest time tracking API][htt].

[View this documentation online][rdoc].

[![Build Status](https://travis-ci.org/zenhob/hcl.png?branch=master)](https://travis-ci.org/zenhob/hcl)
[![Gem Version](https://badge.fury.io/rb/hcl.png)](http://badge.fury.io/rb/hcl)

[htt]: http://www.getharvest.com/api/time_tracking
[rdoc]: http://www.rubydoc.info/github/zenhob/hcl/master

## GETTING STARTED

You can install hcl directly from rubygems.org:

    gem install hcl

or you can install from source:

    rake doc && rake install

Once installed, you can view this README as a man page:

    gem man hcl

I recommend aliasing your `man` command to additionally load gem man pages:

    alias man="gem man -ls"

## SYNOPSIS

    hcl [start] @<task_alias> [+<time>] [<message>]
    hcl note <message>
    hcl stop [<message>]
    hcl resume [@<task_alias>]
    hcl log @<task_alias> [+<time>] [<message>]
    hcl show [<date>]
    hcl tasks [<project_code>]
    hcl alias <task_alias> <project_id> <task_id>
    hcl unalias <task_alias>
    hcl aliases
    hcl (cancel | nvm | oops)
    hcl config
    hcl status

## DESCRIPTION

### Available Projects and Tasks

To start a new timer you need to identify the project and task.
The tasks command displays a list of available tasks with their
project and task IDs.

    hcl tasks

You can also pass a project code (this is the short optional code associated
with each project) to list only the tasks for that project.

### Starting a Timer

Since it's not practical to enter two long numbers every time you want to
identify a task, HCl supports task aliases:

    hcl alias tacodev 1234 5678
    hcl @tacodev Adding a new feature

### Starting a Timer with Initial Time

You can also provide an initial time when starting a new timer.
This can be expressed in floating-point or HH:MM. The following two
commands are equivalent:

    hcl @tacodev +0:15 Doing some stuff
    hcl +.25 @tacodev Doing some stuff
    
### Getting the Current Status

The show command can give you a live view of your current day including
any running tasks, last note, and total time.

    hcl show

Show can also be used with a variety of date formats. See [Date Formats](#date-formats) for more information

### Adding Notes to a Running Task

While a task is running you can append lines to the task notes:

    hcl note Then I did something else

**Note** that `show` only displays the last line of the timer notes.
You can list all the notes for a running timer by issuing the note
command without any arguments:

    hcl note

### Stopping a Timer

The following command will stop a running timer (currently only one timer at
a time is supported). You can provide a message when stopping a timer as
well:

    hcl stop All done doing things

### Resuming a Timer

You can resume a stopped timer. Specify a task to resume the last timer
for that task:

    hcl resume
    hcl resume @xdev

### Canceling a Timer

If you accidentally started a timer that you didn't mean to, you can cancel
it:

    hcl cancel

This will delete the running timer, or the last-updated timer if one isn't
running. You can also use `nvm` or `oops` instead of `cancel`.

### Logging without Starting a Timer

You can log time and notes without leaving a timer running. It takes
the same arguments as start:

    hcl log @xdev +1 Worked for an hour.

The above starts and immediately stops a one-hour timer with the given note.

## ADVANCED USAGE

### Bash Tab Completions

You can enable auto-completion of commands, project ids, task ids and task aliases by adding this to your shell
configuration:

    source $(ruby -e "print File.dirname(Gem.bin_path('hcl', 'hcl'))")/_hcl_completions

### Configuration Profiles

You can modify your credentials with the `--reauth` option, and review them
with `hcl config`. If you'd rather store multiple configurations at
once, specify an alternate configuration directory in the environment as
`HCL_DIR`. This can be used to interact with multiple harvest accounts at
once.

Here is a shell alias `myhcl` with a separate configuration from the
main `hcl` command, and another command to configure alias completion:

    alias myhcl="env HCL_DIR=~/.myhcl hcl"
    complete -F _hcl myhcl

Adding something like the above to your bashrc will enable a new command,
`myhcl`. When using `myhcl` you can use different credentials and aliases,
while `hcl` will continue to function with your original configuration.

### Interactive Console

An interactive Ruby console is provided to allow you to use the fairly
powerful Harvest API client built into HCl, since not all of its
features are exposed via the command line. The current {HCl::App}
instance is available as `hcl`.

It's also possible to issue HCl commands directly (except `alias`, see
below), or to query specific JSON end points and have the results
pretty-printed:

    hcl console
    hcl> show "yesterday"
    # => prints yesterday's timesheet, note the quotes!
    hcl> hcl.http.get('daily')
    # => displays a pretty-printed version of the JSON output

Note that the HCl internals may change without notice.
Also, commands (like `alias`) that are also reserved words in Ruby
can't be issued directly (use `send :alias` instead).

### Date Formats

Dates can be expressed in a variety of ways. See the [Chronic documentation][cd]
for more information about available date input formats. The following
commands show the time sheet for the specified day:

    hcl show yesterday
    hcl show last friday
    hcl show 2 days ago
    hcl show 1 week ago

[cd]: http://chronic.rubyforge.org/

### Harvest service status

Harvest provides a [status API], which you can query using the
`hcl status` command. This will tell you whether Harvest itself is up,
along with a timestamp of when it was last tested.

[status API]: http://harveststatus.com

## AUTHOR

HCl was designed and implemented by [Zack Hobson][zgh].

* Non-SSL support by [Michael Bleigh][mbleigh].
* Resume command by [Brian Cooke][bricooke].
* UI improvements by [Chris Scharf][scharfie].

See LICENSE for copyright details.

[zgh]: http://github.com/zenhob
[mbleigh]: http://github.com/mbleigh
[bricooke]: http://github.com/bricooke
[scharfie]: http://github.com/scharfie



