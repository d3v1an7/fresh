#!/bin/bash

download() {
  echo "steal from existing"
}

sys_check(){
  echo "steal from existing"
  pip install yq
}

create_brewfile() {
  yq -r \
    '.brew | to_entries[] |
    if .key == "mas" then
      (.value[]) as $item | "\(.key) \"\($item.name)\", id: \($item.id)"
    else
      "\(.key) \"\(.value[])\""
    end' ~/.fresh/config.yaml \
  > ~/.fresh/Brewfile
}

create_mackupcfg() {
  yq -r \
    '.mackup | to_entries[] |
    if .key == "storage" then
      (.value | to_entries[]) as $item | "[\(.key)]","\($item.key)=\($item.value)"
    else
      "[\(.key)]","\(.value[])"
    end' ~/.fresh/config.yaml \
  > ~/.mackup.cfg
}

update_defaults() {
  defaults=$(yq -r '.system.defaults | to_entries[]' ~/.fresh/config.yaml)
  echo $defaults | jq -r '(.value[]) as $item | "\(.key) \"\($item.key)\" \($item.type) \($item.value)"' | while read item; do
    bork do ok defaults "${item}"
    echo
  done
}

update_defaults_global() {
  defaults=$(yq -r '.system.defaults_global | to_entries[]' ~/.fresh/config.yaml)
  echo $defaults | jq -r '(.value[]) as $item | "\(.key) \"\($item.key)\" \($item.type) \($item.value)"' | while read item; do
    # sudo???
    bork do ok defaults "${item}"
    echo
  done
}

update_defaults_plistbuddy() {
  # Check
  defaults=$(yq -r '.system.defaults_plistbuddy | to_entries[]' ~/.fresh/config.yaml)
  echo $defaults | jq -r '(.value[]) as $item | "\"Print :\($item.key)\" \(.key)"' | while read item; do
    echo "${item}"
    echo "/usr/libexec/PlistBuddy -c ${item}" | sh
    echo
  done

  # Delete
  defaults=$(yq -r '.system.defaults_plistbuddy | to_entries[]' ~/.fresh/config.yaml)
  echo $defaults | jq -r '(.value[]) as $item | "\"Delete :\($item.key)\" \(.key)"' | while read item; do
    echo "${item}"
    echo "/usr/libexec/PlistBuddy -c ${item}" | sh
    echo
  done

  # Add
  defaults=$(yq -r '.system.defaults_plistbuddy | to_entries[]' ~/.fresh/config.yaml)
  echo $defaults | jq -r '(.value[]) as $item | "\"Add :\($item.key) \($item.type) \($item.value)\" \(.key)"' | while read item; do
    echo "${item}"
    echo "/usr/libexec/PlistBuddy -c ${item}" | sh
    echo
  done
}

  #
  # - name: check spctl status
  #   shell: "spctl --status"
  #   register: last_osx_spctl_status
  #   failed_when: false
  #   changed_when: false
  # - name: set OS X Gatekeeper
  #   become: yes
  #   shell: "spctl --master-{{ spctl_status }}"

  #
  # - name: check computer name
  #   shell: "scutil --get {{ item.name }}"
  #   with_items: "{{ computer_names }}"
  #   register: last_osx_computer_names
  #   failed_when: false
  #   changed_when: false
  # - name: set computer name
  #   shell: "sudo scutil --set {{ item.name }} '{{ item.value }}'"
  #   with_items: "{{ computer_names }}"

  # - name: check power settings
  #   shell: "pmset -g custom"
  #   register: last_osx_power_settings
  #   failed_when: false
  #   changed_when: false
  # - name: power settings (all)
  #   shell: "sudo pmset -a {{ item.name }} {{ item.value }}"
  #   with_items: "{{ power_settings_all }}"
  #
  # - name: power settings (battery)
  #   shell: "sudo pmset -b {{ item.name }} {{ item.value }}"
  #   with_items: "{{ power_settings_battery }}"
  #
  # - name: power settings (charger)
  #   shell: "sudo pmset -c {{ item.name }} {{ item.value }}"
  #   with_items: "{{ power_settings_charger }}"


brew_bundle_install() {
  brew bundle install --file=~/.fresh/Brewfile
}


#    ... wait until dropbox configured

mackup_restore() {
  mackup restore
}

run_sysconfig() {
  echo "make changes to system config"
}


# create_brewfile #done
# create_mackupcfg #done
# brew_bundle_install #done
# update_defaults
# update_defaults_global
update_defaults_plistbuddy





# ## Credit: http://www.commandlinefu.com/commands/view/13592/get-hardware-uuid-in-mac-os-x
# # need it for screensaver
# UUID="$(system_profiler SPHardwareDataType | awk '/UUID/ { print $3; }')"
#
# if [ -z "${UUID}" ]; then
#   echo -e "{\"failed\": true, \"msg\": \"Could not detect the hardware UUID!\"}"
#   exit 0
# fi
#
# USER_NAME="${USER}"
#
# ## Credit: http://stackoverflow.com/a/11704652
# USER_NAME_FULL=$(osascript -e "long user name of (system info)")
#
# ## Credit: http://stackoverflow.com/a/19878198
# USER_EMAIL=$(dscl . -read /Users/$(whoami) | grep '<string>.*@' | sed -e 's/<[^>]*>//g' | xargs)
#
# if [ -z "${USER_NAME}" ]; then
#   USER_NAME="null"
# fi
#
# if [ -z "${USER_NAME_FULL}" ]; then
#   USER_NAME_FULL="null"
# fi
#
# if [ -z "${USER_EMAIL}" ]; then
#   USER_EMAIL="null"
# fi
#
# ## Ansible doesn't like new lines in the json, so make sure to strip those out with tr
# cat | tr '\n' ' ' << EOF
# {
#   "changed": "true",
#   "ansible_facts": {
#     "user_name": "${USER_NAME}",
#     "user_name_full": "${USER_NAME_FULL}",
#     "user_email": "${USER_EMAIL}"
#   }
# }
# EOF
#
#
#
#
# # say done
# - name: see you space cowboy
#   osx_say:
#     msg: "See you, Space Cowboy"
#     voice: "Fred"
#
#
#
#
# # restart services
# - name: restart services
#   command: "killall {{ item }}"
#   with_items:
#     - Finder
#     - Dock
#     - SystemUIServer
#     - cfprefsd
