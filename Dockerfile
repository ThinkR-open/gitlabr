FROM rocker/r-devel:latest

RUN apt-get install -y libssl-dev libxml2-dev
ADD ./DESCRIPTION /DESCRIPTION
RUN R --vanilla -e ' if (!require(devtools)) { install.packages("devtools", repos = "https://cran.rstudio.com"); library(devtools); }; devtools::install_dev_deps()'

