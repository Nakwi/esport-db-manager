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
5.  **Bonus 1** : Insertion massive des données.
6.  **Bonus 2.1** : Génération d’un MLD pour une base orientée documents (MongoDB).
7.  **Bonus 2.2** : Migration des données de PostgreSQL vers MongoDB.

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
- Chaque équipe peut être dirigée par **un coach**, mais un coach n’est pas obligatoirement dans une équipe (*cardinalité 0,1 côté Coach et 1,1 côté Équipe*).  
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
  
  **Code qui gère la connexion**

```python
import psycopg2

# Configuration de la connexion PostgreSQL
DB_NAME = "esport_db"
DB_USER = "***"
DB_PASSWORD = "***"
DB_HOST = "localhost"

try:
    conn = psycopg2.connect(
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        host=DB_HOST
    )
    cur = conn.cursor()
    print("✅ Connexion réussie à PostgreSQL")
except Exception as e:
    print(f"❌ Erreur de connexion à PostgreSQL : {e}")

```
-  Gestion des requêtes SQL pour insérer et récupérer les données

  **Exemple code Insertion de données (ajout d’un joueur)**

```python
def ajouter_joueur(pseudonyme, id_role, id_equipe):
    try:
        cur.execute(
            "INSERT INTO joueur (pseudonyme, id_role, id_equipe) VALUES (%s, %s, %s)",
            (pseudonyme, id_role, id_equipe)
        )
        conn.commit()
        print(f"✅ Joueur {pseudonyme} ajouté avec succès !")
    except Exception as e:
        print(f"❌ Erreur lors de l'ajout du joueur : {e}")
```

---

L’ensemble du code source est disponible dans le **repository GitHub**.  


## 🌟 Bonus 1 : Insertion massive des données

Pour tester la scalabilité et la performance de la base de données, un script Python a été développé pour insérer 1 million de joueurs dans la table **joueur**.

**📌 Optimisation du processus d’insertion**
L’approche adoptée repose sur plusieurs techniques d’optimisation :

- **Insertion en batch :** Utilisation de copy_from() au lieu d’exécuter 1 million de requêtes INSERT, ce qui réduit le temps d’exécution.
- **Utilisation d’un buffer StringIO :** Stocke temporairement les données en mémoire avant envoi en base, limitant ainsi les I/O disque.
- **Génération dynamique des données :** Grâce à Faker, chaque joueur reçoit un pseudonyme réaliste et est affecté à un rôle et une équipe de manière aléatoire.
- **Résultat de l’insertion massive :**
  - 1 million de joueurs insérés en quelques minutes, validant la capacité de PostgreSQL à gérer des volumes importants de données de manière efficace.

[![Image](https://i.goopics.net/iur6d4.png)](https://goopics.net/i/iur6d4)

**Le script est directement disponible dans le dépot GitHub**

---

## 🌟 Bonus 2.1 : Génération d’un MLD pour une base orientée documents (MongoDB)
Dans le cadre de ce projet, une migration vers MongoDB a été étudiée en utilisant MongoDB Relational Migrator. Cette migration vise à adapter la structure de la base relationnelle en une base NoSQL document-oriented.

📌 Transformation du Modèle Logique de Données (MLD)
L'ancien schéma relationnel PostgreSQL contenait plusieurs tables distinctes (équipe, joueur, match, statistiques, etc.). Dans MongoDB, nous avons regroupé les données en deux collections principales :

✅ Collection equipe

- Contient toutes les informations sur une équipe
- Inclut directement ses joueurs
- Un coach est stocké dans le document de l'équipe

✅ Collection match

- Contient toutes les informations relatives à un match
- Inclut directement les statistiques des joueurs

**Collection equipe**

```sql
{
  "_id": ObjectId("..."),
  "nom": "T1",
  "historiqueVictoires": 120,
  "historiqueDefaites": 30,
  "joueurs": [
    {
      "pseudonyme": "Faker",
      "role": "Mid"
    },
    {
      "pseudonyme": "Zeus",
      "role": "Top"
    }
  ],
  "coach": {
    "nom": "Bengi",
    "experience": 10,
    "specialite": "Stratégie"
  }
}

```

**Collection match**

```sql
{
  "_id": ObjectId("..."),
  "date": "2024-02-02T18:00:00",
  "idEquipe1": "T1",
  "idEquipe2": "G2 Esports",
  "resultat": "Victoire de T1",
  "statistiques": [
    {
      "pseudonyme": "Faker",
      "kills": 10,
      "assists": 5,
      "deaths": 2
    },
    {
      "pseudonyme": "Caps",
      "kills": 8,
      "assists": 7,
      "deaths": 4
    }
  ]
}

```

[![Image](https://i.goopics.net/7io7p4.png)](https://goopics.net/i/7io7p4)


---

## 🌟 Bonus 2.2 : Migration des données de PostgreSQL vers MongoDB

L’exportation des données de PostgreSQL vers MongoDB a été réalisée à l'aide de **MongoDB Relational Migrator**, un outil officiel de MongoDB permettant de simplifier la conversion des bases relationnelles en bases NoSQL.

### 🔄 Processus de Migration

**Connexion à PostgreSQL**

Une connexion à la base de données PostgreSQL a été établie avec les informations suivante

[![Image](https://i.goopics.net/s7pacj.png)](https://goopics.net/i/s7pacj)

**Connexion à MongoDB**

Un serveur MongoDB a été déployé en local sur Docker, vérification de la connexion :

[![Image](https://i.goopics.net/20u02i.png)](https://goopics.net/i/20u02i)

**Lancement de la migration**

[![Image](https://i.goopics.net/ie6gq8.png)](https://goopics.net/i/ie6gq8)
[![Image](https://i.goopics.net/3juk9d.png)](https://goopics.net/i/3juk9d)

**Résultat de la migration**

Une fois la migration terminée, une vérification a été effectuée en listant les collections dans la base MongoDB :

[![Image](https://i.goopics.net/v2ujxw.png)](https://goopics.net/i/v2ujxw)

---

## 6️⃣ Outils utilisés  

🏗 **Lucidchart** – Modélisation du MCD  
*Utilisé pour concevoir le MCD et structurer les entités avant de passer au MLD.*  

🎨 **DBdiagram** – Génération du MLD et du SQL  
*Outil utilisé pour transformer le MCD en MLD et exporter automatiquement le script SQL.*  

🤖 **ChatGPT** – Apprentissage et accompagnement technique  
*Utilisé pour :*  
- Apprendre l’utilisation de PostgreSQL et comprendre ses bonnes pratiques.  
- Compléter l’intégration de Flask avec la base de données.
- Création du code pour faire insertion de 1Millions de joueurs avec Faker  

🍃 **MongoDB Compass & PyMongo** – Migration vers MongoDB  
*Utilisés pour :*  
- Convertir les données de PostgreSQL vers MongoDB.  
- Gérer et visualiser les collections de données dans MongoDB.  
- Automatiser l’insertion et la récupération des données avec PyMongo.  

---

## 🎯 Conclusion  
Ce projet m’a permis d’acquérir de nouvelles compétences en **modélisation de bases de données, PostgreSQL et Flask**, tout en développant une application fonctionnelle pour la gestion d’une ligue d’esport.  

📌 **Le code complet est disponible sur GitHub.** 🚀
