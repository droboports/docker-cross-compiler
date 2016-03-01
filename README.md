# docker-cross-compiler

## Pull the container

This container is available from [Docker Hub](https://registry.hub.docker.com/u/droboports/compiler/).

```
docker pull droboports/compiler
```

## Build the container

```
docker build --tag="droboports/compiler" https://github.com/droboports/docker-cross-compiler.git
```

## Start a temporary interactive container

```
docker run --rm -t -i droboports/compiler
```

## Build `busybox` using a temporary interactive container

From the container prompt:
```
cd ~/build
git clone https://github.com/droboports/busybox.git
cd busybox
./build.sh
ls -la *.tgz
```

## Build `samba` using a temporary interactive container (python cross-compiler)

From the container prompt:
```
cd ~/build
git clone https://github.com/droboports/samba.git
cd samba
./build.sh
ls -la *.tgz
```

## Build some golang code using a temporary interactive container

From the container prompt:
```
cd ~/build
export GOPATH=/mnt/DroboFS/Shares/DroboApps/hello-world
cat > hello-world.go << EOF
package main
import "fmt"
func main() {
  fmt.Println("hello world")
}
EOF
go build -o hello-world hello-world.go
```

This is the resulting `hello-world`:
```
$ file hello-world
hello-world: ELF 32-bit LSB  executable, ARM, EABI5 version 1 (SYSV), statically linked, not stripped
```

## Using the container's build command

This container provides a special `build` command to build projects in git repositories.

The syntax is `build project-name` or `build url.git`, where `project-name` is the name of the DroboPorts project, and `url.git` is the URL of a git repository (e.g., https://github.com/droboports/busybox.git).

For DroboPorts projects, the name is the last component of the GitHub URL. For example, to build the project hosted by the repository https://github.com/droboports/busybox, use the name `busybox`.

To use the build command, first create a folder to host the resulting packages:
```
mkdir -p ~/dist
chmod a+rw ~/dist
```

Then start the container using the special `build` syntax:
```
docker run --rm --volume ~/dist:/dist droboports/compiler build project-name
```

Once the build is done, `~/dist` will contain `project-name.tgz`.
