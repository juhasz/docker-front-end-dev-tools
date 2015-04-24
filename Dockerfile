#
# Dockerfile for front end developement tools.
#

FROM buildpack-deps:jessie
MAINTAINER Márton Juhász <m@juhaszmarton.hu>

# Set locales
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

# ---------------------------------------------------------------------------------------------------------------
# Install nodejs.
# Script from https://github.com/joyent/docker-node/blob/04e6f537ede555b2558abfab32a1b8d31e7c1500/0.12/Dockerfile
# ---------------------------------------------------------------------------------------------------------------
# verify gpg and sha256: http://nodejs.org/dist/v0.10.30/SHASUMS256.txt.asc
# gpg: aka "Timothy J Fontaine (Work) <tj.fontaine@joyent.com>"
# gpg: aka "Julien Gilli <jgilli@fastmail.fm>"
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys 7937DFD2AB06298B2293C3187D33FF9D0246406D 114F43EE0176B71C7BC219DD50A3051F888C628D

RUN apt-get update

ENV NODE_VERSION 0.12.2
ENV NPM_VERSION 2.7.3
ENV PHANTOMJS_VERSION 1.9.7
ENV CASPERJS_VERSION 1.1-beta3

RUN curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
  && curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --verify SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
  && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc \
  && npm install -g npm@"$NPM_VERSION" \
  && npm cache clear

# ---------------------------------------------------------------------------------------------------------------
# Install ruby.
# Script from https://github.com/docker-library/ruby/blob/69582bf7de57fe358d4c3c7c23400aebaf626b92/2.2/Dockerfile
# ---------------------------------------------------------------------------------------------------------------
ENV RUBY_MAJOR 2.2
ENV RUBY_VERSION 2.2.1
ENV RUBY_DOWNLOAD_SHA256 5a4de38068eca8919cb087d338c0c2e3d72c9382c804fb27ab746e6c7819ab28

# some of ruby's build scripts are written in ruby
# we purge this later to make sure our final image uses what we just built
RUN apt-get install -y bison libgdbm-dev ruby \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /usr/src/ruby \
  && curl -fSL -o ruby.tar.gz "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.gz" \
  && echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.gz" | sha256sum -c - \
  && tar -xzf ruby.tar.gz -C /usr/src/ruby --strip-components=1 \
  && rm ruby.tar.gz \
  && cd /usr/src/ruby \
  && autoconf \
  && ./configure --disable-install-doc \
  && make -j"$(nproc)" \
  && make install \
  && apt-get purge -y --auto-remove bison libgdbm-dev ruby \
  && rm -r /usr/src/ruby

# skip installing gem documentation
RUN echo 'gem: --no-rdoc --no-ri' >> "$HOME/.gemrc"

# install things globally, for great justice
ENV GEM_HOME /usr/local/bundle
ENV PATH $GEM_HOME/bin:$PATH
RUN gem install bundler \
  && bundle config --global path "$GEM_HOME" \
  && bundle config --global bin "$GEM_HOME/bin"

# don't create ".bundle" in all our apps
ENV BUNDLE_APP_CONFIG $GEM_HOME

# ---------------------------------------------------------------------------------------------------------------
# Install PhantomJS.
# ---------------------------------------------------------------------------------------------------------------
RUN curl -L -o phantomjs.tar.bz2 https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 && \
  tar -xjf phantomjs.tar.bz2 && \
  ln -s /phantomjs*/bin/phantomjs /bin/

# ---------------------------------------------------------------------------------------------------------------
# Install CasperJS.
# ---------------------------------------------------------------------------------------------------------------
RUN apt-get update
RUN apt-get install -y unzip
RUN curl -L -o casperjs.zip https://github.com/n1k0/casperjs/zipball/$CASPERJS_VERSION && \
  unzip casperjs.zip && \
  ln -s /n1k0-casperjs*/bin/casperjs /bin/

# ---------------------------------------------------------------------------------------------------------------

# Clear apt sources.
RUN apt-get autoremove -y && \
  apt-get clean -y

# Install compass.
RUN gem install --no-rdoc --no-ri compass

# Install Bower and Grunt.
RUN npm install --global bower

WORKDIR /app
