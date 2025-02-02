# 🏆 Documentation du projet - Gestion d’une ligue d’esport

---

## 1️⃣ Introduction  

Ce projet a pour objectif de concevoir une **base de données relationnelle** dédiée à la gestion d’une **ligue d’esport**. Il permettra d’assurer un suivi structuré des **équipes, matchs et joueurs**, tout en intégrant une **interface web développée avec Flask** pour simplifier l’interaction et la saisie des données.  

### 🎯 Objectifs et fonctionnalités  
Cette base de données centralisera et organisera les informations essentielles liées aux compétitions esportives. Elle offrira notamment :  
-  **La gestion des équipes** : suivi des joueurs, coachs et historique des performances.  
-  **La gestion des matchs** : enregistrement des équipes participantes, des scores et des résultats.  
-  **La gestion des joueurs** : stockage des pseudonymes, rôles (capitaine, remplaçant, etc.) et statistiques individuelles.  

### 🏗️ Structure du projet  
Le projet se déroulera en **quatre étapes principales** :  
1.  **Modélisation Conceptuelle des Données (MCD)** : définition des entités et de leurs relations.  
2.  **Modélisation Logique des Données (MLD)** : traduction du MCD en un modèle adapté aux bases relationnelles.  
3.  **Création de la base de données sous PostgreSQL** : implémentation du schéma et des relations.  
4.  **Intégration avec Flask** : développement d’une interface web pour interagir avec la base de données.  

---

## 2️⃣ Modélisation Conceptuelle des Données (MCD)  

### 🏗 Présentation du MCD  
La première étape de ce projet consiste à concevoir un **Modèle Conceptuel des Données (MCD)**, permettant d’organiser les informations et de définir les relations entre les différentes entités.  

📌 **L'image ci-dessous représente le MCD conçu pour cette base de données** :  

[![Image](https://i.goopics.net/sq2jym.png)](https://goopics.net/i/sq2jym)

### 🔍 Justification des choix de modélisation  

#### 📌 Gestion des équipes et des joueurs  
- Une **équipe** est identifiée par un **nom** et possède un **historique des victoires et défaites** afin de suivre ses performances.  
- Un **joueur** est caractérisé par un **pseudonyme** et est obligatoirement rattaché à **une seule équipe** (*cardinalité 1,1 côté joueur et 1,N côté équipe*).  
- Une relation *Appartient* entre **Joueur** et **Équipe** assure cette affiliation unique.  

#### 🎓 Gestion des coachs  
- Chaque équipe peut être dirigée par **un coach**, mais un coach n’est pas obligatoire (*cardinalité 0,1 côté Coach et 1,1 côté Équipe*).  
- Le coach est défini par son **nom**, son **expérience**, et sa **spécialité**.  

#### ⚔️ Gestion des matchs  
- Un **match** est identifié par un **ID, une date**, ainsi que les scores des deux équipes et le résultat.  
- Chaque match **oppose obligatoirement deux équipes** (*cardinalité 2,N côté Équipe et 1,N côté Match*).  

#### 📊 Gestion des statistiques des joueurs  
- Un joueur **peut participer à plusieurs matchs** et ses performances sont enregistrées individuellement pour chaque match via la table **Statistiques**.  
- La relation *Performe* entre **Joueur** et **Statistiques** possède une cardinalité de *(1,N)* côté Joueur et *(0,N)* côté Statistiques*.  
- Les statistiques incluent : **kills, assists, deaths** et sont reliées au **Joueur** et au **Match** correspondant.  

---

## 3️⃣ Modélisation Logique des Données (MLD)  

### 📌 Présentation du MLD  
Après la conception du **Modèle Conceptuel des Données (MCD)**, la prochaine étape consiste à traduire ce modèle en un **Modèle Logique des Données (MLD)**, adapté à un **système de gestion de bases de données relationnelles**.  

📌 **L'image ci-dessous représente le MLD généré** :  

[![Image](https://i.goopics.net/i47o7d.png)](https://goopics.net/i/i47o7d)

### ✅ Justification des choix de modélisation  
- Chaque entité du **MCD** a été transformée en une **table relationnelle** avec une clé primaire unique (*ID_*).  
- Les **clés étrangères** assurent les relations entre les différentes tables.  
- Des contraintes ont été ajoutées pour garantir la cohérence des données (ex: une équipe ne peut pas jouer contre elle-même).  
- Des **index** sont mis en place pour optimiser les requêtes SQL.  

---

## 4️⃣ Création de la base de données sous PostgreSQL  

### 🔍 Choix de la technologie  
PostgreSQL a été choisi afin d’acquérir de nouvelles compétences tout en utilisant une base de données robuste et performante.  
J’ai également utilisé **DBdiagram** pour générer le script SQL à partir du MLD.  

### 🏗️ Structure de la base de données  
- **Tables principales** : `equipe`, `joueur`, `match`, `coach`, `role`, `statistiques`.  
- **Relations et contraintes** :  
  -  Les **clés étrangères** assurent l’intégrité des données.  
  -  Des **CHECK constraints** évitent les valeurs négatives pour les scores et statistiques.  
  -  Des **index** accélèrent les requêtes fréquentes.  

**Exemple création table equipe :**
```sql
CREATE TABLE equipe (
  id_equipe SERIAL PRIMARY KEY,
  nom VARCHAR(255) NOT NULL,
  historique_victoires INTEGER DEFAULT 0 CHECK (historique_victoires >= 0),
  historique_defaites INTEGER DEFAULT 0 CHECK (historique_defaites >= 0),
  id_coach INTEGER,
  CONSTRAINT fk_coach FOREIGN KEY (id_coach) REFERENCES coach (id_coach) ON DELETE SET NULL
);
```
**Explication des contraintes dans cette table :**
- PRIMARY KEY (id_equipe) → Garantit un identifiant unique pour chaque équipe.
- NOT NULL sur nom → Empêche la création d’une équipe sans nom.
- CHECK (historique_victoires >= 0) → Empêche les valeurs négatives pour le nombre de victoires.
- CHECK (historique_defaites >= 0) → Assure que le nombre de défaites ne soit jamais négatif.
- FOREIGN KEY (id_coach) REFERENCES coach(id_coach) ON DELETE SET NULL → Si un coach est supprimé, son ID devient NULL dans l'équipe au lieu de supprimer l'équipe.

L’implémentation complète est disponible sur **GitHub**.  

---

## 5️⃣ Intégration avec Flask  

### 🎯 Objectif  
Flask a été utilisé pour développer une **interface web** permettant de gérer les équipes, joueurs et matchs plus facilement.  

[![Image](https://i.goopics.net/zyuknp.gif)](https://goopics.net/i/zyuknp)

### 🌐 Fonctionnalités mises en place  
-  **Afficher les joueurs d’une équipe**  
-  **Ajouter un joueur**  
-  **Créer un match avec génération aléatoire des scores**  
-  **Afficher l’historique des matchs**  
-  **Consulter les détails d’un match**  

### 🔗 Connexion avec PostgreSQL  
-  Connexion gérée via **psycopg2**  
-  Gestion des requêtes SQL pour insérer et récupérer les données  

L’ensemble du code source est disponible dans le **repository GitHub**.  

---

## 6️⃣ Outils utilisés  

### 🏗 Lucidchart – Modélisation du MCD  
Utilisé pour concevoir le **MCD** et structurer les entités avant de passer au MLD.  

### 🎨 DBdiagram – Génération du MLD et du SQL  
Outil utilisé pour transformer le **MCD** en **MLD** et exporter automatiquement le **script SQL**.  

### 🤖 ChatGPT – Apprentissage et accompagnement technique  
Utilisé pour :  
- Apprendre l’utilisation de **PostgreSQL** et comprendre ses bonnes pratiques.  
- Compléter l’**intégration de Flask** avec la base de données.  

---

## 🎯 Conclusion  
Ce projet m’a permis d’acquérir de nouvelles compétences en **modélisation de bases de données, PostgreSQL et Flask**, tout en développant une application fonctionnelle pour la gestion d’une ligue d’esport.  

📌 **Le code complet est disponible sur GitHub.** 🚀
