# Paso 1: Usamos la imagen oficial de OSRM solo para extraer el programa ya compilado
FROM osrm/osrm-backend:latest AS osrm_source

# Paso 2: Creamos nuestro contenedor definitivo sobre una base moderna y estable
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Instalamos curl y las librerías básicas de mapas que necesita OSRM para correr
RUN apt-get update && apt-get install -y \
    curl \
    libboost-program-options1.74.0 \
    libboost-filesystem1.74.0 \
    libboost-thread1.74.0 \
    libtbb2 \
    && rm -rf /var/lib/apt/lists/*

# Copiamos las herramientas de enrutamiento y los perfiles de la imagen oficial
COPY --from=osrm_source /usr/local/bin/osrm-* /usr/local/bin/
COPY --from=osrm_source /profiles /profiles

WORKDIR /data

# 1. Descargamos un extracto urbano ultra ligero (Los Ángeles) para no saturar la RAM de Railway
RUN curl -L -o /data/zona-reparto.osm.pbf https://download.bbbike.org/osm/bbbike/LosAngeles/LosAngeles.osm.pbf

# 2. Procesamos el mapa limitando el uso a 1 solo hilo (Evita que Railway mate el proceso por consumo de RAM)
RUN osrm-extract -p /profiles/car.lua /data/zona-reparto.osm.pbf --threads 1 && \
    osrm-partition /data/zona-reparto.osm.pbf && \
    osrm-customize /data/zona-reparto.osm.pbf && \
    rm /data/zona-reparto.osm.pbf

EXPOSE 5000

# Arrancamos el servidor nativo en el puerto 5000, manteniendo intacta la lógica de tu PWA
CMD ["osrm-routed", "--algorithm", "ch", "/data/zona-reparto.osrm", "--port", "5000"]
