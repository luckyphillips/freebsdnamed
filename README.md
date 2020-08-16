# freebsdnamed

# Should give an insight at least on how to install Bind/Named on freebsd

# Make sure bash is installed and located at /usr/local/bin/bash

#

git clone https://github.com/luckyphillips/freebsdnamed.git

cd freebsdnamed

chmod 755 installnamed.sh

./installnamed.sh

sysrc named_enable=yes
