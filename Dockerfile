FROM r-base:latest
MAINTAINER chanyub.park "mrchypark@gmail.com"

RUN apt-get update && apt-get install -y python-pip python-dev build-essential libssl-dev libffi-dev

RUN apt-get update && apt-get install -y libopenblas-base r-base-dev
RUN apt-get update && Rscript -e 'install.packages("Rcpp", destdir ="/usr/local/lib/R/site-library")' \
    && Rscript -e 'install.packages("https://cran.r-project.org/src/contrib/reticulate_0.8.tar.gz", repo=NULL, type="source", destdir ="/usr/local/lib/R/site-library")'

RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip vim wget && \
  rm -rf /var/lib/apt/lists/*

RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java7-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk7-installer

# Define working directory.
WORKDIR /data

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle

COPY app/requirements.txt /app/requirements.txt
WORKDIR /app
RUN pip install -r requirements.txt

COPY app/ /app
WORKDIR /app

ENTRYPOINT ["Rscript"]
CMD ["app.R"]