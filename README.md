# DRBD Kernel Module Builder for CentOS Stream 9

Automated build system for DRBD kernel modules supporting multiple CentOS Stream 9 kernel versions. This project uses Docker and GitHub Actions to automatically build and release DRBD kernel modules when new kernel versions are released.

## Features

- 🔄 Automatic builds every 12 hours via GitHub Actions
- 🎯 Supports multiple kernel versions simultaneously
- 📦 Generates RPM packages for each kernel version
- 🚀 Docker-based build environment for consistency
- 📋 Detailed build reports and metadata
- 🔧 Configurable EL minor versions

## Quick Start

### Local Build

1. Clone the repository:
```bash
git clone https://github.com/gr8linux/kmod-drbd-builder-centos9-stream.git
cd kmod-drbd-builder-centos9-stream
```

2. Build using Docker:
```bash
# Build with default settings
docker build -t drbd-builder .
docker run --rm -v $(pwd)/output:/root/output drbd-builder

# Build with specific EL minor version
docker build -t drbd-builder \
    --build-arg EL_MINOR_VERSION=5 \
    .
```

### Using Ansible

1. Update inventory file with your target hosts:
```ini
[build_servers]
build-server ansible_host=your-server.example.com
```

2. Run the playbook:
```bash
ansible-playbook -i inventory build_drbd_rpm.yml
```

## Build Methods

### 1. GitHub Actions Workflow

The project supports three build trigger methods:

1. **Scheduled Builds**
   - Runs automatically every 12 hours
   - Checks for new kernel versions
   - Uploads artifacts to GitHub

2. **Manual Trigger**
   - Go to Actions → "DRBD Kernel Module Builder"
   - Click "Run workflow"
   - Optionally specify:
     - Force build (even if no new kernel version)
     - EL Minor Version (e.g., 5 for el9_5)

3. **Push Triggers**
   - Triggered by changes to:
     - Dockerfile
     - scripts/**
     - .github/workflows/drbd-build.yml
     - .kernel-versions
     - **.sh

### 2. Local Development

Build and test locally using Docker:

```bash
# Build image
docker build -t drbd-builder .

# Run with default settings
docker run --rm -v $(pwd)/output:/root/output drbd-builder

# Run with specific EL minor version
docker run --rm \
    --build-arg EL_MINOR_VERSION=5 \
    -v $(pwd)/output:/root/output \
    drbd-builder
```

## Project Structure

```
.
├── .github/
│   └── workflows/
│       ├── drbd-build.yml        # Main build workflow
│       └── build-rpm-release.yml # Release workflow
├── scripts/
│   ├── build-drbd.sh            # Main build script
│   └── get-kernels.sh           # Kernel version detection
├── Dockerfile                   # Build environment definition
├── build_drbd_rpm.yml          # Ansible playbook
└── README.md                   # This file
```

## Configuration

### Build Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `EL_MINOR_VERSION` | EL Minor Version (e.g., 5 for el9_5) | 5 |

## Output

The build process generates:

1. **RPM Packages**
   - DRBD kernel modules for each kernel version
   - Located in `output/RPMS/x86_64/`

2. **Build Reports**
   - Build status for each kernel version
   - Located in `output/build_report.md`

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- Open an issue for bug reports or feature requests
- Pull requests are welcome
- For questions, please use GitHub Discussions

## Acknowledgments

- LINBIT for DRBD development
- CentOS Stream community
- Contributors to this project

## Security

Please report security vulnerabilities to security@your-domain.com or via GitHub's security advisory feature.

