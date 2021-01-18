FROM riazarbi/datasci-gui-minimal:focal

LABEL authors="Riaz Arbi"

USER root

# ARGS ===========================================================================
ENV DEBIAN_FRONTEND=noninteractive
ARG r_packages=" \
    devtools \
    tidyverse \
    tidyquant \
    IBrokers \
    arrow \
    reticulate \
    skimr \
  # Extrafont is for skimr
    extrafont \
    "

RUN echo $r_packages

ARG julia_packages=" \
    'https://github.com/lbilli/Jib.jl' \
    'DataFrames' \
    "

# For arrow to install bindings
ENV LIBARROW_DOWNLOAD=true

# Python packages ===============================================================
RUN python3 -m pip install ib_insync \
                           numpy \
                           pandas \
                           pyarrow \
 && python3 -m pip install setuptools \
 && python3 -m pip install pywikibot \
                           wikitextparser
                           
# R packages ===================================================================
RUN apt-get update && \
    apt-get install -y \
# pandoc for PDF rendering 
    pandoc \
# For devtools
   libcurl4-openssl-dev \
# Clean out cache
 && apt-get autoclean && apt-get autoremove \
 && rm -rf /var/lib/apt/lists/* 

RUN install2.r --error  --skipinstalled  $r_packages

RUN Rscript -e "remotes::install_github('lbilli/rib')"

# Julia packages ===================================================================

RUN julia -e "using Pkg; Pkg.add($julia_packages)"

# Back to non privileged user ======================================================
USER $NB_USER
