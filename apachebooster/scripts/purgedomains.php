<?php
# get param
$url = "/";
$host = $argv[1];
 
  $ip = "127.0.0.1";
  $port = "8082";
 
  $timeout = 1;
  $verbose = 1; 
  # inits
  $sock = fsockopen ($ip,$port,$errno, $errstr,$timeout);
  if (!$sock) { echo "connections failed $errno $errstr"; exit; }
 
  if ( !($url || $host) ) { echo "No params"; exit; }
 
  stream_set_timeout($sock,$timeout);
 
  $pcommand = "purge";
  # Send command
  $pcommand .= ".hash $url#$host#";
 
  put ($pcommand);
  put ("quit");
 
  fclose ($sock);
 
  function readit() {
    global $sock,$verbose;
    if (!$verbose) { return; }
    while ($sockstr = fgets($sock,1024)) {
      $str .= "rcv: " . $sockstr . "
";
    }
    if ($verbose) { echo "$str\n"; }
  }
 
  function put($str) {
    global $sock,$verbose;
    fwrite ($sock, $str . "\r\n");
    if ($verbose) { echo "send: $str 
\n"; }
    readit();
  }
?>
