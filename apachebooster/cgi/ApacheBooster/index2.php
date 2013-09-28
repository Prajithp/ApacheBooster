
<?php


function Nginx_status($status){
        $handle = popen("$status", 'r');
        while(!feof($handle)) {
                $ret = fgets($handle);
                echo "<b>$ret</b>";
                ob_flush();
                flush();
        }
        pclose($handle);
}

?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="stylesheet" type="text/css" href="style.css"></link>
</head>
<body>
<div class="content2">
<strong><font color="#0570b9">Apachebooster Status:</font> <?php Nginx_status("if  pgrep nginx   &> /dev/null; then echo -ne \"<font color=\"green\">Online</font>\"; else echo -ne \"<font color=\"red\">Offline</font>\"; fi "); ?></strong>&nbsp;&nbsp;&nbsp;&nbsp;<strong><font color="#0570b9">ApacheBooster Version: </font><font color="green"><?php echo  shell_exec('cat version.txt'); ?></font></strong><br /> <br /> <br />

<div  id="contentimg" style="float:left;" ><a href="restart_nginx.php"><img width="45px" height="45px" img src="./images/restartservices.png" alt="alt" border="0"/></a><br/><a href="restart_nginx.php" >Restart ApacheBooster</a></div>
<div  id="contentimg" style="float:left;"><a href="rebuild_nginx.php"><img  width="45px" height="45px" src="./images/configure.png" alt="alt" border="0"/></a><br/><a href="rebuild_nginx.php" >Rebuild nginx Conf</a></div>
<div  id="contentimg" style="float:left;"><a href="rebuild_vhost.php"><img width="45px" height="45px"  src="./images/playpause.png" alt="alt" border="0"/></a><br/><a href="rebuild_vhost.php" >Rebuild Vhosts</a></div>

<div  id="contentimg" style="float:left;"><a href="confediter.php"><img width="45px" height="45px" src="./images/advanced.png" alt="alt" border="0"/></a><br/><a href="confediter.php" >Nginx Conf Editor</a></div>
<div  id="contentimg" style="float:left;"><a href="varnishconfediter.php"><img width="45px" height="45px" src="./images/veditor.png" alt="alt" border="0"/></a><br/><a href="varnishconfediter.php" >Varnish Conf Editor</a></div>

<div  id="contentimg" style="float:left;"><a href="tune_varnish.php"><img width="45px" height="45px"  src="./images/tune.png" alt="alt" border="0"/></a><br/><a href="tune_varnish.php" >Varnish Tunner</a></div>
<div  id="contentimg" style="float:left;"><a href="rebuild_ip.php"><img width="45px" height="45px"  src="./images/rebuildip.png" alt="alt" border="0"/></a><br/><a href="rebuild_ip.php" >Rebuild IP Pool</a></div>
<div  id="contentimg" style="float:left;"><a href="stats.php"><img width="45px" height="45px" src="./images/stats.png" alt="alt" border="0"/></a><br/><a href="stats.php" >Show connection stats</a></div>
<div  id="contentimg" style="float:left;"><a href="purge_varnish.php"><img width="45px" height="45px" src="./images/time.png" alt="alt" border="0"/></a><br/><a href="purge_varnish.php" >Purge Varnish Cache</a></div>
<div  id="contentimg" style="float:left;"><a href="upgrade.php"><img width="45px" height="45px" src="./images/upgrade.png" alt="alt" border="0"/></a><br/><a href="upgrade.php" >Check for upgrade</a></div>
</div>
<br /><br /><br /><br /><br />
<?php include('footer.php');
?>
</div>
