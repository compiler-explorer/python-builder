### Python build scripts.

The repository is part of the [Compiler Explorer](https://godbolt.org/) project. It builds
the docker images used to build the various Python interpreters used on the site.


## Testing

```bash
$ docker build -t pythonbuilder .
$ docker run pythonbuilder ./build.sh 3.8.1
```
