# Docker for Fess

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/codelibs/docker-fess/blob/master/LICENSE)

The official Docker repository for Fess - a powerful, easily deployable Enterprise Search Server built on OpenSearch.

## What is Fess?

Fess is an enterprise search server that makes it easy to deploy powerful search capabilities across your organization. Built on OpenSearch, Fess provides:

- **All-in-One Solution**: No OpenSearch expertise required
- **Web-based Administration**: Configure everything through an intuitive GUI  
- **Multi-format Support**: Index MS Office, PDF, ZIP and many other file formats
- **Flexible Crawling**: Web pages, file systems, databases, and more
- **Enterprise Ready**: User authentication, access control, and scalability

For more information, visit the [official Fess documentation](http://fess.codelibs.org/).

## Key Features

- 🔍 **Powerful Search Engine** - Full-text search with advanced filtering and faceted navigation
- 🕷️ **Built-in Crawlers** - Web, file system, database, and social media crawlers
- 📄 **Document Support** - MS Office, PDF, HTML, XML, CSV, and 40+ file formats
- 🔐 **Security & Access Control** - LDAP, Active Directory, and SSO integration
- 🎨 **Customizable UI** - Modern responsive interface with theming support
- ⚡ **High Performance** - Distributed architecture with horizontal scaling
- 🐳 **Docker Ready** - Multi-platform containers for easy deployment

## Tech Stack

- **Search Engine**: OpenSearch 3.x
- **Application Server**: Apache Tomcat (embedded)
- **Runtime**: Java 21 (Eclipse Temurin)
- **Base Images**: Alpine Linux (production), Amazon Linux 2023, Ubuntu Noble
- **Containerization**: Docker & Docker Compose
- **Optional Services**: OpenSearch Dashboards, MinIO object storage

## Quick Start

### Prerequisites

**System Requirements:**
- Docker and Docker Compose installed
- At least 4GB RAM available
- For OpenSearch: `vm.max_map_count` >= 262144

**Set vm.max_map_count (Linux/WSL):**
```bash
# Temporary
sudo sysctl -w vm.max_map_count=262144

# Permanent
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf
```

### Standard Deployment

```bash
# Clone the repository
git clone https://github.com/codelibs/docker-fess.git
cd docker-fess

# Start Fess with OpenSearch
docker compose -f compose.yaml -f compose-opensearch3.yaml up -d

# Access Fess web interface
open http://localhost:8080
```

### With OpenSearch Dashboards

```bash
# Start with visualization dashboard
docker compose -f compose.yaml -f compose-opensearch3.yaml -f compose-dashboards3.yaml up -d

# Access services
open http://localhost:8080  # Fess
open http://localhost:5601  # OpenSearch Dashboards
```

### With Object Storage (MinIO)

```bash
# Start with MinIO for file storage
docker compose -f compose.yaml -f compose-opensearch3.yaml -f compose-minio.yaml up -d

# Access services
open http://localhost:8080  # Fess
open http://localhost:9001  # MinIO Console
```

## Usage

### Basic Search Setup

1. **Access Fess Admin**: Navigate to http://localhost:8080/admin
   - Default credentials: `admin` / `admin`

2. **Create a Web Crawler**:
   - Go to Crawler > Web
   - Add URL: `https://example.com/*`
   - Start crawling from System > Scheduler

3. **Configure Search**:
   - Set crawl schedules, filters, and permissions
   - Monitor crawl status and logs

### Environment Variables

Configure Fess behavior through environment variables:

```yaml
environment:
  # Search backend configuration
  - SEARCH_ENGINE_HTTP_URL=http://search01:9200
  
  # Dictionary and data paths
  - FESS_DICTIONARY_PATH=/usr/share/opensearch/config/dictionary/
  
  # Performance tuning
  - FESS_HEAP_SIZE=1g
  - FESS_JAVA_OPTS=-server -Xms1g -Xmx1g
  
  # Plugin installation
  - FESS_PLUGINS=fess-webapp-semantic-search:15.5.0 fess-ds-wikipedia:15.5.0
```

### Multi-Instance Deployment

Run multiple Fess instances sharing one OpenSearch cluster:

```bash
cd compose/multi-instance

# Start OpenSearch + 2 Fess instances
docker compose -f compose.yaml -f compose-fess01.yaml -f compose-fess02.yaml up -d

# Access instances
open http://localhost:8080  # Fess instance 1
open http://localhost:8081  # Fess instance 2
```

Each instance uses separate indices for data isolation.

### Service URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Fess Web UI | http://localhost:8080 | Main search interface |
| Fess Admin | http://localhost:8080/admin | Administration panel |
| OpenSearch API | http://localhost:9200 | Direct search engine access |
| OpenSearch Dashboards | http://localhost:5601 | Data visualization |
| MinIO Console | http://localhost:9001 | Object storage management |

## Development

### Building Images

**Fess Application:**
```bash
# Build specific version
docker build --rm -t ghcr.io/codelibs/fess:15.5.1 ./fess/15.5/

# Build with custom args
docker build --build-arg FESS_VERSION=15.5.1 -t my-fess ./fess/15.5/
```

**OpenSearch with Fess Plugins:**
```bash
# Build OpenSearch image
docker build --rm -t ghcr.io/codelibs/fess-opensearch:3.5.0 ./opensearch/3.5/
```

### Project Structure

```
docker-fess/
├── fess/                    # Fess Docker images
│   ├── 15.5/               # Latest stable version
│   ├── 15.4/               # Previous versions
│   └── snapshot/           # Development builds
├── opensearch/             # OpenSearch images with Fess plugins
│   ├── 3.5/               # Latest OpenSearch
│   └── 3.4/               # Previous versions
├── elasticsearch/          # Elasticsearch images (legacy)
├── compose/                # Docker Compose configurations
│   ├── compose.yaml        # Base Fess service
│   ├── compose-opensearch3.yaml  # OpenSearch 3.x
│   ├── compose-dashboards3.yaml  # OpenSearch Dashboards
│   ├── compose-minio.yaml  # MinIO object storage
│   └── multi-instance/     # Multi-instance setup
└── archive/                # Archived older versions
```

### Configuration Files

**Key Configuration Locations:**
- `/etc/fess/` - Main configuration directory
- `/opt/fess/` - Custom configuration overrides  
- `/var/log/fess/` - Application logs
- `/var/lib/fess/` - Variable data storage

**Custom Index Configuration:**
```bash
# Configure separate indices for multi-instance
FESS_JAVA_OPTS="-Dfess.config.index.document.search.index=myapp.search \
                -Dfess.config.index.document.update.index=myapp.update \
                -Dfess.config.index.config.index=myapp_config"
```

### Version Matrix

| Fess Version | OpenSearch | Elasticsearch | Java | Base Image |
|--------------|------------|---------------|------|------------|
| 15.5.1 | 3.5.0 | - | 21 | Alpine/Ubuntu Noble |
| 15.2.0 | 3.2.0 | - | 21 | Alpine/Ubuntu Noble |
| 15.0.0 | 2.15 | 8.10+ | 17 | Alpine |
| 14.x | 2.x | 7.17/8.x | 11 | Alpine |

## Troubleshooting

### Common Issues

**Container fails to start:**
```bash
# Check vm.max_map_count
cat /proc/sys/vm/max_map_count  # Should be >= 262144

# Check container logs
docker compose logs fess01
docker compose logs search01
```

**Out of memory errors:**
```bash
# Increase heap size
export FESS_HEAP_SIZE=2g
docker compose up -d
```

**Search not working:**
```bash
# Verify OpenSearch connection
curl http://localhost:9200/_cluster/health

# Check Fess connectivity
docker compose exec fess01 curl http://search01:9200
```

**Data persistence:**
```bash
# List volumes
docker volume ls | grep compose

# Remove volumes (WARNING: deletes data)
docker volume rm compose_search01_data compose_search01_dictionary
```

### Performance Tuning

**For production deployments:**

1. **Memory allocation:**
   - Fess: 2-4GB heap (`FESS_HEAP_SIZE=2g`)
   - OpenSearch: 50% of available RAM (`OPENSEARCH_JAVA_OPTS=-Xms2g -Xmx2g`)

2. **Storage optimization:**
   - Use SSD storage for OpenSearch data volumes
   - Separate OS disk from data volumes

3. **Network configuration:**
   - Use dedicated network for container communication
   - Configure proper DNS resolution

## Advanced Usage

### Custom Plugins

Install additional Fess plugins:

```yaml
environment:
  - FESS_PLUGINS=fess-webapp-semantic-search:15.5.0 fess-ds-wikipedia:15.5.0
```

### SSL/TLS Configuration

Configure HTTPS for production:

```bash
# Mount certificate volumes
volumes:
  - ./certs/keystore.jks:/usr/share/fess/keystore.jks:ro
  
environment:
  - FESS_JAVA_OPTS=-Dserver.ssl.key-store=/usr/share/fess/keystore.jks
```

### Backup and Recovery

```bash
# Backup OpenSearch data
docker run --rm -v compose_search01_data:/data -v $(pwd):/backup alpine tar czf /backup/opensearch-backup.tar.gz /data

# Restore OpenSearch data
docker run --rm -v compose_search01_data:/data -v $(pwd):/backup alpine tar xzf /backup/opensearch-backup.tar.gz -C /
```

## License

[Apache License 2.0](LICENSE)

Copyright 2016-2026 CodeLibs Project and the Others.
