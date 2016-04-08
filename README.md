# Ruby + Nginx

This Docker image contains the basics to run a Ruby app with nginx.
Running the app is delegated to supervisord, so it just requires
a small configuration file in /etc/supervisord/conf.d, like the
following one:

```
[program:nginx]
command=/usr/sbin/nginx

[program:app]
command=/home/app/myappinit.sh
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
```

And nginx configuration should be placed in /etc/nginx/conf.d,
which is included in the http directive, the following is an
example of it:

```
upstream app {
  server unix:/home/app/current/tmp/app.sock fail_timeout=0;
}

server {
  listen      80;
  server_name _;

  root /home/app/current/public;

  error_page 500 502 503 504 /500.html;
  location = /500.html {
    root /home/app/current/public;
  }

  try_files $uri @app;
  location @app {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://app;
  }
}
```
