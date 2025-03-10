/* Creation de la base de donnees SPA */

create table employes (
    matricule serial PRIMARY KEY,
    nom varchar(25),
    prenom varchar(25),
    adresse text,
    num_tel varchar(14),
    date_naissance date,
    num_sec_social varchar(13),
    date_debut date,
    login_compte text,
    mdp text
);

create table refuges (
    id_refuge serial PRIMARY KEY,
    nom varchar(25),
    adresse text,
    num_tel varchar(14),
    capacite int,
    nb_anim int,
    gerant int,
    FOREIGN KEY (gerant) references employes(matricule),
    CONSTRAINT capaciteAnimaux CHECK (nb_anim <= capacite)
);

create table animal (
    id_animal serial PRIMARY KEY,
    espece varchar(25),
    nom varchar(25),
    age int,
    sexe varchar(1),
    signe_distinctif text,
    date_arrive date,
    image_animal text
);

create table soin(
    id_soin serial,
    matricule int,
    type_soin text,
    date_soin date,
    id_animal int,
    PRIMARY KEY (id_soin,matricule),
    FOREIGN KEY (matricule) references employes(matricule),
    FOREIGN KEY (id_animal) references animal(id_animal)
);

create table client(
    id_client serial PRIMARY KEY,
    nom varchar(25),
    prenom varchar(25),
    adresse text, 
    num_tel varchar(14)
);

create table adopte (
    id_client int, 
    id_animal int,
    date_adoption date,
    PRIMARY KEY (id_client,id_animal),
    FOREIGN KEY (id_animal) REFERENCES animal(id_animal),
    FOREIGN KEY (id_client) REFERENCES client(id_client) 
);

create table travaille (
    id_travail serial PRIMARY KEY,
    matricule int,
    id_refuge int,
    fonction text,
    FOREIGN KEY (matricule) REFERENCES employes(matricule),
    FOREIGN KEY (id_refuge) REFERENCES refuges(id_refuge)
);

create table fouriere (
    id_fouriere serial PRIMARY KEY, 
    id_animal int,
    id_refuge int,
    nom varchar(25),
    FOREIGN KEY (id_animal) REFERENCES animal(id_animal),
    FOREIGN KEY (id_refuge) REFERENCES refuges(id_refuge)
);

create table transfere (
    id_transfere serial PRIMARY KEY,
    id_refuge1 int,
    id_refuge2 int,
    date_depart date, 
    date_arrive date,
    id_animal int,
    FOREIGN KEY (id_animal) REFERENCES animal(id_animal),
    FOREIGN KEY (id_refuge1) REFERENCES refuges(id_refuge),
    FOREIGN KEY (id_refuge2) REFERENCES refuges(id_refuge),
    CONSTRAINT transfere_pas_meme_refuge CHECK (id_refuge1 <> id_refuge2)
);

create view vaccins_a_faire as (
    with vaccins_possible as (
        select type_soin from soin
        where type_soin like '%Vaccin%'
    )
    select id_animal,type_soin from animal,vaccins_possible
    except
    select id_animal,type_soin from soin where type_soin like '%Vaccin%'
);

create view nombre_transfere as (
    select id_refuge1,count(id_transfere) from transfere
    group by id_refuge1
    order by count(id_transfere) desc
    limit(5)
);

create view refuge_animal as(
    select id_refuge,id_animal from fouriere where id_animal not in (
        select distinct id_animal from transfere 
    )
    union
    select distinct id_refuge2 as id_refuge,id_animal from transfere as t1 where t1.date_arrive = (select t2.date_arrive from transfere as t2 where t1.id_animal = t2.id_animal order by date_arrive desc limit(1))
);

/* insertions des donnees dans animal*/

INSERT INTO animal(espece,nom,age,sexe,signe_distinctif,date_arrive,image_animal) VALUES ('teckel', 'eliot', 12, 'F', 'taches noire', '2001-09-11', 'image1.jpeg');
INSERT INTO animal(espece,nom,age,sexe,signe_distinctif,date_arrive,image_animal) VALUES ('golden retriver', 'volt', 3, 'M', 'queue coupée', '2011-05-02', 'image2.jpeg');
INSERT INTO animal(espece,nom,age,sexe,signe_distinctif,date_arrive,image_animal) VALUES ('bulldog', 'rex', 4, 'F', 'yeux vairons', '2007-04-07', 'image3.jpeg');
INSERT INTO animal(espece,nom,age,sexe,signe_distinctif,date_arrive,image_animal) VALUES ('bichon maltais', 'princesse', 13, 'F', 'sourd', '2022-09-02', 'image4.jpeg');
INSERT INTO animal(espece,nom,age,sexe,signe_distinctif,date_arrive,image_animal) VALUES ('husky', 'médor', 8, 'F', 'aucun', '2022-10-25', 'image5.jpeg');
INSERT INTO animal(espece,nom,age,sexe,signe_distinctif,date_arrive,image_animal) VALUES ('dalmatien', '101', 5, 'M', 'taches blanche', '2001-09-11', 'image6.jpeg');
INSERT INTO animal(espece,nom,age,sexe,signe_distinctif,date_arrive,image_animal) VALUES ('maine coon', 'Ulk', 11, 'F', 'tigré', '2011-05-02', 'image7.jpeg');
INSERT INTO animal(espece,nom,age,sexe,signe_distinctif,date_arrive,image_animal) VALUES ('bengal', 'Arif', 7, 'M', 'aveugle', '2007-04-07', 'image8.jpeg');
INSERT INTO animal(espece,nom,age,sexe,signe_distinctif,date_arrive,image_animal) VALUES ('bleu russe', 'Poutpout', 14, 'F', 'yeux vairons', '2022-09-02', 'image9.jpeg');
INSERT INTO animal(espece,nom,age,sexe,signe_distinctif,date_arrive,image_animal) VALUES ('somali', 'Aled', 2, 'F', 'aucun', '2022-10-25', 'image10.jpeg');

/* insertions des donnees dans employes*/

INSERT INTO employes(nom,prenom,adresse,num_tel,date_naissance,num_sec_social,date_debut,login_compte,mdp) VALUES ('A', 'Rachid', '15 Avenue du Chomedu', '01 23 45 67 89', '2005-03-08', '0634567891011', '2014-02-22', 'ARachidE', 'CaCahuete123');
INSERT INTO employes(nom,prenom,adresse,num_tel,date_naissance,num_sec_social,date_debut,login_compte,mdp) VALUES ('Ntelombila', 'Baltazar', '7 Rue de Lisbonne', '06 78 91 23 45', '1997-05-29', '0701987654321', '2000-11-11', 'BalTelo', '123456789');
INSERT INTO employes(nom,prenom,adresse,num_tel,date_naissance,num_sec_social,date_debut,login_compte,mdp) VALUES ('Houba', 'Marsupilami', '2bis Passage Ruelle', '01 23 45 67 89', '1982-07-16', '0701112131415', '2023-12-12', 'Houba-Houba', 'Houba');
INSERT INTO employes(nom,prenom,adresse,num_tel,date_naissance,num_sec_social,date_debut,login_compte,mdp) VALUES ('Verräter', 'Caïn', '11 Rue Jean Mace', '09 87 65 43 21', '2001-10-16', '079296937989', '2012-02-12', 'Fils_de_Adam', 'Tra1tre');
INSERT INTO employes(nom,prenom,adresse,num_tel,date_naissance,num_sec_social,date_debut,login_compte,mdp) VALUES ('Opfer', 'Abel', '51 Rue de Rivoli', '05 46 73 82 19', '2005-03-08', '0701119141416', '2012-12-31', 'Fils_De_Eve', 'V1ct1m3');
INSERT INTO employes(nom,prenom,adresse,num_tel,date_naissance,num_sec_social,date_debut,login_compte,mdp) VALUES ('Cho', 'Tylan', '235 Rue Saint-Charles', '06 78 91 23 55', '2004-05-12', '0701112678413', '2014-04-22', 'Cho_co', 'LKFDFDD');
INSERT INTO employes(nom,prenom,adresse,num_tel,date_naissance,num_sec_social,date_debut,login_compte,mdp) VALUES ('Tho', 'Dylan', '46 Rue de Rome', '06 78 12 23 65', '2000-06-11', '0701987654567', '2011-12-11', 'Tho.hou', '12DE45F');
INSERT INTO employes(nom,prenom,adresse,num_tel,date_naissance,num_sec_social,date_debut,login_compte,mdp) VALUES ('Lob', 'Arthure', '21 Rue de la Gaite', '06 78 12 45 45', '2002-03-12', '079296937345', '2020-03-23', 'Lob_04', 'ref45e');
INSERT INTO employes(nom,prenom,adresse,num_tel,date_naissance,num_sec_social,date_debut,login_compte,mdp) VALUES ('Vader', 'Joza', '14 Rue des Taillandiers', '06 78 98 09 67', '2005-01-23', '0745619141416', '2019-12-12', 'Vader_dark', 'trre32l');
INSERT INTO employes(nom,prenom,adresse,num_tel,date_naissance,num_sec_social,date_debut,login_compte,mdp) VALUES ('Malo', 'Lori', '21 Bd. Edgar Quinet', '07 45 66 99 87', '2005-01-01', '0701112678567', '2003-11-03', 'Malo.saint', 'jdnf56');

/* insertions des donnees dans refuges*/

INSERT INTO refuges(nom,adresse,num_tel,capacite,nb_anim,gerant) VALUES ('Le refuge', '285 Rue Fulton', '04 22 52 10 10', 5, 2, 3);
INSERT INTO refuges(nom,adresse,num_tel,capacite,nb_anim,gerant) VALUES ('Le nouveau départ', '21 Rue Stalingrad', '01 45 39 40 00', 12, 9, 2);
INSERT INTO refuges(nom,adresse,num_tel,capacite,nb_anim,gerant) VALUES ('La SPA du Poitou', '69 Avenue De Fort-Boyard', '09 72 39 40 50', 100, 69, 4);
INSERT INTO refuges(nom,adresse,num_tel,capacite,nb_anim,gerant) VALUES ('Venez les chercher', '34 Chemin de Traverse', '08 90 88 89 89', 2, 1, 1);
INSERT INTO refuges(nom,adresse,num_tel,capacite,nb_anim,gerant) VALUES ('Lost And Found', '221 bis Rue du Boulanger', '06 21 64 74 20', 50, 25, 5);
INSERT INTO refuges(nom,adresse,num_tel,capacite,nb_anim,gerant) VALUES ('spa 1', '1 Rue du Chateau d''Eau', '01 43 71 78 18', 48, 45, 6);
INSERT INTO refuges(nom,adresse,num_tel,capacite,nb_anim,gerant) VALUES ('spa 2', '12 Rue des Petits Carreau', '01 56 81 76 00', 56, 50, 7);
INSERT INTO refuges(nom,adresse,num_tel,capacite,nb_anim,gerant) VALUES ('spa 4', '20 Rue de la Verrerie', '01 42 28 11 00', 34, 20, 8);
INSERT INTO refuges(nom,adresse,num_tel,capacite,nb_anim,gerant) VALUES ('spa 3', '35 Rue du Mont Thabor', '01 40 09 70 30', 23, 18, 9);
INSERT INTO refuges(nom,adresse,num_tel,capacite,nb_anim,gerant) VALUES ('spa 5', '56 Rue de Bagnolet', '01 43 26 50 04', 78, 60, 10);

/* insertions des donnees dans soin*/

INSERT INTO soin(matricule,type_soin,date_soin,id_animal) VALUES (4, 'Vaccin contre la rage', '2001-09-12', 1);
INSERT INTO soin(matricule,type_soin,date_soin,id_animal) VALUES (4, 'Vaccin contre la rage', '2007-04-08', 3);
INSERT INTO soin(matricule,type_soin,date_soin,id_animal) VALUES (5, 'Patte sous attele', '2005-05-05', 1);
INSERT INTO soin(matricule,type_soin,date_soin,id_animal) VALUES (3, 'Checkup', '2010-01-02', 3);
INSERT INTO soin(matricule,type_soin,date_soin,id_animal) VALUES (3, 'Prise de sang', '2023-10-17', 5);
INSERT INTO soin(matricule,type_soin,date_soin,id_animal) VALUES (4, 'Vaccin contre la rage', '2001-12-12', 1);
INSERT INTO soin(matricule,type_soin,date_soin,id_animal) VALUES (4, 'Vaccin contre la rage', '2007-07-08', 3);
INSERT INTO soin(matricule,type_soin,date_soin,id_animal) VALUES (5, 'Patte sous attele', '2005-08-05', 1);
INSERT INTO soin(matricule,type_soin,date_soin,id_animal) VALUES (3, 'Checkup', '2010-04-02', 3);
INSERT INTO soin(matricule,type_soin,date_soin,id_animal) VALUES (3, 'Prise de sang', '2023-12-17', 5);

/* insertions des donnees dans client*/

INSERT INTO client(nom,prenom,adresse,num_tel) VALUES ('Dupont', 'Edouar', '123 rue Saint-Lazard', '01 23 44 67 89');
INSERT INTO client(nom,prenom,adresse,num_tel) VALUES ('Cho', 'Chris', '321 rue Saint-Germain', '06 78 92 23 45');
INSERT INTO client(nom,prenom,adresse,num_tel) VALUES ('Cat', 'Catie', '456 This Street', '01 23 46 67 89');
INSERT INTO client(nom,prenom,adresse,num_tel) VALUES ('Ego', 'Ethan', '654 Bd. Saint-Goerge', '09 87 65 44 21');
INSERT INTO client(nom,prenom,adresse,num_tel) VALUES ('Tho', 'Corentin', '789 Avenue de la Lune', '05 46 72 82 19');
INSERT INTO client(nom,prenom,adresse,num_tel) VALUES ('Travis', 'Vic', '39 Rue du Montparnasse', '05 46 75 62 59');
INSERT INTO client(nom,prenom,adresse,num_tel) VALUES ('Plat', 'Victor', '76 Rue de Picpus', '09 98 12 44 21');
INSERT INTO client(nom,prenom,adresse,num_tel) VALUES ('Alonzo', 'Lori', '18 Rue Paul Bert', '06 09 92 34 45');
INSERT INTO client(nom,prenom,adresse,num_tel) VALUES ('Vettel', 'Eto', '77 Rue du Cherche-Midi', '09 07 61 74 21');
INSERT INTO client(nom,prenom,adresse,num_tel) VALUES ('Verstappen', 'Pol', '13 Rue Quentin-Bauchart', '09 87 54 99 67');

/* insertions des donnees dans adopte*/

INSERT INTO adopte(id_client,id_animal,date_adoption) VALUES (1, 1, '2023-11-01');
INSERT INTO adopte(id_client,id_animal,date_adoption) VALUES (2, 2, '2023-11-02');
INSERT INTO adopte(id_client,id_animal,date_adoption) VALUES (3, 3, '2023-11-04');
INSERT INTO adopte(id_client,id_animal,date_adoption) VALUES (4, 4, '2023-11-05');
INSERT INTO adopte(id_client,id_animal,date_adoption) VALUES (1, 5, '2023-11-10');
INSERT INTO adopte(id_client,id_animal,date_adoption) VALUES (1, 6, '2023-11-06');
INSERT INTO adopte(id_client,id_animal,date_adoption) VALUES (2, 7, '2023-11-07');
INSERT INTO adopte(id_client,id_animal,date_adoption) VALUES (3, 8, '2023-11-08');
INSERT INTO adopte(id_client,id_animal,date_adoption) VALUES (4, 9, '2023-11-09');
INSERT INTO adopte(id_client,id_animal,date_adoption) VALUES (1, 10, '2023-11-03');

/* insertions des donnees dans travaille*/

INSERT INTO travaille(matricule,id_refuge,fonction) VALUES (1, 1, 'Concierge');
INSERT INTO travaille(matricule,id_refuge,fonction) VALUES (2, 2, 'Accompagnateur pour animaux');
INSERT INTO travaille(matricule,id_refuge,fonction) VALUES (1, 4, 'Agent d''accueil');
INSERT INTO travaille(matricule,id_refuge,fonction) VALUES (1, 5, 'Comptable');
INSERT INTO travaille(matricule,id_refuge,fonction) VALUES (4, 3, 'Concierge');
INSERT INTO travaille(matricule,id_refuge,fonction) VALUES (3, 3, 'Surveillant');
INSERT INTO travaille(matricule,id_refuge,fonction) VALUES (5, 5, 'Vigile');
INSERT INTO travaille(matricule,id_refuge,fonction) VALUES (6, 6, 'Agent d''acceuil');
INSERT INTO travaille(matricule,id_refuge,fonction) VALUES (3, 1, 'Agent d''acceuil');
INSERT INTO travaille(matricule,id_refuge,fonction) VALUES (7, 4, 'Accompagnateur pour animaux');

/* insertions des donnees dans fouriere*/

INSERT INTO fouriere(id_animal,id_refuge,nom) VALUES (1, 1, 'Animaux Retrouvés');
INSERT INTO fouriere(id_animal,id_refuge,nom) VALUES (2, 2, 'Lost And Found');
INSERT INTO fouriere(id_animal,id_refuge,nom) VALUES (3, 1, 'Finders Keepers');
INSERT INTO fouriere(id_animal,id_refuge,nom) VALUES (4, 4, 'Premiers arrivés');
INSERT INTO fouriere(id_animal,id_refuge,nom) VALUES (5, 4, 'Premiers servis');
INSERT INTO fouriere(id_animal,id_refuge,nom) VALUES (6, 5, 'A');
INSERT INTO fouriere(id_animal,id_refuge,nom) VALUES (7, 6, 'B');
INSERT INTO fouriere(id_animal,id_refuge,nom) VALUES (8, 8, 'C');
INSERT INTO fouriere(id_animal,id_refuge,nom) VALUES (9, 9, 'D');
INSERT INTO fouriere(id_animal,id_refuge,nom) VALUES (10, 10, 'E');

/* insertions des donnees dans transfere*/

INSERT INTO transfere(id_refuge1,id_refuge2,date_depart,date_arrive,id_animal) VALUES (1, 2, '2023-10-29', '2023-10-30', 1);
INSERT INTO transfere(id_refuge1,id_refuge2,date_depart,date_arrive,id_animal) VALUES (2, 1, '2023-10-30', '2023-11-01', 2);
INSERT INTO transfere(id_refuge1,id_refuge2,date_depart,date_arrive,id_animal) VALUES (1, 4, '2023-11-01', '2023-11-02', 3);
INSERT INTO transfere(id_refuge1,id_refuge2,date_depart,date_arrive,id_animal) VALUES (4, 3, '2023-11-02', '2023-11-03', 4);
INSERT INTO transfere(id_refuge1,id_refuge2,date_depart,date_arrive,id_animal) VALUES (4, 5, '2023-11-04', '2023-11-05', 5);
INSERT INTO transfere(id_refuge1,id_refuge2,date_depart,date_arrive,id_animal) VALUES (5, 6, '2023-11-05', '2023-11-06', 6);
INSERT INTO transfere(id_refuge1,id_refuge2,date_depart,date_arrive,id_animal) VALUES (6, 7, '2023-11-06', '2023-11-07', 7);
INSERT INTO transfere(id_refuge1,id_refuge2,date_depart,date_arrive,id_animal) VALUES (7, 8, '2023-11-07', '2023-11-08', 8);
INSERT INTO transfere(id_refuge1,id_refuge2,date_depart,date_arrive,id_animal) VALUES (9, 10, '2023-11-08', '2023-11-09', 9);
INSERT INTO transfere(id_refuge1,id_refuge2,date_depart,date_arrive,id_animal) VALUES (10, 4, '2023-11-09', '2023-11-10', 10);

