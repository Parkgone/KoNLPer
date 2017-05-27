FROM r-base:latest
MAINTAINER chanyub.park "mrchypark@gmail.com"

RUN apt-get update && apt-get install -y python-pip python-dev build-essential libssl-dev libffi-dev

# pre set for install
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get install -y build-essential software-properties-common python3-software-properties && \
  apt-get -y --purge remove libssh2 && \
  apt-get install -y byobu curl git htop man unzip vim wget gnupg2 libopenblas-base libcurl4-openssl-dev libssh2-1=1.7.0-1 libssh2-1-dev && \
  rm -rf /var/lib/apt/lists/*


# Install java 8
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C2518248EEA14886 &&\
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  apt install oracle-java8-set-default && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define working directory.
WORKDIR /data

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

RUN apt-get update && R CMD javareconf \
    && Rscript -e 'install.packages(c("Rcpp","curl","reticulate"), destdir ="/usr/local/lib/R/site-library")' \
    && Rscript -e 'install.packages("KoNLP", destdir ="/usr/local/lib/R/site-library")' \
    && Rscript -e 'install.packages("jsonlite", destdir ="/usr/local/lib/R/site-library")' \
    && Rscript -e 'library(KoNLP, lib.loc = "/usr/local/lib/R/site-library");useNIADic();buildDictionary(ext_dic = "woorimalsam")useSejongDic()'

COPY app/requirements.txt /app/requirements.txt
WORKDIR /app
RUN pip install -r requirements.txt

ENV LANG="ko_KR.UTF-8"

COPY app/ /app
WORKDIR /app

ENTRYPOINT ["Rscript"]
CMD ["app.R"]