# openresty-test
Repo to capture tests with openresty

Goal: test where env variables are being set

Context/given:
- an implementation of a reverse proxy with OIDC authentication based on Openresty bitnami docker image with Lua plugins
- a deployment of said docker image as a pod on Redhat Openshift
- a resource server (i.e. that the openresty reverse proxy is shielding) also deployed on Openshift (same cluster)
- environment variables in the openresty docker container refering to the resource server containing IP addresses 

Observation:
- it seems the reverse proxy fails to redirect to the resouce server, it is suspected that this has to do with the ip addresses in the env variables
- as the proxied resource server is also a pod on openshift it's ip address is likely to change on pod restart/redeployment
- the [bitnami openresty docker image](https://github.com/bitnami/containers/blob/main/bitnami/openresty/1.21/debian-11/Dockerfile) is built based on the bitnami [minideb](https://github.com/bitnami/minideb) docker image. This image contains virtually no tools for debugging

Approach:
- rebuild a comparable openresty image based on a full debian install (so debugging tools are availble) and verify where an at what point the observed environment variables come into existance
- validate that indeed the env vars containing ip addresses are the cause of the reverse proxy not being able to reach the resource server

Starting point:
- [docker file](https://github.com/openresty/docker-openresty/blob/master/bullseye/Dockerfile.fat) from openresty docker repo for Debian bullseye fat
- adding lua plugins with opm according to [instructions](https://github.com/openresty/docker-openresty#opm)
    - list of available plugins to be installed via opm on [https://opm.openresty.org/](https://opm.openresty.org/)
- list of lua plugins: as available in the observed bitnami based implementation (i.e. no versions of said lua plugins are defined)
- add config for resouce server to be proxied

### Practical

- Building the docker image

    ```docker build -t openresty-deb-fat .```

- List the images

    ```docker images -a```

- Run the docker container interactively

    ```docker run -it --expose 80 -p 80:80 openresty-deb-fat bash```

- Inside the docker container start openresty

    ```openresty```
