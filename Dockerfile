# Volvemos a la base oficial que tiene las librerías de Boost perfectas
FROM osrm/osrm-backend:latest

# TRUCO MÁGICO: Desactivamos las actualizaciones automáticas de Debian Stretch 
# para que no tire el error que nos bloqueaba al inicio.
RUN echo "" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian/ stretch main" >> /etc/apt/sources.list

# Ahora sí instalamos curl de forma limpia desde el archivo histórico
RUN apt-get update && apt-get install -y --allow-downgrades curl && rm -rf /var/lib/apt/lists/*

WORKDIR /data

# 1. Creamos las carpetas de perfiles
RUN mkdir -p /data/profiles/lib

# 2. Descargamos el perfil oficial de coche de OSRM
RUN curl -L -o /data/profiles/car.lua https://raw.githubusercontent.com/Project-OSRM/osrm-backend/master/profiles/car.lua && \
    curl -L -o /data/profiles/lib/raster.lua https://raw.githubusercontent.com/Project-OSRM/osrm-backend/master/profiles/lib/raster.lua && \
    curl -L -o /data/profiles/lib/guidance.lua https://raw.githubusercontent.com/Project-OSRM/osrm-backend/master/profiles/lib/guidance.lua && \
    curl -L -o /data/profiles/lib/destination.lua https://raw.githubusercontent.com/Project-OSRM/osrm-backend/master/profiles/lib/destination.lua && \
    curl -L -o /data/profiles/lib/sequence.lua https://raw.githubusercontent.com/Project-OSRM/osrm-backend/master/profiles/lib/sequence.lua

# 3. Descargamos tu zona de reparto ligera (Los Ángeles)
RUN curl -L -o /data/zona-reparto.osm.pbf https://download.bbbike.org/osm/bbbike/LosAngeles/LosAngeles.osm.pbf

# 4. Procesamos el mapa usando 1 solo hilo para cuidar la RAM de tu plan Hobby
RUN osrm-extract -p /data/profiles/car.lua /data/zona-reparto.osm.pbf --threads 1 && \
    osrm-partition /data/zona-reparto.osm.pbf && \
    osrm-customize /data/zona-reparto.osm.pbf && \
    rm /data/zona-reparto.osm.pbf

EXPOSE 5000

# Arrancamos el motor OSRM nativo
CMD ["osrm-routed", "--algorithm", "ch", "/data/zona-reparto.osrm", "--port", "5000"]
