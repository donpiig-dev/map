FROM osrm/osrm-backend:latest

WORKDIR /data

# 1. Descargamos la zona ligera de Berkeley usando ADD para evitar depender de curl
ADD https://download.bbbike.org/osm/bbbike/Berkeley/Berkeley.osm.pbf /data/zona-reparto.osm.pbf

# 2. PROCESAMIENTO CH: Cambiamos partition/customize por osrm-contract
# Forzamos 1 solo hilo para asegurar que Railway apruebe el proceso en segundos
RUN osrm-extract -p /usr/local/share/osrm/profiles/car.lua /data/zona-reparto.osm.pbf --threads 1 && \
    osrm-contract /data/zona-reparto.osm.pbf --threads 1 && \
    rm /data/zona-reparto.osm.pbf

EXPOSE 5000

# Arrancamos el motor OSRM usando CH, exactamente como lo espera tu app
CMD ["osrm-routed", "--algorithm", "ch", "/data/zona-reparto.osrm", "--port", "5000"]
