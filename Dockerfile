FROM osrm/osrm-backend:latest

WORKDIR /data

# Cambiamos radicalmente la variable para obligar a Railway a destruir la caché vieja
ENV FORCE_RESET_CACHE=2026_05_30_RESET_LA_FULL
ENV OSRM_ALGORITHM=mld

# Descargamos el mapa metropolitano completo de Los Ángeles
ADD https://download.bbbike.org/osm/bbbike/LosAngeles/LosAngeles.osm.pbf /data/zona-reparto.osm.pbf

# Ejecutamos el pipeline MLD en una sola línea combinada (Esto destruye cualquier caché intermedia)
RUN osrm-extract -p /usr/local/share/osrm/profiles/car.lua /data/zona-reparto.osm.pbf --threads 1 && \
    osrm-partition /data/zona-reparto.osm.pbf && \
    osrm-customize /data/zona-reparto.osm.pbf && \
    rm /data/zona-reparto.osm.pbf

EXPOSE 5000

# Arrancamos usando el algoritmo MLD nativo
CMD ["osrm-routed", "--algorithm", "mld", "/data/zona-reparto.osrm", "--port", "5000"]
