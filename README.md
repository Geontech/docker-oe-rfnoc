# docker-oe-rfnoc
A containerized build process for the REDHAWK RF-NoC assets

# Build
docker build --rm -t oe-rfnoc .

# Run
docker run --rm -it <-v /path/to/build:/opt/oe-project/build> oe-rfnoc
