FROM osrm/osrm-backend:latest

WORKDIR /data

# 1. Forzamos limpieza de caché
ENV REFRESHED_AT=2026-05-30_oxnard_hills

# 2. Descargamos Oxnard (Cubre perfectamente la franja de Agoura Hills, Calabasas, Bell Canyon y West Hills)
ADD https://download.bbbike.org/osm/bbbike/Oxnard/Oxnard.osm.pbf /data/zona-reparto.osm.pbf

# 3. Procesamos con un solo hilo para Railway Hobby
RUN osrm-extract -p /usr/local/share/osrm/profiles/car.lua /data/zona-reparto.osm.pbf --threads 1
RUN osrm-contract /data/zona-reparto.osm.pbf --threads 1
RUN rm /data/zona-reparto.osm.pbf

EXPOSE 5000

CMD ["osrm-routed", "--algorithm", "ch", "/data/zona-reparto.osrm", "--port", "5000"]
