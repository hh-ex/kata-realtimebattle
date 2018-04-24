#!/bin/sh

prog=/usr/bin/vncpasswd
mypass="password"

/usr/bin/expect <<EOF
spawn "$prog" .passwd
expect "Password:"
send "$mypass\r"
expect "Verify:"
send "$mypass\r"
expect eof
exit
EOF