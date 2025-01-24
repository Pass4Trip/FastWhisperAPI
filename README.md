# FastWhisperAPI

## Installation et Déploiement

### Prérequis
- Python 3.8+
- Docker
- Environnement virtuel

### Installation Locale

1. Cloner le dépôt :
```bash
git clone https://github.com/3choff/FastWhisperAPI.git
cd FastWhisperAPI
```

2. Créer et activer l'environnement virtuel :
```bash
python3 -m venv uv
source uv/bin/activate
```

3. Installer les dépendances :
```bash
pip install -r requirements.txt
```

## Déploiement Docker

### Construction de l'Image

1. Construire l'image Docker :
```bash
docker build -t fastwhisper-api .
```

2. Pousser l'image vers le registry local :
```bash
docker push 51.77.200.196:32000/fastwhisper-api:latest
```

### Lancement du Conteneur

1. Démarrer le conteneur :
```bash
docker run -d --name fastwhisper-api -p 0.0.0.0:8765:8000 51.77.200.196:32000/fastwhisper-api:latest
```

### Configuration Réseau

1. Configurer le pare-feu UFW :
```bash
sudo ufw enable
sudo ufw allow 8765/tcp
```

2. Configuration iptables (si nécessaire) :
```bash
sudo iptables -t nat -A DOCKER -p tcp --dport 8765 -j DNAT --to-destination 172.17.0.2:8000
sudo iptables -t nat -A POSTROUTING -j MASQUERADE
```

### Vérification

- Tester l'accessibilité :
```bash
curl http://51.77.200.196:8765/docs
```

- **URL Swagger** : `http://51.77.200.196:8765/docs`

## Résolution des Problèmes

- Vérifier l'état du conteneur : `docker ps`
- Consulter les logs : `docker logs fastwhisper-api`
- Problèmes de réseau : `docker inspect fastwhisper-api`
