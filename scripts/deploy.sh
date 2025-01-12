#!/bin/bash

# Configuration
VPS_HOST="vps-af24e24d.vps.ovh.net"
VPS_IP="51.77.200.196"
VPS_USER="ubuntu"
REGISTRY_PORT="32000"
LOCAL_PATH="/Users/vinh/Documents/fastWhisperAPI"

# Couleurs pour les messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'



echo -e "${YELLOW}🚀 Déploiement de fastwhisper-api...${NC}"

# Nettoyer les images locales
echo -e "${YELLOW}🧹 Nettoyage des images locales...${NC}"
docker rmi -f fastwhisper-api ${VPS_IP}:${REGISTRY_PORT}/fastwhisper-api 2>/dev/null || true

# Build de l'image pour linux/amd64
echo -e "${YELLOW}🔨 Build de l'image Docker...${NC}"
docker build --no-cache --platform linux/amd64 -t fastwhisper-api ${LOCAL_PATH}

# Tag de l'image pour le registry local
echo -e "${YELLOW}🏷️  Tag de l'image...${NC}"
docker tag fastwhisper-api ${VPS_IP}:${REGISTRY_PORT}/fastwhisper-api

# Push de l'image vers le registry
echo -e "${YELLOW}📤 Push de l'image vers le registry...${NC}"
docker push ${VPS_IP}:${REGISTRY_PORT}/fastwhisper-api

# Nettoyer et préparer le VPS
echo -e "${YELLOW}🧹 Préparation du VPS...${NC}"
ssh ${VPS_USER}@${VPS_HOST} "
    set -x  # Mode debug pour afficher chaque commande
    
    echo \"🔍 Vérification des images existantes\"
    microk8s ctr image ls | grep localhost:32000/fastwhisper-api || echo \"Aucune image trouvée\"
    
    echo \"🗑️ Tentative de suppression des anciennes images\"
    microk8s ctr image rm localhost:32000/fastwhisper-api 2>&1 || echo \"Aucune image à supprimer\"
    
" 2>&1 | tee /tmp/vps_deploy.log

# Redéploiement du pod api
echo -e "${YELLOW}🔄 Redéploiement de l'API...${NC}"
if ssh ${VPS_USER}@${VPS_HOST} "
    # Debug: Vérifier l'image actuelle
    echo '🔍 Image actuelle :'
    microk8s kubectl get deployment fastwhisper-api -o=jsonpath='{.spec.template.spec.containers[0].image}'
    echo
    
    # Recharger la configuration du déploiement
    microk8s kubectl apply -f /home/ubuntu/fastwhisper-api-deployment.yaml
  
    # Redémarrer le déploiement
    microk8s kubectl rollout restart deployment fastwhisper-api
"
then
    
    # Vérification détaillée du pod
    echo -e "${YELLOW}🔍 Vérification du pod déployé...${NC}"
    
    # Récupérer les détails du pod
    POD_INFO=$(ssh ${VPS_USER}@${VPS_HOST} "microk8s kubectl get pods -l app=fastwhisper-api -o=jsonpath='{.items[0].metadata.name} {.items[0].status.containerStatuses[0].imageID} {.items[0].status.containerStatuses[0].image} {.items[0].metadata.creationTimestamp}'")
    
    echo -e "${YELLOW}Détails du pod :${NC}"
    echo "$POD_INFO" | awk '{print "Nom du pod: " $1 "\nImage ID: " $2 "\nImage: " $3 "\nDate de création: " $4}'
    
  
    
    echo -e "${GREEN}✅ Déploiement terminé avec succès${NC}"
else
    echo -e "${RED}❌ Échec du déploiement${NC}"
    exit 1
fi