SHELL 		:= /bin/bash
MAIN_HOST := $(shell docker network inspect --format='{{json (index .IPAM.Config 0).Gateway}}' bridge)
DOCKER_USER := $(shell echo $$(id -u):$$(id -g))

## Usage: make [target]
##
## targets:
##
## ---
## [help] show this help :)
.PHONY : help
help : Makefile
	@sed -n 's/^##//p' $<

## ---

build-spring-cloud:
	cd ./api-gateway/spring-cloud-gateway; \
	./mvnw clean spring-boot:build-image -Dspring-boot.build-image.imageName=tmp/spring-boot-gateway

add-host-entries:
	if [ ! "$$(grep gateway.docker /etc/hosts)" ]; then \
		sudo sh -c "echo '127.0.0.1 gateway.docker' >> /etc/hosts"; \
	fi;

## [build] You should run this before everything else
build: build-spring-cloud

## ---

## [up] up all api-gateways
up: add-host-entries
	docker-compose \
	-p gateway \
	-f ./raw-servers/docker-compose.yml \
	-f ./api-gateway/nginx/docker-compose.yml \
 	-f ./api-gateway/spring-cloud-gateway/docker-compose.yml \
	-f ./api-gateway/krakend-service/docker-compose.yml \
	-f ./api-gateway/krakend-framework/docker-compose.yml \
	-f ./api-gateway/nodejs-custom/docker-compose.yml \
	up \
	-d \
	--build \
	--remove-orphans;

## [down] down all api-gateways
down:
	docker-compose \
	-p gateway \
	-f ./raw-servers/docker-compose.yml \
	-f ./api-gateway/nginx/docker-compose.yml \
	-f ./api-gateway/spring-cloud-gateway/docker-compose.yml \
	-f ./api-gateway/krakend-service/docker-compose.yml \
	-f ./api-gateway/krakend-framework/docker-compose.yml \
	-f ./api-gateway/nodejs-custom/docker-compose.yml \
	down \
	--remove-orphans

## ---

## [test-endpoints] verify if all endpoints are really up and returning 200!
test-endpoints:
	@run_raw(){ \
		local NAME="$${1}"; \
		local URL="$${2}"; \
		echo "$${URL} - $$(curl -s -w "%{http_code} - %{content_type} - %{size_download}\\n" $${URL} -o /dev/null)"; \
	}; \
	run(){ \
		local NAME="$${1}"; \
		local URL="$${2}"; \
		set -- $$API_MAP; \
		while [ -n "$$1" ]; do \
			local API="$${1}"; \
			local NEW_NAME="$${NAME}_$${API}"; \
			local NEW_URL=$$(echo "$${URL}" | sed "s/{api}/$${API/&/\&}/g"); \
			run_raw "$${NEW_NAME}" "$${NEW_URL}"; \
			shift; \
		done; \
	}; \
	echo "name - http_code - content_type - bytes_download"; \
	echo "---"; \
	. endpoints.sh;

## [bench] run the benchmark
bench:
	MAIN_HOST="${MAIN_HOST}" \
	DOCKER_USER=${DOCKER_USER} \
	docker-compose \
	-f ./benchmark/docker-compose.yml \
	up \
	--remove-orphans

## [plot-bench] generate beatiful charts from benchmark results
plot-bench:
	DOCKER_USER=${DOCKER_USER} docker-compose \
	-f ./benchmark-plot/docker-compose.yml \
	up \
	--remove-orphans

## ---

## [monitor] show containers CPU/Mem, may be useful during the benchmark
monitor:
	docker stats --all --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"