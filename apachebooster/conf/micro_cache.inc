####
## Ripped from https://gist.github.com/fennb/1283573
####

# Setup var defaults
set $no_cache "";
 
# If non GET/HEAD, don't cache & mark user as uncacheable for 1 second via cookie
if ($request_method !~ ^(GET|HEAD)$) 
{
  set $no_cache "1";
}
 
# Drop no cache cookie if need be
# (for some reason, add_header fails if included in prior if-block)
if ($no_cache = "1") 
{
  add_header Set-Cookie "_mcnc=1; Max-Age=2; Path=/";
  add_header X-Microcachable "0";
}
 
# Bypass cache if no-cache cookie is set
if ($http_cookie ~* "_mcnc") 
{
  set $no_cache "1";
}
 
# Bypass cache if flag is set
proxy_no_cache $no_cache;
proxy_cache_bypass $no_cache;
 
# Set cache zone
proxy_cache microcache;
 
# Set cache key to include identifying components
proxy_cache_key $scheme$host$request_method$request_uri;
 
# Only cache valid HTTP 200 responses for 1 second
proxy_cache_valid 200 1s;
 
# Serve from cache if currently refreshing
proxy_cache_use_stale updating;
 
# Set files larger than 1M to stream rather than cache
proxy_max_temp_file_size 1M;
 
# Custom logging
#access_log logs/microcache.log custom;
