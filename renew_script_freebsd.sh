#!/bin/sh
x=0
for file in `find /etc/letsencrypt/live -name "cert.pem"`
do
   x=`expr $x + 1`
   eval b_hash$x=$file"\ "`md5 $file|awk '{print \$4}'i`
:
done

letsencrypt renew

rc=0
for i in `seq 1 $x`
do
   
   file=`eval echo \\$b_hash${i}|awk '{print \$1}'`
   hash=`eval echo \\$b_hash${i}|awk '{print \$2}'`
   if [ `md5 $file|awk '{print \$4}'` = $hash ]; 
   then
      echo "Certificate $file ($hash) is fine"
   else
      echo "Certificate $file ($hash) renewed"
      rc=`expr $rc + 1`
   fi  
done

if [ $rc -ne 0 ]; 
then
   echo "Certificates renewed. Restarting nginx and apache24" 
   /usr/local/etc/rc.d/apache24 restart
   /usr/local/etc/rc.d/nginx reload
fi 
echo $rc

