########################################################################################################################
# Base Image
########################################################################################################################
# Core Config
ARG alpine_tag=3.19.0
ARG repo_tag=v26.0
ARG container_name=bitcoind
ARG repo=https://github.com/bitcoin/bitcoin

# Ports:
# 8332: JSON-RPC
# 8333: peers
# 28332: ZMQ
ARG ports='8332 8333 28332'

# Defaults
ARG additional_args=
ARG build_dir=/tmp/build
ARG data_dir=/var/lib/bitcoin
ARG dist_dir=/usr/local/bin
ARG install_dir=$dist_dir
ARG uid=10000
ARG user=$container_name
ARG bitcoin_conf=/home/$user/.bitcoin/bitcoin.conf

FROM alpine:${alpine_tag} as base


########################################################################################################################
# Build Image
########################################################################################################################
FROM base as build
ARG build_dir dist_dir repo repo_tag

WORKDIR $build_dir

# Update base Alpine system and add build packages
RUN apk update
ARG build_packages='autoconf automake bash boost-dev git g++ libevent-dev libtool make pkgconf zeromq-dev'
#ARG build_packages='cmake curl-dev g++ git libuv-dev make zeromq-dev'
RUN apk add $build_packages

# Download source
RUN git clone --recursive $repo source
WORKDIR $build_dir/source
RUN git checkout $repo_tag
RUN git submodule sync
RUN git submodule update --init --force

# Container specific build
RUN ./autogen.sh
ARG configure_args=--without-bdb
RUN ./configure $configure_args
RUN make -j$(nproc)
RUN make install
RUN contrib/devtools/gen-bitcoin-conf.sh


########################################################################################################################
# Final Image
########################################################################################################################
FROM base as final
ARG build_dir bitcoin_conf data_dir dist_dir install_dir ports uid user

WORKDIR /home/$user

# Upgrade pre-installed Alpine packages and install runtime dependencies
RUN apk --no-cache upgrade
ARG runtime_packages='libevent libstdc++ libzmq'
RUN apk add --no-cache $runtime_packages

# Install binaries
RUN mkdir -p "$install_dir"
COPY --from=build $dist_dir $install_dir
COPY --from=build $build_dir/source/share/examples/bitcoin.conf $bitcoin_conf

# Environment variables, overridable from container
ENV BITCOIND_ADDITIONAL_ARGS=$additional_args
ENV BITCOIND_CONF=$bitcoin_conf
ENV BITCOIND_DATA_DIR=$data_dir

# Create user
RUN addgroup -g $uid -S $user && adduser -u $uid -S -D -G $user $user

# Copy container entrypoint script into container
COPY entrypoint.sh .

# Change ownership of all files in user dir and data dir
RUN mkdir -p $data_dir
RUN chown -R $user:$user /home/$user $data_dir
RUN chown $user:$user $bitcoin_conf

# Setup volume for blockchain
VOLUME $data_dir

# Expose ports
EXPOSE $ports

# Run as user
USER $user

# Run entrypoint script
ENTRYPOINT ["./entrypoint.sh"]
