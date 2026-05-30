FROM osrm/osrm-backend:latest

# Instalar curl para poder descargar el mapa dinámicamente
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Crear directorio de trabajo
WORKDIR /data

# Copiar el script de inicio al contenedor
COPY start.sh /data/start.sh
RUN chmod +x /data/start.sh

# Exponer el puerto de OSRM
EXPOSE 5000

# Ejecutar el script al arrancar
CMD ["/data/start.sh"]