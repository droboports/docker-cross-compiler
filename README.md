# docker-cross-compiler

## Build the container

From the docker host:

```
docker build --tag="droboports/compiler" https://github.com/droboports/docker-cross-compiler.git
```

## Start a temporary container

From the docker host:

```
docker run --rm -t -i droboports/compiler
```

## Build `busybox` using the container

From the container prompt:

```
cd ~/build
git clone https://github.com/droboports/busybox.git
cd busybox
./build.sh
ls -la *.tgz
```
