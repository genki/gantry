build:
	echo `docker build ./docker \
		| tail -n 1 | sed "s/Successfully built //"` > ./CID

run: build
	docker run --rm -i --name gantry-dev \
		-v /var/run/docker.sock:/tmp/docker.sock \
		-v /etc/docker/certs.d:/certs:ro \
		-v /var/lib/gantry:/var/lib/gantry \
		-e ETCD_ENDPOINT=https://192.168.10.1:2379 \
  	-e ETCD_CAFILE=/certs/ca.crt \
  	-e ETCD_CERTFILE=/certs/client.crt \
  	-e ETCD_KEYFILE=/certs/client.key.insecure \
		`cat CID`

.PHONY: version
version:
	w3m https://hub.docker.com/r/s21g/gantry/tags/ \
		| grep -E "\d+\.\d+.\d+\s+[0-9.]+\s+[KMG]B" \
		| sort -t. -k 1,1n -k 2,2n -k 3,3n \
		| tail -n 1 | grep -o -E "^\d+\.\d+\.\d+" > ./VERSION
	cat ./VERSION

inc:
	cat ./VERSION \
		| awk -F . '{print $$1 "." $$2 "." $$3+1}' > ./NEW_VERSION
	mv ./NEW_VERSION ./VERSION

tag:
	ID=`docker build ./docker \
		| tail -n 1 | sed "s/Successfully built //"` \
	V=`cat ./VERSION` \
	awk 'BEGIN{ \
		print "docker tag -f " ENVIRON["ID"] " s21g/gantry:" ENVIRON["V"]; \
		print "docker tag -f " ENVIRON["ID"] " s21g/gantry:latest" \
	}' | sh

release: build version inc tag
	docker push s21g/gantry
