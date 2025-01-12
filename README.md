# FastWhisperAPI

## Installation sur Environnement de Développement Local (Mac M1)

### Prérequis
- Python 3.8 ou supérieur
- Docker Desktop
- Environnement virtuel UV

### Étapes d'Installation

1. Cloner le dépôt :
```bash
git clone https://github.com/3choff/FastWhisperAPI.git
cd FastWhisperAPI
```

2. Créer et activer l'environnement virtuel UV :
```bash
python3 -m venv uv
source uv/bin/activate
```

3. Installer les dépendances avec UV :
```bash
uv pip install -r requirements.txt
```

## Déploiement

Le déploiement se fait via le script `deploy.sh` :
```bash
./scripts/deploy.sh
```

## Configuration Kubernetes et Ingress

### Configuration du Déploiement

Le déploiement Kubernetes utilise plusieurs paramètres clés :

- **Port du Conteneur** : `8000`
  - Le conteneur FastWhisper écoute sur le port 8000 à l'intérieur du pod
  - Commande Uvicorn : `uvicorn main:app --host 0.0.0.0 --port 8000`

- **Port du Service** : `8001`
  - Le service Kubernetes expose le port 8001 
  - Redirection du port 8000 du conteneur vers le port 8001 du service
  ```yaml
  ports:
  - port: 8001        # Port externe du service
    targetPort: 8000  # Port du conteneur
  ```

### Configuration Ingress

L'ingress gère le routage externe avec des annotations spécifiques :

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    # Configuration de proxy pour les connexions WebSocket
    nginx.ingress.kubernetes.io/configuration-snippet: |
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
    
    # Limites de taille et de timeout
    nginx.ingress.kubernetes.io/proxy-body-size: 50m
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
```

#### Chemins de Routage
- `/fastwhisper-api` : Point d'entrée principal du service
- `/fastwhisper-api/docs` : Documentation Swagger
- `/fastwhisper-api/openapi.json` : Spécification OpenAPI

### Pourquoi le Port 8001 ?

Le port 8001 est utilisé pour :
1. Éviter les conflits avec d'autres services (comme `agent-api` sur le port 8000)
2. Fournir une couche d'abstraction entre le port du conteneur et le port externe
3. Permettre une configuration flexible du réseau Kubernetes

## Construction de l'Image Docker pour AMD64

### Contexte de la Compatibilité Multi-Architecture

Sur un Mac M1 (architecture ARM), la construction d'une image pour des serveurs x86_64 (AMD64) nécessite des étapes spécifiques.

### Stratégies de Construction d'Image

1. **Build Multi-Architecture**
```bash
docker buildx create --use
docker buildx build \
    --platform linux/amd64 \
    -t fastwhisper-api:amd64 \
    --push \
    .
```

2. **Utilisation de QEMU**
   - QEMU permet l'émulation de différentes architectures
   - Installable via Docker BuildX ou directement sur le système

### Dockerfile Optimisé

Exemple de configuration pour supporter multiple architectures :
```dockerfile
# Utiliser une image de base compatible multi-architecture
FROM --platform=$TARGETPLATFORM python:3.10-slim

# Arguments pour le multi-architecture
ARG TARGETPLATFORM
ARG BUILDPLATFORM

# Instructions de build indépendantes de l'architecture
RUN echo "Building for $TARGETPLATFORM"
```

### Considérations pour AMD64

- Les images AMD64 sont optimisées pour les processeurs Intel et AMD x86_64
- Performances potentiellement différentes par rapport à ARM
- Nécessité de tester sur l'environnement cible

### Commandes Utiles

- Vérifier l'architecture : `docker inspect fastwhisper-api:amd64`
- Lister les plateformes supportées : `docker buildx ls`

### Résolution des Problèmes Courants

- **Erreur de dépendances** : Certaines bibliothèques peuvent nécessiter une compilation spécifique
- **Différences de performance** : Les optimisations peuvent varier entre ARM et AMD64
- **Compatibilité des GPU** : Les configurations CUDA peuvent différer

## Conseils Supplémentaires

- Toujours tester l'image sur un environnement similaire à la production
- Utiliser des images de base officielles et à jour
- Surveiller les performances et les éventuels problèmes de compatibilité

## Accès à la Documentation Swagger

### Environnement Local
- URL : `http://localhost:8000/docs`

### Environnement Serveur VPS
- URL : `http://vps-af24e24d.vps.ovh.net/fastwhisper-api/docs`

### Accès Distant
1. Assurez-vous d'être connecté au VPN ou au réseau approprié
2. Utilisez les identifiants de connexion fournis
3. Naviguez vers l'URL de documentation Swagger

## Utilisation de la Documentation Swagger

1. Ouvrez l'URL de la documentation
2. Explorez les différents endpoints disponibles
3. Utilisez le bouton "Try it out" pour tester les requêtes directement depuis l'interface

## Dépannage

- Vérifiez que le déploiement via `deploy.sh` s'est terminé sans erreur
- Consultez les logs du déploiement avec `microk8s kubectl logs deployment/fastwhisper-api`
- Vérifiez l'état du pod avec `microk8s kubectl get pods`
- En cas de problème, inspectez la configuration du service et de l'ingress

## Support

Pour toute question ou support, n'hésitez pas à ouvrir une issue sur le dépôt GitHub ou à contacter l'équipe de développement.