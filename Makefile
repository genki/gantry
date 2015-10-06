all:
	docker build ./docker

.PHONY: version
version:
	w3m https://hub.docker.com/r/s21g/gantry/tags/ \
		| grep -E "\d+\.\d+.\d+\s+[0-9.]+\s+[KMG]B" \
		| sort | tail -n 1 | grep -o -E "^\d+\.\d+\.\d+" > ./VERSION
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
		print "docker tag -f " ENVIRON["ID"] " s21g/gantry:" ENVIRON["V"] \
	}' | sh

release:
	docker push s21g/gantry
