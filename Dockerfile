FROM osrm/osrm-backend:latest

# Desactivamos los repositorios rotos de Debian Stretch e instalamos git
RUN echo "" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian/ stretch main" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y --allow-downgrades git && rm -rf /var/lib/apt/lists/*

WORKDIR /data

# 1. TRUCO DEFINITIVO: Clonamos todo el repositorio oficial para tener todos los archivos de Lua originales
RUN git clone --depth 1 https://github.com/Project-OSRM/osrm-backend.git /tmp/osrm-repo && \
    mkdir -p /data/lib && \
    cp /tmp/osrm-repo/profiles/car.lua /data/car.lua && \
    cp /tmp/osrm-repo/profiles/lib/* /data/lib/ && \
    rm -rf /tmp/osrm-repo

# 2. Descargamos la zona de reparto de Los Ángeles
RUN curl -L -o /data/zona-reparto.osm.pbf https://download.bbbike.org/osm/bbbike/LosAngeles/LosAngeles.osm.pbf

# 3. Procesamos el mapa restringiendo los hilos para cuidar la RAM de Railway
RUN osrm-extract -p /data/car.lua /data/zona-reparto.osm.pbf --threads 1 && \
    osrm-partition /data/zona-reparto.osm.pbf && \
    osrm-customize /data/zona-reparto.osm.pbf && \
    rm /data/zona-reparto.osm.pbf

EXPOSE 5000

CMD ["osrm-routed", "--algorithm", "ch", "/data/zona-reparto.osrm", "--port", "5000"]
