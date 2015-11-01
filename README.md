Gantry
======

An etcd backed docker container loader with dynamic configuration.

Official docker image is hosted on the docker hub: [s21g/gantry](https://hub.docker.com/r/s21g/gantry/)

[![Docker Repository on Quay.io](https://quay.io/repository/s21g/gantry/status "Docker Repository on Quay.io")](https://quay.io/repository/s21g/gantry)

**Functions**

* generates config files from templates when backend services changed.
* checks the config files and launches container process (as PID=1)
* Now it has its own service registration (from v0.2)
* Adds/removes entries also for Skydns2 (from v0.3)

**Prerequisites**:

 * docker
 * etcd cluster (with v2 API)

**USAGE**:

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

Registration
------------

Gantry registers containers that have environment variable `SERVICE_NAME`
in the etcd automatically.
Environment variables such as `SERVICE_XXX` are stored as service param.
Available variables are here:

 * `SERVICE_NAME` it is used for etcd path prefix
 * `SERVICE_MACHINE` you can refer it by `machine` in the template file
 * `SERVICE_NODE` you can refer it by `name` in the template file
 * `SERVICE_INDEX` you can refer it by `index` in the template file
 * `SERVICE_TAGS` comma separated tag list. You can refer it by `tags` as array in the template file
 * `SERVICE_PRIORITY` priority number used for skydns record
 * `SERVICE_WEIGHT` weight number used for skydns record
 * `SERVICE_DNS_TEXT` text used for skydns record
 * `SERVICE_DNS_TTL` ttl used for skydns record
 * `SERVICE_DNS_GROUP` group used for skydns record

Services will be registered under the dir `/<service name>/<proto>-<src-port>`.

For Skydns2
-----------

Gantry registers services also to skydns2 entries under `/skydns` on etcd.
Typically, the path of entry forms like this.

```
/skydns/local/skydns/<service name>/<proto>-<src-port>/<machine>/<node>/<index>/<dst-port>
```

Blank items will be omitted.
