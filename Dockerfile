# Usamos una base moderna y estable de Ubuntu en lugar de las imágenes viejas de Debian
FROM ubuntu:22.04

# Evitar preguntas interactivas durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalar OSRM y curl usando repositorios modernos que SÍ funcionan
RUN apt-get update && apt-get install -y \
    osrm-backend \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Crear el directorio para los mapas
WORKDIR /data

# 1. Descargamos un extracto urbano ligero (Los Ángeles en este ejemplo para que no sature la RAM)
RUN curl -L -o /data/zona-reparto.osm.pbf https://download.bbbike.org/osm/bbbike/LosAngeles/LosAngeles.osm.pbf

# 2. Procesamos el mapa con los comandos nativos de OSRM
RUN osrm-extract -p /usr/share/osrm/profiles/car.lua /data/zona-reparto.osm.pbf && \
    osrm-partition /data/zona-reparto.osm.pbf && \
    osrm-customize /data/zona-reparto.osm.pbf && \
    rm /data/zona-reparto.osm.pbf

# Exponer el puerto nativo de OSRM
EXPOSE 5000

# Arrancar el motor OSRM exactamente igual a como lo espera tu app.js
CMD ["osrm-routed", "--algorithm", "ch", "/data/zona-reparto.osrm", "--port", "5000"]
