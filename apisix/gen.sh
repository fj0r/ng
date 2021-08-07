#diff -u Dockerfile-origin Dockerfile
curl https://raw.githubusercontent.com/openresty/docker-openresty/master/alpine/Dockerfile > Dockerfile-origin
curl https://raw.githubusercontent.com/openresty/docker-openresty/master/alpine/Dockerfile.fat >> Dockerfile-origin
curl https://raw.githubusercontent.com/apache/apisix-docker/master/alpine/Dockerfile >> Dockerfile-origin
patch Dockerfile-origin -i diff -o Dockerfile
