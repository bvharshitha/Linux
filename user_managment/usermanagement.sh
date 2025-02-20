#!/bin/bash

file="students.txt"
removal="deleteuser.txt"
log_file="/var/log/user_management.logs"

if [ ! -f "$log_file" ]; then
    touch  $log_file
fi

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $log_file
}

echo "User Managment file helps to create a set of User Accounts or remove User Accounts./n 1. Creating and Assigning users and groups /n 2. removing the users "

read -p  "Choose option 1 or 2 :" Option


case $Option in 1)
if [[ ${UID} -ne 0 ]]; then
  echo "Please run the script as the root user."
  exit 1

else
  while IFS=';' read -r user group; do
    if [[ -z "$user" || -z "$group" ]]; then
       exit 1
    fi

    if id "$user" &>/dev/null; then

       if getent group "$group" &>/dev/null; then
            if ! id -nG "$user" | grep -qw "$group"; then
                log_message "User '$user' is not a member of the '$group' group. Adding user to the group."
                usermod -aG "$group" "$user"
            else
                log_message "User '$user' is already a member of the '$group' group."
            fi
        else
            log_message "Group '$group' does not exist. Creating group and adding user."
            groupadd "$group"
            usermod -aG "$group" "$user"
        fi
    else
         if getent group "$group" &>/dev/null; then
            log_message "User '$user' does not exist. Creating user and adding to group '$group'."
            useradd "$user"
            usermod -aG "$group" "$user"
        else
            log_message "User '$user' and group '$group' do not exist. Creating user and group, then adding user to the group."
            groupadd "$group"
            useradd "$user"
            usermod -aG "$group" "$user"
        fi
    fi
  done < "$file"
fi
;;

2)
  while IFS=";" read -r user group; do
   if [[ -z "$user" || -z "$group" ]]; then
       exit 1
   fi
   if id "$user" &>/dev/null; then
      if getent group "$group"  &>/dev/null; then
         if ! id -nG "$user" | grep -qw "$group"; then
              log_message "User $user is not from the $group group so user cann't be deleted"
         else 
          userdel $user
          read -p "Do want to delete the group also:" QA
          if [[ ${UID} -ne 0 ]]; then
              log_message "User $user deleted and $group group can not be deleted as user don't have root privileges"
          else
              log_message "Group and user were removed"
              groupdel $group
          fi
          fi
     else
      log_message "Group does not exits. User cann't be deleted"
     fi
   else
     log_message "User does not exits"
   fi
  done < "$removal" 
;;
*) 
    echo "choose the task to perform"
    ;;
esac

