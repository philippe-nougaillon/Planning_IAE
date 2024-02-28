# Outil Business School Planning
*Application web de planification de cours. Collaborative, flexible et simple d'utilisation*

## Détail des fonctionnalités

### Gestion des Cours
- Chaque cours est associé à une Formation, un ou deux Intervenants, une Salle et un Etat (Planifié, Confirmé, Reporté, Annulé, Réalisé) 
- Affichage des cours sous forme de Liste, de Calendrier (semaine/mois) ou Etat d'Occupation des salles
- Affichage d'alerte si dépassement de capacité de la salle 
- Impossibilité de saisir un nouveau cours ayant lieu un dimanche ou un jour de fermeture de l'établissement
- Pas de chevauchement horaire pour un même intervenant. Il est pas possible de saisir un nouveau cours si le formateur intervient déjà sur un autre cours aux même heures
- Recheche multi-critères (Filtre sur Date, Formation, Intervenant, Etat, Cours passés ou futurs)
- Manipulation d'un groupe de cours (Changement d'Etat, changement de Salle, Export...) 
- Export des cours vers Excel (au format CSV) / Outlook, Google Agenda, etc... (au format iCal)

### Gestion des Formations
- Chaque formation est associée à un code couleur pour un répérage rapide dans le planning
- Gestion des UE (une liste d'UE est associée à chaque formation, avec indication du nombre d'heures)

### Gestion des Etudiants
- Chaque étudiant est associé à une formation

### Gestion des Intervenants
- Profil des intervenants avec photo, status, formations dispensées (affichage dynamique basé sur les cours enregistrés, avec le nombre d'heures planifiées et la date du premier cours)  

### Gestion des Salles
- Gestion de la capacité (alerte si dépassement)
- Visualisation des créneaux horaires libres/occupés pour une date, une salle

### Gestion des Utilisateurs
- Le profil 'admin' permet d'administrer les cours (suppression) et les utilisateurs

### Historique des modifications
- Chaque modification apportée aux données est enregistrée dans un journal, avec la date, l'utilisateur, la table, le champs et la valeur avant/après modification 

### Affichage sur panneaux lumineux et smartphones
- Le planning peut être visualisé sur différents supports (Responsive Design)
- [Planning du jour optimisé pour les grands écrans]

### Notification
- Les chargés de scolarité et les étudiants peuvent recevoir une notification par email/SMS(à venir) lors de l'annulation de cours

### Importation des données
- Les cours, formations, intervenants, étudiants et les utilisateurs peuvent être importés en masse à partir de fichiers CSV issues de tableaux Excel.

### Export des données
- Toutes les données sont exportables au format CSV

### RH
- Etat récapitulatif mensuel des cours effectués

### API
- une API fournit les données du planning au format JSON aux applications tierces/mobiles

### TODO

||
|-|
| - Notification d'annulation de cours par SMS à chaque étudiant |
| - Notification de cours en e-learning (envoi du lien à tous les étudiants de la formation) |

