#!/bin/bash

check_hash ()
{
   if grep -q "^PasswordAuthentication\s*no" /etc/ssh/sshd_config ; then return 0 ; fi
   test -x /usr/bin/mkpasswd || return 0
   SHADOW="$(sudo -n grep -E '^pi:' /etc/shadow 2>/dev/null)"
   test -n "${SHADOW}" || return 0
   if echo $SHADOW | grep -q "pi:!" ; then return 0 ; fi
   SALT=$(echo "${SHADOW}" | sed -n 's/pi:\$6\$//;s/\$.*//p')
   HASH=$(mkpasswd -msha-512 raspberry "$SALT")
   test -n "${HASH}" || return 0

   if echo "${SHADOW}" | grep -q "${HASH}"; then
	zenity --warning --text="SSH is enabled and the default password for the 'pi' user has not been changed.\nThis is a security risk - please login as the 'pi' user and run Raspberry Pi Configuration to set a new password."
   fi
}

if service ssh status | grep -q running; then
	check_hash
	unset check_hash
fi
