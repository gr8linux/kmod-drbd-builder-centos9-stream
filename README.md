# DRBD Kernel Module Builder for CentOS Stream 9

Automated build system for DRBD kernel modules supporting multiple CentOS Stream 9 kernel versions. This project uses Docker and GitHub Actions to automatically build and release DRBD kernel modules when new kernel versions are released.

## Features

- 🔄 Automatic weekly builds via GitHub Actions
- 🎯 Supports multiple kernel versions simultaneously
- 📦 Generates RPM packages for each kernel version
- 🚀 Docker-based build environment for consistency
- 📋 Detailed build reports and metadata
- 🔧 Configurable DRBD versions and releases

## Quick Start

### Local Build

1. Clone the repository:
```bash
git clone https://github.com/<your-username>/drbd-kernel-builder.git
cd drbd-kernel-builder
```

2. Build using Docker:
```bash
# Build with default settings
docker build -t drbd-builder .
docker run --rm -v $(pwd)/output:/root/output drbd-builder

# Build with specific DRBD version
docker build -t drbd-builder \
    --build-arg DRBD_VERSION=9.1.23 \
    --build-arg DRBD_RELEASE=1 \
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
   - Runs automatically every Sunday
   - Checks for new kernel versions
   - Uploads artifacts to GitHub

2. **Manual Trigger**
   - Go to Actions → "DRBD RPM Build and Release"
   - Click "Run workflow"
   - Optionally specify DRBD version and release

3. **Release Builds**
   - Triggered by version tags
   - Creates GitHub releases with artifacts
   ```bash
   git tag v9.1.23
   git push origin v9.1.23
   ```

### 2. Local Development

Build and test locally using Docker:

```bash
# Build image
docker build -t drbd-builder .

# Run with default settings
docker run --rm -v $(pwd)/output:/root/output drbd-builder

# Run with specific kernel versions
docker run --rm \
    -e KERNEL_VERSIONS="5.14.0-554.el9 5.14.0-553.el9" \
    -v $(pwd)/output:/root/output \
    drbd-builder
```

## Project Structure

```
.
├── .github/
│   └── workflows/
│       └── drbd-build.yml    # GitHub Actions workflow
├── scripts/
│   ├── build-drbd.sh        # Main build script
│   └── get-kernels.sh       # Kernel version detection
├── Dockerfile               # Build environment definition
├── build_drbd_rpm.yml      # Ansible playbook
└── README.md               # This file
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DRBD_VERSION` | DRBD version to build | 9.1.23 |
| `DRBD_RELEASE` | Release number | 1 |
| `EL_VERSION` | Enterprise Linux version | 9 |
| `KERNEL_VERSIONS` | Space-separated list of kernel versions | auto-detected |

### Build Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `DRBD_VERSION` | DRBD version | 9.1.23 |
| `DRBD_RELEASE` | Release number | 1 |
| `EL_VERSION` | Enterprise Linux version | 9 |

## Output

The build process generates:

1. **RPM Packages**
   - DRBD kernel modules for each kernel version
   - Located in `output/RPMS/x86_64/`

2. **Build Reports**
   - Build status for each kernel version
   - Located in `output/build_report.txt`

3. **Metadata**
   - Build information and configuration
   - Located in `output/metadata.txt`

## Contributing

1. Fork the repository
2. Create your feature branch:
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. Commit your changes:
   ```bash
   git commit -m 'Add amazing feature'
   ```
4. Push to the branch:
   ```bash
   git push origin feature/amazing-feature
   ```
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

