function __fish_hcl_needs_command
    set -l cmd (commandline -opc)
    if [ (count $cmd) -eq 1 -a $cmd[1] = 'hcl' ]
        return 0
    end
    return 1
end

function __fish_hcl_using_command
    set -l cmd (commandline -opc)
    if [ (count $cmd) -gt 1 ]
        if [ $argv[1] = $cmd[2] ]
            return 0
        end
    end
    return 1
end

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

complete -c hcl -n '__fish_hcl_needs_command' -f -a "start resume log stop note show tasks alias unalias aliases cancel nvm oops config status"
complete -c hcl -n '__fish_hcl_using_command start' -f -a '(hcl aliases | sed -e "s/,//g")'
complete -c hcl -n '__fish_hcl_using_command resume' -f -a '(hcl aliases | sed -e "s/,//g")'
complete -c hcl -n '__fish_hcl_using_command log' -f -a '(hcl aliases | sed -e "s/,//g")'
complete -c hcl -n '__fish_hcl_using_command alias' -f
complete -c hcl -n '__fish_hcl_using_command alias; and __fish_hcl_arg_count 3' -a '(__fish_hcl_customers)'
complete -c hcl -n '__fish_hcl_using_command alias; and __fish_hcl_arg_count 4' -a '(__fish_hcl_tasks)'
