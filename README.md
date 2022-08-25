### Python build scripts.

The repository is part of the [Compiler Explorer](https://godbolt.org/) project. It builds
the docker images used to build the various Python interpreters used on the site.


## Testing

`sudo docker build -t pythonbuilder .`

`sudo docker run pythonbuilder ./build.sh 3.8.1`
