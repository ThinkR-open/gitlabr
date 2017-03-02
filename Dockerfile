FROM rocker/r-devel:latest

RUN apt-get update && apt-get install -y qpdf libssl-dev libxml2-dev
ADD ./DESCRIPTION /DESCRIPTION
RUN R -e "if (!require(devtools)) { install.packages('devtools', repos = 'https://cran.rstudio.com') }"
RUN R -e "require(devtools); install.packages(subset(dev_package_deps(devtools:::load_pkg_description('./'), dependencies = TRUE), diff != 0)[['package']])" ## unclear why install_dev_deps() doesnt work

