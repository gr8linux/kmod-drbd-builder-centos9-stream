#!/bin/bash
# Script to fetch latest CentOS Stream 9 kernel versions
dnf repolist --enabled | grep -q "centos-stream-9" || {
    echo "Error: CentOS Stream 9 repositories not found"
    exit 1
}

dnf list available --quiet kernel-devel.x86_64 | \
    grep -oP '5\.14\.0-[0-9]+\.el9' | \
    sort -Vr | \
    head -n 5 