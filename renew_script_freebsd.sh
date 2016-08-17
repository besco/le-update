#!/bin/sh

os=`uname`

if [ $os = "FreeBSD" ];
then
   echo "FreeBSD detected"
   apache_service="/usr/local/etc/rc.d/apache24"
   nginx_service="/usr/local/etc/rc.d/nginx"
   md5="md5"
   awk_hash_num=4
elif [ $os = "Linux" ];
then
   echo "Linux detected"
   apache_service="service apache2"
   nginx_service="service nginx"
   md5="md5sum"
   awk_num=1
else
   echo "What kind of OS do you using?"
   exit 9999
fi



#exit 3

x=0
for file in `find /etc/letsencrypt/live -name "cert.pem"`
do
   x=`expr $x + 1`
   eval b_hash$x=$file"\ "`$md5 $file|awk '{print \$$awk_num}'i`
:
done

# certbot-auto renew

rc=0
for i in `seq 1 $x`
do

   file=`eval echo \\$b_hash${i}|awk '{print \$1}'`
   hash=`eval echo \\$b_hash${i}|awk '{print \$2}'`
   if [ `$md5 $file|awk '{print \$$awk_num}'` = $hash ];
   then
      echo "Certificate $file ($hash) is fine"
   else
      echo "Certificate $file ($hash) renewed"
      rc=`expr $rc + 1`
   fi
done

if [ $rc -ne 0 ];
then
   echo "Certificates renewed. Restarting Nginx and Apache"
   $apache_service reload
   $nginx_service reload
fi
exit $rc

