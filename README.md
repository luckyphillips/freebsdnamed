# freebsdnamed

# This is not tested, but should work. Once I've had time to test it, I'll remove this line. Should give an insight at least on how to install Bind/Named on freebsd

git clone https://github.com/luckyphillips/freebsdnamed.git

cd freebsdnamed

chmod 755 installnamed.sh

./installnamed.sh

sysrc named_enable=yes
