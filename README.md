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

This container provides a special `build` command to build projects in Git repositories.

The build command has two forms: `build PROJECT_NAME` and `build GIT_URL`.

The `build PROJECT_NAME` form is a shortcut to build a project from the DroboPorts GitHub organization (https://github.com/droboports), with the `PROJECT_NAME` being the last component of the GitHub URL. For example, the `PROJECT_NAME` for the https://github.com/droboports/busybox project would be simply `busybox`.

The `build GIT_URL` form allows any arbitrary Git repo to be built. For GitHub repos, `GIT_URL` would be the clone URL (e.g., https://github.com/droboports/busybox.git). The URL can optionally include a fragment ID to specify a branch or tag name. For example, to build the `v0.0.1` tag in your https://github.com/username/project.git repo, the `GIT_URL` would be `https://github.com/username/project.git#v0.0.1`. Without a branch or tag name specified, the [default Git branch](https://help.github.com/articles/setting-the-default-branch/) will be used.

(Note that the building a specific branch or tag only works with the `build GIT_URL` form.)

To use the build command, first create a folder to host the resulting packages:
```
mkdir -p ~/dist
chmod a+rw ~/dist
```

Then start the container using the special `build` syntax:
```
docker run --rm --volume ~/dist:/dist droboports/compiler build PROJECT_NAME
```

Once the build is done, `~/dist` will contain `PROJECT_NAME.tgz`.
