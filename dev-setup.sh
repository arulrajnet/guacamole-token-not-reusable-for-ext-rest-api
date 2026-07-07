#!/bin/bash
set -e

# Define multiple Guacamole versions to build
GUACAMOLE_VERSIONS=("1.5.5" "1.6.0")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Loop through each version
for GUACAMOLE_VERSION in "${GUACAMOLE_VERSIONS[@]}"; do
    echo ""
    echo "=========================================="
    echo "==> Setting up for guacamole-client v${GUACAMOLE_VERSION}..."
    echo "=========================================="

    GUAC_REPO_DIR="apache-guacamole-${GUACAMOLE_VERSION}"

    # Clone apache guacamole-client if not already present, otherwise reset to default branch
    if [ ! -d "${SCRIPT_DIR}/${GUAC_REPO_DIR}" ]; then
        echo "==> Cloning apache/guacamole-client..."
        git clone --depth 1 --branch "${GUACAMOLE_VERSION}" git@github.com:apache/guacamole-client.git "${SCRIPT_DIR}/${GUAC_REPO_DIR}"
    else
        echo "==> '${GUAC_REPO_DIR}' already exists, remove and cloning..."
        rm -rf "${SCRIPT_DIR}/${GUAC_REPO_DIR}"
        git clone --depth 1 --branch "${GUACAMOLE_VERSION}" git@github.com:apache/guacamole-client.git "${SCRIPT_DIR}/${GUAC_REPO_DIR}"
    fi

    cd "${SCRIPT_DIR}/${GUAC_REPO_DIR}"

    # Patch pom.xml: disable license errors and skip guacamole web app module
    sed -i.bak \
        -e "s|<ignoreLicenseErrors>false</ignoreLicenseErrors>|<ignoreLicenseErrors>true</ignoreLicenseErrors>|g" \
        -e "s|<module>guacamole</module>|<!-- <module>guacamole</module> -->|g" \
        ./pom.xml

    # Patch extensions/pom.xml: skip exec-maven-plugin execution
    sed -i.bak \
        -e "s|<artifactId>exec-maven-plugin</artifactId>$|<artifactId>exec-maven-plugin</artifactId><configuration><skip>true</skip></configuration>|g" \
        ./extensions/pom.xml

    # Build guacamole-auth-header and install to local Maven repo
    echo "==> Building guacamole-auth-header..."
    cd "${SCRIPT_DIR}/${GUAC_REPO_DIR}"
    cd extensions/guacamole-auth-header
    mvn -B install
    # Copy guacamole-auth-header pom.xml to local Maven repo
    echo "==> Copying guacamole-auth-header pom to local Maven repo..."
    EXTENSIONS_REPO_DIR="${HOME}/.m2/repository/org/apache/guacamole/extensions/${GUACAMOLE_VERSION}"
    mkdir -p "${EXTENSIONS_REPO_DIR}"
    cp "${SCRIPT_DIR}/${GUAC_REPO_DIR}/extensions/guacamole-auth-header/pom.xml" \
        "${EXTENSIONS_REPO_DIR}/guacamole-auth-header-${GUACAMOLE_VERSION}.pom"

    echo "==> Completed setup for guacamole-client v${GUACAMOLE_VERSION}"
done

echo ""
echo "=========================================="
echo "==> All setups complete! Build the modules:"
echo "=========================================="
echo "    cd ${SCRIPT_DIR}"
echo "    mvn clean package -P guac-1.5.5"
echo "    mvn package -P guac-1.6.0"
