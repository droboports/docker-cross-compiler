# docker-cross-compiler

## To build the container

```
git clone https://github.com/droboports/docker-cross-compiler.git
cd docker-cross-compiler
docker build --force-rm --tag="droboports/compiler" .
```

## To start a container

```
docker run --rm -t -i droboports/compiler
```

