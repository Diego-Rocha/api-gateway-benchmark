# API Gateway - Benchmark

The propose of this project is to compare some open-source api gateways avaliable on the market

## Meet the contenders

 - Spring: Custom build using Spring Cloud Gateway
 - Node: Custom build using Node with express 
 - Krakend as Framework: Custom build usins krakend framework
 - Krakend as Service: Krakend ready to use solution
 - Nginx: Nginx ready to use solution

## Requirements

  - Linux
  - Java 11
  - Docker
  - Docker Compose

## Quick Start

```bash
# build spring image
make build

#up all gateways
make up

#run the bench
make bench

#generate graph
make plot-bench
```

to see all options run: `make help`

## Contributors

 - [Diego Rocha](https://github.com/Diego-Rocha): Main developer
 - [Rafael Guerra](https://github.com/rafaelluisguerra): Made the graphs in Python.