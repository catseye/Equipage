PureScript implementation of Equipage
=====================================

Docker
------

For convenience sake, the PureScript compiler and package managers are provided in a Docker image.

See `docker-compose.yml` and `Dockerfile`.

### Build

    $ docker-compose run dev bower install
    $ docker-compose run dev pulp build

### Running example Equipage programs

The `eg` folder of this repository is mounted at `/eg` in the container.

    $ docker-compose run dev pulp run -- /eg/trivial1.equipage

### Tests

    $ docker-compose run dev pulp test

### Compile to a standalone `.js` file

    $ docker-compose run dev pulp build --optimise --to Equipage.js

You may then run `Equipage.js` via `node`, as follows:

    $ docker-compose run dev node Equipage.js /eg/pop-all-positives.equipage
