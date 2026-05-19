--
-- PostgreSQL database dump
--

\restrict AxhfyUXDgVgDH7JagXcrfZr9EEaAJ6SV0g3TnIiBs8zJh9wGMEn3qHiKbevMvwS

-- Dumped from database version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)

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

SET default_tablespace = refs;

SET default_table_access_method = heap;

--
-- Name: accounting_object; Type: TABLE; Schema: public; Owner: postgres; Tablespace: refs
--

CREATE TABLE public.accounting_object (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.accounting_object OWNER TO postgres;

--
-- Name: accounting_object_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.accounting_object_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.accounting_object_id_seq OWNER TO postgres;

--
-- Name: accounting_object_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.accounting_object_id_seq OWNED BY public.accounting_object.id;


SET default_tablespace = '';

--
-- Name: cancellations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cancellations (
    id integer NOT NULL,
    amount integer NOT NULL,
    price double precision NOT NULL,
    manufacture_date date,
    good_until date,
    namenclature_id integer NOT NULL,
    expense_invoice_id integer NOT NULL,
    comment text
);


ALTER TABLE public.cancellations OWNER TO postgres;

--
-- Name: cancellations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cancellations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cancellations_id_seq OWNER TO postgres;

--
-- Name: cancellations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cancellations_id_seq OWNED BY public.cancellations.id;


SET default_tablespace = refs;

--
-- Name: companies; Type: TABLE; Schema: public; Owner: postgres; Tablespace: refs
--

CREATE TABLE public.companies (
    id integer NOT NULL,
    name character varying NOT NULL,
    inn character varying NOT NULL
);


ALTER TABLE public.companies OWNER TO postgres;

--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.companies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.companies_id_seq OWNER TO postgres;

--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.companies_id_seq OWNED BY public.companies.id;


SET default_tablespace = '';

--
-- Name: employees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employees (
    id integer NOT NULL,
    name character varying NOT NULL,
    address character varying,
    email character varying,
    phone character varying
);


ALTER TABLE public.employees OWNER TO postgres;

--
-- Name: employees_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employees_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employees_id_seq OWNER TO postgres;

--
-- Name: employees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employees_id_seq OWNED BY public.employees.id;


--
-- Name: expense_invoices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.expense_invoices (
    id integer NOT NULL,
    document_number character varying NOT NULL,
    date timestamp with time zone NOT NULL,
    accounting_object_id integer,
    storage_id integer,
    comment text
);


ALTER TABLE public.expense_invoices OWNER TO postgres;

--
-- Name: expense_invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.expense_invoices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.expense_invoices_id_seq OWNER TO postgres;

--
-- Name: expense_invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.expense_invoices_id_seq OWNED BY public.expense_invoices.id;


--
-- Name: nomenclatures; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nomenclatures (
    id integer NOT NULL,
    name character varying NOT NULL,
    type_id integer NOT NULL,
    speciality_id integer,
    main_unit_id integer NOT NULL,
    inv_number character varying,
    expiration_date integer,
    expiration_unit_id character varying,
    min_balance smallint,
    max_balance smallint,
    comment text
);


ALTER TABLE public.nomenclatures OWNER TO postgres;

--
-- Name: nomenclatures_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.nomenclatures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.nomenclatures_id_seq OWNER TO postgres;

--
-- Name: nomenclatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.nomenclatures_id_seq OWNED BY public.nomenclatures.id;


--
-- Name: parishes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.parishes (
    id integer NOT NULL,
    amount integer NOT NULL,
    price double precision NOT NULL,
    vat smallint,
    manufacture_date date,
    good_until date,
    namenclature_id integer NOT NULL,
    purchase_invoice_id integer NOT NULL,
    comment text
);


ALTER TABLE public.parishes OWNER TO postgres;

--
-- Name: parishes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.parishes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.parishes_id_seq OWNER TO postgres;

--
-- Name: parishes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.parishes_id_seq OWNED BY public.parishes.id;


--
-- Name: providers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.providers (
    id integer NOT NULL,
    name character varying NOT NULL,
    inn character varying NOT NULL
);


ALTER TABLE public.providers OWNER TO postgres;

--
-- Name: providers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.providers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.providers_id_seq OWNER TO postgres;

--
-- Name: providers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.providers_id_seq OWNED BY public.providers.id;


--
-- Name: purchase_invoices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.purchase_invoices (
    id integer NOT NULL,
    document_number character varying NOT NULL,
    date timestamp with time zone NOT NULL,
    provider_id integer NOT NULL,
    company_id integer NOT NULL,
    storage_id integer,
    comment text
);


ALTER TABLE public.purchase_invoices OWNER TO postgres;

--
-- Name: purchase_invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.purchase_invoices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.purchase_invoices_id_seq OWNER TO postgres;

--
-- Name: purchase_invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.purchase_invoices_id_seq OWNED BY public.purchase_invoices.id;


--
-- Name: specialities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.specialities (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.specialities OWNER TO postgres;

--
-- Name: specialities_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.specialities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.specialities_id_seq OWNER TO postgres;

--
-- Name: specialities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.specialities_id_seq OWNED BY public.specialities.id;


--
-- Name: storages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.storages (
    id integer NOT NULL,
    name character varying NOT NULL,
    company_id integer
);


ALTER TABLE public.storages OWNER TO postgres;

--
-- Name: storages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.storages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.storages_id_seq OWNER TO postgres;

--
-- Name: storages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.storages_id_seq OWNED BY public.storages.id;


--
-- Name: strorage_structures; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.strorage_structures (
    id integer NOT NULL,
    parent_id integer NOT NULL,
    child_id integer NOT NULL
);


ALTER TABLE public.strorage_structures OWNER TO postgres;

--
-- Name: strorage_structures_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.strorage_structures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.strorage_structures_id_seq OWNER TO postgres;

--
-- Name: strorage_structures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.strorage_structures_id_seq OWNED BY public.strorage_structures.id;


--
-- Name: types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.types (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.types OWNER TO postgres;

--
-- Name: types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.types_id_seq OWNER TO postgres;

--
-- Name: types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.types_id_seq OWNED BY public.types.id;


--
-- Name: units; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.units (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.units OWNER TO postgres;

--
-- Name: units_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.units_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.units_id_seq OWNER TO postgres;

--
-- Name: units_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.units_id_seq OWNED BY public.units.id;


--
-- Name: accounting_object id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounting_object ALTER COLUMN id SET DEFAULT nextval('public.accounting_object_id_seq'::regclass);


--
-- Name: cancellations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cancellations ALTER COLUMN id SET DEFAULT nextval('public.cancellations_id_seq'::regclass);


--
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.companies ALTER COLUMN id SET DEFAULT nextval('public.companies_id_seq'::regclass);


--
-- Name: employees id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees ALTER COLUMN id SET DEFAULT nextval('public.employees_id_seq'::regclass);


--
-- Name: expense_invoices id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expense_invoices ALTER COLUMN id SET DEFAULT nextval('public.expense_invoices_id_seq'::regclass);


--
-- Name: nomenclatures id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nomenclatures ALTER COLUMN id SET DEFAULT nextval('public.nomenclatures_id_seq'::regclass);


--
-- Name: parishes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parishes ALTER COLUMN id SET DEFAULT nextval('public.parishes_id_seq'::regclass);


--
-- Name: providers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.providers ALTER COLUMN id SET DEFAULT nextval('public.providers_id_seq'::regclass);


--
-- Name: purchase_invoices id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_invoices ALTER COLUMN id SET DEFAULT nextval('public.purchase_invoices_id_seq'::regclass);


--
-- Name: specialities id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specialities ALTER COLUMN id SET DEFAULT nextval('public.specialities_id_seq'::regclass);


--
-- Name: storages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.storages ALTER COLUMN id SET DEFAULT nextval('public.storages_id_seq'::regclass);


--
-- Name: strorage_structures id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.strorage_structures ALTER COLUMN id SET DEFAULT nextval('public.strorage_structures_id_seq'::regclass);


--
-- Name: types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.types ALTER COLUMN id SET DEFAULT nextval('public.types_id_seq'::regclass);


--
-- Name: units id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.units ALTER COLUMN id SET DEFAULT nextval('public.units_id_seq'::regclass);


--
-- Data for Name: accounting_object; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.accounting_object (id, name) FROM stdin;
1	Стоматология
2	Хирургия
\.


--
-- Data for Name: cancellations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cancellations (id, amount, price, manufacture_date, good_until, namenclature_id, expense_invoice_id, comment) FROM stdin;
1	10	4	\N	\N	1	1	\N
2	2	35	2025-10-04	2027-10-04	2	2	\N
\.


--
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.companies (id, name, inn) FROM stdin;
1	Здоровье Плюс	7712345678
2	Здоровье Премиум	7712345679
3	Здоровье Плюс	7712345678
4	Здоровье Премиум	7712345679
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employees (id, name, address, email, phone) FROM stdin;
1	Иванов Алексей Сергеевич	г. Москва, ул. Ленина, д. 45, кв. 12	a.ivanov1985@example.com	79113257485
2	Петрова Елена Дмитриевна	г. Екатеринбург, ул. Мира, д. 22, кв. 56	elena.petrova.spb@example.com	79217784521
3	Сидоров Михаил Андреевич	г. Санкт-Петербург, пр. Невский, д. 78, кв. 34	m.sidorov_ekb@example.com	+79214126971
\.


--
-- Data for Name: expense_invoices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.expense_invoices (id, document_number, date, accounting_object_id, storage_id, comment) FROM stdin;
1	РН-2025-0315	2025-12-05 00:00:00+03	2	2	\N
2	РН-2025-0316	2025-12-05 00:00:00+03	3	\N	\N
\.


--
-- Data for Name: nomenclatures; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.nomenclatures (id, name, type_id, speciality_id, main_unit_id, inv_number, expiration_date, expiration_unit_id, min_balance, max_balance, comment) FROM stdin;
3	Шприц инсулиновый 1 мл	3	2	6	001897564-А	\N	5	100	1000	Одноразовый шприц с фиксированной иглой для подкожных инъекций инсулина
4	Шприц медицинский стерильный 3 мл с фиксированной иглой	3	\N	6	001897565-А	\N	5	100	1000	Шприц одноразовый с фиксированной иглой
5	Таблетки «Парацетамол 500 мг	2	3	7	\N	\N	5	10	50	Жаропонижающее и обезболивающее средство, упаковка 10 таблеток
\.


--
-- Data for Name: parishes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.parishes (id, amount, price, vat, manufacture_date, good_until, namenclature_id, purchase_invoice_id, comment) FROM stdin;
1	100	4	\N	\N	\N	1	1	\N
2	20	35	\N	\N	\N	2	1	\N
3	150	4	\N	\N	\N	1	2	\N
4	30	35	\N	\N	\N	2	2	\N
\.


--
-- Data for Name: providers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.providers (id, name, inn) FROM stdin;
1	ООО «МедТехСнаб»	7701234567
2	ФармЛогистика Плюс	7702345678
3	ООО «БиоХимТрейд»	7703456789
\.


--
-- Data for Name: purchase_invoices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.purchase_invoices (id, document_number, date, provider_id, company_id, storage_id, comment) FROM stdin;
1	ПН-2025-0427	2025-12-01 00:00:00+03	3	1	1	2
2	ПН-2025-0428	2025-12-02 00:00:00+03	2	3	2	3
\.


--
-- Data for Name: specialities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.specialities (id, name) FROM stdin;
1	Стоматология
2	Хирургия
3	Терапия
4	Педиатрия
5	Урология
\.


--
-- Data for Name: storages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.storages (id, name, company_id) FROM stdin;
1	Общий	\N
2	Здоровье Плюс Склад	1
3	Здоровье Премиум склад	2
4	Склад техники	\N
\.


--
-- Data for Name: strorage_structures; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.strorage_structures (id, parent_id, child_id) FROM stdin;
1	3	4
\.


--
-- Data for Name: types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.types (id, name) FROM stdin;
1	Медицинские изделия
2	Лекарственные препараты
3	Расходный материал
4	Реагенты и диагностические наборы
\.


--
-- Data for Name: units; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.units (id, name) FROM stdin;
1	Час
2	Сутки
3	Неделя
4	Месяц
5	Год
6	Штука
7	Упаковка
8	Ампула
9	Миллилитр
10	Грамм
\.


--
-- Name: accounting_object_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.accounting_object_id_seq', 2, true);


--
-- Name: cancellations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cancellations_id_seq', 2, true);


--
-- Name: companies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.companies_id_seq', 4, true);


--
-- Name: employees_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employees_id_seq', 3, true);


--
-- Name: expense_invoices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.expense_invoices_id_seq', 2, true);


--
-- Name: nomenclatures_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.nomenclatures_id_seq', 5, true);


--
-- Name: parishes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.parishes_id_seq', 4, true);


--
-- Name: providers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.providers_id_seq', 3, true);


--
-- Name: purchase_invoices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.purchase_invoices_id_seq', 2, true);


--
-- Name: specialities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.specialities_id_seq', 5, true);


--
-- Name: storages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.storages_id_seq', 4, true);


--
-- Name: strorage_structures_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.strorage_structures_id_seq', 1, true);


--
-- Name: types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.types_id_seq', 4, true);


--
-- Name: units_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.units_id_seq', 10, true);


--
-- Name: accounting_object accounting_object_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounting_object
    ADD CONSTRAINT accounting_object_pkey PRIMARY KEY (id);


--
-- Name: cancellations cancellations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cancellations
    ADD CONSTRAINT cancellations_pkey PRIMARY KEY (id);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- Name: expense_invoices expense_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expense_invoices
    ADD CONSTRAINT expense_invoices_pkey PRIMARY KEY (id);


--
-- Name: nomenclatures nomenclatures_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nomenclatures
    ADD CONSTRAINT nomenclatures_pkey PRIMARY KEY (id);


--
-- Name: parishes parishes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parishes
    ADD CONSTRAINT parishes_pkey PRIMARY KEY (id);


--
-- Name: providers providers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.providers
    ADD CONSTRAINT providers_pkey PRIMARY KEY (id);


--
-- Name: purchase_invoices purchase_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_invoices
    ADD CONSTRAINT purchase_invoices_pkey PRIMARY KEY (id);


--
-- Name: specialities specialities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specialities
    ADD CONSTRAINT specialities_pkey PRIMARY KEY (id);


--
-- Name: types types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.types
    ADD CONSTRAINT types_pkey PRIMARY KEY (id);


--
-- Name: units units_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

\unrestrict AxhfyUXDgVgDH7JagXcrfZr9EEaAJ6SV0g3TnIiBs8zJh9wGMEn3qHiKbevMvwS

