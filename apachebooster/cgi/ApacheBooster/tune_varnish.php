<?php

error_reporting(1);
define(BUF_SIZ, 2048);        # max buffer size
define(FD_WRITE, 0);        # stdin
define(FD_READ, 1);        # stdout
define(FD_ERR, 2);        # stderr




function retrieve_current_ttl() {
	tune_varnish("/scripts/getfilettl -f");
}

function retrieve_current_static_ttl() {
	tune_varnish("/scripts/getfilettl -d");
}

function retrieve_current_bin() {
	tune_varnish("/scripts/getfilettl -b");
}


function proc_exec($cmd)
{
    $descriptorspec = array(
        0 => array("pipe", "r"),
        1 => array("pipe", "w"),
        2 => array("pipe", "w")
    );

    $ptr = proc_open($cmd, $descriptorspec, $pipes, NULL, $_ENV);
    if (!is_resource($ptr))
        return false;

    while (($buffer = fgets($pipes[FD_READ], BUF_SIZ)) != NULL
            || ($errbuf = fgets($pipes[FD_ERR], BUF_SIZ)) != NULL) {
        if (!isset($flag)) {
            $pstatus = proc_get_status($ptr);
            $first_exitcode = $pstatus["exitcode"];
            $flag = true;
        }
        if (strlen($buffer))
            echo $buffer;
        if (strlen($errbuf))
            echo "ERR: " . $errbuf;
    }

    foreach ($pipes as $pipe)
        fclose($pipe);

    /* Get the expected *exit* code to return the value */
    $pstatus = proc_get_status($ptr);
    if (!strlen($pstatus["exitcode"]) || $pstatus["running"]) {
        /* we can trust the retval of proc_close() */
        if ($pstatus["running"])
            proc_terminate($ptr);
        $ret = proc_close($ptr);
    } else {
        if ((($first_exitcode + 256) % 256) == 255
                && (($pstatus["exitcode"] + 256) % 256) != 255)
            $ret = $pstatus["exitcode"];
        elseif (!strlen($first_exitcode))
            $ret = $pstatus["exitcode"];
        elseif ((($first_exitcode + 256) % 256) != 255)
            $ret = $first_exitcode;
        else
            $ret = 0; /* we "deduce" an EXIT_SUCCESS ;) */
        proc_close($ptr);
    }

    return ($ret + 256) % 256;
}
function tune_varnish($action){
	
        proc_exec($action);
}

function action_varnish($init){
$handle = popen("$init", 'r');
while(!feof($handle)) {
    $ret = fgets($handle);
    echo "<b>$ret</b><br/>\n";
    ob_flush();
    flush();
        }
pclose($handle);
}



print('
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="stylesheet" type="text/css" href="style.css"></link>
</head>
<body>
<div class="content1">
');

?>
<p>


<form action="tune_varnish.php" method="post">
<strong>Dynamic File cache TTL&nbsp;&nbsp; </strong>(seconds):
<input type="input" name="ttl" value="<?php retrieve_current_ttl(); ?>">
<input type="submit" name="submit" value="submit"> <strong>Hint</strong>: Higher means faster browsing & low server load.
</form>

<form action="tune_varnish.php" method="post">
<strong>Static File Cache TTL</strong>(minutes):&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="input" name="staticttl" value="<?php retrieve_current_static_ttl(); ?>">
<input type="submit" name="submit" value="submit"> <strong>Hint</strong>: Caching period for static files (png, css, etc).
</form>


<form action="tune_varnish.php" method="post">
<strong>Memory Cache&nbsp;&nbsp; </strong>(100M,1G,4G,etc):&nbsp;
<input type="input" name="bin" value="<?php retrieve_current_bin(); ?>">
<input type="submit" name="submit" value="submit"> <strong><font color="red">Caution</font></strong>: Please set it to below  2GB on 32-bit OS.

</form>
<div class="content1">
<h3><font color="#0570b9">Exclude url's and files from varnish caching</font</h3>
<form action="tune_varnish.php" method="post">
<textarea name='newd' cols='50%' rows='15'>
<?php
$flines=file("/usr/local/varnish/etc/varnish/exclude.url.tpl");
foreach ($flines as $line_num => $line){
echo $line;
}
?>
</textarea>
<br /><br />
<input type="submit" name="submit" value="Update">
</form>
</p>
<br /><br /><br /><br /><br />

<P>
<form action="listaccts.cgi" method="GET">
<strong><font color="#0570b9">Exclude Domain from varnish caching </font></strong> <input type="submit" name="submit" value="Show Now">
</form>
</p>

<br /><br /><br /><br /><br />
</p>


<?php
if(isset($_POST['submit'])){
$fh = fopen("/usr/local/varnish/varnish_restart/restart.file",'w' );
fwrite($fh,1);
fclose($fh);
	if(isset($_POST['ttl'])) {
		tune_varnish("/scripts/adjustwrap -cd " .  $_POST['ttl']);
		echo "<meta http-equiv=refresh content=\"0; URL=tune_varnish.php\">";
	}
        if(isset($_POST['bin'])) {
                tune_varnish("/scripts/adjustwrap -cb " .  $_POST['bin']);
		echo "<meta http-equiv=refresh content=\"0; URL=tune_varnish.php\">";
        }
        if(isset($_POST['staticttl'])) {
                tune_varnish("/scripts/adjustwrap -cs " .  $_POST['staticttl']);
                echo "<meta http-equiv=refresh content=\"0; URL=tune_varnish.php\">";
        }
 if(isset($_POST['newd'])) {
           $fh = fopen("/usr/local/varnish/etc/varnish/exclude.url.tpl",'w' );
fwrite($fh,$_POST['newd']);
fclose($fh);
 tune_varnish("/scripts/varnishurlexlude");
echo "<meta http-equiv=refresh content=\"0; URL=tune_varnish.php\">";
}
}

?>
</p>
<br /><br /><br /><br /><br />

<?php include('footer.php'); ?>
</div>

