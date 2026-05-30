FROM osrm/osrm-backend:latest

# Desactivamos los repositorios rotos de Debian Stretch e instalamos curl
RUN echo "" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian/ stretch main" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y --allow-downgrades curl && rm -rf /var/lib/apt/lists/*

# Establecemos la carpeta de trabajo
WORKDIR /data

# 1. Creamos la subcarpeta 'lib' directamente en /data (así lo exige Lua)
RUN mkdir -p /data/lib

# 2. Descargamos el script principal en la raíz de trabajo
RUN curl -L -o /data/car.lua https://raw.githubusercontent.com/Project-OSRM/osrm-backend/master/profiles/car.lua

# 3. Descargamos absolutamente TODAS las librerías necesarias dentro de /data/lib/
RUN curl -L -o /data/lib/set.lua https://raw.githubusercontent.com/Project-OSRM/osrm-backend/master/profiles/lib/set.lua && \
    curl -L -o /data/lib/raster.lua https://raw.githubusercontent.com/Project-OSRM/osrm-backend/master/profiles/lib/raster.lua && \
    curl -L -o /data/lib/guidance.lua https://raw.githubusercontent.com/Project-OSRM/osrm-backend/master/profiles/lib/guidance.lua && \
    curl -L -o /data/lib/destination.lua https://raw.githubusercontent.com/Project-OSRM/osrm-backend/master/profiles/lib/destination.lua && \
    curl -L -o /data/lib/sequence.lua https://raw.githubusercontent.com/Project-OSRM/osrm-backend/master/profiles/lib/sequence.lua

# 4. Descargamos la zona de reparto de Los Ángeles
RUN curl -L -o /data/zona-reparto.osm.pbf https://download.bbbike.org/osm/bbbike/LosAngeles/LosAngeles.osm.pbf

# 5. Procesamos usando el archivo car.lua parado en /data
RUN osrm-extract -p /data/car.lua /data/zona-reparto.osm.pbf --threads 1 && \
    osrm-partition /data/zona-reparto.osm.pbf && \
    osrm-customize /data/zona-reparto.osm.pbf && \
    rm /data/zona-reparto.osm.pbf

EXPOSE 5000

CMD ["osrm-routed", "--algorithm", "ch", "/data/zona-reparto.osrm", "--port", "5000"]
