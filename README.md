Gantry
======

An etcd backed docker container loader with dynamic configuration.

**Functions**

* generates config files from templates when backend services changed.
* checks the config files and launches container process (as PID=1)
* Now it has its own service registration (from v0.2)
* Adds/removes entries also for Skydns2 (from v0.3)

docker hub: [s21g/gantry](https://hub.docker.com/r/s21g/gantry/)

Prerequisites:

 * etcd cluster (with v2 API)

USAGE:

Run gantry container for each docker host with options as follows:

```shell
docker run --name gantry --volumes-from etcd --link etcd \
  -v /var/run/docker.sock:/tmp/docker.sock \
  -v /var/lib/gantry:/var/lib/gantry \
  -e ETCD_ENDPOINT=https://etcd:2379 \
  -e ETCD_CAFILE=/certs/ca.crt \
  -e ETCD_CERTFILE=/certs/client.crt \
  -e ETCD_KEYFILE=/certs/client.key \
  s21g/gantry
```

Then, run docker containers using with gantry like this:

```
docker run -v /var/lib/gantry:/var/lib/gantry \
  --entrypoint /var/lib/gantry/client \
  -e GANTRY_TEMPLATE=/etc/foo/foo.conf.tmpl \
  -e GANTRY_TARGET=/etc/foo/foo.conf \
  <other options> <docker-image> \
  <real entrypoint command here>
```

Gantry generate the config file from the template at the begining,
and wait for a change of etcd registration.

Because it uses ERB as the template engine, the tepmplate files are like this.

```erb
foo
  serviers:
  <%- backend "service-name/tcp-1234" do -%>
    <%- if node == 'n2' -%>
    server: <%= ip %>:<%= port %> <%= param "option" %>
    <%- end -%>
  <%- end.else do -%>
    no server
  <%- end -%>
```

`param "option"` refers environment variable `GANTRY_OPTION`
