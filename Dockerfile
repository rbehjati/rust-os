
# Use fixed snapshot of Debian to create a deterministic environment.
# Snapshot tags can be found at https://hub.docker.com/r/debian/snapshot/tags
ARG debian_snapshot=sha256:b7ec0670f1f5887d013c79126724f0bb4c6cd742a1eb59fbb7d935fb9dc65ac9
FROM debian/snapshot@${debian_snapshot}

# Set the SHELL option -o pipefail before RUN with a pipe in.
# See https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Getting curl and certificates dependecies.
# We're rate-limiting HTTP requests to 500 kB/s as otherwise we may get timeout errors
# when downloading from snapshot.debian.org.
RUN apt-get --yes update \
  && apt-get install --no-install-recommends --yes --option Acquire::http::Dl-Limit=500 \
  apt-transport-https \
  build-essential \
  ca-certificates \  
  curl \
  qemu-system-x86 \
  # Cleanup
  && apt-get clean \
  && rm --recursive --force /var/lib/apt/lists/* \
  # Print version of various installed tools.
  && curl --version 

# Install rustup.
ARG rustup_dir=/usr/local/cargo
ENV RUSTUP_HOME ${rustup_dir}
ENV CARGO_HOME ${rustup_dir}
ENV PATH "${rustup_dir}/bin:${PATH}"
RUN curl --location https://sh.rustup.rs > /tmp/rustup \ 
    && sh /tmp/rustup -y --default-toolchain=none \
    && chmod a+rwx ${rustup_dir} \
    && rustup --version

# Install Rust toolchain.
# See https://rust-lang.github.io/rustup-components-history/ for how to pick a version that supports
# the appropriate set of components.
# See https://github.com/rust-lang/rust/blob/master/RELEASES.md for Rust releases.
ARG rust_version=nightly-2022-04-26
RUN rustup toolchain install ${rust_version} \
  && rustup default ${rust_version}


# Install thumbv7em-none-eabihf for embedded ARM.
RUN rustup target add thumbv7em-none-eabihf

# Install rust source code.
RUN rustup component add rust-src

# Install bootimage.
RUN cargo install bootimage

# install llvm-tools-preview, required for running bootimage.
RUN rustup component add llvm-tools-preview
