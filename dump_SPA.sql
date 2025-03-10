--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.19
-- Dumped by pg_dump version 9.6.24

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: adopte; Type: TABLE; Schema: public; Owner: loic.bergeot
--

CREATE TABLE public.adopte (
    id_client integer NOT NULL,
    id_animal integer NOT NULL,
    date_adoption date
);


ALTER TABLE public.adopte OWNER TO "loic.bergeot";

--
-- Name: animal; Type: TABLE; Schema: public; Owner: loic.bergeot
--

CREATE TABLE public.animal (
    id_animal integer NOT NULL,
    espece character varying(25),
    nom character varying(25),
    age integer,
    sexe character varying(1),
    signe_distinctif text,
    date_arrive date,
    image_animal text
);


ALTER TABLE public.animal OWNER TO "loic.bergeot";

--
-- Name: animal_id_animal_seq; Type: SEQUENCE; Schema: public; Owner: loic.bergeot
--

CREATE SEQUENCE public.animal_id_animal_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.animal_id_animal_seq OWNER TO "loic.bergeot";

--
-- Name: animal_id_animal_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: loic.bergeot
--

ALTER SEQUENCE public.animal_id_animal_seq OWNED BY public.animal.id_animal;


--
-- Name: client; Type: TABLE; Schema: public; Owner: loic.bergeot
--

CREATE TABLE public.client (
    id_client integer NOT NULL,
    nom character varying(25),
    prenom character varying(25),
    adresse text,
    num_tel character varying(14)
);


ALTER TABLE public.client OWNER TO "loic.bergeot";

--
-- Name: client_id_client_seq; Type: SEQUENCE; Schema: public; Owner: loic.bergeot
--

CREATE SEQUENCE public.client_id_client_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.client_id_client_seq OWNER TO "loic.bergeot";

--
-- Name: client_id_client_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: loic.bergeot
--

ALTER SEQUENCE public.client_id_client_seq OWNED BY public.client.id_client;


--
-- Name: employes; Type: TABLE; Schema: public; Owner: loic.bergeot
--

CREATE TABLE public.employes (
    matricule integer NOT NULL,
    nom character varying(25),
    prenom character varying(25),
    adresse text,
    num_tel character varying(14),
    date_naissance date,
    num_sec_social character varying(13),
    date_debut date,
    login_compte text,
    mdp text
);


ALTER TABLE public.employes OWNER TO "loic.bergeot";

--
-- Name: employes_matricule_seq; Type: SEQUENCE; Schema: public; Owner: loic.bergeot
--

CREATE SEQUENCE public.employes_matricule_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employes_matricule_seq OWNER TO "loic.bergeot";

--
-- Name: employes_matricule_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: loic.bergeot
--

ALTER SEQUENCE public.employes_matricule_seq OWNED BY public.employes.matricule;


--
-- Name: fouriere; Type: TABLE; Schema: public; Owner: loic.bergeot
--

CREATE TABLE public.fouriere (
    id_fouriere integer NOT NULL,
    id_animal integer,
    id_refuge integer,
    nom character varying(25)
);


ALTER TABLE public.fouriere OWNER TO "loic.bergeot";

--
-- Name: fouriere_id_fouriere_seq; Type: SEQUENCE; Schema: public; Owner: loic.bergeot
--

CREATE SEQUENCE public.fouriere_id_fouriere_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fouriere_id_fouriere_seq OWNER TO "loic.bergeot";

--
-- Name: fouriere_id_fouriere_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: loic.bergeot
--

ALTER SEQUENCE public.fouriere_id_fouriere_seq OWNED BY public.fouriere.id_fouriere;


--
-- Name: transfere; Type: TABLE; Schema: public; Owner: loic.bergeot
--

CREATE TABLE public.transfere (
    id_transfere integer NOT NULL,
    id_refuge1 integer,
    id_refuge2 integer,
    date_depart date,
    date_arrive date,
    id_animal integer,
    CONSTRAINT transfere_pas_meme_refuge CHECK ((id_refuge1 <> id_refuge2))
);


ALTER TABLE public.transfere OWNER TO "loic.bergeot";

--
-- Name: nombre_transfere; Type: VIEW; Schema: public; Owner: loic.bergeot
--

CREATE VIEW public.nombre_transfere AS
 SELECT transfere.id_refuge1,
    count(transfere.id_transfere) AS count
   FROM public.transfere
  GROUP BY transfere.id_refuge1
  ORDER BY (count(transfere.id_transfere)) DESC
 LIMIT 5;


ALTER TABLE public.nombre_transfere OWNER TO "loic.bergeot";

--
-- Name: refuge_animal; Type: VIEW; Schema: public; Owner: loic.bergeot
--

CREATE VIEW public.refuge_animal AS
 SELECT fouriere.id_refuge,
    fouriere.id_animal
   FROM public.fouriere
  WHERE (NOT (fouriere.id_animal IN ( SELECT DISTINCT transfere.id_animal
           FROM public.transfere)))
UNION
 SELECT DISTINCT t1.id_refuge2 AS id_refuge,
    t1.id_animal
   FROM public.transfere t1
  WHERE (t1.date_arrive = ( SELECT t2.date_arrive
           FROM public.transfere t2
          WHERE (t1.id_animal = t2.id_animal)
          ORDER BY t2.date_arrive DESC
         LIMIT 1));


ALTER TABLE public.refuge_animal OWNER TO "loic.bergeot";

--
-- Name: refuges; Type: TABLE; Schema: public; Owner: loic.bergeot
--

CREATE TABLE public.refuges (
    id_refuge integer NOT NULL,
    nom character varying(25),
    adresse text,
    num_tel character varying(14),
    capacite integer,
    nb_anim integer,
    gerant integer,
    CONSTRAINT capaciteanimaux CHECK ((nb_anim <= capacite))
);


ALTER TABLE public.refuges OWNER TO "loic.bergeot";

--
-- Name: refuges_id_refuge_seq; Type: SEQUENCE; Schema: public; Owner: loic.bergeot
--

CREATE SEQUENCE public.refuges_id_refuge_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.refuges_id_refuge_seq OWNER TO "loic.bergeot";

--
-- Name: refuges_id_refuge_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: loic.bergeot
--

ALTER SEQUENCE public.refuges_id_refuge_seq OWNED BY public.refuges.id_refuge;


--
-- Name: soin; Type: TABLE; Schema: public; Owner: loic.bergeot
--

CREATE TABLE public.soin (
    id_soin integer NOT NULL,
    matricule integer NOT NULL,
    type_soin text,
    date_soin date,
    id_animal integer
);


ALTER TABLE public.soin OWNER TO "loic.bergeot";

--
-- Name: soin_id_soin_seq; Type: SEQUENCE; Schema: public; Owner: loic.bergeot
--

CREATE SEQUENCE public.soin_id_soin_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.soin_id_soin_seq OWNER TO "loic.bergeot";

--
-- Name: soin_id_soin_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: loic.bergeot
--

ALTER SEQUENCE public.soin_id_soin_seq OWNED BY public.soin.id_soin;


--
-- Name: transfere_id_transfere_seq; Type: SEQUENCE; Schema: public; Owner: loic.bergeot
--

CREATE SEQUENCE public.transfere_id_transfere_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.transfere_id_transfere_seq OWNER TO "loic.bergeot";

--
-- Name: transfere_id_transfere_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: loic.bergeot
--

ALTER SEQUENCE public.transfere_id_transfere_seq OWNED BY public.transfere.id_transfere;


--
-- Name: travaille; Type: TABLE; Schema: public; Owner: loic.bergeot
--

CREATE TABLE public.travaille (
    id_travail integer NOT NULL,
    matricule integer,
    id_refuge integer,
    fonction text
);


ALTER TABLE public.travaille OWNER TO "loic.bergeot";

--
-- Name: travaille_id_travail_seq; Type: SEQUENCE; Schema: public; Owner: loic.bergeot
--

CREATE SEQUENCE public.travaille_id_travail_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.travaille_id_travail_seq OWNER TO "loic.bergeot";

--
-- Name: travaille_id_travail_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: loic.bergeot
--

ALTER SEQUENCE public.travaille_id_travail_seq OWNED BY public.travaille.id_travail;


--
-- Name: vaccins_a_faire; Type: VIEW; Schema: public; Owner: loic.bergeot
--

CREATE VIEW public.vaccins_a_faire AS
 WITH vaccins_possible AS (
         SELECT soin.type_soin
           FROM public.soin
          WHERE (soin.type_soin ~~ '%Vaccin%'::text)
        )
 SELECT animal.id_animal,
    vaccins_possible.type_soin
   FROM public.animal,
    vaccins_possible
EXCEPT
 SELECT soin.id_animal,
    soin.type_soin
   FROM public.soin
  WHERE (soin.type_soin ~~ '%Vaccin%'::text);


ALTER TABLE public.vaccins_a_faire OWNER TO "loic.bergeot";

--
-- Name: animal id_animal; Type: DEFAULT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.animal ALTER COLUMN id_animal SET DEFAULT nextval('public.animal_id_animal_seq'::regclass);


--
-- Name: client id_client; Type: DEFAULT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.client ALTER COLUMN id_client SET DEFAULT nextval('public.client_id_client_seq'::regclass);


--
-- Name: employes matricule; Type: DEFAULT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.employes ALTER COLUMN matricule SET DEFAULT nextval('public.employes_matricule_seq'::regclass);


--
-- Name: fouriere id_fouriere; Type: DEFAULT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.fouriere ALTER COLUMN id_fouriere SET DEFAULT nextval('public.fouriere_id_fouriere_seq'::regclass);


--
-- Name: refuges id_refuge; Type: DEFAULT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.refuges ALTER COLUMN id_refuge SET DEFAULT nextval('public.refuges_id_refuge_seq'::regclass);


--
-- Name: soin id_soin; Type: DEFAULT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.soin ALTER COLUMN id_soin SET DEFAULT nextval('public.soin_id_soin_seq'::regclass);


--
-- Name: transfere id_transfere; Type: DEFAULT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.transfere ALTER COLUMN id_transfere SET DEFAULT nextval('public.transfere_id_transfere_seq'::regclass);


--
-- Name: travaille id_travail; Type: DEFAULT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.travaille ALTER COLUMN id_travail SET DEFAULT nextval('public.travaille_id_travail_seq'::regclass);


--
-- Data for Name: adopte; Type: TABLE DATA; Schema: public; Owner: loic.bergeot
--

INSERT INTO public.adopte VALUES (1, 1, '2023-11-01');
INSERT INTO public.adopte VALUES (2, 2, '2023-11-02');
INSERT INTO public.adopte VALUES (3, 3, '2023-11-04');
INSERT INTO public.adopte VALUES (4, 4, '2023-11-05');
INSERT INTO public.adopte VALUES (1, 5, '2023-11-10');
INSERT INTO public.adopte VALUES (1, 6, '2023-11-06');
INSERT INTO public.adopte VALUES (2, 7, '2023-11-07');
INSERT INTO public.adopte VALUES (3, 8, '2023-11-08');
INSERT INTO public.adopte VALUES (4, 9, '2023-11-09');
INSERT INTO public.adopte VALUES (1, 10, '2023-11-03');


--
-- Data for Name: animal; Type: TABLE DATA; Schema: public; Owner: loic.bergeot
--

INSERT INTO public.animal VALUES (1, 'teckel', 'eliot', 12, 'F', 'taches noire', '2001-09-11', 'image1.jpeg');
INSERT INTO public.animal VALUES (2, 'golden retriver', 'volt', 3, 'M', 'queue coupée', '2011-05-02', 'image2.jpeg');
INSERT INTO public.animal VALUES (3, 'bulldog', 'rex', 4, 'F', 'yeux vairons', '2007-04-07', 'image3.jpeg');
INSERT INTO public.animal VALUES (4, 'bichon maltais', 'princesse', 13, 'F', 'sourd', '2022-09-02', 'image4.jpeg');
INSERT INTO public.animal VALUES (5, 'husky', 'médor', 8, 'F', 'aucun', '2022-10-25', 'image5.jpeg');
INSERT INTO public.animal VALUES (6, 'dalmatien', '101', 5, 'M', 'taches blanche', '2001-09-11', 'image6.jpeg');
INSERT INTO public.animal VALUES (7, 'maine coon', 'Ulk', 11, 'F', 'tigré', '2011-05-02', 'image7.jpeg');
INSERT INTO public.animal VALUES (8, 'bengal', 'Arif', 7, 'M', 'aveugle', '2007-04-07', 'image8.jpeg');
INSERT INTO public.animal VALUES (9, 'bleu russe', 'Poutpout', 14, 'F', 'yeux vairons', '2022-09-02', 'image9.jpeg');
INSERT INTO public.animal VALUES (10, 'somali', 'Aled', 2, 'F', 'aucun', '2022-10-25', 'image10.jpeg');


--
-- Name: animal_id_animal_seq; Type: SEQUENCE SET; Schema: public; Owner: loic.bergeot
--

SELECT pg_catalog.setval('public.animal_id_animal_seq', 10, true);


--
-- Data for Name: client; Type: TABLE DATA; Schema: public; Owner: loic.bergeot
--

INSERT INTO public.client VALUES (1, 'Dupont', 'Edouar', '123 rue Saint-Lazard', '01 23 44 67 89');
INSERT INTO public.client VALUES (2, 'Cho', 'Chris', '321 rue Saint-Germain', '06 78 92 23 45');
INSERT INTO public.client VALUES (3, 'Cat', 'Catie', '456 This Street', '01 23 46 67 89');
INSERT INTO public.client VALUES (4, 'Ego', 'Ethan', '654 Bd. Saint-Goerge', '09 87 65 44 21');
INSERT INTO public.client VALUES (5, 'Tho', 'Corentin', '789 Avenue de la Lune', '05 46 72 82 19');
INSERT INTO public.client VALUES (6, 'Travis', 'Vic', '39 Rue du Montparnasse', '05 46 75 62 59');
INSERT INTO public.client VALUES (7, 'Plat', 'Victor', '76 Rue de Picpus', '09 98 12 44 21');
INSERT INTO public.client VALUES (8, 'Alonzo', 'Lori', '18 Rue Paul Bert', '06 09 92 34 45');
INSERT INTO public.client VALUES (9, 'Vettel', 'Eto', '77 Rue du Cherche-Midi', '09 07 61 74 21');
INSERT INTO public.client VALUES (10, 'Verstappen', 'Pol', '13 Rue Quentin-Bauchart', '09 87 54 99 67');


--
-- Name: client_id_client_seq; Type: SEQUENCE SET; Schema: public; Owner: loic.bergeot
--

SELECT pg_catalog.setval('public.client_id_client_seq', 10, true);


--
-- Data for Name: employes; Type: TABLE DATA; Schema: public; Owner: loic.bergeot
--

INSERT INTO public.employes VALUES (1, 'A', 'Rachid', '15 Avenue du Chomedu', '01 23 45 67 89', '2005-03-08', '0634567891011', '2014-02-22', 'ARachidE', 'CaCahuete123');
INSERT INTO public.employes VALUES (2, 'Ntelombila', 'Baltazar', '7 Rue de Lisbonne', '06 78 91 23 45', '1997-05-29', '0701987654321', '2000-11-11', 'BalTelo', '123456789');
INSERT INTO public.employes VALUES (3, 'Houba', 'Marsupilami', '2bis Passage Ruelle', '01 23 45 67 89', '1982-07-16', '0701112131415', '2023-12-12', 'Houba-Houba', 'Houba');
INSERT INTO public.employes VALUES (4, 'Verräter', 'Caïn', '11 Rue Jean Mace', '09 87 65 43 21', '2001-10-16', '079296937989', '2012-02-12', 'Fils_de_Adam', 'Tra1tre');
INSERT INTO public.employes VALUES (5, 'Opfer', 'Abel', '51 Rue de Rivoli', '05 46 73 82 19', '2005-03-08', '0701119141416', '2012-12-31', 'Fils_De_Eve', 'V1ct1m3');
INSERT INTO public.employes VALUES (6, 'Cho', 'Tylan', '235 Rue Saint-Charles', '06 78 91 23 55', '2004-05-12', '0701112678413', '2014-04-22', 'Cho_co', 'LKFDFDD');
INSERT INTO public.employes VALUES (7, 'Tho', 'Dylan', '46 Rue de Rome', '06 78 12 23 65', '2000-06-11', '0701987654567', '2011-12-11', 'Tho.hou', '12DE45F');
INSERT INTO public.employes VALUES (8, 'Lob', 'Arthure', '21 Rue de la Gaite', '06 78 12 45 45', '2002-03-12', '079296937345', '2020-03-23', 'Lob_04', 'ref45e');
INSERT INTO public.employes VALUES (9, 'Vader', 'Joza', '14 Rue des Taillandiers', '06 78 98 09 67', '2005-01-23', '0745619141416', '2019-12-12', 'Vader_dark', 'trre32l');
INSERT INTO public.employes VALUES (10, 'Malo', 'Lori', '21 Bd. Edgar Quinet', '07 45 66 99 87', '2005-01-01', '0701112678567', '2003-11-03', 'Malo.saint', 'jdnf56');


--
-- Name: employes_matricule_seq; Type: SEQUENCE SET; Schema: public; Owner: loic.bergeot
--

SELECT pg_catalog.setval('public.employes_matricule_seq', 10, true);


--
-- Data for Name: fouriere; Type: TABLE DATA; Schema: public; Owner: loic.bergeot
--

INSERT INTO public.fouriere VALUES (1, 1, 1, 'Animaux Retrouvés');
INSERT INTO public.fouriere VALUES (2, 2, 2, 'Lost And Found');
INSERT INTO public.fouriere VALUES (3, 3, 1, 'Finders Keepers');
INSERT INTO public.fouriere VALUES (4, 4, 4, 'Premiers arrivés');
INSERT INTO public.fouriere VALUES (5, 5, 4, 'Premiers servis');
INSERT INTO public.fouriere VALUES (6, 6, 5, 'A');
INSERT INTO public.fouriere VALUES (7, 7, 6, 'B');
INSERT INTO public.fouriere VALUES (8, 8, 8, 'C');
INSERT INTO public.fouriere VALUES (9, 9, 9, 'D');
INSERT INTO public.fouriere VALUES (10, 10, 10, 'E');


--
-- Name: fouriere_id_fouriere_seq; Type: SEQUENCE SET; Schema: public; Owner: loic.bergeot
--

SELECT pg_catalog.setval('public.fouriere_id_fouriere_seq', 10, true);


--
-- Data for Name: refuges; Type: TABLE DATA; Schema: public; Owner: loic.bergeot
--

INSERT INTO public.refuges VALUES (1, 'Le refuge', '285 Rue Fulton', '04 22 52 10 10', 5, 2, 3);
INSERT INTO public.refuges VALUES (2, 'Le nouveau départ', '21 Rue Stalingrad', '01 45 39 40 00', 12, 9, 2);
INSERT INTO public.refuges VALUES (3, 'La SPA du Poitou', '69 Avenue De Fort-Boyard', '09 72 39 40 50', 100, 69, 4);
INSERT INTO public.refuges VALUES (4, 'Venez les chercher', '34 Chemin de Traverse', '08 90 88 89 89', 2, 1, 1);
INSERT INTO public.refuges VALUES (5, 'Lost And Found', '221 bis Rue du Boulanger', '06 21 64 74 20', 50, 25, 5);
INSERT INTO public.refuges VALUES (6, 'spa 1', '1 Rue du Chateau d''Eau', '01 43 71 78 18', 48, 45, 6);
INSERT INTO public.refuges VALUES (7, 'spa 2', '12 Rue des Petits Carreau', '01 56 81 76 00', 56, 50, 7);
INSERT INTO public.refuges VALUES (8, 'spa 4', '20 Rue de la Verrerie', '01 42 28 11 00', 34, 20, 8);
INSERT INTO public.refuges VALUES (9, 'spa 3', '35 Rue du Mont Thabor', '01 40 09 70 30', 23, 18, 9);
INSERT INTO public.refuges VALUES (10, 'spa 5', '56 Rue de Bagnolet', '01 43 26 50 04', 78, 60, 10);


--
-- Name: refuges_id_refuge_seq; Type: SEQUENCE SET; Schema: public; Owner: loic.bergeot
--

SELECT pg_catalog.setval('public.refuges_id_refuge_seq', 10, true);


--
-- Data for Name: soin; Type: TABLE DATA; Schema: public; Owner: loic.bergeot
--

INSERT INTO public.soin VALUES (1, 4, 'Vaccin contre la rage', '2001-09-12', 1);
INSERT INTO public.soin VALUES (2, 4, 'Vaccin contre la rage', '2007-04-08', 3);
INSERT INTO public.soin VALUES (3, 5, 'Patte sous attele', '2005-05-05', 1);
INSERT INTO public.soin VALUES (4, 3, 'Checkup', '2010-01-02', 3);
INSERT INTO public.soin VALUES (5, 3, 'Prise de sang', '2023-10-17', 5);
INSERT INTO public.soin VALUES (6, 4, 'Vaccin contre la rage', '2001-12-12', 1);
INSERT INTO public.soin VALUES (7, 4, 'Vaccin contre la rage', '2007-07-08', 3);
INSERT INTO public.soin VALUES (8, 5, 'Patte sous attele', '2005-08-05', 1);
INSERT INTO public.soin VALUES (9, 3, 'Checkup', '2010-04-02', 3);
INSERT INTO public.soin VALUES (10, 3, 'Prise de sang', '2023-12-17', 5);


--
-- Name: soin_id_soin_seq; Type: SEQUENCE SET; Schema: public; Owner: loic.bergeot
--

SELECT pg_catalog.setval('public.soin_id_soin_seq', 10, true);


--
-- Data for Name: transfere; Type: TABLE DATA; Schema: public; Owner: loic.bergeot
--

INSERT INTO public.transfere VALUES (1, 1, 2, '2023-10-29', '2023-10-30', 1);
INSERT INTO public.transfere VALUES (2, 2, 1, '2023-10-30', '2023-11-01', 2);
INSERT INTO public.transfere VALUES (3, 1, 4, '2023-11-01', '2023-11-02', 3);
INSERT INTO public.transfere VALUES (4, 4, 3, '2023-11-02', '2023-11-03', 4);
INSERT INTO public.transfere VALUES (5, 4, 5, '2023-11-04', '2023-11-05', 5);
INSERT INTO public.transfere VALUES (6, 5, 6, '2023-11-05', '2023-11-06', 6);
INSERT INTO public.transfere VALUES (7, 6, 7, '2023-11-06', '2023-11-07', 7);
INSERT INTO public.transfere VALUES (8, 7, 8, '2023-11-07', '2023-11-08', 8);
INSERT INTO public.transfere VALUES (9, 9, 10, '2023-11-08', '2023-11-09', 9);
INSERT INTO public.transfere VALUES (10, 10, 4, '2023-11-09', '2023-11-10', 10);


--
-- Name: transfere_id_transfere_seq; Type: SEQUENCE SET; Schema: public; Owner: loic.bergeot
--

SELECT pg_catalog.setval('public.transfere_id_transfere_seq', 10, true);


--
-- Data for Name: travaille; Type: TABLE DATA; Schema: public; Owner: loic.bergeot
--

INSERT INTO public.travaille VALUES (1, 1, 1, 'Concierge');
INSERT INTO public.travaille VALUES (2, 2, 2, 'Accompagnateur pour animaux');
INSERT INTO public.travaille VALUES (3, 1, 4, 'Agent d''accueil');
INSERT INTO public.travaille VALUES (4, 1, 5, 'Comptable');
INSERT INTO public.travaille VALUES (5, 4, 3, 'Concierge');
INSERT INTO public.travaille VALUES (6, 3, 3, 'Surveillant');
INSERT INTO public.travaille VALUES (7, 5, 5, 'Vigile');
INSERT INTO public.travaille VALUES (8, 6, 6, 'Agent d''acceuil');
INSERT INTO public.travaille VALUES (9, 3, 1, 'Agent d''acceuil');
INSERT INTO public.travaille VALUES (10, 7, 4, 'Accompagnateur pour animaux');


--
-- Name: travaille_id_travail_seq; Type: SEQUENCE SET; Schema: public; Owner: loic.bergeot
--

SELECT pg_catalog.setval('public.travaille_id_travail_seq', 10, true);


--
-- Name: adopte adopte_pkey; Type: CONSTRAINT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.adopte
    ADD CONSTRAINT adopte_pkey PRIMARY KEY (id_client, id_animal);


--
-- Name: animal animal_pkey; Type: CONSTRAINT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT animal_pkey PRIMARY KEY (id_animal);


--
-- Name: client client_pkey; Type: CONSTRAINT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT client_pkey PRIMARY KEY (id_client);


--
-- Name: employes employes_pkey; Type: CONSTRAINT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.employes
    ADD CONSTRAINT employes_pkey PRIMARY KEY (matricule);


--
-- Name: fouriere fouriere_pkey; Type: CONSTRAINT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.fouriere
    ADD CONSTRAINT fouriere_pkey PRIMARY KEY (id_fouriere);


--
-- Name: refuges refuges_pkey; Type: CONSTRAINT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.refuges
    ADD CONSTRAINT refuges_pkey PRIMARY KEY (id_refuge);


--
-- Name: soin soin_pkey; Type: CONSTRAINT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.soin
    ADD CONSTRAINT soin_pkey PRIMARY KEY (id_soin, matricule);


--
-- Name: transfere transfere_pkey; Type: CONSTRAINT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.transfere
    ADD CONSTRAINT transfere_pkey PRIMARY KEY (id_transfere);


--
-- Name: travaille travaille_pkey; Type: CONSTRAINT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.travaille
    ADD CONSTRAINT travaille_pkey PRIMARY KEY (id_travail);


--
-- Name: adopte adopte_id_animal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.adopte
    ADD CONSTRAINT adopte_id_animal_fkey FOREIGN KEY (id_animal) REFERENCES public.animal(id_animal);


--
-- Name: adopte adopte_id_client_fkey; Type: FK CONSTRAINT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.adopte
    ADD CONSTRAINT adopte_id_client_fkey FOREIGN KEY (id_client) REFERENCES public.client(id_client);


--
-- Name: fouriere fouriere_id_animal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.fouriere
    ADD CONSTRAINT fouriere_id_animal_fkey FOREIGN KEY (id_animal) REFERENCES public.animal(id_animal);


--
-- Name: fouriere fouriere_id_refuge_fkey; Type: FK CONSTRAINT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.fouriere
    ADD CONSTRAINT fouriere_id_refuge_fkey FOREIGN KEY (id_refuge) REFERENCES public.refuges(id_refuge);


--
-- Name: refuges refuges_gerant_fkey; Type: FK CONSTRAINT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.refuges
    ADD CONSTRAINT refuges_gerant_fkey FOREIGN KEY (gerant) REFERENCES public.employes(matricule);


--
-- Name: soin soin_id_animal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.soin
    ADD CONSTRAINT soin_id_animal_fkey FOREIGN KEY (id_animal) REFERENCES public.animal(id_animal);


--
-- Name: soin soin_matricule_fkey; Type: FK CONSTRAINT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.soin
    ADD CONSTRAINT soin_matricule_fkey FOREIGN KEY (matricule) REFERENCES public.employes(matricule);


--
-- Name: transfere transfere_id_animal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.transfere
    ADD CONSTRAINT transfere_id_animal_fkey FOREIGN KEY (id_animal) REFERENCES public.animal(id_animal);


--
-- Name: transfere transfere_id_refuge1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.transfere
    ADD CONSTRAINT transfere_id_refuge1_fkey FOREIGN KEY (id_refuge1) REFERENCES public.refuges(id_refuge);


--
-- Name: transfere transfere_id_refuge2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.transfere
    ADD CONSTRAINT transfere_id_refuge2_fkey FOREIGN KEY (id_refuge2) REFERENCES public.refuges(id_refuge);


--
-- Name: travaille travaille_id_refuge_fkey; Type: FK CONSTRAINT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.travaille
    ADD CONSTRAINT travaille_id_refuge_fkey FOREIGN KEY (id_refuge) REFERENCES public.refuges(id_refuge);


--
-- Name: travaille travaille_matricule_fkey; Type: FK CONSTRAINT; Schema: public; Owner: loic.bergeot
--

ALTER TABLE ONLY public.travaille
    ADD CONSTRAINT travaille_matricule_fkey FOREIGN KEY (matricule) REFERENCES public.employes(matricule);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

