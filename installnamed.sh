#!/bin/bash
if ! [ $(id -u) = 0 ]; then
   echo -e "\n\n****  You must run this script as ROOT user  ****\n\n"
   exit 1
fi



COLORIZE()
{
    echo -e "\e[36m\e[1m"${@}"\e[30m\e[0m"
}
MSGBOX()
{

cat <<EOF



    ==========================================================================================
    =                                                                                        =
    =                                                                                        =
    =                                                                                        =
    =                                                                                        =
    
EOF

    argv=("${@}") 
    
    for((j=0;j<=((((94-${#argv[0]}))/2));j+=1));do printf "$n ";done
    COLORIZE ${argv[0]}
    echo ""
    echo ""
    
    for ((k=1;k<${#argv[@]};k++))
    do

        if ((${#argv[$k]}<94)) 
            then
            ((v=((94-${#argv[$k]}))/2))
            for((j=0;j<=((((94-${#argv[$k]}))/2));j+=1));do printf "$n ";done
            echo "${argv[$k]}"
            echo ""
        else
            printf "%10s" '' "${argv[$k]}" | sed 's/[.!?]  */&\n\t* /g' 
            echo ""
            echo ""
        fi
    done
    
cat <<NEF
    =                                                                                        =
    =                                                                                        =
    =                                                                                        =
    =                                                                                        =
    =                                                                                        =     
    ==========================================================================================
    
    
NEF
}


INSTALLNAMED()
{
pkg install -y bind9-devel
cd /usr/local/etc/namedb
ln -s /usr/local/etc/namedb /namedb
mkdir zones
d=$(date '+%Y%m%d')
if  ! [ -f "localhost.rev" ]; then
cat <<EOF > localhost.rev    
\$TTL    3600
@       IN      SOA     $1. $3.  (
                                $d        ; Serial
                                3600    ; Refresh
                                900     ; Retry
                                3600000 ; Expire
                                3600 )  ; Minimum
        IN      NS      $1.
1       IN      PTR     localhost.$4.
EOF
fi

myvar=$2
IFS="." read -a myarray <<< $myvar
newstring="${myarray[3]}.${myarray[2]}.${myarray[1]}.in-addr.arpa"

#INSTALLNAMED $myNAMESERVER $myIP $myEmail $myHOST

if  ! [ -f "site-reverse" ]; then
cat <<EOF >> site-reverse
\$TTL    3600
@       IN      SOA     $4. $3.  (
                                $d        ; Serial
                                3600    ; Refresh
                                900     ; Retry
                                3600000 ; Expire
                                3600 )  ; Minimum
        IN      NS      $1.
1       IN      A       $2
EOF
fi

cat <<EOF >> named.conf    

zone "$newstring" {
        type master;
        file "/usr/local/etc/namedb/site-reverse";
};
EOF
sysrc named_enable=yes
}




ADDSUBDOMAIN()
{
foo=("enter subdomain" " i.e. ftp")
MSGBOX "${foo[@]}"
read mySUB

foo2=("enter ip address of sub domain" " 111.222.333.444")
MSGBOX "${foo2[@]}"
read mySUBIP
if  ! [ -d "/usr/local/etc/namedb/zones/" ]; then
mkdir -p /usr/local/etc/namedb/zones/
fi
cd /usr/local/etc/namedb/zones/
cat <<EOF >> $1
$mySUB  IN  A   $mySUBIP
EOF
ADDSUBDOMAINPREPARE $1
}

ADDSUBDOMAINPREPARE()
{

echo "Do you want to add a sub domain? i.e. ftp.yourdomain.com"
echo "(Y)es, (N)o"
echo ""

read addmySUBDOMAIN
case $addmySUBDOMAIN in
    [yY]*)
        ADDSUBDOMAIN $1
    ;;
    *)
        echo "FINISHED"
        exit 0 # PUT ADD DKIM, etc here instead of exit
    ;;
esac
}


ADDDOMAIN()
{
d=$(date '+%Y%m%d')
if  ! [ -d "/usr/local/etc/namedb/zones/" ]; then
mkdir -p /usr/local/etc/namedb/zones/
fi

cd /usr/local/etc/namedb
if ! grep -Fxq "/usr/local/etc/namedb/zones/$1" named.conf; then

cat <<EOF >> named.conf    
zone "$1" {
        type master;
        file "/usr/local/etc/namedb/zones/$1";
};
EOF
fi

mx=""
if [ -z $4 ]
then
mx="MX $4.  ; Primary Mail Exchanger"
fi

mc=""
if [ -z $5 ]
then
mc="TXT \"$5\""
fi

cd /usr/local/etc/namedb/zones/
if  ! [ -f "$1" ]; then
cat <<EOF > $1
\$TTL 3D
@       IN      SOA     $1. $3. (
                        $d
                        3600
                        900
                        3600000
                        3600 )

                NS      $6.
                $mx
                $mc

$1.      IN      A       $2
EOF
fi
ADDSUBDOMAINPREPARE $1
}



PREPAREDOMAIN()
{
foo=("Add your domain name" " i.e. yourdomain.com ")
MSGBOX "${foo[@]}"
read myDOMAINNAME

if [ -f "/usr/local/etc/namedb/zones/$myDOMAINNAME" ]; then
echo "You already have this domain in your records"
ADDSUBDOMAINPREPARE $myDOMAINNAME
exit 1
fi


foo=("Enter IP of the domain name" " i.e. 111.222.333.444 ")
MSGBOX "${foo[@]}"
read myIP

foo=("enter your Email Address for domain" "Use '.' instead of @" "i.e. admin.yourdomain.com ")
MSGBOX "${foo[@]}"
read myEMAIL

foo=("Enter MX record" "i.e. 10 yourdomain.com")
MSGBOX "${foo[@]}"
read myMX

foo=("Add company name" "i.e. YourCompany Inc")
MSGBOX "${foo[@]}"
read myCOMPANY

foo=("Enter nameserver this domain belongs" "ns1.yourdomain.com")
MSGBOX "${foo[@]}"
read myNAMESERVER


ADDDOMAIN $myDOMAINNAME $myIP $myEMAIL $myMX $myCOMPANY $myNAMESERVER
}


PREPAREINSTALL()
{
foo=("Add your nameserver domain" " i.e. ns1.yourdomain.com ")
MSGBOX "${foo[@]}"
read myNAMESERVER

foo=("Enter IP of server" " i.e. 111.222.333.444 ")
MSGBOX "${foo[@]}"
read myIP

foo=("Enter email address" "Use '.' instead of @" "i.e. admin.yourdomain.com ")
MSGBOX "${foo[@]}"
read myEmail

foo=("enter your host name" "Use . instead of @" "i.e. yourdomain.com ")
MSGBOX "${foo[@]}"
read myHOST

INSTALLNAMED $myNAMESERVER $myIP $myEmail $myHOST
}



clear

START()
{
foo=("Install bind/named or add domain?" "(I)nstall" "(A)dd domain to named" "(E)xit script")
MSGBOX "${foo[@]}"

stty -echo
read myAction
stty echo
case $myAction in
    [aA]*)
        PREPAREDOMAIN        
    ;;
    [iI]*)
        PREPAREINSTALL
#         INSTALLNAMED
    ;;
    *)
        exit 0
    ;;
esac
}
START

