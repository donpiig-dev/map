# Usamos la imagen oficial de OSRM solo para extraer el ejecutable ya compilado
FROM osrm/osrm-backend:latest AS osrm_source

# Nuestro contenedor definitivo basado en un Ubuntu limpio y moderno
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Instalamos curl y las librerías necesarias de enrutamiento
RUN apt-get update && apt-get install -y \
    curl \
    libboost-program-options1.74.0 \
    libboost-filesystem1.74.0 \
    libboost-thread1.74.0 \
    libtbb2 \
    && rm -rf /var/lib/apt/lists/*

# Copiamos UNICAMENTE las herramientas ejecutables que ya están listas
COPY --from=osrm_source /usr/local/bin/osrm-* /usr/local/bin/

WORKDIR /data

# 1. Creamos TODAS las subcarpetas necesarias para los perfiles de OSRM
RUN mkdir -p /data/profiles/lib

# 2. Descargamos el perfil oficial de coche (car.lua) y sus dependencias directamente de GitHub
RUN curl -L -o /data/profiles/car.lua https://raw.githubusercontent.com/Project-OSRM/osrm-backend/master/profiles/car.lua && \
    curl -L -o /data/profiles/lib/raster.lua https://raw.githubusercontent.com/Project-OSRM/osrm-backend/master/profiles/lib/raster.lua && \
    curl -L -o /data/profiles/lib/guidance.lua https://raw.githubusercontent.com/Project-OSRM/osrm-backend/master/profiles/lib/guidance.lua && \
    curl -L -o /data/profiles/lib/destination.lua https://raw.githubusercontent.com/Project-OSRM/osrm-backend/master/profiles/lib/destination.lua && \
    curl -L -o /data/profiles/lib/sequence.lua https://raw.githubusercontent.com/Project-OSRM/osrm-backend/master/profiles/lib/sequence.lua

# 3. Descargamos el extracto urbano ligero de Los Ángeles
RUN curl -L -o /data/zona-reparto.osm.pbf https://download.bbbike.org/osm/bbbike/LosAngeles/LosAngeles.osm.pbf

# 4. Procesamos el mapa usando el perfil descargado y limitando a 1 solo hilo por RAM
RUN osrm-extract -p /data/profiles/car.lua /data/zona-reparto.osm.pbf --threads 1 && \
    osrm-partition /data/zona-reparto.osm.pbf && \
    osrm-customize /data/zona-reparto.osm.pbf && \
    rm /data/zona-reparto.osm.pbf

EXPOSE 5000

# Arrancamos el servidor nativo en el puerto 5000 para tu PWA
CMD ["osrm-routed", "--algorithm", "ch", "/data/zona-reparto.osrm", "--port", "5000"]
