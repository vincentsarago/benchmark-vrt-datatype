
SHELL = /bin/bash

build:
	docker build --tag bench:latest .

build-fix:
	docker build -f Dockerfile-fix --tag bench:latest .

run:
	docker run \
		--name bench \
		-w /scripts/ \
		--volume $(shell pwd)/scripts:/scripts \
		-itd bench:latest /bin/bash

test: build run
	docker exec -it bench bash -c 'sh main.sh 1.0.18'
	docker stop bench
	docker rm bench

test-fix: build-fix run
	docker exec -it bench bash -c 'sh main.sh 1.0.18'
	docker stop bench
	docker rm bench

shell: build
	docker run --name bench  \
		-w /scripts/ \
		--volume $(shell pwd)/scripts:/scripts \
		--rm -it bench:latest /bin/bash

clean:
	docker stop bench
	docker rm bench
