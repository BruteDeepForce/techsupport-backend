FROM postgres:18

# Install build dependencies to compile pgvector
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential git ca-certificates postgresql-server-dev-18 pkg-config && \
    rm -rf /var/lib/apt/lists/*

# Pin a pgvector tag if you want reproducible builds (adjust as needed)
ARG PGVECTOR_VERSION="v0.5.5"

RUN git clone https://github.com/pgvector/pgvector.git /tmp/pgvector && \
    cd /tmp/pgvector && \
    git checkout ${PGVECTOR_VERSION} || true && \
    make && make install && \
    rm -rf /tmp/pgvector

# Clean up build deps to reduce image size
RUN apt-get purge -y --auto-remove build-essential git pkg-config && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# Default postgres image entrypoint/command will run as usual
