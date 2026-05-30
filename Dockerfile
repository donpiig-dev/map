FROM osrm/osrm-backend:latest

WORKDIR /data

# 1. Agregamos una variable de entorno para romper la caché de Railway por completo
ENV REFRESHED_AT=2026-05-30_v2

# 2. Descargamos el mapa mini de Berkeley
ADD https://download.bbbike.org/osm/bbbike/Berkeley/Berkeley.osm.pbf /data/zona-reparto.osm.pbf

# 3. Forzamos la extracción y la contracción en comandos separados 
# (Esto hace que Docker no pueda usar la caché vieja)
RUN osrm-extract -p /usr/local/share/osrm/profiles/car.lua /data/zona-reparto.osm.pbf --threads 1
RUN osrm-contract /data/zona-reparto.osm.pbf --threads 1
RUN rm /data/zona-reparto.osm.pbf

EXPOSE 5000

# Arrancamos usando el algoritmo CH nativo
CMD ["osrm-routed", "--algorithm", "ch", "/data/zona-reparto.osrm", "--port", "5000"]
