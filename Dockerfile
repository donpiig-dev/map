FROM osrm/osrm-backend:latest

# Instalar curl de forma limpia
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

WORKDIR /data

# 1. Descargamos únicamente el mapa de la zona Sur de California (pesa mucho menos)
RUN curl -L -o /data/socals.osm.pbf https://download.geofabrik.de/north-america/us/california/southern-latest.osm.pbf

# 2. Procesamos el mapa limitando el uso de hilos de ejecución para no ahogar la RAM
RUN osrm-extract -p /profiles/car.lua /data/socals.osm.pbf && \
    osrm-partition /data/socals.osm.pbf && \
    osrm-customize /data/socals.osm.pbf && \
    rm /data/socals.osm.pbf

EXPOSE 5000

# Comando de arranque apuntando al nuevo mapa compacto
CMD ["osrm-routed", "--algorithm", "ch", "/data/socals.osrm", "--port", "5000"]
