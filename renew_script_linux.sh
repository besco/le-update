#!/bin/sh
echo "----------------------------------------------------------------------------------------------------" >>/var/log/renew_scrip.log
echo `date` >>/var/log/renew_scrip.log
x=0
for file in `find /etc/letsencrypt/live -name "cert.pem"`
do
   x=`expr $x + 1`
   eval b_hash$x=$file"\ "`md5sum $file|awk '{print \$1}'i`
done

/etc/letsencrypt/certbot-auto renew

rc=0
for i in `seq 1 $x`
do
   
   file=`eval echo \\$b_hash${i}|awk '{print \$1}'`
   hash=`eval echo \\$b_hash${i}|awk '{print \$2}'`
   if [ `md5sum $file|awk '{print \$1}'` = $hash ]; 
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
   /etc/init.d/httpd reload 
   /etc/init.d/nginx reload
fi 
exit $rc

