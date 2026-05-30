FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Instalamos OSRM, curl y stxxl (necesario para la gestión de memoria de OSRM en Ubuntu)
RUN apt-get update && apt-get install -y \
    osrm-backend \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /data

# 1. Descargamos el extracto urbano ligero de Los Ángeles (BBBike)
RUN curl -L -o /data/zona-reparto.osm.pbf https://download.bbbike.org/osm/bbbike/LosAngeles/LosAngeles.osm.pbf

# 2. Procesamos el mapa limitando los hilos a 1 para proteger la memoria RAM de Railway
RUN osrm-extract -p /usr/share/osrm/profiles/car.lua /data/zona-reparto.osm.pbf --threads 1 && \
    osrm-partition /data/zona-reparto.osm.pbf && \
    osrm-customize /data/zona-reparto.osm.pbf && \
    rm /data/zona-reparto.osm.pbf

EXPOSE 5000

# Arrancamos el motor exactamente igual a como lo lee tu app.js
CMD ["osrm-routed", "--algorithm", "ch", "/data/zona-reparto.osrm", "--port", "5000"]
