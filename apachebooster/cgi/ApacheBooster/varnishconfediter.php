<?php
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
<h3><font color="#0570b9">Edit  Varnish Master  Configuration</font</h3>
');

?>

<p>
<?php
if(isset($_POST['submit'])){
$fh = fopen("/usr/local/varnish/etc/varnish/default.vcl.tpl",'w' );
fwrite($fh,$_POST['newd']);
fclose($fh);
$fh2 = fopen("/usr/local/varnish/etc/varnish/default.vcl",'w' );
fwrite($fh2,$_POST['newd']);
fclose($fh2);
echo "<font color=\"green\">Varnish master configurations updated. You may need to restart ApacheBooster server  now</font>";
}else{
?>
<form action="varnishconfediter.php" method="post">
<textarea name='newd' cols='100%' rows='30'> 
<?php
$flines=file("/usr/local/varnish/etc/varnish/default.vcl");
foreach ($flines as $line_num => $line){ 
echo $line;
}
?>
</textarea>
<br /><br />
<input type="submit" name="submit" value="Update">
</form>
<?php
}
?>
</p>
<br /><br /><br /><br /><br />

<?php include('footer.php'); ?>
</div>
