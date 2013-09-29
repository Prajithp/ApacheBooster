 
###############################################
# Created by Prajith
# http://prajith.in
#                                              
###############################################
include "/usr/local/varnish/etc/varnish/cpanel.backend.vcl";
include "/usr/local/varnish/etc/varnish/vhost.vcl";

sub vcl_recv {
set req.backend = default;
include "/usr/local/varnish/etc/varnish/acl.vcl";
include "/usr/local/varnish/etc/varnish/vhost.exclude.vcl";
set req.grace = 5m;

   # Handle IPv6
   if (req.http.Host ~ "^ipv6.*") {
        set req.http.host = regsub(req.http.host, "^ipv6\.(.*)","www\.\1");
   }


    # Sanitise X-Forwarded-For...
    remove req.http.X-Forwarded-For;
    set req.http.X-Forwarded-For = client.ip;
     include "/usr/local/varnish/etc/varnish/cpanel.url.vcl"; 
    # Remove has_js and Google Analytics cookies.
    set req.http.Cookie = regsuball(req.http.Cookie, "(^|;\s*)(__[a-z]+|has_js)=[^;]*", "");
    # Remove a ";" prefix, if present.
    set req.http.Cookie = regsub(req.http.Cookie, "^;\s*", ""); 
    # Normalize the Accept-Encoding header
    if (req.http.Accept-Encoding) {
        if (req.url ~ "\.(jpg|jpeg|png|gif|gz|tgz|bz2|tbz|mp3|ogg|swf|flv|pdf|ico)$") {
            # No point in compressing these
            remove req.http.Accept-Encoding;
        } elsif (req.http.Accept-Encoding ~ "gzip") {
            set req.http.Accept-Encoding = "gzip";
        } elsif (req.http.Accept-Encoding ~ "deflate") {
            set req.http.Accept-Encoding = "deflate";
        } else {
            # unknown algorithm
            remove req.http.Accept-Encoding;
        }
    }

include "/usr/local/varnish/etc/varnish/url.exclude.vcl"; 
    # Ignore empty cookies
    if (req.http.Cookie ~ "^\s*$") {
        remove req.http.Cookie;
    }
    
          if (req.request == "PURGE") {
        if (!client.ip ~ acl127_0_0_1) {error 405 "Not permitted";}
        return (lookup);
}

    if (req.request != "GET" &&
       req.request != "HEAD" &&
       req.request != "POST" &&
       req.request != "PUT" &&
       req.request != "PURGE" &&
       req.request != "DELETE" ) {
    return (pipe);    
}

    if (req.request != "GET" && req.request != "HEAD") {
        /* We only deal with GET and HEAD by default, the rest get passed direct to backend */
        return (pass);
    }
   


if (req.http.Cookie ~ "^\s*$") {
        unset req.http.Cookie;
}


    if (req.http.Authorization || req.http.Cookie) {
        return (pass);
    }
 
set req.url = regsub(req.url, "\.js\?.*", ".js");
set req.url = regsub(req.url, "\.css\?.*", ".css");
set req.url = regsub(req.url, "\.jpg\?.*", ".jpg");
set req.url = regsub(req.url, "\.gif\?.*", ".gif");
set req.url = regsub(req.url, "\.swf\?.*", ".swf");
set req.url = regsub(req.url, "\.xml\?.*", ".xml");

# Cache things with these extensions
if (req.url ~ "\.(js|css|jpg|jpeg|png|gif|gz|tgz|bz2|tbz|mp3|ogg|swf|pdf)$" && ! (req.url ~ "\.(php)") ) {
    unset req.http.Cookie;
    return (lookup);
}

    
return (lookup);
}


sub vcl_fetch {

set beresp.ttl = 45s;
set beresp.http.Server = " - ApacheBooster by http://www.prajith.in";

set beresp.do_gzip = true;
set beresp.do_gunzip = false;
set beresp.do_stream = false;
set beresp.do_esi = false;

set beresp.grace = 5m;

unset beresp.http.expires;
if (req.url ~ "\.(js|css|jpg|jpeg|png|gif|gz|tgz|bz2|tbz|mp3|ogg|swf|pdf|ico)$" && ! (req.url ~ "\.(php)") ) {
        unset beresp.http.set-cookie;
       include  "/usr/local/varnish/etc/varnish/static_file.vcl";
}
else {
         include  "/usr/local/varnish/etc/varnish/dynamic_file.vcl";
}

if (beresp.status == 503 || beresp.status == 500) {
        set beresp.http.X-Cacheable = "NO: beresp.status";
        set beresp.http.X-Cacheable-status = beresp.status;
        return (hit_for_pass);
}

if (beresp.status == 404) {
        set beresp.http.magicmarker = "1";
        set beresp.http.X-Cacheable = "YES";
        set beresp.ttl = 20s;
        return (deliver);
}

set beresp.http.magicmarker = "1";
set beresp.http.X-Cacheable = "YES";


}
sub vcl_deliver {

if ( obj.hits == 0 ) {
  set req.http.X-Stats-HitMiss = "miss";
 } else {
  set req.http.X-Stats-HitMiss = "hit";
 }

}
