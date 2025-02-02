CREATE TABLE coach (
  id_coach SERIAL PRIMARY KEY,
  nom VARCHAR(255) NOT NULL UNIQUE,
  experience INTEGER CHECK (experience >= 0),
  specialite VARCHAR(255)
);

CREATE TABLE equipe (
  id_equipe SERIAL PRIMARY KEY,
  nom VARCHAR(255) NOT NULL UNIQUE,
  historique_victoires INTEGER DEFAULT 0 CHECK (historique_victoires >= 0),
  historique_defaites INTEGER DEFAULT 0 CHECK (historique_defaites >= 0),
  id_coach INTEGER,
  CONSTRAINT fk_coach FOREIGN KEY (id_coach) REFERENCES coach (id_coach) ON DELETE SET NULL
);

CREATE INDEX idx_equipe_coach ON equipe(id_coach);

CREATE TABLE role (
  id_role SERIAL PRIMARY KEY,
  nom_role VARCHAR(255) NOT NULL UNIQUE,
  description TEXT
);

CREATE TABLE joueur (
  id_joueur SERIAL PRIMARY KEY,
  pseudonyme VARCHAR(255) NOT NULL UNIQUE,
  id_role INTEGER NOT NULL,
  id_equipe INTEGER NOT NULL,
  CONSTRAINT fk_role FOREIGN KEY (id_role) REFERENCES role (id_role) ON DELETE CASCADE,
  CONSTRAINT fk_equipe FOREIGN KEY (id_equipe) REFERENCES equipe (id_equipe) ON DELETE CASCADE
);

CREATE INDEX idx_joueur_role ON joueur(id_role);
CREATE INDEX idx_joueur_equipe ON joueur(id_equipe);

CREATE TABLE match (
  id_match SERIAL PRIMARY KEY,
  date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  score_equipe1 INTEGER CHECK (score_equipe1 >= 0),
  score_equipe2 INTEGER CHECK (score_equipe2 >= 0),
  resultat VARCHAR(50),
  id_equipe1 INTEGER NOT NULL,
  id_equipe2 INTEGER NOT NULL,
  CONSTRAINT fk_match_equipe1 FOREIGN KEY (id_equipe1) REFERENCES equipe (id_equipe) ON DELETE CASCADE,
  CONSTRAINT fk_match_equipe2 FOREIGN KEY (id_equipe2) REFERENCES equipe (id_equipe) ON DELETE CASCADE,
  CONSTRAINT check_different_teams CHECK (id_equipe1 <> id_equipe2)
);

CREATE INDEX idx_match_equipe1 ON match(id_equipe1);
CREATE INDEX idx_match_equipe2 ON match(id_equipe2);

CREATE TABLE statistiques (
  id_statistique SERIAL PRIMARY KEY,
  kills INTEGER CHECK (kills >= 0),
  assists INTEGER CHECK (assists >= 0),
  deaths INTEGER CHECK (deaths >= 0),
  id_joueur INTEGER NOT NULL,
  id_match INTEGER NOT NULL,
  CONSTRAINT fk_stat_joueur FOREIGN KEY (id_joueur) REFERENCES joueur (id_joueur) ON DELETE CASCADE,
  CONSTRAINT fk_stat_match FOREIGN KEY (id_match) REFERENCES match (id_match) ON DELETE CASCADE
);

CREATE INDEX idx_stat_joueur ON statistiques(id_joueur);
CREATE INDEX idx_stat_match ON statistiques(id_match);

-- 🔹 NOUVELLE TABLE pour suivre quels joueurs ont joué dans un match
CREATE TABLE joueur_match (
  id_joueur INTEGER NOT NULL,
  id_match INTEGER NOT NULL,
  kills INTEGER DEFAULT 0 CHECK (kills >= 0),
  assists INTEGER DEFAULT 0 CHECK (assists >= 0),
  deaths INTEGER DEFAULT 0 CHECK (deaths >= 0),
  PRIMARY KEY (id_joueur, id_match),
  CONSTRAINT fk_joueur_match FOREIGN KEY (id_joueur) REFERENCES joueur (id_joueur) ON DELETE CASCADE,
  CONSTRAINT fk_match_joueur FOREIGN KEY (id_match) REFERENCES match (id_match) ON DELETE CASCADE
);

CREATE INDEX idx_joueur_match_joueur ON joueur_match(id_joueur);
CREATE INDEX idx_joueur_match_match ON joueur_match(id_match);
