#!/bin/bash
set -eo pipefail

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function to cleanup
cleanup() {
    log "Cleaning up build environment..."
    dnf remove -y kernel-devel-* kernel-headers-* || true
    dnf clean all
}

# Function to download SRPM
download_srpm() {
    local srpm_name="kmod-drbd9x-${DRBD_VERSION}-${DRBD_RELEASE}.el${EL_VERSION}.elrepo.src.rpm"
    log "Downloading SRPM: ${srpm_name}"
    wget -O ${RPMBUILD_DIR}/SRPMS/kmod-drbd9x.src.rpm ${ELREPO_URL}/${srpm_name}
    rpm -ivh ${RPMBUILD_DIR}/SRPMS/kmod-drbd9x.src.rpm
}

# Function to build for a specific kernel version
build_for_kernel() {
    local kernel_version=$1
    local release_version=$(echo ${kernel_version} | cut -d"-" -f2)
    
    log "Building for kernel ${kernel_version}"
    
    # Install kernel dependencies
    dnf install -y kernel-devel-${kernel_version} kernel-headers-${kernel_version} || {
        log "Error: Failed to install kernel packages for ${kernel_version}"
        return 1
    }
    
    # Update spec file
    sed -i "s/^Release:.*/Release: 1.el${EL_VERSION}.${release_version}/" ${RPMBUILD_DIR}/SPECS/kmod-drbd9x.spec
    sed -i "s/%{!?kmod_kernel_version: %define kmod_kernel_version .*}/%{!?kmod_kernel_version: %define kmod_kernel_version ${kernel_version}}/" \
        ${RPMBUILD_DIR}/SPECS/kmod-drbd9x.spec
    
    # Build RPM
    rpmbuild -ba ${RPMBUILD_DIR}/SPECS/kmod-drbd9x.spec || {
        log "Error: Failed to build RPM for ${kernel_version}"
        return 1
    }
    
    cleanup
}

# Main execution
main() {
    trap cleanup EXIT
    
    # Download SRPM
    download_srpm
    
    # Read kernel versions from file if it exists
    if [ -f "${KERNEL_VERSION_FILE}" ]; then
        mapfile -t KERNEL_VERSIONS < "${KERNEL_VERSION_FILE}"
    else
        # Fallback to get-kernels.sh
        mapfile -t KERNEL_VERSIONS < <(/usr/local/bin/get-kernels.sh)
    fi
    
    # Create build report file
    echo "DRBD Build Report" > ${OUTPUT_DIR}/build_report.txt
    echo "Date: $(date)" >> ${OUTPUT_DIR}/build_report.txt
    echo "DRBD Version: ${DRBD_VERSION}" >> ${OUTPUT_DIR}/build_report.txt
    echo "-------------------" >> ${OUTPUT_DIR}/build_report.txt
    
    # Build for each kernel version
    for kernel_version in "${KERNEL_VERSIONS[@]}"; do
        if build_for_kernel "${kernel_version}"; then
            echo "✓ ${kernel_version} - Success" >> ${OUTPUT_DIR}/build_report.txt
        else
            echo "✗ ${kernel_version} - Failed" >> ${OUTPUT_DIR}/build_report.txt
        fi
    done
    
    # Copy built RPMs to output directory
    cp -r ${RPMBUILD_DIR}/RPMS ${OUTPUT_DIR}/
    cp -r ${RPMBUILD_DIR}/SRPMS ${OUTPUT_DIR}/
    
    # List built RPMs
    echo -e "\nBuilt RPMs:" >> ${OUTPUT_DIR}/build_report.txt
    find ${OUTPUT_DIR}/RPMS -name '*.rpm' -exec basename {} \; >> ${OUTPUT_DIR}/build_report.txt
    
    cat ${OUTPUT_DIR}/build_report.txt
}

main "$@"