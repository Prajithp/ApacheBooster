if (req.http.host ~ "^webmail\.") { set req.backend = webmail; set req.http.connection = "close"; return (pipe); }
if (req.http.host ~ "^cpanel\.") { set req.backend = cpanel; set req.http.connection = "close"; return (pipe); }
if (req.http.host ~ "^whm\.") { set req.backend = whm; set req.http.connection = "close"; return (pipe); }
if (req.http.host ~ "^webdisk\.") { set req.backend = webdisk; set req.http.connection = "close"; return (pipe); }
