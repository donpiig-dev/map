FROM osrm/osrm-backend:latest

WORKDIR /data

# 1. Railway descarga el mapa de Los Ángeles de forma externa
ADD https://download.bbbike.org/osm/bbbike/LosAngeles/LosAngeles.osm.pbf /data/zona-reparto.osm.pbf

# 2. Procesamos el mapa usando CONTRACT (necesario para el algoritmo CH que pide tu app)
# Limitamos a 1 solo hilo para asegurar que no tire picos de RAM en Railway
RUN osrm-extract -p /usr/local/share/osrm/profiles/car.lua /data/zona-reparto.osm.pbf --threads 1 && \
    osrm-contract /data/zona-reparto.osm.pbf --threads 1 && \
    rm /data/zona-reparto.osm.pbf

EXPOSE 5000

# Arrancamos el motor OSRM usando CH exactamente como lo espera tu PWA
CMD ["osrm-routed", "--algorithm", "ch", "/data/zona-reparto.osrm", "--port", "5000"]
