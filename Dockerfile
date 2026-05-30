FROM osrm/osrm-backend:latest

WORKDIR /data

# 1. Rompemos la caché para que Railway compile la nueva zona extendida
ENV REFRESHED_AT=2026-05-30_westhills_v1

# 2. Descargamos el extracto Noroeste de LA (Cubre perfectamente Agoura Hills, Calabasas, Bell Canyon y West Hills)
ADD https://download.bbbike.org/osm/bbbike/LosAngelesNorthwest/LosAngelesNorthwest.osm.pbf /data/zona-reparto.osm.pbf

# 3. Procesamos las rutas con 1 solo hilo para cuidar tu plan Hobby
RUN osrm-extract -p /usr/local/share/osrm/profiles/car.lua /data/zona-reparto.osm.pbf --threads 1
RUN osrm-contract /data/zona-reparto.osm.pbf --threads 1
RUN rm /data/zona-reparto.osm.pbf

EXPOSE 5000

# Arrancamos el motor listo para tu PWA
CMD ["osrm-routed", "--algorithm", "ch", "/data/zona-reparto.osrm", "--port", "5000"]
