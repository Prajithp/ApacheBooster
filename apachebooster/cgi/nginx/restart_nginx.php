<?php

error_reporting(1);
define(BUF_SIZ, 2048);        # max buffer size
define(FD_WRITE, 0);        # stdin
define(FD_READ, 1);        # stdout
define(FD_ERR, 2);        # stderr



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


print('
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="stylesheet" type="text/css" href="style.css"></link>
</head>
<body>
<div style="clear: both"></div>

<div class="content1">
');

?>
<p>

<form action="restart_nginx.php" method="post">
<strong><font color="#0570b9">Restart ApacheBooster Server </font></strong> <input type="submit" name="submit" value="Restart">
</form>
<?php
if(isset($_POST['submit'])){
  $f=fopen("/usr/local/varnish/varnish_restart/restart.file",'w');
fwrite($f,"dummy");
        fclose($f);
        echo "<b>ApacheBooster restart process completed </b><br />";
echo "<pre>";
proc_exec("/etc/init.d/httpd status");
echo "</pre>";
}
?>

</p>
<br /><br /><br /><br /><br />
<?php
include('footer.php');
?>

