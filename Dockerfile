FROM osrm/osrm-backend:latest

WORKDIR /data

# 1. Forzamos actualización limpia de la zona completa de Los Ángeles
ENV REFRESHED_AT=2026-05-30_la_full_mld

# 2. Descargamos el mapa completo de Los Ángeles de BBBike
ADD https://download.bbbike.org/osm/bbbike/LosAngeles/LosAngeles.osm.pbf /data/zona-reparto.osm.pbf

# 3. PROCESAMIENTO MLD (Usa poquísima RAM, ideal para mapas grandes en Railway)
RUN osrm-extract -p /usr/local/share/osrm/profiles/car.lua /data/zona-reparto.osm.pbf --threads 1 && \
    osrm-partition /data/zona-reparto.osm.pbf && \
    osrm-customize /data/zona-reparto.osm.pbf && \
    rm /data/zona-reparto.osm.pbf

EXPOSE 5000

# IMPORTANTE: Arrancamos el motor usando el algoritmo "mld" en lugar de "ch"
CMD ["osrm-routed", "--algorithm", "mld", "/data/zona-reparto.osrm", "--port", "5000"]
