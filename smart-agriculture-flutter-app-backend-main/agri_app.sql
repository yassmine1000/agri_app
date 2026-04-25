--
-- PostgreSQL database dump
--

\restrict 8qa0YHVQ5A4pzKq4L8lzzaflBBqOjx3D2TiFfSWC2HaIvjbwHzyrwSvoU5VvPTb

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: crop_library; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crop_library (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    ideal_season character varying(50),
    duration_days integer,
    ideal_sowing_period character varying(100),
    created_at timestamp without time zone DEFAULT now(),
    name_fr character varying(100),
    ideal_season_fr character varying(50),
    ideal_sowing_period_fr character varying(100),
    name_ar character varying(100),
    ideal_season_ar character varying(50),
    ideal_sowing_period_ar character varying(100),
    duration_label_ar character varying(100),
    duration_label_fr character varying(100),
    duration_label_en character varying(100)
);


--
-- Name: crop_library_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.crop_library_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crop_library_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crop_library_id_seq OWNED BY public.crop_library.id;


--
-- Name: crop_planning; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crop_planning (
    id integer NOT NULL,
    user_id integer,
    crop_id integer,
    start_date date NOT NULL,
    expected_harvest_date date NOT NULL,
    notes text,
    irrigation_reminder boolean DEFAULT false,
    fertilizer_reminder boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now(),
    plan_name character varying(255)
);


--
-- Name: crop_planning_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.crop_planning_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crop_planning_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crop_planning_id_seq OWNED BY public.crop_planning.id;


--
-- Name: crop_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crop_tasks (
    id integer NOT NULL,
    planning_id integer,
    task_type character varying(50) NOT NULL,
    task_date date NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    created_at timestamp without time zone DEFAULT now(),
    plan_name character varying(255)
);


--
-- Name: crop_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.crop_tasks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crop_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crop_tasks_id_seq OWNED BY public.crop_tasks.id;


--
-- Name: detection_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.detection_history (
    id integer NOT NULL,
    user_id integer,
    disease character varying(100),
    confidence numeric(5,4),
    advice text,
    image_path character varying(255),
    detected_at timestamp without time zone DEFAULT now()
);


--
-- Name: detection_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.detection_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: detection_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.detection_history_id_seq OWNED BY public.detection_history.id;


--
-- Name: plant_prices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plant_prices (
    id integer NOT NULL,
    plant_name character varying(100) NOT NULL,
    category character varying(50) DEFAULT 'Légumes'::character varying NOT NULL,
    price numeric(10,2) NOT NULL,
    unit character varying(20) DEFAULT 'kg'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: plant_prices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.plant_prices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plant_prices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.plant_prices_id_seq OWNED BY public.plant_prices.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    name_fr character varying(200),
    name_ar character varying(200),
    price numeric(10,3) NOT NULL,
    category character varying(100) NOT NULL,
    category_fr character varying(100),
    category_ar character varying(100),
    description text,
    description_fr text,
    description_ar text,
    image_url character varying(500),
    stock_available boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    description_en text
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    password character varying(255) NOT NULL,
    role character varying(10) NOT NULL,
    name character varying(100) NOT NULL,
    address text NOT NULL,
    phone_no character varying(20) NOT NULL,
    gender character varying(10),
    dob date,
    farm_name character varying(100),
    farmer_registration_no character varying(50),
    alt_contact_no character varying(20),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    reset_token character varying(255),
    reset_token_expiry timestamp without time zone,
    email character varying(255),
    qr_token character varying(255),
    CONSTRAINT users_gender_check CHECK (((gender)::text = ANY ((ARRAY['male'::character varying, 'female'::character varying, 'other'::character varying])::text[]))),
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['farmer'::character varying, 'customer'::character varying, 'admin'::character varying])::text[])))
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: crop_library id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crop_library ALTER COLUMN id SET DEFAULT nextval('public.crop_library_id_seq'::regclass);


--
-- Name: crop_planning id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crop_planning ALTER COLUMN id SET DEFAULT nextval('public.crop_planning_id_seq'::regclass);


--
-- Name: crop_tasks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crop_tasks ALTER COLUMN id SET DEFAULT nextval('public.crop_tasks_id_seq'::regclass);


--
-- Name: detection_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detection_history ALTER COLUMN id SET DEFAULT nextval('public.detection_history_id_seq'::regclass);


--
-- Name: plant_prices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plant_prices ALTER COLUMN id SET DEFAULT nextval('public.plant_prices_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: crop_library; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.crop_library (id, name, ideal_season, duration_days, ideal_sowing_period, created_at, name_fr, ideal_season_fr, ideal_sowing_period_fr, name_ar, ideal_season_ar, ideal_sowing_period_ar, duration_label_ar, duration_label_fr, duration_label_en) FROM stdin;
4	Corn	Summer	120	April - May	2026-04-11 19:29:23.192684	Maïs	Été	Avril - Mai	ذرة	صيف	أفريل - ماي	4 أشهر	4 mois	4 months
5	Pepper	Spring/Summer	90	March - April	2026-04-11 19:29:23.192684	Poivron	Printemps/Été	Mars - Avril	فلفل	ربيع/صيف	مارس - أفريل	3 أشهر	3 mois	3 months
6	Onion	Fall/Winter	120	October - November	2026-04-11 19:29:23.192684	Oignon	Automne/Hiver	Octobre - Novembre	بصل	خريف/شتاء	أكتوبر - نوفمبر	4 أشهر	4 mois	4 months
7	Carrot	Fall/Winter	90	September - November	2026-04-11 19:29:23.192684	Carotte	Automne/Hiver	Septembre - Novembre	جزر	خريف/شتاء	سبتمبر - نوفمبر	3 أشهر	3 mois	3 months
8	Watermelon	Spring/Summer	100	March - April	2026-04-11 19:29:23.192684	Pastèque	Printemps/Été	Mars - Avril	دلاع	ربيع/صيف	مارس - أفريل	3 أشهر و10 يوم	3 mois et 10 jours	3 months and 10 days
9	Orange	Winter harvest (Nov-Feb)	365	March - April (transplant)	2026-04-11 19:29:23.192684	Orange	Récolte hivernale (Nov-Fév)	Mars - Avril (transplantation)	برتقال	حصاد شتوي (نوفمبر-فيفري)	مارس - أفريل (زراعة)	سنة كاملة	1 an	1 year
22	Fig	Summer / Harvest Jul-Sep	150	February - March (cuttings)	2026-04-18 12:23:19.232496	Figuier	Été / Récolte Juil-Sep	Février - Mars (boutures)	تين	صيف / حصاد جويلية-سبتمبر	فيفري - مارس (عقل)	5 أشهر	5 mois	5 months
10	Olive	All seasons / Harvest Oct-Jan	365	February - March (transplant)	2026-04-11 19:29:23.192684	Olive	Toutes saisons / Récolte Oct-Jan	Février - Mars (transplantation)	زيتون	جميع الفصول / حصاد أكتوبر-جانفي	فيفري - مارس (زراعة)	سنة كاملة	1 an	1 year
21	Date Palm	Summer / Harvest Aug-Oct	365	March - April (transplant)	2026-04-18 12:23:19.232496	Palmier dattier	Été / Récolte Août-Oct	Mars - Avril (plantation)	نخيل التمر	صيف / حصاد أغسطس-أكتوبر	مارس - أفريل (زراعة)	سنة كاملة	1 an	1 year
23	Pomegranate	Summer / Harvest Sep-Nov	180	February - March (transplant)	2026-04-18 12:23:19.232496	Grenadier	Été / Récolte Sep-Nov	Février - Mars (transplantation)	رمان	صيف / حصاد سبتمبر-نوفمبر	فيفري - مارس (زراعة)	6 أشهر	6 mois	6 months
24	Grape	Summer / Harvest Jul-Sep	150	February - March (pruning)	2026-04-18 12:23:19.232496	Vigne	Été / Récolte Juil-Sep	Février - Mars (taille)	عنب	صيف / حصاد جويلية-سبتمبر	فيفري - مارس (تقليم)	5 أشهر	5 mois	5 months
25	Almond	Spring / Harvest May-Jun	210	October - November (transplant)	2026-04-18 12:23:19.232496	Amandier	Printemps / Récolte Mai-Juin	Octobre - Novembre (plantation)	لوز	ربيع / حصاد ماي-جوان	أكتوبر - نوفمبر (زراعة)	7 أشهر	7 mois	7 months
26	Apricot	Spring / Harvest May-Jun	180	October - December (transplant)	2026-04-18 12:23:19.232496	Abricotier	Printemps / Récolte Mai-Juin	Octobre - Décembre (plantation)	مشمش	ربيع / حصاد ماي-جوان	أكتوبر - ديسمبر (زراعة)	6 أشهر	6 mois	6 months
27	Lemon	All seasons / Harvest Nov-Apr	365	March - April (transplant)	2026-04-18 12:23:19.232496	Citronnier	Toutes saisons / Récolte Nov-Avr	Mars - Avril (plantation)	ليمون	جميع الفصول / حصاد نوفمبر-أبريل	مارس - أفريل (زراعة)	سنة كاملة	1 an	1 year
30	Chickpea	Winter/Spring	120	November - January	2026-04-18 12:23:19.232496	Pois chiche	Hiver/Printemps	Novembre - Janvier	حمص	شتاء/ربيع	نوفمبر - جانفي	4 أشهر	4 mois	4 months
1	Tomato	Spring/Summer & Fall	80	Feb-Apr (spring) / Aug-Sep (fall)	2026-04-11 19:29:23.192684	Tomate	Printemps/Été et Automne	Fév-Avr (printemps) / Août-Sep (automne)	طماطم	ربيع/صيف وخريف	فيفري-أفريل (ربيع) / أوت-سبتمبر (خريف)	2 أشهر و20 يوم	2 mois et 20 jours	2 months and 20 days
2	Potato	Winter & Fall	90	Jan-Feb (winter) / Aug-Sep (fall)	2026-04-11 19:29:23.192684	Pomme de terre	Hiver et Automne	Jan-Fév (hiver) / Août-Sep (automne)	بطاطا	شتاء وخريف	جانفي-فيفري (شتاء) / أوت-سبتمبر (خريف)	3 أشهر	3 mois	3 months
3	Wheat	Winter	150	November - December	2026-04-11 19:29:23.192684	Blé	Hiver	Novembre - Décembre	قمح	شتاء	نوفمبر - ديسمبر	5 أشهر	5 mois	5 months
28	Garlic	Winter/Spring	180	October - November	2026-04-18 12:23:19.232496	Ail	Hiver/Printemps	Octobre - Novembre	ثوم	شتاء/ربيع	أكتوبر - نوفمبر	6 أشهر	6 mois	6 months
29	Broad Bean	Winter/Spring	100	November - December	2026-04-18 12:23:19.232496	Fève	Hiver/Printemps	Novembre - Décembre	فول	شتاء/ربيع	نوفمبر - ديسمبر	3 أشهر و10 يوم	3 mois et 10 jours	3 months and 10 days
34	Barley	Winter	130	November - December	2026-04-18 12:23:19.232496	Orge	Hiver	Novembre - Décembre	شعير	شتاء	نوفمبر - ديسمبر	4 أشهر و10 يوم	4 mois et 10 jours	4 months and 10 days
31	Lettuce	Fall/Winter/Spring	55	September - February	2026-04-18 12:23:19.232496	Laitue	Automne/Hiver/Printemps	Septembre - Février	خس	خريف/شتاء/ربيع	سبتمبر - فيفري	1 أشهر و25 يوم	1 mois et 25 jours	1 months and 25 days
32	Zucchini	Spring/Summer	55	March - May	2026-04-18 12:23:19.232496	Courgette	Printemps/Été	Mars - Mai	قرع أخضر	ربيع/صيف	مارس - ماي	1 أشهر و25 يوم	1 mois et 25 jours	1 months and 25 days
33	Eggplant	Spring/Summer	80	March - April	2026-04-18 12:23:19.232496	Aubergine	Printemps/Été	Mars - Avril	باذنجان	ربيع/صيف	مارس - أفريل	2 أشهر و20 يوم	2 mois et 20 jours	2 months and 20 days
35	Sunflower	Spring/Summer	100	March - April	2026-04-18 12:23:19.232496	Tournesol	Printemps/Été	Mars - Avril	عباد الشمس	ربيع/صيف	مارس - أفريل	3 أشهر و10 يوم	3 mois et 10 jours	3 months and 10 days
\.


--
-- Data for Name: crop_planning; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.crop_planning (id, user_id, crop_id, start_date, expected_harvest_date, notes, irrigation_reminder, fertilizer_reminder, created_at, plan_name) FROM stdin;
5	3	6	2026-04-22	2026-05-22	\N	t	t	2026-04-22 16:31:05.288361	\N
6	3	4	2026-04-22	2026-05-22	\N	f	f	2026-04-22 18:37:53.401303	\N
7	3	6	2026-04-22	2026-05-22	\N	f	f	2026-04-22 21:09:01.44874	\N
8	3	6	2026-04-24	2026-05-24	\N	f	f	2026-04-24 21:27:07.234106	\N
9	3	5	2026-04-24	2026-05-24	\N	t	t	2026-04-24 21:35:02.768669	Pepper
10	3	8	2026-04-24	2026-05-31	\N	t	t	2026-04-24 23:03:15.58459	Watermelon
11	3	7	2026-04-16	2026-05-19	\N	f	f	2026-04-25 00:11:41.811482	Carrot
12	3	5	2026-04-24	2026-05-25	\N	f	f	2026-04-25 02:06:03.360749	Pepper
13	14	5	2026-04-23	2026-05-14	\N	f	f	2026-04-25 02:07:49.867271	Pepper
14	14	6	2026-04-22	2026-05-30	\N	f	f	2026-04-25 02:18:50.770209	Onion
\.


--
-- Data for Name: crop_tasks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.crop_tasks (id, planning_id, task_type, task_date, status, created_at, plan_name) FROM stdin;
9	5	Irrigation	2026-04-13	pending	2026-04-24 21:42:21.13683	\N
11	10	Sowing	2026-04-25	pending	2026-04-24 23:04:48.334078	Watermelon
\.


--
-- Data for Name: detection_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.detection_history (id, user_id, disease, confidence, advice, image_path, detected_at) FROM stdin;
1	3	Background_without_leaves	0.9987	Please retake the photo with a single leaf filling most of the frame for better analysis results.	\N	2026-04-09 15:14:30.407189
2	3	Tomato___Late_blight	0.9339	Apply metalaxyl + mancozeb immediately. Remove and bag all infected plant material — do not compost.	\N	2026-04-09 17:42:57.001981
3	3	Apple___Black_rot	0.9903	Remove mummified fruits and dead wood from trees immediately. Apply copper-based fungicide during the growing season.	\N	2026-04-09 17:43:14.294498
4	3	Tomato___Tomato_Yellow_Leaf_Curl_Virus	1.0000	Remove and destroy infected plants immediately. Use reflective mulch to repel whiteflies from young transplants.	\N	2026-04-10 00:25:34.51916
5	3	Corn___Common_rust	0.9647	Apply foliar fungicide (propiconazole or azoxystrobin) when rust pustules first appear on lower leaves.	\N	2026-04-11 14:23:55.841723
6	3	Tomato___Tomato_Yellow_Leaf_Curl_Virus	1.0000	Plant resistant varieties (TYLCV-resistant). Apply insecticide at transplanting and use insect-proof screens in nurseries.	\N	2026-04-11 14:24:32.215083
7	3	Tomato___Tomato_Yellow_Leaf_Curl_Virus	1.0000	Plant resistant varieties (TYLCV-resistant). Apply insecticide at transplanting and use insect-proof screens in nurseries.	\N	2026-04-11 14:31:49.647636
8	3	Tomato___Tomato_Yellow_Leaf_Curl_Virus	1.0000	Control whitefly populations with systemic insecticides (imidacloprid). Use yellow sticky traps for monitoring.	\N	2026-04-11 14:38:19.577349
9	3	Tomato___Tomato_Yellow_Leaf_Curl_Virus	1.0000	Plant resistant varieties (TYLCV-resistant). Apply insecticide at transplanting and use insect-proof screens in nurseries.	\N	2026-04-11 14:42:15.781964
10	3	Tomato___Tomato_Yellow_Leaf_Curl_Virus	1.0000	Remove and destroy infected plants immediately. Use reflective mulch to repel whiteflies from young transplants.	\N	2026-04-11 14:47:18.977113
11	3	Peach___healthy	0.9748	Peach tree is healthy! Thin fruit to 6-8 inches apart for larger, higher quality peaches.	\N	2026-04-11 14:50:58.038553
12	3	Tomato___Tomato_Yellow_Leaf_Curl_Virus	1.0000	Remove and destroy infected plants immediately. Use reflective mulch to repel whiteflies from young transplants.	\N	2026-04-11 15:00:39.457671
13	3	Tomato___Tomato_Yellow_Leaf_Curl_Virus	1.0000	Control whitefly populations with systemic insecticides (imidacloprid). Use yellow sticky traps for monitoring.	\N	2026-04-11 15:03:29.114623
14	3	Tomato___Tomato_Yellow_Leaf_Curl_Virus	1.0000	Plant resistant varieties (TYLCV-resistant). Apply insecticide at transplanting and use insect-proof screens in nurseries.	\N	2026-04-11 15:06:49.912378
15	3	Tomato___Tomato_Yellow_Leaf_Curl_Virus	1.0000	Remove and destroy infected plants immediately. Use reflective mulch to repel whiteflies from young transplants.	\N	2026-04-11 15:14:53.695894
16	3	Tomato___Tomato_Yellow_Leaf_Curl_Virus	1.0000	Plant resistant varieties (TYLCV-resistant). Apply insecticide at transplanting and use insect-proof screens in nurseries.	\N	2026-04-11 15:20:36.043923
17	3	Tomato___Tomato_Yellow_Leaf_Curl_Virus	1.0000	Planter des variétés résistantes (TYLCV-résistantes). Appliquer des insecticides à la plantation et utiliser des filets insect-proof en pépinière.	\N	2026-04-11 19:19:15.583267
18	3	Tomato___Tomato_Yellow_Leaf_Curl_Virus	1.0000	Plant resistant varieties (TYLCV-resistant). Apply insecticide at transplanting and use insect-proof screens in nurseries.	\N	2026-04-11 19:19:40.79532
19	3	Tomato___Tomato_Yellow_Leaf_Curl_Virus	1.0000	Planter des variétés résistantes (TYLCV-résistantes). Appliquer des insecticides à la plantation et utiliser des filets insect-proof en pépinière.	\N	2026-04-14 21:53:06.332972
20	9	Background_without_leaves	1.0000	L'image ne contient pas de feuille reconnaissable. Assurez un bon éclairage et focalisez l'appareil photo directement sur la feuille.	\N	2026-04-14 23:10:37.061931
21	9	Background_without_leaves	0.5593	Veuillez reprendre la photo avec une seule feuille remplissant la majeure partie du cadre pour de meilleurs résultats.	\N	2026-04-14 23:11:37.830539
22	10	Tomato___Late_blight	0.7335	Appliquer immédiatement du métalaxyl + mancozèbe. Retirer et emballer tous les matériaux végétaux infectés — ne pas composter.	\N	2026-04-17 11:00:03.789389
23	10	Tomato___Late_blight	0.9999	Détruire les plants infectés pour éviter la propagation. Appliquer un fongicide à base de cuivre comme mesure préventive sur les plants voisins.	\N	2026-04-17 11:01:30.780542
24	10	Tomato___Late_blight	0.9976	Appliquer immédiatement du métalaxyl + mancozèbe. Retirer et emballer tous les matériaux végétaux infectés — ne pas composter.	\N	2026-04-17 11:01:45.934447
25	10	Tomato___Late_blight	0.7335	Détruire les plants infectés pour éviter la propagation. Appliquer un fongicide à base de cuivre comme mesure préventive sur les plants voisins.	\N	2026-04-17 11:05:52.011223
26	10	Tomato___Late_blight	0.9976	Appliquer un fongicide protecteur avant les pluies. Éviter l'irrigation par aspersion et travailler dans les champs uniquement quand ils sont secs.	\N	2026-04-17 11:12:21.273673
27	10	Tomato___Late_blight	0.7335	Détruire les plants infectés pour éviter la propagation. Appliquer un fongicide à base de cuivre comme mesure préventive sur les plants voisins.	\N	2026-04-17 11:16:03.0995
28	10	Tomato___Late_blight	0.9999	Appliquer immédiatement du métalaxyl + mancozèbe. Retirer et emballer tous les matériaux végétaux infectés — ne pas composter.	\N	2026-04-17 11:16:09.181217
29	3	Tomato___Septoria_leaf_spot	0.9983	Mulch to prevent soil splash. Apply copper fungicide every 7-10 days during wet weather conditions.	\N	2026-04-19 12:09:08.416737
30	3	Background_without_leaves	0.5807	Please retake the photo with a single leaf filling most of the frame for better analysis results.	\N	2026-04-19 12:12:38.113249
31	3	Apple___Apple_scab	0.9752	Use resistant apple varieties when replanting. Rake and compost infected leaves away from the orchard.	\N	2026-04-19 12:13:09.156289
32	3	Tomato___Late_blight	0.9642	Destroy infected plants to prevent spread. Apply copper-based fungicide as protective measure in neighboring plants.	\N	2026-04-19 12:16:10.366655
33	3	Apple___Apple_scab	0.9752	Prune trees to improve air circulation. Apply protective fungicide sprays before and after rain events during spring.	\N	2026-04-19 12:19:43.735516
34	3	Background_without_leaves	0.5807	Please retake the photo with a single leaf filling most of the frame for better analysis results.	\N	2026-04-19 12:19:53.104302
35	3	Tomato___Septoria_leaf_spot	0.9983	Mulch to prevent soil splash. Apply copper fungicide every 7-10 days during wet weather conditions.	\N	2026-04-19 12:20:11.416191
36	3	Background_without_leaves	0.9988	Image does not contain a recognizable leaf. Ensure good lighting and focus the camera directly on the leaf.	\N	2026-04-19 12:20:56.698961
37	3	Background_without_leaves	0.9988	Aucune plante détectée dans l'image. Veuillez prendre une photo claire d'une feuille de plante pour une détection précise.	\N	2026-04-19 23:18:40.738369
38	3	Orange___Haunglongbing_(Citrus_greening)	0.7721	Contrôler le psylle des agrumes (vecteur de la maladie) avec des insecticides systémiques. Inspecter les nouvelles plantations issues de pépinières certifiées.	\N	2026-04-19 23:21:20.24127
39	3	Apple___Apple_scab	0.9752	Tailler les arbres pour améliorer la circulation de l'air. Appliquer des fongicides préventifs avant et après les pluies printanières.	\N	2026-04-19 23:21:36.58149
40	3	Corn___Northern_Leaf_Blight	0.9982	Alterner les cultures et labourer les débris infectés. Utiliser des hybrides résistants au mildiou nordique.	\N	2026-04-19 23:22:35.379231
41	3	Grape___healthy	1.0000	Très bon état ! Assurer un éclaircissage des rameaux et un effeuillage autour de la zone fructifère pour prévenir les maladies.	\N	2026-04-19 23:23:35.327291
42	3	Peach___Bacterial_spot	1.0000	Planter des variétés de pêchers résistants. Appliquer un bactéricide cuivré à la chute des calices et continuer tous les 7-14 jours.	\N	2026-04-19 23:24:19.273055
43	3	Apple___Apple_scab	0.3359	Utiliser des variétés de pommes résistantes lors de la replantation. Ratisser les feuilles infectées loin du verger.	\N	2026-04-19 23:26:01.160663
44	3	Background_without_leaves	0.9999	Aucune plante détectée dans l'image. Veuillez prendre une photo claire d'une feuille de plante pour une détection précise.	\N	2026-04-19 23:26:39.1425
45	3	Background_without_leaves	0.9991	Aucune plante détectée dans l'image. Veuillez prendre une photo claire d'une feuille de plante pour une détection précise.	\N	2026-04-19 23:27:06.675178
46	3	Background_without_leaves	0.9156	Aucune plante détectée dans l'image. Veuillez prendre une photo claire d'une feuille de plante pour une détection précise.	\N	2026-04-19 23:27:44.965863
47	3	Background_without_leaves	1.0000	Aucune plante détectée dans l'image. Veuillez prendre une photo claire d'une feuille de plante pour une détection précise.	\N	2026-04-19 23:28:05.914275
48	3	Apple___Black_rot	0.9997	Tailler les chancres et les branches mortes. Désinfecter les outils de taille entre chaque coupe. Appliquer du captane à la chute des pétales.	\N	2026-04-19 23:29:15.577233
49	3	Corn___healthy	0.3663	Culture saine détectée. Continuer à surveiller les premiers signes de maladie et maintenir la densité de plantation recommandée.	\N	2026-04-19 23:30:01.86374
50	3	Apple___Apple_scab	0.6027	Utiliser des variétés de pommes résistantes lors de la replantation. Ratisser les feuilles infectées loin du verger.	\N	2026-04-19 23:30:52.368997
51	3	Apple___Apple_scab	0.6027	Appliquer des fongicides (myclobutanil ou captane) dès le débourrement. Ramasser et détruire les feuilles tombées pour réduire les spores hivernantes.	\N	2026-04-19 23:31:21.032118
52	3	Cherry___Powdery_mildew	0.9815	Améliorer la circulation de l'air par la taille. Éviter l'irrigation par aspersion. Appliquer de l'huile de neem le matin.	\N	2026-04-19 23:31:49.321313
53	3	Background_without_leaves	0.9986	Veuillez reprendre la photo avec une seule feuille remplissant la majeure partie du cadre pour de meilleurs résultats.	\N	2026-04-19 23:35:24.432895
54	3	Background_without_leaves	1.0000	Aucune plante détectée dans l'image. Veuillez prendre une photo claire d'une feuille de plante pour une détection précise.	\N	2026-04-19 23:35:47.598953
55	3	Potato___Early_blight	0.9966	Maintenir des niveaux adéquats de potassium — la carence augmente la sensibilité. Appliquer un fongicide tous les 7 jours par temps humide.	\N	2026-04-19 23:36:35.326872
56	3	Strawberry___healthy	0.7030	Les plants de fraisiers sont en excellent état ! Appliquez un engrais équilibré après la rénovation et maintenez une humidité constante.	\N	2026-04-19 23:38:26.519738
57	3	Potato___Late_blight	0.7800	Éviter l'irrigation par aspersion. Appliquer un fongicide protecteur avant la pluie et un systémique après confirmation de l'infection.	\N	2026-04-19 23:39:26.633605
58	3	Soybean___healthy	0.9954	La culture de soja est en excellent état ! Assurez un apport adéquat en phosphore et potassium pour un remplissage optimal des gousses.	\N	2026-04-19 23:39:48.439098
59	3	Potato___Late_blight	0.7800	Retirer et détruire les plants entiers infectés y compris les tubercules. Appliquer un fongicide tous les 5-7 jours par temps frais et humide.	\N	2026-04-19 23:40:10.465525
60	3	Soybean___healthy	0.9954	Très bon état ! Surveiller le puceron du soja et le coléoptère des haricots. Maintenir la densité de plantation pour la fermeture de la canopée.	\N	2026-04-20 17:39:56.006816
61	3	Peach___Bacterial_spot	1.0000	Planter des variétés de pêchers résistants. Appliquer un bactéricide cuivré à la chute des calices et continuer tous les 7-14 jours.	\N	2026-04-20 17:40:23.960266
62	3	Soybean___healthy	0.9954	Soybean crop looks excellent! Ensure adequate phosphorus and potassium for optimal pod fill.	\N	2026-04-20 17:40:59.530055
63	3	Grape___healthy	1.0000	La vigne est en excellent état ! Maintenir une nutrition équilibrée en potassium et magnésium pour une qualité optimale des baies.	\N	2026-04-20 17:42:13.334376
64	3	Potato___Early_blight	0.9966	Alterner les cultures pendant 3 ans minimum. Appliquer des fongicides préventifs dès la fermeture des rangs.	\N	2026-04-20 17:44:27.232278
65	3	Peach___Bacterial_spot	1.0000	Tailler pour améliorer la circulation de l'air. Appliquer des pulvérisations de cuivre fixe avant les pluies pendant la saison de croissance.	\N	2026-04-20 21:19:21.794002
66	3	Soybean___healthy	0.9954	Soybean crop looks excellent! Ensure adequate phosphorus and potassium for optimal pod fill.	\N	2026-04-20 21:19:45.061008
67	3	Peach___Bacterial_spot	1.0000	ضع هيدروكسيد النحاس أو أوكسيتتراسايكلين خلال الإزهار. تجنب الري بالرش لتقليل فترات ترطيب الأوراق.	\N	2026-04-20 21:26:59.982517
68	3	Corn___Northern_Leaf_Blight	0.9982	Alterner les cultures et labourer les débris infectés. Utiliser des hybrides résistants au mildiou nordique.	\N	2026-04-20 21:29:40.663521
69	3	Potato___Early_blight	0.9966	ضع كلوروثالونيل أو مانكوزيب عند ظهور الآفة الأولى. أزل الأوراق السفلية الملامسة للتربة.	\N	2026-04-21 02:09:21.540847
70	3	Soybean___healthy	0.9954	La culture de soja est en excellent état ! Assurez un apport adéquat en phosphore et potassium pour un remplissage optimal des gousses.	\N	2026-04-21 02:09:48.557304
71	3	Cherry___Powdery_mildew	0.9815	Improve air circulation by pruning. Avoid overhead irrigation. Apply neem oil spray in early morning.	\N	2026-04-21 12:11:39.62594
72	3	Background_without_leaves	0.9991	No plant detected in the image. Please take a clear photo of a plant leaf for accurate disease detection.	\N	2026-04-21 12:12:03.538293
73	3	Background_without_leaves	0.9999	L'image ne contient pas de feuille reconnaissable. Assurez un bon éclairage et focalisez l'appareil photo directement sur la feuille.	\N	2026-04-21 12:38:14.83742
74	3	Tomato___Late_blight	0.9244	Détruire les plants infectés pour éviter la propagation. Appliquer un fongicide à base de cuivre comme mesure préventive sur les plants voisins.	\N	2026-04-21 14:01:59.557105
75	3	Corn___Northern_Leaf_Blight	0.9982	Appliquer un fongicide (azoxystrobine, propiconazole) à la floraison si le mildiou apparaît sur les feuilles inférieures.	\N	2026-04-21 14:03:40.99989
76	3	Peach___Bacterial_spot	1.0000	Appliquer de l'hydroxyde de cuivre ou de l'oxytétracycline pendant la floraison. Éviter l'irrigation par aspersion pour réduire le mouillage des feuilles.	\N	2026-04-21 14:04:23.674071
77	3	Background_without_leaves	0.9999	Veuillez reprendre la photo avec une seule feuille remplissant la majeure partie du cadre pour de meilleurs résultats.	\N	2026-04-21 14:04:40.745446
78	32	Blueberry___healthy	0.9968	La myrtille est en bonne santé ! Maintenez le pH du sol entre 4,5 et 5,5 pour une absorption optimale des nutriments.	\N	2026-04-22 00:11:50.54651
79	32	Strawberry___Leaf_scorch	0.6710	Appliquer du captane ou du myclobutanil aux premiers signes de taches violettes. Retirer et détruire les feuilles infectées.	\N	2026-04-22 00:12:06.646006
80	32	Corn___Cercospora_leaf_spot Gray_leaf_spot	0.6622	Utiliser des hybrides résistants. Le labour pour enfouir les résidus infectés réduit considérablement l'inoculum hivernal.	\N	2026-04-22 00:12:18.203368
81	32	Peach___Bacterial_spot	0.9993	Planter des variétés de pêchers résistants. Appliquer un bactéricide cuivré à la chute des calices et continuer tous les 7-14 jours.	\N	2026-04-22 00:12:36.301585
82	32	Potato___Early_blight	0.2773	Maintenir des niveaux adéquats de potassium — la carence augmente la sensibilité. Appliquer un fongicide tous les 7 jours par temps humide.	\N	2026-04-22 00:12:48.024979
83	32	Grape___healthy	1.0000	Vigne saine détectée. Continuer la gestion de la canopée et surveiller l'oïdium et le mildiou pendant les périodes humides.	\N	2026-04-22 00:13:09.351526
84	32	Potato___Early_blight	0.8141	Alterner les cultures pendant 3 ans minimum. Appliquer des fongicides préventifs dès la fermeture des rangs.	\N	2026-04-22 00:14:07.840653
85	32	Potato___Early_blight	0.5881	Alterner les cultures pendant 3 ans minimum. Appliquer des fongicides préventifs dès la fermeture des rangs.	\N	2026-04-22 00:14:18.486573
86	32	Strawberry___Leaf_scorch	0.9971	Éviter l'irrigation par aspersion. Appliquer un fongicide à base de cuivre pendant la période de rénovation après la récolte.	\N	2026-04-22 00:14:29.959352
87	32	Apple___Apple_scab	0.9116	Utiliser des variétés de pommes résistantes lors de la replantation. Ratisser les feuilles infectées loin du verger.	\N	2026-04-22 00:14:39.118623
88	32	Background_without_leaves	0.4111	No plant detected in the image. Please take a clear photo of a plant leaf for accurate disease detection.	\N	2026-04-22 00:15:36.936523
89	32	Potato___Early_blight	0.5004	Maintain adequate potassium levels — deficiency increases susceptibility. Apply fungicide on 7-day intervals during wet weather.	\N	2026-04-22 00:16:03.0497
90	32	Tomato___Late_blight	0.9629	Apply metalaxyl + mancozeb immediately. Remove and bag all infected plant material — do not compost.	\N	2026-04-22 00:16:30.07694
91	32	Potato___Early_blight	0.9627	Apply chlorothalonil or mancozeb fungicide at first lesion appearance. Remove lower leaves touching the soil.	\N	2026-04-22 00:18:04.394757
92	32	Strawberry___healthy	0.6978	Healthy plants detected. Monitor for two-spotted spider mite during hot, dry weather.	\N	2026-04-22 00:18:12.895412
93	32	Background_without_leaves	0.4899	No plant detected in the image. Please take a clear photo of a plant leaf for accurate disease detection.	\N	2026-04-22 00:18:21.289038
94	32	Background_without_leaves	0.9627	Image does not contain a recognizable leaf. Ensure good lighting and focus the camera directly on the leaf.	\N	2026-04-22 00:18:35.246262
95	32	Background_without_leaves	0.9422	No plant detected in the image. Please take a clear photo of a plant leaf for accurate disease detection.	\N	2026-04-22 00:18:50.668983
96	32	Corn___healthy	0.6859	Healthy crop detected. Continue scouting for early disease signs and maintain recommended plant population.	\N	2026-04-22 00:19:02.15631
97	32	Raspberry___healthy	0.4614	Raspberry canes are healthy! Remove spent fruiting canes after harvest to encourage new primocane growth.	\N	2026-04-22 00:19:44.756283
98	32	Corn___healthy	0.8599	Corn looks healthy! Ensure adequate nitrogen fertilization at V6 stage for optimal ear development.	\N	2026-04-22 00:20:22.120236
99	32	Strawberry___Leaf_scorch	0.9999	Avoid overhead irrigation. Apply copper-based fungicide during the renovation period after harvest.	\N	2026-04-22 00:21:54.269509
100	32	Strawberry___Leaf_scorch	0.9883	Apply captan or myclobutanil fungicide at first sign of purple spots. Remove and destroy infected leaves.	\N	2026-04-22 00:30:47.270951
101	32	Peach___Bacterial_spot	0.9987	Plant resistant peach varieties. Apply copper bactericide at shuck split and continue on 7-14 day intervals.	\N	2026-04-22 00:32:00.911493
102	32	Corn___healthy	0.4774	Great plant health! Monitor for pest damage and maintain consistent soil moisture during pollination.	\N	2026-04-22 00:33:29.422932
103	3	Pepper,_bell___healthy	0.2635	Le poivron est en excellent état ! Maintenez une humidité du sol constante et fertilisez avec du calcium pour prévenir la pourriture apicale.	\N	2026-04-22 12:01:27.478528
104	3	Strawberry___Leaf_scorch	0.7523	Rénover les plantations de fraisiers après la récolte — tondre le feuillage, réduire les rangs, appliquer un fongicide pour encourager une repousse saine.	\N	2026-04-22 12:01:45.60841
105	3	Strawberry___healthy	0.9975	Plants sains détectés. Surveillez l'acarien tétranyque par temps chaud et sec.	\N	2026-04-22 12:01:54.861829
106	3	Potato___Early_blight	0.9903	Appliquer du chlorothalonil ou du mancozèbe dès l'apparition des premières lésions. Retirer les feuilles inférieures touchant le sol.	\N	2026-04-22 12:02:04.92441
107	3	Corn___healthy	0.6068	Corn looks healthy! Ensure adequate nitrogen fertilization at V6 stage for optimal ear development.	\N	2026-04-22 12:02:19.938247
108	3	Corn___Northern_Leaf_Blight	0.5993	Apply fungicide (azoxystrobin, propiconazole) at early tasseling if blight appears on lower leaves.	\N	2026-04-22 12:02:31.203396
109	3	Potato___Late_blight	0.9848	Remove and destroy entire infected plants including tubers. Apply fungicide on 5-7 day intervals during cool, wet weather.	\N	2026-04-22 12:02:41.485234
110	3	Strawberry___Leaf_scorch	0.7179	Avoid overhead irrigation. Apply copper-based fungicide during the renovation period after harvest.	\N	2026-04-22 12:02:52.655892
111	3	Peach___Bacterial_spot	0.7988	Prune to improve air circulation. Apply fixed copper sprays before rain events during the growing season.	\N	2026-04-22 12:03:06.41978
112	3	Grape___healthy	0.9886	Great condition! Ensure proper shoot thinning and leaf removal around the fruit zone for disease prevention.	\N	2026-04-22 12:03:23.906369
113	3	Grape___healthy	0.9982	Grapevine looks excellent! Maintain balanced nutrition with potassium and magnesium for optimal berry quality.	\N	2026-04-22 12:03:32.445043
114	3	Background_without_leaves	0.6446	Image does not contain a recognizable leaf. Ensure good lighting and focus the camera directly on the leaf.	\N	2026-04-22 12:03:39.110507
115	3	Strawberry___Leaf_scorch	0.9986	Apply captan or myclobutanil fungicide at first sign of purple spots. Remove and destroy infected leaves.	\N	2026-04-22 12:03:46.609867
116	3	Apple___Black_rot	0.6343	Remove mummified fruits and dead wood from trees immediately. Apply copper-based fungicide during the growing season.	\N	2026-04-22 12:03:54.565181
117	3	Corn___Northern_Leaf_Blight	0.3832	Rotate crops and till infected debris. Use resistant hybrids rated for Northern Leaf Blight tolerance.	\N	2026-04-22 12:04:08.555847
118	3	Corn___healthy	0.4774	Great plant health! Monitor for pest damage and maintain consistent soil moisture during pollination.	\N	2026-04-22 14:05:46.722461
119	3	Peach___Bacterial_spot	0.9987	Apply copper hydroxide or oxytetracycline during bloom. Avoid overhead irrigation to reduce leaf wetness periods.	\N	2026-04-22 14:06:24.734772
120	3	Apple___Cedar_apple_rust	0.9052	Apply protective fungicide sprays from pink bud through petal fall. Use rust-resistant apple varieties for new plantings.	\N	2026-04-22 14:28:15.428714
121	3	Strawberry___Leaf_scorch	0.8333	Avoid overhead irrigation. Apply copper-based fungicide during the renovation period after harvest.	\N	2026-04-22 14:28:24.214975
122	3	Background_without_leaves	0.9977	Image does not contain a recognizable leaf. Ensure good lighting and focus the camera directly on the leaf.	\N	2026-04-22 14:28:41.567848
123	3	Tomato___Septoria_leaf_spot	0.3979	Apply chlorothalonil or mancozeb at first spotting. Remove infected lower leaves to slow upward disease spread.	\N	2026-04-22 14:28:48.482985
124	3	Tomato___Late_blight	0.9629	Apply metalaxyl + mancozeb immediately. Remove and bag all infected plant material — do not compost.	\N	2026-04-22 14:28:56.576803
125	3	Background_without_leaves	0.9999	Image does not contain a recognizable leaf. Ensure good lighting and focus the camera directly on the leaf.	\N	2026-04-22 14:30:21.532706
126	3	Blueberry___healthy	0.2832	Blueberry plant looks healthy! Maintain soil pH between 4.5-5.5 for optimal nutrient uptake.	\N	2026-04-22 14:32:14.817072
127	3	Apple___healthy	0.9998	Your apple tree looks healthy! Maintain regular pruning to improve air circulation and light penetration.	\N	2026-04-22 14:32:53.035954
128	3	Blueberry___healthy	0.9464	Plant is thriving. Ensure adequate irrigation during fruit development and fertilize with acid-forming fertilizers.	\N	2026-04-22 14:33:34.873901
129	3	Corn___healthy	0.4876	Great plant health! Monitor for pest damage and maintain consistent soil moisture during pollination.	\N	2026-04-22 14:36:37.193263
130	3	Corn___Cercospora_leaf_spot Gray_leaf_spot	0.6622	Apply fungicide (azoxystrobin or propiconazole) when lesions first appear. Maintain proper plant spacing for airflow.	\N	2026-04-22 14:36:47.827951
131	3	Apple___Apple_scab	0.9116	Use resistant apple varieties when replanting. Rake and compost infected leaves away from the orchard.	\N	2026-04-22 14:37:04.412082
132	3	Apple___Apple_scab	0.8096	Use resistant apple varieties when replanting. Rake and compost infected leaves away from the orchard.	\N	2026-04-22 14:37:45.817844
133	3	Potato___Late_blight	0.9515	Apply systemic fungicide (metalaxyl + mancozeb) immediately. Destroy infected plant material — do NOT compost.	\N	2026-04-22 14:39:29.343673
134	3	Apple___Apple_scab	0.8096	Prune trees to improve air circulation. Apply protective fungicide sprays before and after rain events during spring.	\N	2026-04-22 14:39:36.732975
135	3	Apple___healthy	0.9760	Great condition! Apply balanced fertilizer in early spring and ensure consistent watering during dry periods.	\N	2026-04-22 14:40:24.596216
136	3	Apple___healthy	0.9883	Your apple tree looks healthy! Maintain regular pruning to improve air circulation and light penetration.	\N	2026-04-22 14:40:47.348849
137	3	Corn___Cercospora_leaf_spot Gray_leaf_spot	0.9906	Use resistant hybrid varieties. Tillage to bury infected residue reduces overwintering inoculum significantly.	\N	2026-04-22 14:41:31.638378
138	3	Corn___healthy	0.8599	Healthy crop detected. Continue scouting for early disease signs and maintain recommended plant population.	\N	2026-04-22 14:42:13.066964
139	3	Corn___healthy	0.6859	Healthy crop detected. Continue scouting for early disease signs and maintain recommended plant population.	\N	2026-04-22 14:42:22.272251
140	3	Corn___Cercospora_leaf_spot Gray_leaf_spot	0.5809	Use resistant hybrid varieties. Tillage to bury infected residue reduces overwintering inoculum significantly.	\N	2026-04-22 14:42:41.279656
141	3	Corn___healthy	1.0000	Corn looks healthy! Ensure adequate nitrogen fertilization at V6 stage for optimal ear development.	\N	2026-04-22 14:43:52.345032
142	3	Background_without_leaves	0.9773	Please retake the photo with a single leaf filling most of the frame for better analysis results.	\N	2026-04-22 14:44:07.466282
143	3	Corn___healthy	0.9735	Great plant health! Monitor for pest damage and maintain consistent soil moisture during pollination.	\N	2026-04-22 14:44:23.491011
144	3	Corn___Common_rust	0.9922	Fungicide application is most effective before tasseling. Use mancozeb or triazole-based products at first sign.	\N	2026-04-22 14:45:08.906912
145	3	Corn___Common_rust	0.9999	Plant rust-resistant corn hybrids. Scout fields regularly and apply fungicide before disease spreads to upper canopy.	\N	2026-04-22 14:45:46.911132
146	3	Corn___Common_rust	0.7957	Fungicide application is most effective before tasseling. Use mancozeb or triazole-based products at first sign.	\N	2026-04-22 14:46:02.346544
147	3	Corn___Northern_Leaf_Blight	0.9850	Apply fungicide (azoxystrobin, propiconazole) at early tasseling if blight appears on lower leaves.	\N	2026-04-22 14:47:43.221812
148	3	Corn___Cercospora_leaf_spot Gray_leaf_spot	0.8936	Apply strobilurin or triazole fungicide at early tassel stage. Rotate crops — avoid planting corn after corn.	\N	2026-04-22 14:48:06.100991
149	3	Corn___Northern_Leaf_Blight	0.6561	Rotate crops and till infected debris. Use resistant hybrids rated for Northern Leaf Blight tolerance.	\N	2026-04-22 14:48:31.788554
150	3	Grape___healthy	0.5581	Healthy vine detected. Continue canopy management and monitor for powdery and downy mildew during humid periods.	\N	2026-04-22 14:49:25.970223
151	3	Grape___Black_rot	0.9765	Prune heavily to improve air circulation. Apply protective fungicide every 7-10 days during wet spring weather.	\N	2026-04-22 14:49:57.977571
152	3	Grape___Black_rot	0.9948	Remove all infected plant material from the vineyard. Apply triazole fungicide at fruit set and berry touch stages.	\N	2026-04-22 14:50:06.758713
153	3	Background_without_leaves	0.9994	No plant detected in the image. Please take a clear photo of a plant leaf for accurate disease detection.	\N	2026-04-22 15:02:49.318691
154	3	Squash___Powdery_mildew	0.5257	Apply neem oil or horticultural oil spray in early morning. Remove severely infected leaves promptly.	\N	2026-04-22 15:03:17.431377
155	3	Strawberry___Leaf_scorch	0.9978	Avoid overhead irrigation. Apply copper-based fungicide during the renovation period after harvest.	\N	2026-04-22 15:03:40.697846
156	3	Grape___Esca_(Black_Measles)	1.0000	No curative treatment available. Remove and destroy infected wood. Paint pruning wounds with fungicidal paste.	\N	2026-04-22 15:04:44.436481
157	3	Grape___Esca_(Black_Measles)	1.0000	Improve vine nutrition and reduce water stress. Remove severely infected vines to prevent spread to healthy plants.	\N	2026-04-22 15:05:02.299599
158	3	Grape___Esca_(Black_Measles)	0.9993	No curative treatment available. Remove and destroy infected wood. Paint pruning wounds with fungicidal paste.	\N	2026-04-22 15:05:16.136079
159	3	Soybean___healthy	0.5080	Soybean crop looks excellent! Ensure adequate phosphorus and potassium for optimal pod fill.	\N	2026-04-22 15:06:27.670794
160	3	Grape___healthy	0.9956	Grapevine looks excellent! Maintain balanced nutrition with potassium and magnesium for optimal berry quality.	\N	2026-04-22 15:06:38.884677
161	3	Background_without_leaves	0.9052	Please retake the photo with a single leaf filling most of the frame for better analysis results.	\N	2026-04-22 15:07:00.664313
162	3	Potato___Late_blight	0.5738	Remove and destroy entire infected plants including tubers. Apply fungicide on 5-7 day intervals during cool, wet weather.	\N	2026-04-22 15:07:19.933647
163	3	Grape___Leaf_blight_(Isariopsis_Leaf_Spot)	1.0000	Apply fungicide sprays after rain events. Remove heavily infected leaves to slow disease progression.	\N	2026-04-22 15:07:48.580313
164	3	Grape___Leaf_blight_(Isariopsis_Leaf_Spot)	1.0000	Apply copper-based fungicide or mancozeb at first sign of angular brown lesions on leaves.	\N	2026-04-22 15:08:15.396071
165	3	Tomato___Late_blight	0.9467	Apply metalaxyl + mancozeb immediately. Remove and bag all infected plant material — do not compost.	\N	2026-04-22 15:09:41.662879
166	3	Background_without_leaves	0.9994	Please retake the photo with a single leaf filling most of the frame for better analysis results.	\N	2026-04-22 15:09:57.572603
167	3	Grape___healthy	0.9475	Grapevine looks excellent! Maintain balanced nutrition with potassium and magnesium for optimal berry quality.	\N	2026-04-22 15:10:05.989273
168	3	Grape___healthy	1.0000	Great condition! Ensure proper shoot thinning and leaf removal around the fruit zone for disease prevention.	\N	2026-04-22 15:10:21.974638
169	3	Orange___Haunglongbing_(Citrus_greening)	0.6100	Use psyllid monitoring traps throughout the orchard. Apply insecticide to control psyllid populations. Report to local authorities.	\N	2026-04-22 15:11:46.769065
170	3	Tomato___Late_blight	0.3312	Destroy infected plants to prevent spread. Apply copper-based fungicide as protective measure in neighboring plants.	\N	2026-04-22 15:13:05.0452
171	3	Orange___Haunglongbing_(Citrus_greening)	0.4052	Use psyllid monitoring traps throughout the orchard. Apply insecticide to control psyllid populations. Report to local authorities.	\N	2026-04-22 15:13:35.312661
172	3	Peach___Bacterial_spot	0.9993	Prune to improve air circulation. Apply fixed copper sprays before rain events during the growing season.	\N	2026-04-22 15:15:15.264388
173	3	Peach___Bacterial_spot	0.4668	Plant resistant peach varieties. Apply copper bactericide at shuck split and continue on 7-14 day intervals.	\N	2026-04-22 15:15:53.312042
174	3	Peach___Bacterial_spot	0.7968	Prune to improve air circulation. Apply fixed copper sprays before rain events during the growing season.	\N	2026-04-22 15:16:15.268187
175	3	Peach___Bacterial_spot	0.7279	Plant resistant peach varieties. Apply copper bactericide at shuck split and continue on 7-14 day intervals.	\N	2026-04-22 15:17:16.730355
176	3	Peach___Bacterial_spot	0.3384	Prune to improve air circulation. Apply fixed copper sprays before rain events during the growing season.	\N	2026-04-22 15:17:38.335603
177	3	Background_without_leaves	0.9999	No plant detected in the image. Please take a clear photo of a plant leaf for accurate disease detection.	\N	2026-04-22 15:18:13.128592
178	3	Orange___Haunglongbing_(Citrus_greening)	0.3317	No cure exists. Remove and destroy infected trees immediately to prevent spread to healthy citrus.	\N	2026-04-22 15:18:36.463153
179	3	Background_without_leaves	0.9945	Please retake the photo with a single leaf filling most of the frame for better analysis results.	\N	2026-04-22 15:19:11.092366
180	3	Corn___healthy	0.4774	Healthy crop detected. Continue scouting for early disease signs and maintain recommended plant population.	\N	2026-04-22 15:21:12.01751
181	3	Tomato___Septoria_leaf_spot	0.7431	Mulch to prevent soil splash. Apply copper fungicide every 7-10 days during wet weather conditions.	\N	2026-04-22 15:21:22.3821
182	3	Background_without_leaves	0.7371	Image does not contain a recognizable leaf. Ensure good lighting and focus the camera directly on the leaf.	\N	2026-04-22 15:22:14.619593
183	3	Pepper,_bell___Bacterial_spot	0.9955	Use certified disease-free transplants. Apply copper bactericide every 5-7 days during warm, wet weather.	\N	2026-04-22 15:22:37.414604
184	3	Tomato___Septoria_leaf_spot	0.3341	Apply chlorothalonil or mancozeb at first spotting. Remove infected lower leaves to slow upward disease spread.	\N	2026-04-22 15:23:08.462462
185	3	Corn___healthy	0.4286	Healthy crop detected. Continue scouting for early disease signs and maintain recommended plant population.	\N	2026-04-22 15:24:34.236471
186	3	Orange___Haunglongbing_(Citrus_greening)	0.5064	No cure exists. Remove and destroy infected trees immediately to prevent spread to healthy citrus.	\N	2026-04-22 15:24:55.024842
187	3	Corn___healthy	1.0000	Great plant health! Monitor for pest damage and maintain consistent soil moisture during pollination.	\N	2026-04-22 15:25:16.425042
188	3	Strawberry___Leaf_scorch	0.9926	Avoid overhead irrigation. Apply copper-based fungicide during the renovation period after harvest.	\N	2026-04-22 15:27:12.998777
189	3	Potato___Early_blight	0.9563	Maintain adequate potassium levels — deficiency increases susceptibility. Apply fungicide on 7-day intervals during wet weather.	\N	2026-04-22 15:27:23.329712
190	3	Potato___Early_blight	0.9183	Apply chlorothalonil or mancozeb fungicide at first lesion appearance. Remove lower leaves touching the soil.	\N	2026-04-22 15:27:31.668775
191	3	Potato___Early_blight	0.8141	Maintain adequate potassium levels — deficiency increases susceptibility. Apply fungicide on 7-day intervals during wet weather.	\N	2026-04-22 15:28:36.112585
192	3	Potato___Early_blight	0.5881	Maintain adequate potassium levels — deficiency increases susceptibility. Apply fungicide on 7-day intervals during wet weather.	\N	2026-04-22 15:28:52.318515
193	3	Potato___Late_blight	0.8151	Remove and destroy entire infected plants including tubers. Apply fungicide on 5-7 day intervals during cool, wet weather.	\N	2026-04-22 15:29:10.957515
194	3	Background_without_leaves	0.9978	Please retake the photo with a single leaf filling most of the frame for better analysis results.	\N	2026-04-22 15:30:33.286446
195	3	Potato___Early_blight	0.9879	Rotate crops for 3 years minimum. Apply preventive fungicide sprays starting at row closure stage.	\N	2026-04-22 15:30:52.198168
196	3	Blueberry___healthy	0.9298	Plant is thriving. Ensure adequate irrigation during fruit development and fertilize with acid-forming fertilizers.	\N	2026-04-22 15:31:57.628796
197	3	Background_without_leaves	0.3878	Please retake the photo with a single leaf filling most of the frame for better analysis results.	\N	2026-04-22 15:32:12.595634
198	3	Background_without_leaves	0.9941	Please retake the photo with a single leaf filling most of the frame for better analysis results.	\N	2026-04-22 15:32:28.387001
199	3	Potato___healthy	0.9941	Great condition! Ensure consistent moisture — irregular watering causes common scab and hollow heart disorders.	\N	2026-04-22 15:32:54.753959
200	3	Potato___healthy	0.9968	Potato plant looks healthy! Hill soil around stems to prevent tuber greening and improve yield.	\N	2026-04-22 15:33:09.405203
201	3	Background_without_leaves	0.9918	Image does not contain a recognizable leaf. Ensure good lighting and focus the camera directly on the leaf.	\N	2026-04-22 15:34:06.84661
202	3	Raspberry___healthy	0.9993	Raspberry canes are healthy! Remove spent fruiting canes after harvest to encourage new primocane growth.	\N	2026-04-22 15:34:47.067358
203	3	Background_without_leaves	0.9899	No plant detected in the image. Please take a clear photo of a plant leaf for accurate disease detection.	\N	2026-04-22 15:35:15.599979
204	3	Blueberry___healthy	0.3155	Excellent condition! Mulch with pine bark to maintain acidity and moisture. Prune old canes annually.	\N	2026-04-22 15:36:54.634826
205	3	Potato___Late_blight	0.5000	Avoid overhead irrigation. Apply protectant fungicide (chlorothalonil) before rain and systemic after infection is confirmed.	\N	2026-04-22 15:37:24.503153
206	3	Blueberry___healthy	0.2501	Plant is thriving. Ensure adequate irrigation during fruit development and fertilize with acid-forming fertilizers.	\N	2026-04-22 15:38:06.692085
207	3	Grape___healthy	0.9836	Great condition! Ensure proper shoot thinning and leaf removal around the fruit zone for disease prevention.	\N	2026-04-22 15:38:21.531478
208	3	Strawberry___Leaf_scorch	1.0000	Renovate strawberry beds after harvest — mow foliage, narrow rows, apply fungicide to encourage healthy regrowth.	\N	2026-04-22 15:42:18.539006
209	3	Blueberry___healthy	0.2501	Excellent condition! Mulch with pine bark to maintain acidity and moisture. Prune old canes annually.	\N	2026-04-22 15:42:26.992389
210	3	Strawberry___Leaf_scorch	0.9996	Renovate strawberry beds after harvest — mow foliage, narrow rows, apply fungicide to encourage healthy regrowth.	\N	2026-04-22 15:42:42.340159
211	3	Apple___Apple_scab	0.9993	Use resistant apple varieties when replanting. Rake and compost infected leaves away from the orchard.	\N	2026-04-22 15:44:04.706978
212	3	Apple___Apple_scab	0.9993	Apply fungicides (myclobutanil or captan) at early leaf development. Remove and destroy fallen leaves to reduce overwintering spores.	\N	2026-04-22 15:44:23.315366
213	3	Grape___Black_rot	0.9233	Prune heavily to improve air circulation. Apply protective fungicide every 7-10 days during wet spring weather.	\N	2026-04-22 15:44:45.119134
214	3	Grape___Black_rot	0.9233	Prune heavily to improve air circulation. Apply protective fungicide every 7-10 days during wet spring weather.	\N	2026-04-22 15:45:24.634933
215	3	Potato___Early_blight	0.4678	Apply chlorothalonil or mancozeb fungicide at first lesion appearance. Remove lower leaves touching the soil.	\N	2026-04-22 15:46:42.407414
216	3	Background_without_leaves	0.9999	No plant detected in the image. Please take a clear photo of a plant leaf for accurate disease detection.	\N	2026-04-22 15:47:10.646114
217	3	Corn___Northern_Leaf_Blight	0.7409	Scout fields from V8 stage onward. Apply fungicide if blight reaches third leaf from ear before silking.	\N	2026-04-22 15:47:25.017193
218	3	Tomato___Late_blight	0.8613	Destroy infected plants to prevent spread. Apply copper-based fungicide as protective measure in neighboring plants.	\N	2026-04-22 15:48:17.808561
219	3	Background_without_leaves	0.9829	No plant detected in the image. Please take a clear photo of a plant leaf for accurate disease detection.	\N	2026-04-22 15:51:38.101442
220	3	Tomato___Leaf_Mold	0.9980	Improve ventilation in greenhouses. Remove infected leaves promptly. Apply mancozeb or thiram fungicide preventively.	\N	2026-04-22 15:52:28.059911
221	3	Potato___Late_blight	0.9686	Avoid overhead irrigation. Apply protectant fungicide (chlorothalonil) before rain and systemic after infection is confirmed.	\N	2026-04-22 15:53:08.788575
222	3	Tomato___Leaf_Mold	0.7736	Space plants adequately for airflow. Avoid leaf wetness through drip irrigation instead of overhead sprinklers.	\N	2026-04-22 15:53:14.818085
223	3	Pepper,_bell___Bacterial_spot	0.4406	Remove and destroy heavily infected plants. Rotate with non-solanaceous crops for at least 2 years.	\N	2026-04-22 15:58:14.53873
224	3	Tomato___Late_blight	0.6344	Destroy infected plants to prevent spread. Apply copper-based fungicide as protective measure in neighboring plants.	\N	2026-04-22 15:58:34.027686
225	3	Corn___Common_rust	0.4511	Apply foliar fungicide (propiconazole or azoxystrobin) when rust pustules first appear on lower leaves.	\N	2026-04-22 15:59:25.517696
226	3	Background_without_leaves	1.0000	Please retake the photo with a single leaf filling most of the frame for better analysis results.	\N	2026-04-22 16:00:48.209952
227	3	Background_without_leaves	1.0000	Please retake the photo with a single leaf filling most of the frame for better analysis results.	\N	2026-04-22 16:01:20.596091
228	3	Background_without_leaves	0.6376	No plant detected in the image. Please take a clear photo of a plant leaf for accurate disease detection.	\N	2026-04-22 16:01:47.102458
229	3	Pepper,_bell___Bacterial_spot	0.7945	Apply copper + mancozeb tank mix at first sign of water-soaked lesions. Avoid working in wet fields.	\N	2026-04-22 16:02:02.276703
230	3	Strawberry___Leaf_scorch	0.4028	Avoid overhead irrigation. Apply copper-based fungicide during the renovation period after harvest.	\N	2026-04-22 16:04:19.835273
231	3	Background_without_leaves	0.4298	No plant detected in the image. Please take a clear photo of a plant leaf for accurate disease detection.	\N	2026-04-22 16:04:47.67971
232	3	Background_without_leaves	0.5717	No plant detected in the image. Please take a clear photo of a plant leaf for accurate disease detection.	\N	2026-04-22 16:05:01.572162
233	3	Tomato___Late_blight	0.6945	Destroy infected plants to prevent spread. Apply copper-based fungicide as protective measure in neighboring plants.	\N	2026-04-22 16:05:34.951094
234	3	Tomato___Bacterial_spot	0.8767	Apply copper + mancozeb bactericide spray every 5-7 days. Avoid working in the field when plants are wet.	\N	2026-04-22 16:06:01.62919
235	3	Strawberry___Leaf_scorch	0.9999	Renovate strawberry beds after harvest — mow foliage, narrow rows, apply fungicide to encourage healthy regrowth.	\N	2026-04-22 16:16:33.341206
236	3	Pepper,_bell___healthy	0.5778	Excellent condition. Monitor for aphids and thrips which can transmit viral diseases to healthy plants.	\N	2026-04-22 16:17:03.306085
237	3	Pepper,_bell___healthy	0.5778	Healthy plant! Stake plants to improve air circulation. Side-dress with balanced fertilizer at first fruit set.	\N	2026-04-22 16:17:19.42629
238	3	Tomato___Late_blight	0.9903	Apply protectant fungicide before rain events. Avoid overhead irrigation and work in fields only when dry.	\N	2026-04-22 16:18:19.069523
239	3	Tomato___Late_blight	0.7095	Apply metalaxyl + mancozeb immediately. Remove and bag all infected plant material — do not compost.	\N	2026-04-22 16:18:34.777909
240	3	Tomato___Late_blight	0.7095	Destroy infected plants to prevent spread. Apply copper-based fungicide as protective measure in neighboring plants.	\N	2026-04-22 16:18:57.89172
241	3	Tomato___Late_blight	0.9852	Apply metalaxyl + mancozeb immediately. Remove and bag all infected plant material — do not compost.	\N	2026-04-22 16:19:17.755064
242	3	Soybean___healthy	0.9197	Soybean crop looks excellent! Ensure adequate phosphorus and potassium for optimal pod fill.	\N	2026-04-22 16:19:41.516155
243	3	Background_without_leaves	0.2292	Image does not contain a recognizable leaf. Ensure good lighting and focus the camera directly on the leaf.	\N	2026-04-22 16:19:50.623332
244	3	Squash___Powdery_mildew	0.4590	Apply neem oil or horticultural oil spray in early morning. Remove severely infected leaves promptly.	\N	2026-04-22 16:19:56.553606
245	3	Pepper,_bell___Bacterial_spot	0.9235	Remove and destroy heavily infected plants. Rotate with non-solanaceous crops for at least 2 years.	\N	2026-04-22 16:20:17.299045
246	3	Strawberry___Leaf_scorch	0.9883	Avoid overhead irrigation. Apply copper-based fungicide during the renovation period after harvest.	\N	2026-04-22 16:20:28.742229
247	3	Corn___healthy	0.6859	Corn looks healthy! Ensure adequate nitrogen fertilization at V6 stage for optimal ear development.	\N	2026-04-22 16:20:46.31148
248	3	Background_without_leaves	0.9999	Veuillez reprendre la photo avec une seule feuille remplissant la majeure partie du cadre pour de meilleurs résultats.	\N	2026-04-24 03:42:00.070533
249	3	Tomato___Late_blight	0.8613	Appliquer immédiatement du métalaxyl + mancozèbe. Retirer et emballer tous les matériaux végétaux infectés — ne pas composter.	\N	2026-04-24 03:42:07.072292
\.


--
-- Data for Name: plant_prices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.plant_prices (id, plant_name, category, price, unit, created_at, updated_at) FROM stdin;
17	Tomate	Légumes	5.00	kg	2026-04-24 16:17:15.390671	2026-04-24 16:17:15.390671
18	Figue	Fruits	5.00	kg	2026-04-24 16:17:35.154333	2026-04-24 16:17:35.154333
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.products (id, name, name_fr, name_ar, price, category, category_fr, category_ar, description, description_fr, description_ar, image_url, stock_available, created_at, description_en) FROM stdin;
1	Profast	Profast	بروفاست	32.000	Insecticide	Insecticide	مبيد حشري	Insecticide systémique à large spectre	Insecticide systémique à large spectre	مبيد حشري جهازي واسع الطيف	/uploads/products/profast.jpg	t	2026-04-19 22:08:17.075544	Broad-spectrum systemic insecticide
2	Spinozar	Spinozar	سبينوزار	50.000	Insecticide	Insecticide	مبيد حشري	Insecticide biologique à base de spinosad	Insecticide biologique à base de spinosad	مبيد حشري بيولوجي على أساس السبينوساد	/uploads/products/spinozar.jpg	t	2026-04-19 22:08:17.075544	Biological insecticide based on spinosad
3	Takumi	Takumi	تاكومي	88.000	Insecticide	Insecticide	مبيد حشري	Insecticide contre les acariens et thrips	Insecticide contre les acariens et thrips	مبيد حشري ضد العث والتربس	/uploads/products/takumi.jpg	t	2026-04-19 22:08:17.075544	Insecticide against mites and thrips
4	Besiege	Besiege	بيسيج	50.000	Insecticide	Insecticide	مبيد حشري	Insecticide mixte contre chenilles et pucerons	Insecticide mixte contre chenilles et pucerons	مبيد حشري مزدوج ضد اليرقات وحشرات المن	/uploads/products/besiege.jpg	t	2026-04-19 22:08:17.075544	Mixed insecticide against caterpillars and aphids
5	Calypso	Calypso	كاليبسو	67.000	Insecticide	Insecticide	مبيد حشري	Insecticide systémique contre pucerons	Insecticide systémique contre pucerons	مبيد حشري جهازي ضد حشرات المن	/uploads/products/calypso.jpg	t	2026-04-19 22:08:17.075544	Systemic insecticide against aphids
6	Lathrin	Lathrin	لاثرين	35.000	Insecticide	Insecticide	مبيد حشري	Insecticide pyréthrinoïde de contact	Insecticide pyréthrinoïde de contact	مبيد حشري بيريثرويد للتطبيق المباشر	/uploads/products/lathrin.jpg	t	2026-04-19 22:08:17.075544	Pyrethroid contact insecticide
7	Bonbard	Bonbard	بونبارد	45.000	Insecticide	Insecticide	مبيد حشري	Insecticide contre les coléoptères	Insecticide contre les coléoptères	مبيد حشري ضد الخنافس	/uploads/products/bonbard.jpg	t	2026-04-19 22:08:17.075544	Insecticide against beetles and coleoptera
8	Delta	Delta	دلتا	138.000	Insecticide	Insecticide	مبيد حشري	Insecticide puissant à large spectre	Insecticide puissant à large spectre	مبيد حشري قوي واسع الطيف	/uploads/products/delta.jpg	t	2026-04-19 22:08:17.075544	Powerful broad-spectrum insecticide
31	Aggis	Aggis	أغيس	60.000	Insecticide	Insecticide	مبيد حشري	Insecticide contre thrips et acariens	Insecticide contre thrips et acariens	مبيد حشري ضد التربس والعث	/uploads/products/aggis.jpg	t	2026-04-19 22:08:17.075544	Insecticide against thrips and spider mites
33	Volteo	Volteo	فولتيو	75.000	Insecticide	Insecticide	مبيد حشري	Insecticide contre mouches blanches	Insecticide contre mouches blanches	مبيد حشري ضد الذبابة البيضاء	/uploads/products/volteo.jpg	t	2026-04-19 22:08:17.075544	Insecticide against whiteflies
40	Belthirul	Belthirul	بيلثيرول	35.000	Insecticide	Insecticide	مبيد حشري	Insecticide biologique BT	Insecticide biologique BT	مبيد حشري بيولوجي BT	/uploads/products/belthirul.jpg	t	2026-04-19 22:08:17.075544	Biological BT insecticide
42	Rufast	Rufast	روفاست	175.000	Insecticide	Insecticide	مبيد حشري	Insecticide systémique haute efficacité	Insecticide systémique haute efficacité	مبيد حشري جهازي عالي الفعالية	/uploads/products/rufast.jpg	t	2026-04-19 22:08:17.075544	High-efficiency systemic insecticide
43	Cypgold	Cypgold	سيبغولد	65.000	Insecticide	Insecticide	مبيد حشري	Insecticide pyréthrinoïde contact	Insecticide pyréthrinoïde contact	مبيد حشري بيريثرويد بالتلامس	/uploads/products/cypgold.jpg	t	2026-04-19 22:08:17.075544	Pyrethroid contact insecticide
44	Kung Fu 10 CS (Syngenta)	Kung Fu 10 CS (Syngenta)	كونغ فو 10 CS (سينجنتا)	95.000	Insecticide	Insecticide	مبيد حشري	Insecticide encapsulé longue durée	Insecticide encapsulé longue durée	مبيد حشري مغلف طويل المفعول	/uploads/products/kung_fu.jpg	t	2026-04-19 22:08:17.075544	Long-lasting encapsulated insecticide
48	Decis Expert (Bayer)	Decis Expert (Bayer)	ديسيس إكسبرت (باير)	115.000	Insecticide	Insecticide	مبيد حشري	Insecticide deltaméthrine haute concentration	Insecticide deltaméthrine haute concentration	مبيد حشري ديلتامثرين عالي التركيز	/uploads/products/decis_expert.jpg	t	2026-04-19 22:08:17.075544	High-concentration deltamethrin insecticide
49	Sinocyper	Sinocyper	سينوسيبر	65.000	Insecticide	Insecticide	مبيد حشري	Insecticide cyperméthrine contact	Insecticide cyperméthrine contact	مبيد حشري سيبيرمثرين بالتلامس	/uploads/products/sinocyper.jpg	t	2026-04-19 22:08:17.075544	Cypermethrin contact insecticide
51	Voliam Targo (Syngenta)	Voliam Targo (Syngenta)	فوليام تارغو (سينجنتا)	40.000	Insecticide	Insecticide	مبيد حشري	Insecticide acaricide mixte	Insecticide acaricide mixte	مبيد حشري وعث مزدوج	/uploads/products/voliam_targo.jpg	t	2026-04-19 22:08:17.075544	Mixed insecticide-acaricide
52	Movento (Bayer)	Movento (Bayer)	موفينتو (باير)	60.000	Insecticide	Insecticide	مبيد حشري	Insecticide systémique bidirectionnel	Insecticide systémique bidirectionnel	مبيد حشري جهازي ثنائي الاتجاه	/uploads/products/movento.jpg	t	2026-04-19 22:08:17.075544	Bidirectional systemic insecticide
53	Match 050 EC (Syngenta)	Match 050 EC (Syngenta)	ماتش 050 EC (سينجنتا)	80.000	Insecticide	Insecticide	مبيد حشري	Régulateur de croissance insectes	Régulateur de croissance insectes	منظم نمو الحشرات	/uploads/products/match.jpg	t	2026-04-19 22:08:17.075544	Insect growth regulator
9	Kocide 2000	Kocide 2000	كوسيد 2000	80.000	Fongicide	Fongicide	مبيد فطري	Fongicide à base de cuivre hydroxyde	Fongicide à base de cuivre hydroxyde	مبيد فطري على أساس هيدروكسيد النحاس	/uploads/products/kocide_2000.jpg	t	2026-04-19 22:08:17.075544	Copper hydroxide-based fungicide
10	Aliette WG (Bayer)	Aliette WG (Bayer)	أليت WG (باير)	50.000	Fongicide	Fongicide	مبيد فطري	Fongicide systémique contre mildiou	Fongicide systémique contre mildiou	مبيد فطري جهازي ضد البياض الزغبي	/uploads/products/aliette.jpg	t	2026-04-19 22:08:17.075544	Systemic fungicide against downy mildew
11	Azumo	Azumo	أزومو	35.000	Fongicide	Fongicide	مبيد فطري	Fongicide triazole à large spectre	Fongicide triazole à large spectre	مبيد فطري ترايازول واسع الطيف	/uploads/products/azumo.jpg	t	2026-04-19 22:08:17.075544	Broad-spectrum triazole fungicide
12	Stin	Stin	ستين	40.000	Fongicide	Fongicide	مبيد فطري	Fongicide contre maladies foliaires	Fongicide contre maladies foliaires	مبيد فطري ضد الأمراض الورقية	/uploads/products/stin.jpg	t	2026-04-19 22:08:17.075544	Fungicide against foliar diseases
13	Cuprofix	Cuprofix	كوبروفيكس	50.000	Fongicide	Fongicide	مبيد فطري	Fongicide cuivrique de contact	Fongicide cuivrique de contact	مبيد فطري نحاسي بالتلامس	/uploads/products/cuprofix.jpg	t	2026-04-19 22:08:17.075544	Copper contact fungicide
14	Cyclo R Liquide	Cyclo R Liquide	سيكلو R سائل	40.000	Fongicide	Fongicide	مبيد فطري	Fongicide systémique liquide	Fongicide systémique liquide	مبيد فطري جهازي سائل	/uploads/products/cyclo_r_liquide.jpg	t	2026-04-19 22:08:17.075544	Systemic liquid fungicide
15	Pristine	Pristine	بريستين	60.000	Fongicide	Fongicide	مبيد فطري	Fongicide mixte contre botrytis et oïdium	Fongicide mixte contre botrytis et oïdium	مبيد فطري مزدوج ضد البوتريتيس والبياض الدقيقي	/uploads/products/pristine.jpg	t	2026-04-19 22:08:17.075544	Mixed fungicide against botrytis and powdery mildew
16	Evito	Evito	إيفيتو	160.000	Fongicide	Fongicide	مبيد فطري	Fongicide triazole haute performance	Fongicide triazole haute performance	مبيد فطري ترايازول عالي الأداء	/uploads/products/evito.jpg	t	2026-04-19 22:08:17.075544	High-performance triazole fungicide
25	Cropshield	Cropshield	كروبشيلد	50.000	Fongicide	Fongicide	مبيد فطري	Fongicide protecteur polyvalent	Fongicide protecteur polyvalent	مبيد فطري وقائي متعدد الاستخدامات	/uploads/products/cropshield.jpg	t	2026-04-19 22:08:17.075544	Versatile protective fungicide
29	Feuraci	Feuraci	فيوراسي	65.000	Fongicide	Fongicide	مبيد فطري	Fongicide contre rouille et mildiou	Fongicide contre rouille et mildiou	مبيد فطري ضد الصدأ والبياض الزغبي	/uploads/products/feuraci.jpg	t	2026-04-19 22:08:17.075544	Fungicide against rust and downy mildew
41	Preza	Preza	بريزا	120.000	Fongicide	Fongicide	مبيد فطري	Fongicide SDHI contre septoria	Fongicide SDHI contre septoria	مبيد فطري SDHI ضد مرض سبتوريا	/uploads/products/preza.jpg	t	2026-04-19 22:08:17.075544	SDHI fungicide against septoria
36	Orondis Ultra (Syngenta)	Orondis Ultra (Syngenta)	أوروندس ألترا (سينجنتا)	130.000	Fongicide	Fongicide	مبيد فطري	Fongicide contre mildiou avancé	Fongicide contre mildiou avancé	مبيد فطري متقدم ضد البياض الزغبي	/uploads/products/orondis_ultra.jpg	t	2026-04-19 22:08:17.075544	Advanced fungicide against downy mildew
37	Ortiva Top	Ortiva Top	أورتيفا توب	370.000	Fongicide	Fongicide	مبيد فطري	Fongicide mixte premium	Fongicide mixte premium	مبيد فطري مزدوج عالي الجودة	/uploads/products/ortiva_top.jpg	t	2026-04-19 22:08:17.075544	Premium mixed fungicide
38	Volare	Volare	فولاري	220.000	Fongicide	Fongicide	مبيد فطري	Fongicide contre oïdium et mildiou	Fongicide contre oïdium et mildiou	مبيد فطري ضد البياض الدقيقي والزغبي	/uploads/products/volare.jpg	t	2026-04-19 22:08:17.075544	Fungicide against powdery and downy mildew
39	Previcure	Previcure	بريفيكور	45.000	Fongicide	Fongicide	مبيد فطري	Fongicide systémique contre pythium	Fongicide systémique contre pythium	مبيد فطري جهازي ضد البيثيوم	/uploads/products/previcure.jpg	t	2026-04-19 22:08:17.075544	Systemic fungicide against pythium
54	Score 250 EC (Syngenta)	Score 250 EC (Syngenta)	سكور 250 EC (سينجنتا)	103.000	Fongicide	Fongicide	مبيد فطري	Fongicide triazole contre tavelure	Fongicide triazole contre tavelure	مبيد فطري ترايازول ضد الجرب	/uploads/products/score.jpg	t	2026-04-19 22:08:17.075544	Triazole fungicide against apple scab
55	Infinito (Bayer)	Infinito (Bayer)	إنفينيتو (باير)	130.000	Fongicide	Fongicide	مبيد فطري	Fongicide contre mildiou pomme de terre	Fongicide contre mildiou pomme de terre	مبيد فطري ضد لفحة البطاطا المتأخرة	/uploads/products/infinito.jpg	t	2026-04-19 22:08:17.075544	Fungicide against potato late blight
45	Bolido	Bolido	بوليدو	126.000	Fongicide	Fongicide	مبيد فطري	Fongicide contre helminthosporiose	Fongicide contre helminthosporiose	مبيد فطري ضد الهلمينثوسبوريوز	/uploads/products/bolido.jpg	t	2026-04-19 22:08:17.075544	Fungicide against helminthosporium
46	Acrux SC	Acrux SC	أكروكس SC	45.000	Fongicide	Fongicide	مبيد فطري	Fongicide suspension concentrée	Fongicide suspension concentrée	مبيد فطري معلق مركز	/uploads/products/acrux.jpg	t	2026-04-19 22:08:17.075544	Suspension concentrate fungicide
22	Ergon	Ergon	إيرغون	250.000	Herbicide	Herbicide	مبيد أعشاب	Herbicide sélectif grandes cultures	Herbicide sélectif grandes cultures	مبيد أعشاب انتقائي للمحاصيل الكبيرة	/uploads/products/ergon.jpg	t	2026-04-19 22:08:17.075544	Selective herbicide for large crops
32	Stratos Ultra	Stratos Ultra	ستراتوس ألترا	85.000	Herbicide	Herbicide	مبيد أعشاب	Herbicide sélectif graminées	Herbicide sélectif graminées	مبيد أعشاب انتقائي للنجيليات	/uploads/products/stratos_ultra.jpg	t	2026-04-19 22:08:17.075544	Selective herbicide for grasses
34	Roundup Plus	Roundup Plus	راوندب بلاس	55.000	Herbicide	Herbicide	مبيد أعشاب	Herbicide total glyphosate	Herbicide total glyphosate	مبيد أعشاب شامل على أساس الغليفوسات	/uploads/products/roundup_plus.jpg	t	2026-04-19 22:08:17.075544	Total glyphosate herbicide
57	Traxos (Syngenta)	Traxos (Syngenta)	تراكسوس (سينجنتا)	170.000	Herbicide	Herbicide	مبيد أعشاب	Herbicide contre graminées adventices	Herbicide contre graminées adventices	مبيد أعشاب ضد النجيليات الضارة	/uploads/products/traxos.jpg	t	2026-04-19 22:08:17.075544	Herbicide against adventitious grasses
58	Pallas 45 OD	Pallas 45 OD	باللاس 45 OD	120.000	Herbicide	Herbicide	مبيد أعشاب	Herbicide sélectif céréales	Herbicide sélectif céréales	مبيد أعشاب انتقائي للحبوب	/uploads/products/pallas_45.jpg	t	2026-04-19 22:08:17.075544	Selective herbicide for cereals
17	Manni-Plex K	Manni-Plex K	ماني بليكس K	44.000	Fertilisant	Fertilisant	سماد	Fertilisant potassique foliaire	Fertilisant potassique foliaire	سماد بوتاسيوم ورقي	/uploads/products/manni_plex_k.jpg	t	2026-04-19 22:08:17.075544	Foliar potassium fertilizer
18	Borengel	Borengel	بورنجيل	60.000	Fertilisant	Fertilisant	سماد	Engrais boré en gel	Engrais boré en gel	سماد بوروني جل	/uploads/products/borengel.jpg	t	2026-04-19 22:08:17.075544	Boron gel fertilizer
20	Agrobor	Agrobor	أغروبور	40.000	Fertilisant	Fertilisant	سماد	Fertilisant boré pour cultures	Fertilisant boré pour cultures	سماد بوروني للمحاصيل	/uploads/products/agrobor.jpg	t	2026-04-19 22:08:17.075544	Boron fertilizer for crops
21	RA.AN L13186	RA.AN L13186	RA.AN L13186	90.000	Fertilisant	Fertilisant	سماد	Fertilisant foliaire complexe	Fertilisant foliaire complexe	سماد ورقي مركب	/uploads/products/ra_an_l13186.jpg	t	2026-04-19 22:08:17.075544	Complex foliar fertilizer
23	Boramin	Boramin	بورامين	40.000	Fertilisant	Fertilisant	سماد	Fertilisant boré et azoté	Fertilisant boré et azoté	سماد بوروني وآزوتي	/uploads/products/boramin.jpg	t	2026-04-19 22:08:17.075544	Boron and nitrogen fertilizer
24	Naturquel CA/B	Naturquel CA/B	ناتوركيل CA/B	120.000	Fertilisant	Fertilisant	سماد	Chélate de calcium et bore	Chélate de calcium et bore	كيلات الكالسيوم والبورون	/uploads/products/naturquel_cab.jpg	t	2026-04-19 22:08:17.075544	Calcium and boron chelate
26	ACA 27	ACA 27	ACA 27	45.000	Fertilisant	Fertilisant	سماد	Acide aminé concentré pour plantes	Acide aminé concentré pour plantes	حمض أميني مركز للنباتات	/uploads/products/aca27.jpg	t	2026-04-19 22:08:17.075544	Concentrated amino acid for plants
28	Lebosol	Lebosol	ليبوسول	85.000	Fertilisant	Fertilisant	سماد	Fertilisant foliaire fer chélaté	Fertilisant foliaire fer chélaté	سماد ورقي يحتوي على حديد مخلبي	/uploads/products/lebosol.jpg	t	2026-04-19 22:08:17.075544	Chelated iron foliar fertilizer
50	Calimag Plus	Calimag Plus	كاليماغ بلاس	35.000	Fertilisant	Fertilisant	سماد	Fertilisant calcium magnésium	Fertilisant calcium magnésium	سماد كالسيوم ومغنيسيوم	/uploads/products/calimag_plus.jpg	t	2026-04-19 22:08:17.075544	Calcium and magnesium fertilizer
19	Algamina	Algamina	ألغامينا	80.000	Biostimulant	Biostimulant	منشط بيولوجي	Biostimulant à base d algues marines	Biostimulant à base d'algues marines	منشط بيولوجي على أساس الطحالب البحرية	/uploads/products/algamina.jpg	t	2026-04-19 22:08:17.075544	Marine algae-based biostimulant
27	Osiryl	Osiryl	أوزيريل	95.000	Biostimulant	Biostimulant	منشط بيولوجي	Biostimulant acides aminés et peptides	Biostimulant acides aminés et peptides	منشط بيولوجي بالأحماض الأمينية والببتيدات	/uploads/products/osiryl.jpg	t	2026-04-19 22:08:17.075544	Amino acids and peptides biostimulant
30	Rooter 5	Rooter 5	روتر 5	60.000	Biostimulant	Biostimulant	منشط بيولوجي	Stimulateur d enracinement	Stimulateur d'enracinement	منشط تجذير للنباتات	/uploads/products/rooter.jpg	t	2026-04-19 22:08:17.075544	Root growth stimulator
56	Isabion (Syngenta)	Isabion (Syngenta)	إيزابيون (سينجنتا)	45.000	Biostimulant	Biostimulant	منشط بيولوجي	Biostimulant acides aminés végétaux	Biostimulant acides aminés végétaux	منشط بيولوجي بأحماض أمينية نباتية	/uploads/products/isabion.jpg	t	2026-04-19 22:08:17.075544	Plant amino acids biostimulant
47	Synchro	Synchro	سينكرو	18.000	Adjuvant	Adjuvant	مادة مساعدة	Adjuvant pour mélange pesticides	Adjuvant pour mélange pesticides	مادة مساعدة لخلط المبيدات	/uploads/products/synchro.jpg	t	2026-04-19 22:08:17.075544	Adjuvant for pesticide mixing
35	Inex-A	Inex-A	إينيكس-A	45.000	Adjuvant	Adjuvant	مادة مساعدة	Adjuvant mouillant pour pesticides	Adjuvant mouillant pour pesticides	مادة مساعدة مبللة للمبيدات	/uploads/products/inex_a.jpg	f	2026-04-19 22:08:17.075544	Wetting adjuvant for pesticides
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, username, password, role, name, address, phone_no, gender, dob, farm_name, farmer_registration_no, alt_contact_no, created_at, updated_at, reset_token, reset_token_expiry, email, qr_token) FROM stdin;
27	aaaaa	$2b$10$WZo7xsm07KF4fWUZBQAIiejOhw3PuGSJZbhXcFVrtMy2oLUy6QRum	customer	aaaz	kairouan	56	male	\N	\N	\N	\N	2026-04-21 02:34:09.497064	2026-04-21 02:34:09.497064	\N	\N	jagaja@gmail.com	8b27e0c4309292c2f0e2fcc8be0678478126a53742048d4b8c6144b49cc5f4c5
30	ahmed	$2b$10$uwXX4Pk.ZXWZ0TtfNFlqeuFrHj7UkBIHxDtBKR0DPkDxXlJ6LYge2	customer	jzjzj	dth	5657	male	1990-01-01	\N	\N	5757	2026-04-21 02:55:13.862156	2026-04-21 02:55:13.862156	\N	\N	hzjzkz@gmail.com	2b7c0eba141c92196b28ab914bf81be836906c9d3652aeb04a2e33398ecc593e
31	pppp	$2b$10$Np1lhXJioM77.DBHopA/3.XVY5634lkVOmn8HSrvhRSGThr0nubCu	customer	ppppp	hzkzlzv	656566568	male	1990-01-01	\N	\N	556686568	2026-04-21 07:40:00.035146	2026-04-21 07:40:00.035146	\N	\N	exemple@gmail.com	4cecf1c6bbe4a0bf571dfb43e856ee370cbfef44312b4762baf938dd54709b10
32	nidhal	$2b$10$ByoMe8AMz7y4mn.kwkeZr..AE1nYHEjTa.XuzPcAz7UL39dWFtQQe	customer	nidhalkrifa	jdjsisi	58695869	male	1990-01-01	\N	\N	69695858	2026-04-21 14:10:22.8717	2026-04-21 14:10:22.8717	\N	\N	knkqk@gmail.com	67750714b7b06ca5a8c4d4669da8287a05b714909097627220b27aea6a55a896
34	maa	$2b$10$QnXV6SN.WOs2rikwyjL4De1wEOyeciRZjfVJfv6WMfqu8ikipclga	customer	mama	tunisia	56985869	male	\N	\N	\N	\N	2026-04-23 01:43:06.74549	2026-04-23 01:43:06.74549	\N	\N	yasshamzaoui2004@gmail	40eabe5a199e2660231c0d48c1fac7e2926da51f53a029ffbfc174fe55ebb3f7
35	kamel	$2b$10$l0jDcy0iuSE8c/q.gG/x6OHO52FqKM5uFlfieUSgYtvMd9AZmbLAK	customer	kamel	tunisia	23265858	male	\N	\N	\N	\N	2026-04-23 20:34:24.854164	2026-04-23 20:34:24.854164	\N	\N	yasshamzaoui32004@gmail.com	8ac6778163c84bb16823d7004025802d9a2467e34b5c3cfc7b25397233f3d497
38	yassyassaaa	$2b$10$3Ro7Gz1C8o.qRpRKxD/.XeA/LFa.iFB21TcDc3UR.iQoSA9dStaxi	customer	yaaaa	hdkdkz	58698055	male	\N	\N	\N	\N	2026-04-23 20:54:32.268821	2026-04-23 20:54:32.268821	\N	\N	yasshaiiiimzaoui2004@gmail.com	04ae2d59bb2b5430bcc2b240a37990f210ff8b8c39f196f8af79389d91634dd5
39	nour	$2b$10$Z4tDI1fthppNfhbX1VjgYuPUyoQipQxShxOWVrlyU6fEYOZFAZmmS	customer	nour	tunisia	58585858	male	\N	\N	\N	\N	2026-04-23 22:49:33.477049	2026-04-23 22:49:33.477049	\N	\N	nour@gmai.com	9fcd9e99d30546bb6f95e1218c45c6dfe4ff6682b5abd09589d9ae3e673c219c
1	yass	$2b$10$7O7ZgNnuQTUo1DDsooSbEeCuohJQzSYUl2ncXbdVxS/.2aFF7zIaC	customer	YASS	TUNI	32435676	female	1990-01-01	\N	\N	65768798	2026-04-05 00:59:03.389496	2026-04-05 00:59:03.389496	\N	\N	\N	444539f6333160868d05a23570285409e5b314563eda7025bc424e681e79d354
9	tass	$2b$10$7/zcIA.jxVy4Ozyis7lKSuZp.ovMoTW6GKIHK72S2u3RjXpIudzSK	customer	tassnim	tunisia	54545454	female	1990-01-01	\N	\N	65767676	2026-04-14 23:08:49.992082	2026-04-14 23:08:49.992082	\N	\N	\N	aeb57af466fae28c8c7585ca2375e117ef7281a977e2d817d5a711d763553d3a
10	jarrayagro	$2b$10$bkJph3MKYzwlp4brWPu/J.EVBkpTPWgQqIYP/Oc4XvUMBhKn7mxty	farmer	jarrayagro	baten	54657676	male	1990-01-01	jarrayagro	54657689	65768798	2026-04-16 00:53:17.920501	2026-04-16 00:53:17.920501	\N	\N	\N	9d4356158d54dbd0b2a1916e6cd2956830dd9d2e5b0ddaff56c3b45db1d4e8f0
3	admin	$2b$10$LmDWoBNcuiZ6Kcz1lqSLdOlEZeoZuvv.wzOJVko1g1aTGWcuCoQBW	admin	Administrateur	Jarray Agro	00000000	male	1990-01-01	\N	\N	\N	2026-04-05 01:39:57.976166	2026-04-05 01:39:57.976166	\N	\N	adminagriscan@gmail.com	3c6eb76c3d778608f8a4d26736a0830731ca0ce309e0ed357c1a676810852c2d
12	tasstass	$2b$10$ICT9jyuDyNq0/VXnScI/T.iq46kj3Sv1hISkAYqZWlVE613MBIq2m	customer	tasnim	kairouan	65768797	female	1990-01-01	\N	\N	76765454	2026-04-18 23:05:30.499169	2026-04-18 23:05:30.499169	\N	\N	tassnimehamzaoui2026@gmail.com	653a9d5652e63bf6c01bffb49d3e96fbf031207036550063d328831baafd63e1
11	yassyass	$2b$10$me7.4jgONtNJNExAMsZdvuOrJXVdHJvBnUWepZVibV1u1KnnVmj7G	customer	yassminehamzaouiiii	kairouan	55657687	female	1989-12-31			76878879	2026-04-17 20:24:52.389246	2026-04-17 20:24:52.389246	364334	2026-04-19 01:51:09.066	yasshamzaoui2004@gmail.com	53115d635bf76444dd48b83d677cdfb0eda323972621eee26ed4c607850de351
14	bbbb	$2b$10$LkjErXIMCBBajq2Gufk6uOgnG1G2kf3f0oIpUT7KbLZ7CHD864j22	farmer	bbbbbbb	tunisia	82787787	male	1990-01-01	agri	56565667	87656576	2026-04-19 03:27:16.294647	2026-04-19 03:27:16.294647	\N	\N	jzhzjzjzh@gmail.com	ee4d528b9e5b1bc30ed02170c0f48fd3b89b4dfc092815cbef66dbe9b1b00a8f
2	yassmine	$2b$10$ggPzHTGvIfrxf8ti//unGu5XW/7W1jYbjznQGDJiIoG4q/wIJuZb6	customer	YASSmin	tunisia	54610871	\N	\N	\N	\N	55868183	2026-04-05 01:00:46.021218	2026-04-05 01:00:46.021218	\N	\N		b4bb71d9ae2340322e008d7d5ff73ba9695c0c9c40a7affdaae15f72fab02be3
24	aaaaaa	$2b$10$g22pzGXkrbPWBJW9sqKhSeqNTUavRJ/ZFGyxGit2Mg.gqMknVxn1G	customer	aaaa	tunisia	65986565	\N	\N	\N	\N	\N	2026-04-19 16:33:18.982198	2026-04-19 16:33:18.982198	\N	\N	hgjhjklj@gmail.com	f584cc65bf1d57a110f53fc0c516877bc89bde62717887298dd3c4e823e2a393
\.


--
-- Name: crop_library_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.crop_library_id_seq', 35, true);


--
-- Name: crop_planning_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.crop_planning_id_seq', 14, true);


--
-- Name: crop_tasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.crop_tasks_id_seq', 11, true);


--
-- Name: detection_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.detection_history_id_seq', 249, true);


--
-- Name: plant_prices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.plant_prices_id_seq', 18, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.products_id_seq', 58, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 39, true);


--
-- Name: crop_library crop_library_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crop_library
    ADD CONSTRAINT crop_library_pkey PRIMARY KEY (id);


--
-- Name: crop_planning crop_planning_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crop_planning
    ADD CONSTRAINT crop_planning_pkey PRIMARY KEY (id);


--
-- Name: crop_tasks crop_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crop_tasks
    ADD CONSTRAINT crop_tasks_pkey PRIMARY KEY (id);


--
-- Name: detection_history detection_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detection_history
    ADD CONSTRAINT detection_history_pkey PRIMARY KEY (id);


--
-- Name: plant_prices plant_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plant_prices
    ADD CONSTRAINT plant_prices_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_qr_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_qr_token_key UNIQUE (qr_token);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: crop_planning crop_planning_crop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crop_planning
    ADD CONSTRAINT crop_planning_crop_id_fkey FOREIGN KEY (crop_id) REFERENCES public.crop_library(id);


--
-- Name: crop_planning crop_planning_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crop_planning
    ADD CONSTRAINT crop_planning_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: crop_tasks crop_tasks_planning_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crop_tasks
    ADD CONSTRAINT crop_tasks_planning_id_fkey FOREIGN KEY (planning_id) REFERENCES public.crop_planning(id) ON DELETE CASCADE;


--
-- Name: detection_history detection_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detection_history
    ADD CONSTRAINT detection_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict 8qa0YHVQ5A4pzKq4L8lzzaflBBqOjx3D2TiFfSWC2HaIvjbwHzyrwSvoU5VvPTb

