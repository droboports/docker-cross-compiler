# docker-cross-compiler

## Build the container

```
docker build --tag="drobo/cross-compiler:20.04" https://github.com/drobo/docker-cross-compiler.git
```

## Start a temporary interactive container

```
docker run --rm -t -i drobo/cross-compiler:20.04
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

## Using the container's build command

This container provides a special `build` command to build projects in Git repositories.

The command `build GIT_URL` allows any arbitrary Git repo to be built. 
For GitHub repos, `GIT_URL` would be the clone URL (e.g., https://github.com/droboports/busybox.git). 
The URL can optionally include a fragment ID to specify a branch or tag name. 
For example, to build the `v0.0.1` tag in your https://github.com/username/project.git repo, 
the `GIT_URL` would be `https://github.com/username/project.git#v0.0.1`. 
Without a branch or tag name specified, the default Git branch will be used.

To use the build command, first create a folder to host the resulting packages:
```
mkdir -p ~/dist
chmod a+rw ~/dist
```

Then start the container using the special `build` syntax:
```
docker run --rm --volume ~/dist:/dist drobo/cross-compiler:20.04 build GIT_URL
```

Once the build is done, `~/dist` will contain `GIT_REPONAME.tgz`.
