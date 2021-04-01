SHELL := /bin/bash

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


download-big-pdf:
	if ! [ -f "./fake-servers/volume-data/attachment/1.pdf" ]; then \
		curl -o "./fake-servers/volume-data/attachment/1.pdf" "https://www.hq.nasa.gov/alsj/a17/A17_FlightPlan.pdf"; \
	fi

## [up] up all api-gateways
up: download-big-pdf
	docker-compose \
	-f ./fake-servers/docker-compose.yml \
	-f ./api-gateway/nginx/docker-compose.yml \
	up \
	--build \
	--remove-orphans

# api-fake-servers
# > http://localhost:9001/1.xml
# > http://localhost:9002/1.json

# nginx gateway
# > http://user.localhost:9101/1.xml
# > http://address.localhost:9101/1.json
# > http://attachment.localhost:9101/1.pdf