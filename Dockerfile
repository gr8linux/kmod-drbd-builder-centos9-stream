# Use CentOS Stream 9 as the base image
ARG BASE_IMAGE=dokken/centos-stream-9
FROM $BASE_IMAGE

# Set environment variables for DRBD version and SRPM URL
ENV LB_KERNEL_VERSION=5.14.0-533.el9.x86_64
ENV LB_KERNEL_VERSION_NOARC=5.14.0-533.el9
ENV LB_SRPM_URL=https://elrepo.org/linux/elrepo/el9/SRPMS/kmod-drbd9x-9.1.23-1.el9_5.elrepo.src.rpm

# Install necessary build tools and dependencies
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
        kernel-devel\
        kernel-headers \
        epel-release \
        kernel-abi-stablelists \
        kernel-rpm-macros \
    && dnf clean all -y

# Working directory for building the RPM
WORKDIR /root/rpmbuild

# Create the rpmbuild directory structure
RUN mkdir -p /root/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

# Download and install the SRPM
ADD ${LB_SRPM_URL} /root/rpmbuild/SRPMS/

RUN rpm -ivh /root/rpmbuild/SRPMS/*.src.rpm

# Update the spec file with the correct kernel version
RUN sed -i "s/%{!?kmod_kernel_version: %define kmod_kernel_version .*}/%{!?kmod_kernel_version: %define kmod_kernel_version ${LB_KERNEL_VERSION_NOARC}}/" \
    /root/rpmbuild/SPECS/kmod-drbd9x.spec
# Build the RPMs
RUN rpmbuild -ba /root/rpmbuild/SPECS/kmod-drbd9x.spec

# Output directory
RUN mkdir -p /root/output

# Copy the built RPMs to the output directory
RUN cp -r /root/rpmbuild/RPMS /root/output && \
    cp -r /root/rpmbuild/SRPMS /root/output

# Set the output directory as the final directory
WORKDIR /root/output

# Default command to list the built RPMs
CMD ["ls", "-l", "/root/output"]
