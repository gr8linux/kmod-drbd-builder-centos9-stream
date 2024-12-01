# kmod-drbd-builder-centos9-stream

A repository for building custom **kmod-drbd** kernel modules for **CentOS 9 Stream** using Docker and Ansible. This project automates the process of downloading, building, and packaging RPM files for the DRBD kernel module.

## Features

- Builds DRBD kernel module (`kmod-drbd`) for a specified kernel version.
- Uses Docker to create an isolated build environment.
- Provides an Ansible playbook for remote builds.
- Outputs RPM packages ready for installation.

---

## Getting Started

### Prerequisites

- **Docker**: Ensure Docker is installed and running on your system.
- **Ansible**: Required to run the included Ansible playbook.

### Clone the Repository

```bash
git clone https://github.com/<your-username>/kmod-drbd-builder-centos9-stream.git
cd kmod-drbd-builder-centos9-stream
```

---

## Usage

### Using Docker

1. Build the Docker image:
   ```bash
   docker build -t kmod-drbd-builder .
   ```

2. Run the container to build the RPMs:
   ```bash
   docker run --rm -v $(pwd)/output:/root/output kmod-drbd-builder
   ```

3. The built RPMs will be available in the `output/` directory.

---

### Using Ansible

1. Update the Ansible playbook (`build-rpm.yml`) with the desired configuration.

2. Run the playbook to build the RPMs remotely:
   ```bash
   ansible-playbook build-rpm.yml -e "docker_image_name=kmod-drbd-builder docker_container_name=kmod-drbd-container output_directory=/path/to/output"
   ```

3. The built RPMs will be copied to the specified `output_directory`.

---

## Repository Structure

```
.
├── Dockerfile                # Dockerfile to build the kmod-drbd RPM
├── build-rpm.yml             # Ansible playbook for remote builds
├── output/                   # Directory for storing built RPMs
├── .github/
│   └── workflows/
│       └── build-rpm.yml     # GitHub Actions workflow
├── README.md                 # Project documentation
```

---

## Variables

- **LB_KERNEL_VERSION**: The target kernel version for which the DRBD module is built.
- **LB_SRPM_URL**: URL to the DRBD source RPM.

---

## Contributing

1. Fork the repository.
2. Create a new branch (```bash git checkout -b feature/your-feature ```).
3. Commit your changes (```bash git commit -m 'Add your feature' ```).
4. Push to the branch (```bash git push origin feature/your-feature ```).
5. Open a pull request.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

