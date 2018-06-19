function __fish_hcl_arg_count
    set -l cmd (commandline -opc)
    if [ (count $cmd) -eq $argv[1] ]
        return 0
    end
    return 1
end

function __fish_hcl_customers
    hcl tasks | awk -F "\t" '{ split($1,a," "); split($2,b," - "); print a[1] "\t" b[1],"-",b[2] }' | sort -u
end

function __fish_hcl_tasks
    set -l cmd (commandline -opc)
    set -l customer $cmd[4]
    hcl tasks | grep "^$customer" | awk -F "\t" '{ split($1,a," "); split($2,b," - "); print a[2] "\t" b[3] }'
end

function __fish_hcl_aliases
    hcl aliases | sed -e 's/, /\n/g'
end

complete -c hcl -f

complete -c hcl -f -s r -l reauth -d 'Force refresh of auth details'
complete -c hcl -f -s c -l changelog -d 'Review the HCl changelog'
complete -c hcl -f -s v -l version -d 'Print version and exit'
complete -c hcl -f -s h -l help -d 'Show the help message'

complete -c hcl -n '__fish_hcl_arg_count 1' -f -a tasks -d 'show all available tasks'
complete -c hcl -n '__fish_hcl_arg_count 1' -f -a alias -d 'create a task alias'
complete -c hcl -n '__fish_hcl_arg_count 1' -f -a unalias -d 'remove a task alias'
complete -c hcl -n '__fish_hcl_arg_count 1' -f -a aliases -d 'list task aliases'
complete -c hcl -n '__fish_hcl_arg_count 1' -f -a start -d 'start a task using an alias'
complete -c hcl -n '__fish_hcl_arg_count 1' -f -a stop -d 'stop a running timer'
complete -c hcl -n '__fish_hcl_arg_count 1' -f -a note -d 'add a line to a running timer'
complete -c hcl -n '__fish_hcl_arg_count 1' -f -a log -d 'log a task and time without leaving a timer running'
complete -c hcl -n '__fish_hcl_arg_count 1' -f -a resume -d 'resume the last stopped timer or a specific task'
complete -c hcl -n '__fish_hcl_arg_count 1' -f -a 'cancel nvm oops' -d 'delete the current or last running timer'
complete -c hcl -n '__fish_hcl_arg_count 1' -f -a show -d 'display the daily timesheet'
complete -c hcl -n '__fish_hcl_arg_count 1' -f -a config -d 'show your current credentials'
complete -c hcl -n '__fish_hcl_arg_count 1' -f -a status -d 'display Harvest service status'
complete -c hcl -n '__fish_hcl_arg_count 1' -f -a '(__fish_hcl_aliases)' -d 'start work on aliased task'

complete -c hcl -n '__fish_seen_subcommand_from start; and __fish_hcl_arg_count 2' -f -a '(__fish_hcl_aliases)'
complete -c hcl -n '__fish_seen_subcommand_from resume; and __fish_hcl_arg_count 2' -f -a '(__fish_hcl_aliases)'
complete -c hcl -n '__fish_seen_subcommand_from log; and __fish_hcl_arg_count 2' -f -a '(__fish_hcl_aliases)'

complete -c hcl -n '__fish_seen_subcommand_from alias; and __fish_hcl_arg_count 3' -f -a '(__fish_hcl_customers)'
complete -c hcl -n '__fish_seen_subcommand_from alias; and __fish_hcl_arg_count 4' -f -a '(__fish_hcl_tasks)'
