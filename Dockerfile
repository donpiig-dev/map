FROM osrm/osrm-backend:latest

# Desactivamos los repositorios rotos de Debian Stretch e instalamos curl
RUN echo "" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian/ stretch main" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y --allow-downgrades curl && rm -rf /var/lib/apt/lists/*

WORKDIR /data

# 1. Creamos la estructura de carpetas necesaria
RUN mkdir -p /data/lib

# 2. Descargamos el script principal de coche
RUN curl -L -o /data/car.lua https://raw.githubusercontent.com/Project-OSRM/osrm-backend/master/profiles/car.lua

# 3. Descargamos TODAS las dependencias posibles (Incluyendo utils y ayudantes)
RUN for file in set raster guidance destination sequence way_handlers relations tags measure access handlers utils data_facade profiling; do \
      curl -L -o /data/lib/${file}.lua https://raw.githubusercontent.com/Project-OSRM/osrm-backend/master/profiles/lib/${file}.lua; \
    done

# 4. Descargamos la zona de reparto de Los Ángeles
RUN curl -L -o /data/zona-reparto.osm.pbf https://download.bbbike.org/osm/bbbike/LosAngeles/LosAngeles.osm.pbf

# 5. Procesamos el mapa restringiendo los hilos para cuidar la RAM de Railway
RUN osrm-extract -p /data/car.lua /data/zona-reparto.osm.pbf --threads 1 && \
    osrm-partition /data/zona-reparto.osm.pbf && \
    osrm-customize /data/zona-reparto.osm.pbf && \
    rm /data/zona-reparto.osm.pbf

EXPOSE 5000

CMD ["osrm-routed", "--algorithm", "ch", "/data/zona-reparto.osrm", "--port", "5000"]
