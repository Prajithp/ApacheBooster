#!/bin/sh
eval 'if [ -x /usr/local/cpanel/3rdparty/bin/perl ]; then exec /usr/local/cpanel/3rdparty/bin/perl -x -- $0 ${1+"$@"}; else exec /usr/bin/perl -x $0 ${1+"$@"}; fi;'
  if 0;

#!/usr/bin/perl
BEGIN{ unshift(@INC, '/usr/local/cpanel'); }


use Cpanel::Config::LoadUserDomains ();
use Data::Dumper ();
use Whostmgr::ACLS ();
Whostmgr::ACLS::init_acls();


if (!Whostmgr::ACLS::hasroot()) {
  print "You do not have access to this plugin.\n";
  exit();
}
local ($buffer, @pairs, $pair, $name, $value, %FORM);
# Read in text
$ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;
if ($ENV{'REQUEST_METHOD'} eq "POST")
{
  print "Content-type:text/html\r\n\r\n";
  read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
  # Split information into name/value pairs                                                                                                                             
  @pairs = split(/&/, $buffer);
  open(FILEE, ">", "/usr/local/varnish/etc/varnish/exclude.vhost.tpl") or die $!;
  foreach $pair (@pairs)
  {
    ($name, $value) = split(/=/, $pair);
    $value =~ tr/+/ /;
    $value =~ s/%(..)/pack("C", hex($1))/eg;
    $FORM{$name} = $value;
    $disable = $FORM{tmps};
    if ($disable ) 
    {
      @disable = split(',', $disable);
      foreach my $val (@disable) {
      print FILEE "$val\n";
    }
    `/scripts/varnishvhostexclude`;
    } 
    else 
    { 
      `/scripts/varnishvhostexclude`; 
    }
  }
  close FILEE;
  print "<a href=\"./restart_nginx.php\">Click here to restart Apachebooster</a>";
} 
else 
{

print "Content-type:text/html\r\n\r\n";

print <<HTML;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="stylesheet" type="text/css" href="style.css"></link>

                <script type='text/javascript'>
                      
function addOption(theSel,theText,theValue){
   var newOpt=new Option(theText,theValue);
   var selLength=theSel.length;
   theSel.options[selLength]=newOpt;
  }
  function deleteOption(theSel,theIndex){
   var selLength=theSel.length;
   if(selLength>0){
    theSel.options[theIndex]=null;
   }
  }
  function selAll() {
    elem=document.getElementById('receiver');
    varr=new Array();
    for (d=0;d<elem.length;d++){
      varr[d]=elem.options[d].value;
    }
    vars=varr.join(",");
    tmps=document.getElementById('tmps');
    tmps.value=vars;
  }
  function moveOptions(SFrom,STo){
   var theSelFrom = document.getElementById(SFrom);
   var theSelTo = document.getElementById(STo);
   var selLength=theSelFrom.length;
   var selectedText=new Array();
   var selectedValues=new Array();
   var selectedCount=0;
   var i;
   for(i=selLength-1;i>=0;i--){
    if(theSelFrom.options[i].selected){
     selectedText[selectedCount]=theSelFrom.options[i].text;
     selectedValues[selectedCount]=theSelFrom.options[i].value;
     deleteOption(theSelFrom,i);
     selectedCount++;
    }
   }
   for(i=selectedCount-1;i>=0;i--){
    addOption(theSelTo,selectedText[i],selectedValues[i]);
   }
   selAll();
  }
  function swapOpt(shift) {
    elem=document.getElementById('receiver');
    ind=elem.selectedIndex;
    if(ind!=-1) {
      if(ind==0 && shift==-1){return false;}
      if(ind==elem.length-1 && shift==1){return false;}
      nind=ind+shift;
        tval=elem.options[nind].value;
        ttxt=elem.options[nind].text;
        elem.options[nind].value=elem.options[ind].value;
        elem.options[nind].text=elem.options[ind].text;
        elem.options[ind].value=tval;
        elem.options[ind].text=ttxt;
        elem.selectedIndex=nind;
      selAll();
    }
  }
  function frmCheck() {
    if(document.form1.tmps.value=="") {
      return true;
    }
  }


</script>
        </head>
        <body>


HTML
print <<HTML1;
<div class="content1">
<h3><font color="#0570b9">Exclude url's and files from varnish caching</font</h3>
 <form name="form1" method="post" action="listaccts.cgi" onsubmit="return frmCheck();">
    <table class="form" cellpadding="3" cellspacing="1">
      <tr>
        <td><select size="20" style="width:350px;" name="sender" id="sender" ondblclick="moveOptions('sender','receiver')">
HTML1

  &listdomaini2;
print <<HTML3; 
          </select>
        </td>
        <td><input value="&#9658;" type="button" onclick="moveOptions('sender','receiver')" 

/>
          <br />
          <input  value="&#9668;" type="button" onclick="moveOptions('receiver','sender')" 

/>
        </td> 
<td><select size="20" style="width:350px;" id="receiver" name="receiver" ondblclick="moveOptions('receiver','sender')">
HTML3
&read_tpl;
print <<HTML4;

 </select>
          <input type="hidden" name="tmps" id="tmps" value="" />
        </td>
        </td>
      </tr>
      <tr>
        <td colspan="4" align="center"><input class="inputBut" type="submit" value="Submit" 

/></td>
      </tr>
    </table>
  </form>
</div>
</body>
</html>
HTML4
}

sub listdomaini2
{
  Cpanel::Config::LoadUserDomains::loaduserdomains( \%USER_DOMAINS, 1 );
  open my $fh, '<', '/usr/local/varnish/etc/varnish/exclude.vhost.tpl' or die $!;
  my @goodfile = <$fh>;
  foreach my $domain ( sort keys %USER_DOMAINS ) {
    next if ( $domain =~ m/^\*/ );
    next if ( grep(/^$domain/i, @goodfile) );
    print "<option value=\"$domain\">$domain</option>\n";
  }
}

sub read_tpl
{
  open(FILE, "/usr/local/varnish/etc/varnish/exclude.vhost.tpl");
  while ($line = <FILE>) 
  {
    chomp $line;
    print "<option value=\"$line\">$line</option>\n";
  } 
}

