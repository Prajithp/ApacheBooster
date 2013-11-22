#!/bin/bash
nVERSION="1.4.4"
vVERSION="3.0.4"
pcreVERSION="8.33"
CUDIR=`pwd`
bin_mkdir=`which mkdir`
bin_cp=`which cp`
bin_mv=`which mv`
bin_rm=`which rm`
nginx_prefix="/usr/local/nginx"
varnish_prefix="/usr/local/varnish"
RED='\033[01;31m'
GREEN='\033[01;32m'
MOUVE='\033[01;35m'
WHITE='\033[01;1;37m'
DYELLOW='\033[01;33m'
YELLOW='\033[01;1;33m'                                                                                                                                       
DGREEN='\033[01;32m'                                                                                                                                         
RESET='\033[0m'                                                                                                                                              
clear

if [ ! `id -u` = 0 ]; then
        echo
        echo "FAILED:::: You must login as root"
        exit 1;
fi

echo -e  "Checking  cPanel installation.."

if [   -d  "/usr/local/cpanel" ]; then
   echo -e "$GREEN cPanel YES $RESET"
else
   echo -e "$RED cPanel  NO $RESET"
   exit 1
fi
 
clear
echo -e "$GREEN          ************************************************************$RESET"
echo -e "$GREEN          *$RESET$WHITE      ApacheBooster Installation V 2.1          $GREEN*$RESET"
echo -e "$GREEN          *$RESET$WHITE   Copyright (c) 2012-2013  https://www.prajith.in/     $GREEN*$RESET"
echo -e "$GREEN          ************************************************************$RESET"
echo " "
echo " "
sleep 2
trap "" 2 20

exit_code()  
{
 if [ $? -ne $1 ]; then echo $2; fi; 
}

echo -e "$GREEN Installing tmpwatch mailx zlib-devel pcre-devel openssl-devel $RESET"
                 yum -y install tmpwatch mailx  zlib-devel pcre-devel openssl-devel dos2unix >/dev/null 2>&1
clear
dos2unix=`which dos2unix`
if  which incrond > /dev/null 2>&1
            then
            echo " $GREEN Found an existing incron installation .. $RESET "
else
	     #ripped from cloudlinux
	     rpm -q --whatprovides redhat-release > /dev/null 2>&1
             exit_code 0 "There is no package providing /etc/redhat-release, please install correct release package and try again" 
             OS="$(rpm -q --qf %{version} `rpm -q --whatprovides redhat-release` | cut -c 1)"
             bit=`uname -i`
                    if [ $bit = "i386" ] || [ $bit = "i686" ] || [ $bit = "i586" ] ; then
                             rpm -ivh "$CUDIR/packages/$OS/i386/incron*"
                     else
                            rpm -ivh "$CUDIR/packages/$OS/x86_64/incron*"

        fi
fi
echo -e  "Checking cPanel perl modules"

if [ ! -f /usr/local/cpanel/Cpanel/PublicAPI.pm ]; then
                error
               echo "Unable to find Cpanel::PublicAPI. This version of ApacheBooster"
               echo "requires Cpanel::PublicAPI."
               CPVERSION=$(cat /usr/local/cpanel/version)
               echo "You are currently running cPanel version $CPVERSION."
               echo "You should be running at least 11.32 to have Cpanel::PublicAPI."
               echo "Please update cPanel by running /scripts/upcp"
               echo "and then try installing ApacheBooster  again."
               exit;
fi
clear
echo ""
echo ""
echo "############################################################"
echo "# Installing Required Perl Modules. This may take a minute.#"
echo "# If any module installs fail, you will need to manually   #"
echo "# install the module using CPAN or /scripts/perlinstaller. #"
echo "############################################################"
echo ""
echo ""
REQUIREDMODULES=( "IPC::Open3" "JSON::Syck" "Data::Dumper" "XML::DOM" "Getopt::Long" "XML::Simple" "JSON" "IO::Select" )
NEEDSCHECK=()
NOTINSTALLED=()
ALLINSTALLED=1

PERLRESULT=$( perl -MCGI -e "1" 2>&1)
if [[ $PERLRESULT != "" ]]; then
        for i in "${REQUIREDMODULES[@]}"
        do
                echo "installing $i"
                echo "....."
                perl -MCPAN -e "install $i" >/dev/null 2>&1
        done
else
#Otherwise, test each module before install
        for i in "${REQUIREDMODULES[@]}"
        do
          foundmodule=$(perl -M$i -e "1" 2>&1)
          if [[ "$foundmodule" != "" ]]; then
             echo "$i is NOT installed"
                 echo "installing $i"
                 echo "....."
                 perl -MCPAN -e "install $i" >/dev/null 2>&1
                 echo "....."
                 NEEDSCHECK=( "${NEEDSCHECK[@]}" "$i" ) #prevent unset issues with array -1
          fi
        done
fi


SIZEOFNEEDS=${#NEEDSCHECK[@]}
if [[ "$SIZEOFNEEDS" -ge "1" ]]; then
        echo "$GREEN Testing the perl modules we just installed $RESET"
        echo "....."
        for i in "${NEEDSCHECK[@]}"
        do
                ismodulethere=$(perl -M$i -e "1" 2>&1)
                if [[ "$ismodulethere" == "" ]]; then
                        echo "$i is installed properly"
                        echo "....."
        else
                        echo "$i is NOT installed"
                        echo "....."
                        ALLINSTALLED=0
                        NOTINSTALLED=( "${NOTINSTALLED[@]}" "$i" )
                fi
        done

fi

if [[ "$ALLINSTALLED" != 1 ]]; then
        error
        echo "There was an error verifying that all required perl modules are installed."
        echo "The following perl modules could not be installed: "
        for i in "${NOTINSTALLED[@]}"
        do
                echo "$i"
        done
        echo "You can try installing these modules by running" 
        echo "/scripts/perlinstaller <module_name>"
        echo "for each module name listed above."
        echo "If you are unable to install the perl modules, please contact"
        echo "ApacheBooster support for assistance."
        echo "Support Address: prajithpalakkuda@gmail.com"
        exit 1
else
        echo ".....done"
fi
clear
if [ ! -f "latest_cpanel.sh" ]; then
   echo "Please change the working directory to Apachebooster folder"
   exit 1
fi

echo -e "$GREEN Checking for previous installation .. $RESET"
      if [ -d  "/usr/local/cpanel/whostmgr/cgi/ApacheBooster" -o -f "/usr/local/cpanel/whostmgr/cgi/addon_nginx.cgi" ]; then
               echo -e "$GREEN ApacheBooster already installed $RESET"
clear
echo -e "$GREEN Removing olde version $RESET"
               /etc/init.d/varnish stop
               /etc/init.d/nginx stop
               if [ -f "/usr/local/cpanel/whostmgr/cgi/addon_ApacheBooster.cgi" ]; then
                    $bin_rm -rvf /usr/local/cpanel/whostmgr/cgi/addon_ApacheBooster.cgi
                    $bin_rm -rvf /usr/local/cpanel/whostmgr/cgi/ApacheBooster
               elif [ -d "/usr/local/cpanel/whostmgr/cgi/ApacheBooster" ]; then
                    $bin_rm -rvf /usr/local/cpanel/whostmgr/cgi/ApacheBooster
               elif [ -d "/usr/local/cpanel/whostmgr/cgi/nginx" ]; then 
                    $bin_rm -rvf /usr/local/cpanel/whostmgr/cgi/addon_nginx.cgi
                    $bin_rm -rvf /usr/local/cpanel/whostmgr/cgi/nginx
               fi
               if [ -e "/scripts/ApacheBooster.pm" ]; then
                  rm -rvf /scripts/ApacheBooster.pm
               fi
               if [ -e "/usr/local/cpanel/Cpanel/ApacheBooster.pm" ]; then
                  rm -rvf /usr/local/cpanel/Cpanel/ApacheBooster.pm
               fi
               $bin_rm -rvf /scripts/account_modify_pre_apachebooster
               $bin_rm -rvf /scripts/account_modify_post_apachebooster
               $bin_rm -rvf /scripts/postwwwacct_apachebooster
               $bin_rm -rvf /scripts/installmod-rpf
               $bin_rm -rvf /scripts/installmodreverseproxy
               $bin_rm -rvf /scripts/installmodrpaf
               if [ -f "/scripts/installmodremoteip" ]; then
                  $bin_rm -rvf /scripts/installmodremoteip
               fi
               if [ -e "/scripts/incron_apachebooster" ]; then
                  rm -rvf /scripts/incron_apachebooster
               fi
               $bin_rm -rvf /scripts/preeasyapache
               $bin_rm -rvf /scripts/rebuildnginxconf
               $bin_rm -rvf /scripts/rebuildvhost
               $bin_rm -rvf /etc/ini.d/nginx
               $bin_rm -rvf /etc/init.d/varnish
               $bin_rm -rvf /etc/sysconfig/varnish
               $bin_rm -rvf /scripts/genevarnishconf
               $bin_rm -rvf /scripts/purgedomains.php
               $bin_rm -rvf /scripts/purgecache
               $bin_rm -rvf /scripts/prekillacct_apachebooster
               $bin_rm -rvf /scripts/whmapi.pl
               $bin_rm -rvf /scripts/adjustwrap
               $bin_rm -rvf /scripts/checkuserdomains
               $bin_rm -rvf /scripts/getfilettl
               $bin_rm -rvf /scripts/restartcheck
               $bin_rm -rvf /scripts/updateapachebooster
               $bin_rm -rvf /scripts/varnishurlexlude
               $bin_rm -rvf /usr/local/cpanel/hooks/addondomain/addaddondomain
               $bin_rm -rvf /usr/local/cpanel/hooks/subdomain/addsubdomain
               $bin_rm -rvf /usr/local/cpanel/hooks/addondomain/deladdondomain
               $bin_rm -rvf /usr/local/cpanel/hooks/subdomain/delsubdomain
               $bin_rm -rvf /usr/local/cpanel/hooks/park/park
               $bin_rm -rvf /usr/local/cpanel/hooks/park/unpark
               $bin_rm -rvf $nginx_prefix
               $bin_rm -rvf $varnish_prefix
               sed -i '/nobody*/d' /etc/security/limits.d/90-nproc.conf
               if [ -f "/etc/security/limits.conf.backup" ]; then
                  $bin_mv -f  /etc/security/limits.conf.backup  /etc/security/limits.conf
               fi
               if [ -f "/usr/local/cpanel/bin/manage_hooks" ]; then
	          /usr/local/cpanel/bin/manage_hooks  del script /scripts/postwwwacct_apachebooster --describe "Apachebooster" --category Whostmgr --event Accounts::Create --stage post >/dev/null 2>&1
                  /usr/local/cpanel/bin/manage_hooks  del script /scripts/prekillacct_apachebooster --describe "Apachebooster" --category Whostmgr --event Accounts::Remove --stage pre >/dev/null 2>&1
                  /usr/local/cpanel/bin/manage_hooks  del script /scripts/account_modify_post_apachebooster  --describe "Apachebooster" --category Whostmgr --event Accounts::Modify  --stage post >/dev/null 2>&1
                 /usr/local/cpanel/bin/manage_hooks  del script /scripts/account_modify_pre_apachebooster  --describe "Apachebooster" --category Whostmgr --event Accounts::Modify  --stage pre >/dev/null 2>&1
              fi
               cat /var/spool/cron/root | egrep -v "checkuserdomains|restartcheck|tmpwatch" > /tmp/cron.tmp
               mv -f /tmp/cron.tmp /var/spool/cron/root
               cat /var/spool/incron/root | egrep -v "incron_apachebooster|createvhost.pl|restartcheck" > /var/spool/incron/root
clear
echo -e "$GREEN Installing scripts $RESET"
               cd $CUDIR
               chown -R root.root conf/
               chown -R root.root scripts/
               chown -R root.root cgi/
               $bin_cp -prf conf/ApacheBooster.pm /usr/local/cpanel/Cpanel/
               chmod 700 scripts/* -R
               $bin_cp -prf  scripts/* /scripts/
               $bin_cp -prf  cgi/* /usr/local/cpanel/whostmgr/docroot/cgi/
               wget -O /usr/local/cpanel/whostmgr/cgi/ApacheBooster/version.txt http://prajith.in/version.txt
                  ./latest_cpanel.sh

else
clear
echo -e "$GREEN Installing scripts $RESET"
               cd $CUDIR
               chown -R root.root conf/
               chown -R root.root scripts/
               chown -R root.root cgi/
               $bin_cp -prf conf/ApacheBooster.pm /usr/local/cpanel/Cpanel/
               chmod 700 scripts/* -R
               $bin_cp -prf  scripts/* /scripts/
               $bin_cp -prf  cgi/* /usr/local/cpanel/whostmgr/docroot/cgi/
               wget -O /usr/local/cpanel/whostmgr/cgi/ApacheBooster/version.txt http://prajith.in/version.txt
                 ./latest_cpanel.sh
fi
clear
echo -e "$GREEN Installing WHM/cPanel hooks $RESET"
               cd $CUDIR
               $bin_mkdir -p /usr/local/cpanel/hooks/addondomain
               $bin_mkdir -p /usr/local/cpanel/hooks/subdomain
               $bin_mkdir -p /usr/local/cpanel/hooks/park
               $bin_cp -prvf hooks/addaddondomain  /usr/local/cpanel/hooks/addondomain/addaddondomain
               $bin_cp -prvf hooks/addsubdomain    /usr/local/cpanel/hooks/subdomain/addsubdomain
               $bin_cp -prvf hooks/deladdondomain  /usr/local/cpanel/hooks/addondomain/deladdondomain
               $bin_cp -prvf hooks/delsubdomain    /usr/local/cpanel/hooks/subdomain/delsubdomain
               $bin_cp -prvf hooks/park            /usr/local/cpanel/hooks/park/park
               $bin_cp -prvf hooks/unpark          /usr/local/cpanel/hooks/park/unpark
               /usr/local/cpanel/bin/manage_hooks  add script /scripts/postwwwacct_apachebooster --describe "Apachebooster" --category Whostmgr --event Accounts::Create --stage post >/dev/null 2>&1
               /usr/local/cpanel/bin/manage_hooks  add script /scripts/prekillacct_apachebooster --describe "Apachebooster" --category Whostmgr --event Accounts::Remove --stage pre >/dev/null 2>&1
               /usr/local/cpanel/bin/manage_hooks  add script /scripts/account_modify_post_apachebooster  --describe "Apachebooster" --category Whostmgr --event Accounts::Modify  --stage post >/dev/null 2>&1
               /usr/local/cpanel/bin/manage_hooks  add script /scripts/account_modify_pre_apachebooster  --describe "Apachebooster" --category Whostmgr --event Accounts::Modify  --stage pre >/dev/null 2>&1
               sed -i "s/$HTTPD -k .*/\\0\\n\\/etc\\/init.d\\/varnish \$ARGV/g" /usr/local/apache/bin/apachectl
               sed -i "s/$HTTPD -k .*/\\0\\n\\/etc\\/init.d\\/nginx \$ARGV/g" /usr/local/apache/bin/apachectl
               sed -i "s/$HTTPD -k .*/\\0\\n\\/etc\\/init.d\\/nginx \$ARGV/g" /etc/init.d/httpd
               sed -i "s/$HTTPD -k .*/\\0\\n\\/etc\\/init.d\\/varnish \$ARGV/g" /etc/init.d/httpd

clear
echo -e "$GREEN Registering  hooks $RESET"
               /usr/local/cpanel/bin/register_hooks

clear         

echo -e "$GREEN Creating varnish system user $RESET"
               /usr/sbin/groupadd -g 87 varnish 
               /usr/sbin/useradd -g 87 -u 87 varnish -s /sbin/nologin
clear
echo -e "$GREEN startig nginx installation $RESET"
               cd $CUDIR/packages/
               tar -xf  nginx-$nVERSION.tar.gz
               tar -xf  pcre-$pcreVERSION.tar.gz
               cd nginx-$nVERSION/
               ./configure --prefix=/usr/local/nginx/ \
                           --with-ipv6 \
                           --with-pcre=$CUDIR/packages/pcre-$pcreVERSION \
                           --with-http_realip_module  \
                           --with-http_mp4_module \
                           --with-http_flv_module  \
                           --http-proxy-temp-path=/tmp/nginx_proxy \
                           --http-fastcgi-temp-path=/tmp/nginx_fastcgi \
                           --http-client-body-temp-path=/tmp/nginx_client \
                           --with-http_stub_status_module &&  make  && make install
               if [ ! -d "/usr/local/nginx/" ]; then
                   clear
                   echo  "NginX installation failed"
                   exit 1
               fi
               $bin_rm -rvf  /usr/local/nginx/conf/nginx.conf
               if [ -f /usr/bin/dos2unix ]; then 
                  $dos2unix $CUDIR/conf/nginx.conf 
               fi
               $bin_cp -prf  $CUDIR/conf/nginx.conf /usr/local/nginx/conf/
               $bin_cp -prf  $CUDIR/conf/proxy.inc /usr/local/nginx/conf/
               $bin_cp -prf  $CUDIR/conf/cloud_flare.conf /usr/local/nginx/conf/
               $bin_cp -prf  $CUDIR/conf/nginx /etc/init.d/nginx
               $bin_cp -prf  $CUDIR/conf/cpanel_autodiscover.conf /usr/local/nginx/conf/
               chmod 775 /etc/init.d/nginx
               $bin_cp -prf  $CUDIR/conf/apachebooster /etc/init.d/apachebooster
               chmod 775 /etc/init.d/apachebooster
               chkconfig apachebooster on
echo -e "$GREEN Nginx installation completed $RESET"
clear
echo -e "$GREEN Rising system file descriptors $RESET"
	       echo "nobody       soft    nproc     10240" >> /etc/security/limits.d/90-nproc.conf
               echo -e "$RED Default /etc/security/limits.conf will be saved as /etc/security/limits.conf.backup $RESET"
               sleep 2
	       $bin_cp /etc/security/limits.conf /etc/security/limits.conf.backup
	       echo "nobody soft nofile 32768" >>/etc/security/limits.conf
	       echo "nobody hard nofile 32768" >>/etc/security/limits.conf
	       echo "root soft nofile 32768" >>/etc/security/limits.conf
	       echo "root hard nofile 32768" >>/etc/security/limits.conf
clear
echo -e "$GREEN startig varnish installation $RESET"
              cd $CUDIR/packages/
              tar -zxf docutils-0.7.tar.gz
              cd docutils-0.7/
              ./setup.py install  >/dev/null 2>&1
              sleep 1
              cd $CUDIR/packages/
              tar -zxf varnish-$vVERSION.tar.gz
              cd varnish-$vVERSION
              make clean 
              make distclean 
              ./configure --prefix=/usr/local/varnish/  && make  && make install
               if [ ! -d "/usr/local/varnish/" ]; then
                  clear
                  echo  "varnish installation failed"
                  exit 1
               fi
              $bin_rm -rvf /usr/local/varnish/etc/varnish/default.vcl
              $bin_cp -pvr $CUDIR/conf/varnishconf/*  /usr/local/varnish/etc/varnish/
              $bin_cp -pvr $CUDIR/conf/varnish /etc/init.d/varnish
              $bin_cp -pvr $CUDIR/conf/varnish.sys /etc/sysconfig/varnish
              mkdir /usr/local/varnish/var/run/
              mkdir -p /usr/local/varnish/varnish_restart
echo -e "$GREEN Varnish installation completed $RESET" 
clear
echo -e "$GREEN Creating cron $RESET"
              $bin_cp -prf /var/spool/cron/root /var/spool/cron/root-bak
              echo "0 */4 * * * /usr/sbin/tmpwatch -am 4 /tmp/nginx_client" >> /var/spool/cron/root
              echo '/var/cpanel/users IN_MODIFY,IN_NO_LOOP /scripts/incron_apachebooster $#' >>/var/spool/incron/root
              echo '/usr/local/varnish/varnish_restart IN_CREATE,IN_NO_LOOP /scripts/restartcheck' >>/var/spool/incron/root
              /etc/init.d/incrond restart >/dev/null 2>&1
              /sbin/chkconfig incrond on
              /etc/init.d/crond restart >/dev/null 2>&1
clear
echo -e "$GREEN Building varnish configuration files $RESET"
             /scripts/genevarnishconf
             /etc/init.d/varnish restart
             /sbin/chkconfig varnish on
             clear
echo -e "$GREEN  Building Nginx Virtualhost, This may take a while $RESET"
             /scripts/createvhost.pl;
             echo "Done....."

echo -e "$GREEN switching to apachebooster $RESET"
               if grep "apache_port"  /var/cpanel/cpanel.config  > /dev/null ; then
                  sed -i  's/apache_port=0.0.0.0:80/apache_port=0.0.0.0:82/g'  /var/cpanel/cpanel.config
                  /usr/local/cpanel/whostmgr/bin/whostmgr2 --updatetweaksettings >/dev/null 2>&1
               else
                  echo 'apache_port=0.0.0.0:82'  >> /var/cpanel/cpanel.config
                  /usr/local/cpanel/whostmgr/bin/whostmgr2 --updatetweaksettings >/dev/null 2>&1
               fi
               if [ -f "/etc/munin/plugins/apache_accesses" ]; then
                  echo  -e "$GREEN Changing Munin Apache Plugins Port $RESET"
                  sed -i 's/80/82/g' /etc/munin/plugins/apache_accesses /etc/munin/plugins/apache_processes /etc/munin/plugins/apache_volume
                  `which service` munin-node restart >/dev/null 2>&1
               fi
               /scripts/installmod-rpf >/dev/null 2>&1
               /scripts/rebuildnginxconf
               /scripts/rebuildhttpdconf >/dev/null 2>&1
               /scripts/restartsrv_httpd >/dev/null 2>&1
echo -e "$GREEN starting apachebooster $RESET"
                ps aux|grep varnish|awk '{print $2}'|xargs kill -9 >/dev/null 2>&1
               /etc/init.d/varnish restart
               /etc/init.d/nginx restart
               /etc/init.d/httpd restart >/dev/null 2>&1
echo  -e "$GREEN Checking Firewall $RESET"
               if [ -e "/etc/csf/csf.conf" ]; then
                    /scripts/csf_fix.pl
                else 
                     ERROR=1
                fi
clear
echo -e "$GREEN--------------------------------------------------------------------------------------$RESET"
echo -e "$RESET$WHITE                     Installation Completed $GREEN.$RESET"
echo -e "$RESET$WHITE            Please Go to  WHM->PLUGIN->APACHEBOOSTER $GREEN.$RESET"
echo -e "$RESET$WHITE             Please run the following command /etc/init.d/httpd restart $GREEN.$RESET"
echo -e "$RESET$WHITE         Please feel free to contact us, if you need any help $GREEN.$RESET"
echo -e "$RESET$WHITE                      EMAIL: prajithpalakkuda@gmail.com $GREEN.$RESET"
echo -e "$GREEN--------------------------------------------------------------------------------------$RESET"

if [ "$ERROR" ]; then
    echo -e "$GREEN--------------------------------------------------------------------------------------$RESET"
    echo -e "$RESET$RED        Please enable port 82,8082 and 6082 in your firewall $RED.$RESET"
    echo -e "$GREEN--------------------------------------------------------------------------------------$RESET"
fi
