import requests
import os

def transcribe_audio(file_path, api_url='http://vps-af24e24d.vps.ovh.net/fastwhisper-api/v1/transcriptions'):
    """
    Transcrit un fichier audio en utilisant l'API FastWhisper.
    
    :param file_path: Chemin vers le fichier audio à transcrire
    :param api_url: URL de l'endpoint de transcription
    :return: Texte transcrit ou message d'erreur
    """
    try:
        # Token Bearer en dur
        api_token = 'Bearer'
        
        # En-têtes d'authentification
        headers = {
            'Authorization': f'Bearer {api_token}'
        }
        
        # Ouvrir le fichier en mode binaire
        with open(file_path, 'rb') as audio_file:
            # Préparer les fichiers pour la requête multipart
            files = {
                'file': (file_path.split('/')[-1], audio_file, 'audio/wav')
            }
            
            # Paramètres optionnels (à ajuster selon les besoins de l'API)
            data = {
                'language': 'fr',  # Langue de la transcription
                'task': 'transcribe'  # Ou 'translate' si besoin
            }
            
            # Envoyer la requête POST
            response = requests.post(api_url, files=files, data=data, headers=headers)
            
            # Vérifier le statut de la réponse
            if response.status_code == 200:
                # Récupérer le résultat de la transcription
                result = response.json()
                return result.get('text', 'Pas de transcription disponible')
            else:
                # Gérer les erreurs
                return f"Erreur {response.status_code}: {response.text}"
    
    except FileNotFoundError:
        return "Fichier audio non trouvé"
    except requests.RequestException as e:
        return f"Erreur de requête : {e}"

# Exemple d'utilisation
if __name__ == "__main__":
    # Remplacez par le chemin de votre fichier audio
    audio_path = '/Users/vinh/Documents/fastWhisperAPI/audio/file.m4a'
    
    # Transcrire l'audio
    transcription = transcribe_audio(audio_path)
    
    # Afficher le résultat
    print("Transcription :")
    print(transcription)

# Conseils d'utilisation :
# 1. Remplacez 'YOUR_BEARER_TOKEN_HERE' par le token réel
# 2. Assurez-vous d'avoir un fichier audio wav/mp3/etc.
# 3. Remplacez le chemin du fichier par votre propre fichier audio
# 4. Vérifiez que l'URL de l'API correspond à votre configuration
