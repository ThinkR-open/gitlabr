FROM rocker/r-devel:latest

RUN apt-get install -y libssl-dev libxml2-dev
ADD ./DESCRIPTION /DESCRIPTION
RUN R -e "if (!require(devtools)) { install.packages('devtools', repos = 'https://cran.rstudio.com') }"
RUN R -e "if (!require(roxygen2)) { install.packages('roxygen2', repos = 'https://cran.rstudio.com') }"
RUN R -e "require(devtools); install.packages(subset(dev_package_deps(devtools:::load_pkg_description('./')), diff != 0)[['package']])" ## unclear why install_dev_deps() doesnt work

