#!/bin/bash

# Archivo final que busca OSRM
MAP_NAME="california-latest"

if [ ! -f "/data/${MAP_NAME}.osrm" ]; then
    echo "🗺️ El mapa no está procesado. Iniciando descarga..."
    curl -L -o /data/${MAP_NAME}.osm.pbf https://download.geofabrik.de/north-america/us/california-latest.osm.pbf

    echo "⚙️ Extrayendo calles transitables (Perfil: Car)..."
    osrm-extract -p /profiles/car.lua /data/${MAP_NAME}.osm.pbf

    echo "🧱 Creando particiones de celdas..."
    osrm-partition /data/${MAP_NAME}.osm.pbf

    echo "🚀 Optimizando jerarquías de rutas..."
    osrm-customize /data/${MAP_NAME}.osm.pbf

    echo "🧹 Limpiando archivos temporales pesados..."
    rm /data/${MAP_NAME}.osm.pbf
fi

echo "🟢 Servidor OSRM Listo. Arrancando motor en el puerto 5000..."
exec osrm-routed --algorithm ch /data/${MAP_NAME}.osrm --port 5000