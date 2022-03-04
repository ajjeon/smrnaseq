FROM nfcore/base:1.14
LABEL authors="Phil Ewels <phil.ewels@scilifelab.se>, Chuan Wang <chuan.wang@scilifelab.se>, Rickard Hammarén <rickard.hammaren@scilifelab.se>, Lorena Pantano <lorena.pantano@gmail.com>" \
      description="Docker image containing all software requirements for the nf-core/smrnaseq pipeline"

# Install libtbb2 package for bowtie
RUN apt-get update && apt-get install libtbb2 -y

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils

# Install the conda environment
COPY environment.yml /
RUN conda env create --quiet -f /environment.yml && conda clean -a

# Add conda installation dir to PATH (instead of doing 'conda activate')
ENV PATH /opt/conda/envs/ajj-smrnaseq/bin:$PATH

# Dump the details of the installed packages to a file for posterity
RUN conda env export --name ajj-smrnaseq > ajj-smrnaseq.yml

# Install awscli
RUN pip install --target=/opt/pip awscli
RUN pip install awscli


