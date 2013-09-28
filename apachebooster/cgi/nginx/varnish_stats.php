<?
function varnish_stats($stats){
$handle = popen("$stats", 'r');
while(!feof($handle)) {
    $ret = fgets($handle);
    echo "$ret<br/>\n";
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
<center><A HREF="javascript:history.go(0)"><b>Refresh</b></A></center>
<strong>Varnish Memory Usage: </strong>
<br /><br />
<?php $mem = varnish_stats("echo $(/bin/ps -u varnish -o rss | /usr/bin/awk '{sum+=$1} END {print sum}') KBytes");?>
<br /><br />
<strong>Varnish Stats: </strong><br />

<table align="left" border="0" cellspacing="0" cellpadding="0" width="100%">
<tr align="left">
<td align="left" valign="top">
<?php

varnish_stats("/usr/local/varnish/bin/varnishstat -1 -f cache_hit,cache_miss,backend_fail,backend_busy,client_drop,client_conn,client_req,backend_unhealthy,backend_req,backend_conn,backend_reuse,backend_recycle,backend_unused,n_wrk,n_wrk_create,n_wrk_failed,n_wrk_max,n_wrk_queue,n_wrk_overflow,n_wrk_drop,n_backend,n_expired,n_lru_nuked,n_lru_saved,n_lru_moved,n_deathrow,n_vcl,n_vcl_avail,n_vcl_discard,n_purge,n_purge_add,n_purge_retire,n_purge_obj_test,n_purge_re_test,n_purge_dups,accept_fail,client_drop_late,backend_retry,dir_dns_lookups,dir_dns_failed,dir_dns_hit,dir_dns_cache_full,sm_balloc,sm_bfree,s_sess,s_req,s_pipe,s_pass,s_fetch,s_hdrbytes,s_bodybytes,sess_closed,sess_pipeline,sess_readahead,sess_linger,sess_herd,uptime|awk '{print $1\": \" $2}'");

?>
</td>
<br /><br />
<td align="left">

<table class="legend">
<tr><td>client_conn</td><td>Client connections accepted</td></tr>
<tr><td>client_drop</td><td>Connection dropped no sess/wrk</td></tr>
<tr><td>client_req</td><td>Client requests received</td></tr>
<tr><td>cache_hit</td><td>Cache hits</td></tr>
<tr><td>cache_miss</td><td>Cache misses</td></tr>
<tr><td>backend_conn</td><td>Backend conn. success</td></tr>
<tr><td>backend_unhealthy</td><td>Backend conn. not attempted</td></tr>
<tr><td>backend_busy</td><td>Backend conn. too many</td></tr>
<tr><td>backend_fail</td><td>Backend conn. failures</td></tr>
<tr><td>backend_reuse</td><td>Backend conn. reuses</td></tr>
<tr><td>backend_recycle</td><td>Backend conn. recycles</td></tr>
<tr><td>backend_unused</td><td>Backend conn. unused</td></tr>
<tr><td>n_wrk</td><td>N worker threads</td></tr>
<tr><td>n_wrk_create</td><td>N worker threads created</td></tr>
<tr><td>n_wrk_failed</td><td>N worker threads not created</td></tr>
<tr><td>n_wrk_max</td><td>N worker threads limited</td></tr>
<tr><td>n_wrk_queue</td><td>N queued work requests</td></tr>
<tr><td>n_wrk_overflow</td><td>N overflowed work requests</td></tr>
<tr><td>n_wrk_drop</td><td>N dropped work requests</td></tr>
<tr><td>n_backend</td><td>N backends</td></tr>
<tr><td>n_expired</td><td>N expired objects</td></tr>
<tr><td>n_lru_nuked</td><td>N LRU nuked objects</td></tr>
<tr><td>n_lru_saved</td><td>N LRU saved objects</td></tr>
<tr><td>n_lru_moved</td><td>N LRU moved objects</td></tr>
<tr><td>n_deathrow</td><td>N objects on deathrow</td></tr>
<tr><td>s_sess</td><td>Total Sessions</td></tr>
<tr><td>s_req</td><td>Total Requests</td></tr>
<tr><td>s_pipe</td><td>Total pipe</td></tr>
<tr><td>s_pass</td><td>Total pass</td></tr>
<tr><td>s_fetch</td><td>Total fetch</td></tr>
<tr><td>s_hdrbytes</td><td>Total header bytes</td></tr>
<tr><td>s_bodybytes</td><td>Total body bytes</td></tr>
<tr><td>sess_closed</td><td>Session Closed</td></tr>
<tr><td>sess_pipeline</td><td>Session Pipeline</td></tr>
<tr><td>sess_readahead</td><td>Session Read Ahead</td></tr>
<tr><td>sess_linger</td><td>Session Linger</td></tr>
<tr><td>sess_herd</td><td>Session herd</td></tr>
<tr><td>sm_balloc</td><td>bytes allocated</td></tr>
<tr><td>sm_bfree</td><td>bytes free</td></tr>
<tr><td>backend_req</td><td>Backend requests made</td></tr>
<tr><td>n_vcl</td><td>N vcl total</td></tr>
<tr><td>n_vcl_avail</td><td>N vcl available</td></tr>
<tr><td>n_vcl_discard</td><td>N vcl discarded</td></tr>
<tr><td>n_purge</td><td>N total active purges</td></tr>
<tr><td>n_purge_add</td><td>N new purges added</td></tr>
<tr><td>n_purge_retire</td><td>N old purges deleted</td></tr>
<tr><td>n_purge_obj_test</td><td>N objects tested</td></tr>
<tr><td>n_purge_re_test</td><td>N regexps tested against</td></tr>
<tr><td>n_purge_dups</td><td>N duplicate purges removed</td></tr>
<tr><td>accept_fail</td><td>Accept failures</td></tr>
<tr><td>client_drop_late</td><td>Connection dropped late</td></tr>
<tr><td>uptime</td><td>Client uptime</td></tr>
<tr><td>backend_retry</td><td>Backend conn. retry</td></tr>
<tr><td>dir_dns_lookups</td><td>DNS director lookups</td></tr>
<tr><td>dir_dns_failed</td><td>DNS director failed lookups</td></tr>
<tr><td>dir_dns_hit</td><td>DNS director cached lookups hit</td></tr>
<tr><td>dir_dns_cache_full</td><td>DNS director full dnscache</td></tr>
</table>

</td>
</tr>
</table>

</p>
<center><A HREF="javascript:history.go(0)"><b>Refresh</b></A></center>
<br /><br />

<?php include('footer.php'); ?>
</div>

