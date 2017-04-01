################################################################################
# profproc -- parse and process command line arguments for bash scripts        #
# Copyright (c) 2017 Andrew R. M. <andrewmiller237@gmail.com>                  #
#                                                                              # 
# This program is free software: you can redistribute it and/or modify         #
#  it under the terms of the GNU General Public License as published by        #
#  the Free Software Foundation, either version 3 of the License, or           #
#  (at your option) any later version.                                         #
#                                                                              # 
#  This program is distributed in the hope that it will be useful,             #
#  but WITHOUT ANY WARRANTY; without even the implied warranty of              #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               # 
#  GNU General Public License for more details.                                # 
#                                                                              # 
#  You should have received a copy of the GNU General Public License           #
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.       #
################################################################################

# Checks that a string is a command from the list of commands.
profproc__is_command()
{
  for command in "${commands[@]}"; do
    if [ "${1}" = "${command%->*}" ]; then
      echo "${command#*->}"
      return 0
    fi
  done; unset command
  return 1
}

# Check that all commands are valid by checking for leading dashes.
profproc__commands_check()
{
  for command in "${commands[@]}"; do
    if [[ "${command}" =~ ^.*--.*$ ]] || [[ "${command}" =~ ^.*-.*$ ]]; then
      return 1
    fi
  done; unset command
  return 0
}

# Checks that a string is a flag from the list of valid flags.
profproc__is_flag()
{
  for flag in "${flags[@]}"; do
    if [ "${1}" = "${flag%->*}" ]; then
      echo "${flag#*->}"
      return 0
    fi
  done; unset flag
  return 1
}

# Checks that all flags are valid by checking for leading dashes.
profproc__flags_check()
{
  for flag in "${flags[@]}"; do
    if [[ ! "${flag}" =~ ^.*--.*$ ]] || [[ ! "${flag}" =~ ^.*-.*$ ]]; then
      return 1
    fi
  done; unset flag
  return 0
}

profproc__error_handle()
{
  for argument in "$@"; do
    if [ ! "${command}" ] \
    && ([[ ! "${argument}" =~ ^.*--.*$ ]] \
    ||  [[ ! "${argument}" =~ ^.*-.*$ ]]); then
      command="${argument}";
    fi
  done; unset argument
  echo "$0: '${command}' is not a $0 command."
	exit 255
}

#TODO(nixy): Posix Shell compliance, that is remove arrays
profproc()
{
  command=""
  declare -a arguments=()

  # If no arguements run the $default_command if set, otherwise do nothing
  if [ "$#" -eq 0 ]; then
    "${default_command:-:}"
    return
  fi

  for argument in "$@"; do
    if ! [ "${command}" ] \
    && test=$(profproc__is_command "$argument"); then
      command="${test}"
    elif test=$(profproc__is_flag "$argument"); then
      "${test}"
    else
      arguments+=("${argument}")
    fi; unset test
  done; unset argument

  if [ "${command}" ]; then
    "${command}" ${arguments[@]}
    return
  else
    "${default_command}" ${arguments[@]}
    return
  fi
}

default_command=profproc__error_handle
