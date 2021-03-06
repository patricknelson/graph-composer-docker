# graph-composer-docker

Container image for running an isolated instance of the [`graph-composer`](https://github.com/clue/graph-composer#installation-using-composer)
tool without having to install any of _its_ dependencies locally (such as `graphviz`, `composer` or even `php`).

**NOTE:** The `show` command will not work since this is running inside of a container. It's recommended that you use
the `export` command instead.


# Quick start

Launch an interactive shell and then just run `graph-composer.phar` as usual.

```bash
# Generic (replace LOCAL_PATH)
docker run -it --rm -v LOCAL_PATH:/graph-composer patricknelson/graph-composer-docker sh

# ... then run graph-composer.phar as usual...
graph-composer.phar export > graph.svg
```

Or, if you're lazy like me and don't want to type out your `LOCAL_PATH` every time and simply use the current directory:

```bash
# Relative to current directory (MacOS/Linux)
docker run -it --rm -v "$(pwd):/graph-composer" patricknelson/graph-composer-docker sh

# Relative to current directory (Windows with cygwin)
docker run -it --rm -v "$(cygpath -am .):/graph-composer" patricknelson/graph-composer-docker sh
```

Pack it into a single command (more complex). Note that you will have issues exporting to binary formats like `png`.

```bash
# Export to SVG in the current working directory (on host machine, which may vary from the LOCAL_PATH volume mount).
docker run -it --rm -v LOCAL_PATH:/graph-composer patricknelson/graph-composer-docker graph-composer.phar export > graph.svg

# Export directly to PNG file into the LOCAL_PATH NOTE: This version requires  passing
# through 'sh' since redirecting output from docker may not be binary compatible.
docker run -it --rm -v LOCAL_PATH:/graph-composer sh -c '/usr/local/bin/graph-composer.phar export --format=png > graph.pngpatricknelson/graph-composer-docker "
```


# Build and run locally

```bash
git clone git@github.com:patricknelson/graph-composer-docker.git
docker build . -t graph-composer-docker
```

Once built, just drop into an interactive shell:

```bash
# Drop into interactive shell.
docker run -it --rm graph-composer-docker -v LOCAL_PATH:/graph-composer sh
```

Note: Make sure to replace `LOCAL_PATH` with the path to the project directory you want to start generating dependency
graphs for. See [quick start](#quick-start) for some more system specific alternatives to `LOCAL_PATH`.


# Development of this image

This works by building `graph-composer.phar` from source ([clue/graph-composer](https://github.com/clue/graph-composer#installation-using-composer))
using `composer` and bundling it into a small PHP-based image.

To launch, just use `docker-compose up` and then load up an interactive shell:

```bash
docker-compose up -d --build
docker-compose exec app sh

# Don't forget to clean up when finished...
docker-compose down
```

If you'd like to contribute, feel free to submit an issue or PR!


# License

Released under GPL v3 (or later). See [LICENSE](LICENSE).
