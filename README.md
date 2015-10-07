Gantry
======

An etcd backed docker container loader with dynamic configuration.

docker hub: [s21g/gantry](https://hub.docker.com/r/s21g/gantry/)

Prerequisites:

 * etcd cluster
 * registrator

USAGE:

Run gantry container for each docker host with options as follows:

```shell
docker run --name gantry --volumes-from etcd --link etcd \
  -e ETCD_ENDPOINT='https://etcd:2379' \
  -e ETCD_CAFILE: '/certs/ca.crt' \
  -e ETCD_CERTFILE: '/certs/client.crt' \
  -e ETCD_KEYFILE: '/certs/client.key' \
  s21g/gantry
```

Then, run docker containers using with gantry like this:

```
docker run --volumes-from gantry --link gantry \
	--entrypoint /gantry/run \
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
  <%- backend "service-name" do -%>
    <%- if node == 'n2' -%>
    server: <%= ip %>:<%= port %>
    <%- end -%>
  <%- end -%>

```
