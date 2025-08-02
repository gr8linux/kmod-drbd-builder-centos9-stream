# Base stage for checking kernel versions
FROM dokken/centos-stream-9 AS version-checker

RUN dnf install -y dnf-utils yum-utils && \
    dnf clean all -y

COPY scripts/get-kernels.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/get-kernels.sh

# Main build stage
FROM dokken/centos-stream-9

# Build arguments with defaults
ARG DRBD_VERSION=9.2.13
ARG DRBD_RELEASE=5
ARG EL_VERSION=9
ARG EL_MINOR_VERSION=6  # Added for CentOS Stream 9.5

# Runtime environment variables
ENV DRBD_VERSION=${DRBD_VERSION}
ENV DRBD_RELEASE=${DRBD_RELEASE}
ENV EL_VERSION=${EL_VERSION}
ENV EL_MINOR_VERSION=${EL_MINOR_VERSION}
ENV ELREPO_URL="https://elrepo.org/linux/elrepo/el${EL_VERSION}/SRPMS"
ENV OUTPUT_DIR="/root/output"
ENV RPMBUILD_DIR="/root/rpmbuild"
ENV KERNEL_VERSION_FILE="/tmp/kernel_versions.txt"
ENV SRPM_NAME="kmod-drbd9x-${DRBD_VERSION}-${DRBD_RELEASE}.el${EL_VERSION}_${EL_MINOR_VERSION}.elrepo.src.rpm"

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
    && dnf clean all -y

# Copy build scripts
COPY scripts/build-drbd.sh /usr/local/bin/
COPY scripts/get-kernels.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/build-drbd.sh \
    && chmod +x /usr/local/bin/get-kernels.sh

# Create directory structure
RUN mkdir -p ${RPMBUILD_DIR}/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS} \
    && mkdir -p ${OUTPUT_DIR}

WORKDIR ${RPMBUILD_DIR}

# Download and install SRPM
RUN wget -O ${RPMBUILD_DIR}/SRPMS/kmod-drbd9x.src.rpm \
        ${ELREPO_URL}/${SRPM_NAME} || \
        (echo "Failed to download SRPM: ${ELREPO_URL}/${SRPM_NAME}" && exit 1) && \
    rpm -ivh ${RPMBUILD_DIR}/SRPMS/kmod-drbd9x.src.rpm

# Create build report directory
RUN mkdir -p ${OUTPUT_DIR}/reports

# Set working directory to RPMBUILD_DIR
WORKDIR ${RPMBUILD_DIR}

# Default command to build DRBD modules
ENTRYPOINT ["/usr/local/bin/build-drbd.sh"]