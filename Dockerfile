FROM osrm/osrm-backend:latest

WORKDIR /data

# 1. Forzamos una compilación limpia rompiendo la caché de Railway
ENV REFRESHED_AT=2026-05-30_los_angeles_full

# 2. Descargamos el mapa de Los Ángeles completo desde BBBike
ADD https://download.bbbike.org/osm/bbbike/LosAngeles/LosAngeles.osm.pbf /data/zona-reparto.osm.pbf

# 3. PROCESAMIENTO MLD: Ideal para mapas grandes en entornos con RAM limitada
RUN osrm-extract -p /usr/local/share/osrm/profiles/car.lua /data/zona-reparto.osm.pbf --threads 1 && \
    osrm-partition /data/zona-reparto.osm.pbf && \
    osrm-customize /data/zona-reparto.osm.pbf && \
    rm /data/zona-reparto.osm.pbf

EXPOSE 5000

# IMPORTANTE: Arrancamos el motor indicando explícitamente el algoritmo mld
CMD ["osrm-routed", "--algorithm", "mld", "/data/zona-reparto.osrm", "--port", "5000"]
