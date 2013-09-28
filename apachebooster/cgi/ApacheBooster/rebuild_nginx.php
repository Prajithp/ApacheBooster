<?php
function rebuild($cmd){
$handle = popen("$cmd", 'r');
while(!feof($handle)) {
    $buffer = fgets($handle);
    echo "$buffer<br/>\n";
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
<div style="clear: both"></div>

<div class="content1">
');

?>
<p>

<form action="rebuild_nginx.php" method="post">
<strong><font color="#0570b9">Rebuild Nginx configuration file and Restart Nginx server </font></strong> <input type="submit" name="submit" value="Rebuild Now">
</form>
<?php
if(isset($_POST['submit'])){
echo "Rebuilding Nginx conf";
rebuild("/scripts/rebuildnginxconf");

}
?>
</p>
<br /><br /><br /><br /><br />
<?php
include('footer.php');
?>
