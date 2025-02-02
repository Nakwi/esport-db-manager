from flask import Flask, render_template, request, redirect, url_for
import psycopg2
import random

app = Flask(__name__)

# 🔹 Connexion à PostgreSQL
DB_NAME = "***"
DB_USER = "***"
DB_PASSWORD = "***"
DB_HOST = "***"

conn = psycopg2.connect(
    dbname=DB_NAME,
    user=DB_USER,
    password=DB_PASSWORD,
    host=DB_HOST
)
cur = conn.cursor()

@app.route('/', methods=['GET', 'POST'])
def index():
    joueurs_equipe = []

    # 🔹 Voir les joueurs d'une équipe sélectionnée
    if request.method == 'POST' and 'equipe_selected' in request.form:
        id_equipe_selected = request.form['equipe_selected']
        cur.execute("SELECT pseudonyme FROM joueur WHERE id_equipe = %s", (id_equipe_selected,))
        joueurs_equipe = cur.fetchall()

    # 🔹 Ajouter un joueur
    if request.method == 'POST' and 'pseudonyme' in request.form:
        pseudonyme = request.form['pseudonyme']
        id_role = request.form['id_role']
        id_equipe = request.form['id_equipe']
        cur.execute(
            "INSERT INTO joueur (pseudonyme, id_role, id_equipe) VALUES (%s, %s, %s)",
            (pseudonyme, id_role, id_equipe)
        )
        conn.commit()

    # 🔹 Lancer un match
    if request.method == 'POST' and 'id_equipe1' in request.form:
        id_equipe1 = request.form['id_equipe1']
        id_equipe2 = request.form['id_equipe2']
        
        if id_equipe1 == id_equipe2:
            return "Erreur : Une équipe ne peut pas jouer contre elle-même."

        # Générer des scores aléatoires
        score_equipe1, score_equipe2 = random.randint(0, 30), random.randint(0, 30)

        # 🔹 Récupérer les noms des équipes
        cur.execute("SELECT nom FROM equipe WHERE id_equipe = %s", (id_equipe1,))
        nom_equipe1 = cur.fetchone()[0]

        cur.execute("SELECT nom FROM equipe WHERE id_equipe = %s", (id_equipe2,))
        nom_equipe2 = cur.fetchone()[0]

        # 🔹 Déterminer le vainqueur avec le nom
        if score_equipe1 > score_equipe2:
            resultat = f"Victoire de {nom_equipe1}"
        elif score_equipe2 > score_equipe1:
            resultat = f"Victoire de {nom_equipe2}"
        else:
            resultat = "Match nul"

        cur.execute(
            "INSERT INTO match (score_equipe1, score_equipe2, resultat, id_equipe1, id_equipe2) VALUES (%s, %s, %s, %s, %s)",
            (score_equipe1, score_equipe2, resultat, id_equipe1, id_equipe2)
        )
        conn.commit()

    # 🔹 Récupérer les données
    cur.execute("SELECT * FROM joueur")
    joueurs = cur.fetchall()

    cur.execute("SELECT * FROM role")
    roles = cur.fetchall()

    cur.execute("SELECT * FROM equipe")
    equipes = cur.fetchall()

    # 🔹 Récupérer l'historique des matchs avec les noms des équipes
    cur.execute("""
        SELECT m.id_match, e1.nom AS equipe1, e2.nom AS equipe2, 
               m.score_equipe1, m.score_equipe2, m.resultat
        FROM match m
        JOIN equipe e1 ON m.id_equipe1 = e1.id_equipe
        JOIN equipe e2 ON m.id_equipe2 = e2.id_equipe
        ORDER BY m.id_match DESC
    """)
    matchs = cur.fetchall()

    return render_template('index.html', joueurs=joueurs, roles=roles, equipes=equipes, matchs=matchs, joueurs_equipe=joueurs_equipe)

@app.route('/match/<int:id_match>')
def details_match(id_match):
    cur.execute("""
        SELECT m.id_match, e1.nom AS equipe1, e2.nom AS equipe2, 
               m.score_equipe1, m.score_equipe2, m.resultat
        FROM match m
        JOIN equipe e1 ON m.id_equipe1 = e1.id_equipe
        JOIN equipe e2 ON m.id_equipe2 = e2.id_equipe
        WHERE m.id_match = %s
    """, (id_match,))
    match = cur.fetchone()

    return render_template('match_details.html', match=match)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
