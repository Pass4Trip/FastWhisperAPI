# syntax=docker/dockerfile:1

FROM --platform=linux/amd64 python:3.10-slim

# Configuration pour éviter les interactions pendant l'installation
ENV DEBIAN_FRONTEND=noninteractive

# Installation des dépendances système minimales
RUN apt-get update --allow-insecure-repositories \
    && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Création et activation du répertoire de travail
WORKDIR /app

# Mise à jour de pip
RUN python -m pip install --no-cache-dir --upgrade pip setuptools wheel

# Copie des fichiers de dépendances
COPY requirements.txt .

# Installation des dépendances Python
RUN pip install --no-cache-dir torch==2.1.2+cpu -f https://download.pytorch.org/whl/cpu/torch_stable.html && \
    pip install --no-cache-dir -r requirements.txt

# Copie du code de l'application
COPY . .

# Exposition du port
EXPOSE 8000

# Configuration pour forcer l'utilisation du CPU
ENV FORCE_CPU=true

# Commande pour démarrer l'application
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--log-level", "debug"]