#!/bin/bash
# Get latest CentOS Stream 9 kernel versions
dnf list --available kernel-devel.x86_64 | \
    grep -oP '5\.14\.0-[0-9]+\.el9' | \
    sort -Vr | \
    head -n 5 