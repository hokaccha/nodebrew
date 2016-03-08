function __fish_nodebrew_no_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 ]
    return 0
  end
  return 1
end

function __fish_nodebrew_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ $argv[1] = $cmd[2] ]
      return 0
    end
  end
  return 1
end

function __fish_nodebrew_versions
  nodebrew ls ^ /dev/null | grep '^v\|^io@'
end

function __fish_nodebrew_remote_versions
  nodebrew ls-remote ^ /dev/null | sed -e 's/ /\n/g'
end

function __fish_nodebrew_aliases
  nodebrew alias ^ /dev/null | sed -e 's/->.*//' -e 's/ //g'
end

complete -f -c nodebrew -n '__fish_nodebrew_no_command' -a 'alias unalias ls ls-all ls-remote list install install-binary uninstall use clean selfupdate migrate-package exec help'

complete -f -c nodebrew -n '__fish_nodebrew_using_command use' -a '(__fish_nodebrew_versions) (__fish_nodebrew_aliases)'
complete -f -c nodebrew -n '__fish_nodebrew_using_command migrate-package' -a '(__fish_nodebrew_versions) (__fish_nodebrew_aliases)'
complete -f -c nodebrew -n '__fish_nodebrew_using_command exec' -a '(__fish_nodebrew_versions) (__fish_nodebrew_aliases)'
complete -f -c nodebrew -n '__fish_nodebrew_using_command install' -a '(__fish_nodebrew_remote_versions)'
complete -f -c nodebrew -n '__fish_nodebrew_using_command install-binary' -a '(__fish_nodebrew_remote_versions)'
complete -f -c nodebrew -n '__fish_nodebrew_using_command clean' -a '(__fish_nodebrew_versions) all'
complete -f -c nodebrew -n '__fish_nodebrew_using_command uninstall' -a '(__fish_nodebrew_versions)'
complete -f -c nodebrew -n '__fish_nodebrew_using_command alias' -a '(__fish_nodebrew_aliases)'
complete -f -c nodebrew -n '__fish_nodebrew_using_command unalias' -a '(__fish_nodebrew_aliases)'
