# Graylog docker image
[![Build Status](https://travis-ci.com/edyan/docker-graylog.svg?branch=master)](https://travis-ci.com/edyan/docker-graylog)
[![Docker Pulls](https://img.shields.io/docker/pulls/edyan/graylog.svg)](https://hub.docker.com/r/edyan/graylog/)


Docker Hub: https://hub.docker.com/r/edyan/graylog

Docker container that runs [graylog](https://www.graylog.org). It's an alternative 
to the official image as it embeds all required components (MongoDB and Elastic) 
and tries to be as light and simple as possible.  

It's made for development purposes, and will perfectly fit with a docker-compose 
environment. 

**Be careful, it takes some time to load (Java!)**

## Run Docker image
As the logging system of docker works directly via the host, you need to expose
one of the logging port (for example gelf or rsyslog). See below.

Once launched, to access graylog you need to go to [http://localhost:9000](http://localhost:9000/system/inputs)
and log-in with `admin` / `admin`. Then go to [System/Input => Inputs](http://localhost:9000/system/inputs), 
select `GELF UDP` in the dropdown list then `Launch new Input`. 
Check `global`, and anything for the title. You are ready to go.
See [Official Documentation](http://docs.graylog.org/en/2.1/pages/getting_started/config_input.html).

To do that but with curl :

First get a token :  
```bash
$ export GL_TOKEN_URL='http://127.0.0.1:9001/api/users/admin/tokens/docker?pretty=true'
$ curl -u admin:admin -H 'Accept: application/json' -H 'X-Requested-By: cli' -X POST $GL_TOKEN_URL 
```
Returns something like :
```json   
{
  "name" : "docker",
  "token" : "mm1ri8u0qcifrbmtcbcv6clkg2a9jkg3rlhfg5ogc2eihmhu40n",
  "last_access" : "1970-01-01T00:00:00.000Z"
}
```                                                                            

Note the token then : 
```bash
$ export TOKEN='mm1ri8u0qcifrbmtcbcv6clkg2a9jkg3rlhfg5ogc2eihmhu40n'
$ export GL_INPUTS_URL='http://127.0.0.1:9001/api/system/inputs'
$ curl -u ${TOKEN}:token -H 'Content-Type: application/json' -X POST $GL_INPUTS_URL \
       --data-binary '{"title":"Global","type":"org.graylog2.inputs.gelf.udp.GELFUDPInput","configuration":{"bind_address":"0.0.0.0","port":12201,"recv_buffer_size":262144,"override_source":null,"decompress_size_limit":8388608},"global":true}'
```  

## Environment variables
Two variables have been created : 
* `ELASTIC_MAX_RAM` (default: `1024m`) 
* `GRAYLOG_MAX_RAM` (default: `512m`). 

## Docker Compose example
See directory `examples/`, or try : 

```yaml
version: '3.3'

services:
  graylog:
    ports:
      # Graylog web interface and REST API. Required (login / pass : admin / admin)
      - 9000:9000/tcp
      - 9001:9001/tcp
      # GELF TCP and UDP if you use that logging driver
      - 12201:12201/udp
    image: edyan/graylog:latest
    logging:
      driver: gelf
      options:
        gelf-address: "udp://127.0.0.1:12201"

  db:
    depends_on:
      - graylog
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress
    volumes:
      - ./data/mysql:/var/lib/mysql
    logging:
      driver: gelf
      options:
        gelf-address: "udp://127.0.0.1:12201"

  wordpress:
    depends_on:
    - db
    image: wordpress:latest
    ports:
      - "8000:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress
    volumes:
      - ./data/wordpress:/var/www/html/wp-content
    logging:
      driver: gelf
      options:
        gelf-address: "udp://127.0.0.1:12201"
```
