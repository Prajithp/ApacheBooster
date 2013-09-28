backend webmail {
.host = "127.0.0.1";
.port = "2095";
.connect_timeout = 600s;
.first_byte_timeout = 600s;
.between_bytes_timeout = 600s;
.max_connections = 800;
}

backend whm {
.host = "127.0.0.1";
.port = "2086";
.connect_timeout = 600s;
.first_byte_timeout = 600s;
.between_bytes_timeout = 600s;
.max_connections = 800;
}

backend cpanel {
.host = "127.0.0.1";
.port = "2082";
.connect_timeout = 600s;
.first_byte_timeout = 600s;
.between_bytes_timeout = 600s;
.max_connections = 800;
}

backend webdisk {
.host = "127.0.0.1";
.port = "2077";
.connect_timeout = 600s;
.first_byte_timeout = 600s;
.between_bytes_timeout = 600s;
.max_connections = 800;
}

