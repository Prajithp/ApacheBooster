if (req.url ~ "wp-admin") { set req.http.connection = "close"; return (pipe); }
if (req.url ~ "wp-login\.php") { set req.http.connection = "close"; return (pipe); }
if (req.url ~ "test\.html") { set req.http.connection = "close"; return (pipe); }
if (req.url ~ "index\.jpg") { set req.http.connection = "close"; return (pipe); }
