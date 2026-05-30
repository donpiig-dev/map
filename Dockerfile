FROM osrm/osrm-backend:latest

WORKDIR /data

# 1. Railway descarga el mapa de Los Ángeles de forma externa y limpia
ADD https://download.bbbike.org/osm/bbbike/LosAngeles/LosAngeles.osm.pbf /data/zona-reparto.osm.pbf

# 2. Procesamos el mapa usando la ruta absoluta real del perfil nativo en la imagen oficial
RUN osrm-extract -p /usr/local/share/osrm/profiles/car.lua /data/zona-reparto.osm.pbf --threads 1 && \
    osrm-partition /data/zona-reparto.osm.pbf && \
    osrm-customize /data/zona-reparto.osm.pbf && \
    rm /data/zona-reparto.osm.pbf

EXPOSE 5000

# Arrancamos el motor OSRM nativo listo para tu PWA
CMD ["osrm-routed", "--algorithm", "ch", "/data/zona-reparto.osrm", "--port", "5000"]
