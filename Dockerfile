# Use CentOS Stream 9 as the base image
FROM dokken/centos-stream-9

# Build arguments with defaults (DRBD version changes less frequently)
ARG DRBD_VERSION=9.1.23
ARG DRBD_RELEASE=1
ARG EL_VERSION=9

# Runtime environment variables
ENV DRBD_VERSION=${DRBD_VERSION}
ENV DRBD_RELEASE=${DRBD_RELEASE}
ENV EL_VERSION=${EL_VERSION}
ENV ELREPO_URL="https://elrepo.org/linux/elrepo/el${EL_VERSION}/SRPMS"
ENV OUTPUT_DIR="/root/output"
ENV RPMBUILD_DIR="/root/rpmbuild"
ENV KERNEL_VERSION_FILE="/tmp/kernel_versions.txt"

# Copy build scripts
COPY scripts/build-drbd.sh /usr/local/bin/
COPY scripts/get-kernels.sh /usr/local/bin/

# Install base dependencies and set up repositories
RUN dnf -y update-minimal --security --sec-severity=Important --sec-severity=Critical && \
    dnf install -y \
        cpio \
        diffutils \
        gcc \
        make \
        perl \
        tar \
        wget \
        rpm-build \
        redhat-rpm-config \
        epel-release \
        kernel-abi-stablelists \
        kernel-rpm-macros \
        dnf-utils \
        yum-utils \
    && dnf config-manager --set-enabled crb \
    && dnf clean all -y \
    && chmod +x /usr/local/bin/build-drbd.sh \
    && chmod +x /usr/local/bin/get-kernels.sh

# Create directory structure
RUN mkdir -p ${RPMBUILD_DIR}/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS} \
    && mkdir -p ${OUTPUT_DIR}

WORKDIR ${RPMBUILD_DIR}

# Default command to build DRBD modules
ENTRYPOINT ["/usr/local/bin/build-drbd.sh"]