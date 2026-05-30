FROM osrm/osrm-backend:latest

# Desactivamos los repositorios antiguos e instalamos git (git sí suele venir o compilarse fácil, 
# pero para evitar cualquier fallo, usamos una alternativa limpia)
WORKDIR /data

# 1. TRUCO DE MARCO: Usamos ADD para que Railway descargue el mapa de Los Ángeles directamente
ADD https://download.bbbike.org/osm/bbbike/LosAngeles/LosAngeles.osm.pbf /data/zona-reparto.osm.pbf

# 2. Como OSRM ya incluye por defecto sus propios perfiles dentro del contenedor, 
# usaremos directamente el perfil nativo interno en lugar de descargarlo de GitHub.
# El perfil de coche de fábrica está guardado exactamente en /profiles/car.lua

# 3. Procesamos el mapa usando el perfil interno y limitando a 1 solo hilo por la RAM de tu plan Hobby
RUN osrm-extract -p /profiles/car.lua /data/zona-reparto.osm.pbf --threads 1 && \
    osrm-partition /data/zona-reparto.osm.pbf && \
    osrm-customize /data/zona-reparto.osm.pbf && \
    rm /data/zona-reparto.osm.pbf

EXPOSE 5000

# Arrancamos el motor OSRM nativo
CMD ["osrm-routed", "--algorithm", "ch", "/data/zona-reparto.osrm", "--port", "5000"]
