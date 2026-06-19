--
-- PostgreSQL database dump
--
SET session_replication_role = 'replica';
-- Dumped from database version 14.17
-- Dumped by pg_dump version 14.17

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
-- Name: timescaledb; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS timescaledb WITH SCHEMA public;


--
-- Name: EXTENSION timescaledb; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION timescaledb IS 'Enables scalable inserts and complex queries for time-series data (Community Edition)';


--
-- Name: alarm_severity_enum; Type: TYPE; Schema: public; Owner: kristina
--

CREATE TYPE public.alarm_severity_enum AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH',
    'CRITICAL'
);


ALTER TYPE public.alarm_severity_enum OWNER TO kristina;

--
-- Name: incident_severity_enum; Type: TYPE; Schema: public; Owner: kristina
--

CREATE TYPE public.incident_severity_enum AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH',
    'CRITICAL'
);


ALTER TYPE public.incident_severity_enum OWNER TO kristina;

--
-- Name: incident_status_enum; Type: TYPE; Schema: public; Owner: kristina
--

CREATE TYPE public.incident_status_enum AS ENUM (
    'NEW',
    'IN_PROGRESS',
    'RESOLVED'
);


ALTER TYPE public.incident_status_enum OWNER TO kristina;

--
-- Name: sensor_unit_enum; Type: TYPE; Schema: public; Owner: kristina
--

CREATE TYPE public.sensor_unit_enum AS ENUM (
    '°C',
    '%',
    'bar',
    'V'
);


ALTER TYPE public.sensor_unit_enum OWNER TO kristina;

--
-- Name: user_role_enum; Type: TYPE; Schema: public; Owner: kristina
--

CREATE TYPE public.user_role_enum AS ENUM (
    'ADMIN',
    'OPERATOR'
);


ALTER TYPE public.user_role_enum OWNER TO kristina;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alarm; Type: TABLE; Schema: public; Owner: kristina
--

CREATE TABLE public.alarm (
    id integer NOT NULL,
    "lowThreshold" double precision NOT NULL,
    "highThreshold" double precision NOT NULL,
    severity public.alarm_severity_enum DEFAULT 'CRITICAL'::public.alarm_severity_enum NOT NULL,
    "sensorId" integer
);


ALTER TABLE public.alarm OWNER TO kristina;

--
-- Name: alarm_id_seq; Type: SEQUENCE; Schema: public; Owner: kristina
--

CREATE SEQUENCE public.alarm_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.alarm_id_seq OWNER TO kristina;

--
-- Name: alarm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kristina
--

ALTER SEQUENCE public.alarm_id_seq OWNED BY public.alarm.id;


--
-- Name: incident; Type: TABLE; Schema: public; Owner: kristina
--

CREATE TABLE public.incident (
    id integer NOT NULL,
    description character varying NOT NULL,
    severity public.incident_severity_enum NOT NULL,
    status public.incident_status_enum DEFAULT 'NEW'::public.incident_status_enum NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "resolvedAt" timestamp with time zone,
    "pickedUpAt" timestamp with time zone,
    "historyLogs" text,
    "assignedToId" integer,
    "sensorId" integer
);


ALTER TABLE public.incident OWNER TO kristina;

--
-- Name: incident_id_seq; Type: SEQUENCE; Schema: public; Owner: kristina
--

CREATE SEQUENCE public.incident_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.incident_id_seq OWNER TO kristina;

--
-- Name: incident_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kristina
--

ALTER SEQUENCE public.incident_id_seq OWNED BY public.incident.id;


--
-- Name: measurement; Type: TABLE; Schema: public; Owner: kristina
--

CREATE TABLE public.measurement (
    id integer NOT NULL,
    value double precision NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now() NOT NULL,
    "sensorId" integer NOT NULL
);


ALTER TABLE public.measurement OWNER TO kristina;

--
-- Name: measurement_id_seq; Type: SEQUENCE; Schema: public; Owner: kristina
--

CREATE SEQUENCE public.measurement_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.measurement_id_seq OWNER TO kristina;

--
-- Name: measurement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kristina
--

ALTER SEQUENCE public.measurement_id_seq OWNED BY public.measurement.id;


--
-- Name: sensor; Type: TABLE; Schema: public; Owner: kristina
--

CREATE TABLE public.sensor (
    id integer NOT NULL,
    name character varying NOT NULL,
    location character varying NOT NULL,
    unit public.sensor_unit_enum NOT NULL
);


ALTER TABLE public.sensor OWNER TO kristina;

--
-- Name: sensor_id_seq; Type: SEQUENCE; Schema: public; Owner: kristina
--

CREATE SEQUENCE public.sensor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sensor_id_seq OWNER TO kristina;

--
-- Name: sensor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kristina
--

ALTER SEQUENCE public.sensor_id_seq OWNED BY public.sensor.id;


--
-- Name: user; Type: TABLE; Schema: public; Owner: kristina
--

CREATE TABLE public."user" (
    id integer NOT NULL,
    username character varying NOT NULL,
    password character varying NOT NULL,
    email character varying NOT NULL,
    "fullName" character varying,
    "avatarUrl" character varying DEFAULT 'https://cdn-icons-png.flaticon.com/512/149/149071.png'::character varying NOT NULL,
    role public.user_role_enum DEFAULT 'OPERATOR'::public.user_role_enum NOT NULL
);


ALTER TABLE public."user" OWNER TO kristina;

--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: kristina
--

CREATE SEQUENCE public.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_id_seq OWNER TO kristina;

--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kristina
--

ALTER SEQUENCE public.user_id_seq OWNED BY public."user".id;


--
-- Name: alarm id; Type: DEFAULT; Schema: public; Owner: kristina
--

ALTER TABLE ONLY public.alarm ALTER COLUMN id SET DEFAULT nextval('public.alarm_id_seq'::regclass);


--
-- Name: incident id; Type: DEFAULT; Schema: public; Owner: kristina
--

ALTER TABLE ONLY public.incident ALTER COLUMN id SET DEFAULT nextval('public.incident_id_seq'::regclass);


--
-- Name: measurement id; Type: DEFAULT; Schema: public; Owner: kristina
--

ALTER TABLE ONLY public.measurement ALTER COLUMN id SET DEFAULT nextval('public.measurement_id_seq'::regclass);


--
-- Name: sensor id; Type: DEFAULT; Schema: public; Owner: kristina
--

ALTER TABLE ONLY public.sensor ALTER COLUMN id SET DEFAULT nextval('public.sensor_id_seq'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: public; Owner: kristina
--

ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);


--
-- Data for Name: hypertable; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: kristina
--



--
-- Data for Name: chunk; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: kristina
--



--
-- Data for Name: chunk_column_stats; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: kristina
--



--
-- Data for Name: dimension; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: kristina
--



--
-- Data for Name: dimension_slice; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: kristina
--



--
-- Data for Name: chunk_constraint; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: kristina
--



--
-- Data for Name: chunk_index; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: kristina
--



--
-- Data for Name: compression_chunk_size; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: kristina
--



--
-- Data for Name: compression_settings; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: kristina
--



--
-- Data for Name: continuous_agg; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: kristina
--



--
-- Data for Name: continuous_agg_migrate_plan; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: kristina
--



--
-- Data for Name: continuous_agg_migrate_plan_step; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: kristina
--



--
-- Data for Name: continuous_aggs_bucket_function; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: kristina
--



--
-- Data for Name: continuous_aggs_hypertable_invalidation_log; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: kristina
--



--
-- Data for Name: continuous_aggs_invalidation_threshold; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: kristina
--



--
-- Data for Name: continuous_aggs_materialization_invalidation_log; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: kristina
--



--
-- Data for Name: continuous_aggs_watermark; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: kristina
--



--
-- Data for Name: metadata; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: kristina
--


--
-- Data for Name: tablespace; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: kristina
--



--
-- Data for Name: bgw_job; Type: TABLE DATA; Schema: _timescaledb_config; Owner: kristina
--



--
-- Data for Name: alarm; Type: TABLE DATA; Schema: public; Owner: kristina
--

INSERT INTO public.alarm (id, "lowThreshold", "highThreshold", severity, "sensorId") VALUES (1, -10, 24, 'MEDIUM', 1);
INSERT INTO public.alarm (id, "lowThreshold", "highThreshold", severity, "sensorId") VALUES (2, -25, 45, 'CRITICAL', 1);
INSERT INTO public.alarm (id, "lowThreshold", "highThreshold", severity, "sensorId") VALUES (3, 5, 35, 'HIGH', 2);
INSERT INTO public.alarm (id, "lowThreshold", "highThreshold", severity, "sensorId") VALUES (4, 20, 65, 'LOW', 3);
INSERT INTO public.alarm (id, "lowThreshold", "highThreshold", severity, "sensorId") VALUES (5, 10, 85, 'HIGH', 3);
INSERT INTO public.alarm (id, "lowThreshold", "highThreshold", severity, "sensorId") VALUES (7, 0.5, 5, 'HIGH', 4);
INSERT INTO public.alarm (id, "lowThreshold", "highThreshold", severity, "sensorId") VALUES (8, 210, 240, 'HIGH', 5);
INSERT INTO public.alarm (id, "lowThreshold", "highThreshold", severity, "sensorId") VALUES (9, 180, 260, 'CRITICAL', 5);
INSERT INTO public.alarm (id, "lowThreshold", "highThreshold", severity, "sensorId") VALUES (10, 11, 14.5, 'MEDIUM', 6);
INSERT INTO public.alarm (id, "lowThreshold", "highThreshold", severity, "sensorId") VALUES (11, 0, 90, 'LOW', 7);
INSERT INTO public.alarm (id, "lowThreshold", "highThreshold", severity, "sensorId") VALUES (12, 0, 98, 'CRITICAL', 7);
INSERT INTO public.alarm (id, "lowThreshold", "highThreshold", severity, "sensorId") VALUES (13, 18, 26, 'LOW', 8);
INSERT INTO public.alarm (id, "lowThreshold", "highThreshold", severity, "sensorId") VALUES (14, 50, 78, 'CRITICAL', 11);


--
-- Data for Name: incident; Type: TABLE DATA; Schema: public; Owner: kristina
--

INSERT INTO public.incident (id, description, severity, status, "createdAt", "resolvedAt", "pickedUpAt", "historyLogs", "assignedToId", "sensorId") VALUES (4, 'System generated alarm: Value 22.29 is out of range (1 - 4).', 'CRITICAL', 'NEW', '2026-05-18 12:21:24.980626', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.incident (id, description, severity, status, "createdAt", "resolvedAt", "pickedUpAt", "historyLogs", "assignedToId", "sensorId") VALUES (12, 'System generated alarm: Value -8.14 is out of range (0 - 98).', 'CRITICAL', 'RESOLVED', '2026-05-18 13:18:06.680861', '2026-06-04 16:54:12.751+00', '2026-05-18 14:32:27.979+00', '📥 @milica preuzeo u 16:32 | 🏁 @milica rešio u 18:54', 2, 7);
INSERT INTO public.incident (id, description, severity, status, "createdAt", "resolvedAt", "pickedUpAt", "historyLogs", "assignedToId", "sensorId") VALUES (48, 'System generated alarm: Value 109.08 is out of range (0 - 98).', 'CRITICAL', 'NEW', '2026-06-04 16:54:21.881702', NULL, NULL, NULL, NULL, 7);
INSERT INTO public.incident (id, description, severity, status, "createdAt", "resolvedAt", "pickedUpAt", "historyLogs", "assignedToId", "sensorId") VALUES (5, 'System generated alarm: Value 45.44 is out of range (5 - 35).', 'HIGH', 'NEW', '2026-05-18 12:25:05.019557', NULL, NULL, NULL, NULL, 2);
INSERT INTO public.incident (id, description, severity, status, "createdAt", "resolvedAt", "pickedUpAt", "historyLogs", "assignedToId", "sensorId") VALUES (3, 'System generated alarm: Value -32.97 is out of range (-25 - 45).', 'CRITICAL', 'RESOLVED', '2026-05-18 12:21:09.936247', '2026-05-18 12:25:28.912+00', '2026-05-18 12:22:57.217+00', '📥 @ognjen preuzeo u 14:22 | 📥 @ognjen preuzeo u 14:22 | 🏁 @ognjen rešio u 14:25', 1, 1);
INSERT INTO public.incident (id, description, severity, status, "createdAt", "resolvedAt", "pickedUpAt", "historyLogs", "assignedToId", "sensorId") VALUES (2, 'System generated alarm: Value -0.9 is out of range (0 - 98).', 'CRITICAL', 'RESOLVED', '2026-05-18 12:20:54.983537', '2026-05-18 12:28:52.34+00', '2026-05-18 12:23:05.719+00', '📥 @kristina preuzeo u 14:23 | @kristina odustao u 14:26 | 📥 @ognjen preuzeo u 14:27 | 📥 @kristina preuzeo u 14:23 | @kristina odustao u 14:26 | 📥 @ognjen preuzeo u 14:27 | 🏁 @ognjen rešio u 14:28', 1, 7);
INSERT INTO public.incident (id, description, severity, status, "createdAt", "resolvedAt", "pickedUpAt", "historyLogs", "assignedToId", "sensorId") VALUES (10, 'System generated alarm: Value 20.59 is out of range (11 - 14.5).', 'MEDIUM', 'RESOLVED', '2026-05-18 12:30:25.197674', '2026-05-18 13:00:09.185+00', '2026-05-18 12:56:58.423+00', '📥 @kristina preuzeo u 14:56 | 🏁 @kristina rešio u 15:00', 3, 6);
INSERT INTO public.incident (id, description, severity, status, "createdAt", "resolvedAt", "pickedUpAt", "historyLogs", "assignedToId", "sensorId") VALUES (9, 'System generated alarm: Value 86.86 is out of range (20 - 65).', 'LOW', 'RESOLVED', '2026-05-18 12:30:00.161795', '2026-05-18 13:04:39.336+00', '2026-05-18 12:56:52.87+00', '📥 @ognjen preuzeo u 14:56 | ↩️ @ognjen odustao u 14:58 | 📥 @kristina preuzeo u 14:59 | 🏁 @kristina rešio u 15:04', 3, 3);
INSERT INTO public.incident (id, description, severity, status, "createdAt", "resolvedAt", "pickedUpAt", "historyLogs", "assignedToId", "sensorId") VALUES (11, 'System generated alarm: Value 67.77 is out of range (20 - 65).', 'LOW', 'NEW', '2026-05-18 13:10:56.313502', NULL, NULL, NULL, NULL, 3);
INSERT INTO public.incident (id, description, severity, status, "createdAt", "resolvedAt", "pickedUpAt", "historyLogs", "assignedToId", "sensorId") VALUES (46, 'System generated alarm: Value 177.55 is out of range (180 - 260).', 'CRITICAL', 'RESOLVED', '2026-05-18 13:35:11.144358', '2026-06-16 13:58:16.998+00', '2026-06-16 13:57:52.822+00', '📥 @kristina preuzeo u 15:57 | 🏁 @kristina rešio u 15:58', 3, 5);
INSERT INTO public.incident (id, description, severity, status, "createdAt", "resolvedAt", "pickedUpAt", "historyLogs", "assignedToId", "sensorId") VALUES (8, 'System generated alarm: Value 113.14 is out of range (0 - 98).', 'CRITICAL', 'RESOLVED', '2026-05-18 12:28:55.187985', '2026-05-18 13:17:30.401+00', '2026-05-18 13:12:38.91+00', '📥 @ognjen preuzeo u 15:12 | ↩️ @ognjen odustao u 15:15 | 📥 @kristina preuzeo u 15:15 | 🏁 @kristina rešio u 15:17', 3, 7);
INSERT INTO public.incident (id, description, severity, status, "createdAt", "resolvedAt", "pickedUpAt", "historyLogs", "assignedToId", "sensorId") VALUES (90, 'System generated alarm: Value 274.53 is out of range (180 - 260).', 'CRITICAL', 'NEW', '2026-06-16 13:58:38.736781', NULL, NULL, NULL, NULL, 5);
INSERT INTO public.incident (id, description, severity, status, "createdAt", "resolvedAt", "pickedUpAt", "historyLogs", "assignedToId", "sensorId") VALUES (89, 'System generated alarm: Value 92.97 is out of range (50 - 78).', 'CRITICAL', 'NEW', '2026-06-15 23:20:23.103316', NULL, '2026-06-16 22:44:53.876+00', '📥 @kristina preuzeo u 00:44 | ↩️ @kristina odustao u 00:45', NULL, 11);
INSERT INTO public.incident (id, description, severity, status, "createdAt", "resolvedAt", "pickedUpAt", "historyLogs", "assignedToId", "sensorId") VALUES (1, 'System generated alarm: Value 173.28 is out of range (210 - 240).', 'HIGH', 'RESOLVED', '2026-05-18 12:20:49.954744', '2026-05-18 13:34:30.067+00', '2026-05-18 13:32:12.023+00', '📥 @kristina preuzeo u 15:27 | ↩️ @kristina odustao u 15:30 | 📥 @ognjen preuzeo u 15:32 | 🏁 @ognjen rešio u 15:34', 1, 5);
INSERT INTO public.incident (id, description, severity, status, "createdAt", "resolvedAt", "pickedUpAt", "historyLogs", "assignedToId", "sensorId") VALUES (7, 'System generated alarm: Value 16.05 is out of range (18 - 26).', 'LOW', 'NEW', '2026-05-18 12:26:55.119842', NULL, '2026-06-05 17:32:19.418+00', '📥 @kristina preuzeo u 19:32 | ↩️ @kristina odustao u 19:32', NULL, 8);
INSERT INTO public.incident (id, description, severity, status, "createdAt", "resolvedAt", "pickedUpAt", "historyLogs", "assignedToId", "sensorId") VALUES (91, '[RUČNA PRIJAVA - kristina]: Klima se pokvarila, temperatura previsoka', 'CRITICAL', 'NEW', '2026-06-18 19:43:37.225792', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.incident (id, description, severity, status, "createdAt", "resolvedAt", "pickedUpAt", "historyLogs", "assignedToId", "sensorId") VALUES (45, 'System generated alarm: Value 33.31 is out of range (11 - 14.5).', 'MEDIUM', 'RESOLVED', '2026-05-18 13:31:36.135573', '2026-05-18 13:50:46.878+00', '2026-05-18 13:49:27.615+00', '📥 @kristina preuzeo u 15:43 | ↩️ @kristina odustao u 15:46 | 📥 @ognjen preuzeo u 15:49 | 🏁 @ognjen rešio u 15:50', 1, 6);
INSERT INTO public.incident (id, description, severity, status, "createdAt", "resolvedAt", "pickedUpAt", "historyLogs", "assignedToId", "sensorId") VALUES (47, 'System generated alarm: Value -3.59 is out of range (11 - 14.5).', 'MEDIUM', 'RESOLVED', '2026-05-18 13:52:51.674147', '2026-06-18 20:17:58.802+00', '2026-06-18 20:17:20.48+00', '📥 @kristina preuzeo u 22:17 | 🏁 @kristina rešio u 22:17', 3, 6);
INSERT INTO public.incident (id, description, severity, status, "createdAt", "resolvedAt", "pickedUpAt", "historyLogs", "assignedToId", "sensorId") VALUES (92, 'System generated alarm: Value 18.77 is out of range (11 - 14.5).', 'MEDIUM', 'NEW', '2026-06-18 23:21:23.174775', NULL, NULL, NULL, NULL, 6);
INSERT INTO public.incident (id, description, severity, status, "createdAt", "resolvedAt", "pickedUpAt", "historyLogs", "assignedToId", "sensorId") VALUES (6, 'System generated alarm: Value 47.23 is out of range (-25 - 45).', 'CRITICAL', 'RESOLVED', '2026-05-18 12:26:30.009096', '2026-06-15 18:00:08.124+00', '2026-06-15 17:59:15.373+00', '📥 @kristina preuzeo u 19:59 | 🏁 @kristina rešio u 20:00', 3, 1);
INSERT INTO public.incident (id, description, severity, status, "createdAt", "resolvedAt", "pickedUpAt", "historyLogs", "assignedToId", "sensorId") VALUES (88, 'System generated alarm: Value 57.16 is out of range (-25 - 45).', 'CRITICAL', 'NEW', '2026-06-15 18:00:12.182748', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.incident (id, description, severity, status, "createdAt", "resolvedAt", "pickedUpAt", "historyLogs", "assignedToId", "sensorId") VALUES (49, 'System generated alarm: Value 40.42 is out of range (50 - 78).', 'CRITICAL', 'RESOLVED', '2026-06-05 00:38:30.738343', '2026-06-15 23:20:06.094+00', '2026-06-15 23:12:49.586+00', '📥 @kristina preuzeo u 00:44 | ↩️ @kristina odustao u 01:08 | 📥 @milica preuzeo u 01:12 | 🏁 @milica rešio u 01:20', 2, 11);


--
-- Data for Name: measurement; Type: TABLE DATA; Schema: public; Owner: kristina
--

INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1, -29.31, '2026-06-18 23:54:49.535+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2, 34.55, '2026-06-18 23:54:49.56+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (3, 64.84, '2026-06-18 23:54:49.57+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (4, 4.85, '2026-06-18 23:54:49.582+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (5, 231.8, '2026-06-18 23:54:49.593+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (6, 13.92, '2026-06-18 23:54:49.601+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (7, 44.61, '2026-06-18 23:54:49.611+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (8, 22.14, '2026-06-18 23:54:49.619+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (9, 62.24, '2026-06-18 23:54:49.629+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (10, 1.77, '2026-06-18 23:54:54.539+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (11, 13.33, '2026-06-18 23:54:54.55+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (12, 49.47, '2026-06-18 23:54:54.56+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (13, 4.33, '2026-06-18 23:54:54.569+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (14, 251.31, '2026-06-18 23:54:54.577+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (15, 13.88, '2026-06-18 23:54:54.591+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (16, 54.92, '2026-06-18 23:54:54.599+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (17, 29.27, '2026-06-18 23:54:54.611+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (18, 62.44, '2026-06-18 23:54:54.624+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (19, 58.81, '2026-06-18 23:51:29.455+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (20, 25.89, '2026-06-18 23:42:39.079+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (21, 23.7, '2026-06-18 23:37:43.864+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (22, 224.41, '2026-06-16 13:56:48.66+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (23, 31.72, '2026-06-18 23:40:53.94+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (24, 18.21, '2026-06-18 23:51:49.415+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (25, 50.8, '2026-06-15 23:21:43.065+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (26, 2.6, '2026-06-18 23:39:28.881+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (27, 79.43, '2026-06-18 23:37:18.802+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (28, 13.31, '2026-06-18 23:53:09.507+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (29, 36.74, '2026-06-18 23:50:34.399+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (30, 230.8, '2026-06-16 13:58:28.634+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (31, 25.17, '2026-06-18 23:52:09.438+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (32, 27.18, '2026-06-18 23:51:44.449+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (33, 232.43, '2026-06-18 23:42:59.044+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (34, 50.78, '2026-06-18 23:34:23.716+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (35, 17.87, '2026-06-18 23:38:53.878+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (36, 39.58, '2026-06-18 23:37:33.856+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (37, 2.05, '2026-06-18 23:49:14.325+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (38, 12.47, '2026-06-18 23:36:08.773+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (39, -3.13, '2026-06-18 19:44:29.772+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (40, -21.85, '2026-06-18 23:34:28.669+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (41, 8.85, '2026-06-18 23:40:43.928+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (42, 12.83, '2026-06-18 23:36:13.79+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (43, 59.3, '2026-06-18 23:47:54.248+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (44, 16.56, '2026-06-18 19:39:24.718+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (45, 3.12, '2026-06-18 23:41:28.951+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (46, 4.89, '2026-06-18 23:53:09.492+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (47, 22.16, '2026-06-18 19:41:19.844+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (48, 219.03, '2026-06-16 14:02:03.788+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (49, 21.45, '2026-06-18 23:53:04.53+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (50, 11.71, '2026-06-18 23:43:09.025+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (51, 49.56, '2026-06-18 23:50:19.357+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (52, 66.64, '2026-06-18 23:38:13.877+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (53, 237.36, '2026-06-16 14:03:28.79+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (54, 15.67, '2026-06-18 23:34:38.688+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (55, 3.34, '2026-06-18 23:34:33.7+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (56, 2.66, '2026-06-18 23:50:24.355+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (57, 1.04, '2026-06-18 23:53:39.512+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (58, 19.55, '2026-06-18 23:37:58.876+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (59, 233.1, '2026-06-18 23:39:28.887+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (60, 19.76, '2026-06-18 23:39:48.936+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (61, 31.01, '2026-06-18 23:51:39.421+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (62, 71.75, '2026-06-15 23:23:08.036+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (63, -1.34, '2026-05-18 12:25:00.018+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (64, 2.2, '2026-06-18 23:50:09.37+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (65, 70.63, '2026-06-18 23:38:03.888+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (66, 19.14, '2026-06-18 23:40:18.979+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (67, 15.74, '2026-06-15 18:00:07.116+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (68, 58.03, '2026-06-18 23:41:34.031+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (69, 47.63, '2026-06-18 23:42:08.999+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (70, 226.22, '2026-06-16 13:57:03.583+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (71, 71.12, '2026-06-18 23:49:24.38+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (72, 43.11, '2026-06-18 23:50:39.378+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (73, 11.28, '2026-06-18 23:40:58.961+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (74, 218.9, '2026-06-18 23:34:38.705+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (75, 32.59, '2026-06-18 23:48:29.272+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (76, 61.96, '2026-06-18 23:35:13.763+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (77, 0.03, '2026-06-18 19:38:59.718+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (78, 13.4, '2026-06-18 23:37:33.845+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (79, 22.93, '2026-06-18 23:37:13.846+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (80, -1.05, '2026-06-18 23:40:48.922+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (81, 22.88, '2026-06-18 23:50:59.388+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (82, 11.24, '2026-06-18 23:41:38.961+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (83, 3.24, '2026-06-18 23:21:43.184+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (84, 235.53, '2026-06-16 14:03:18.825+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (85, 24.47, '2026-06-18 23:50:29.366+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (86, 11.24, '2026-06-18 23:39:58.93+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (87, 1.3, '2026-06-18 23:53:04.494+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (88, 21.55, '2026-06-18 23:37:53.877+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (89, 227.69, '2026-06-18 23:34:28.718+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (90, -26.15, '2026-06-18 23:39:13.859+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (91, 5.1, '2026-06-18 19:42:04.743+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (92, 8.51, '2026-06-18 23:52:59.47+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (93, 2.85, '2026-06-18 23:39:23.901+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (94, 212.44, '2026-06-18 23:50:29.39+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (95, 55.72, '2026-06-18 23:41:44.021+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (96, 60.75, '2026-06-18 23:36:18.838+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (97, 3.8, '2026-06-18 23:34:28.709+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (98, 17.55, '2026-06-18 19:39:14.716+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (99, 13.97, '2026-06-18 23:49:14.339+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (100, 232.38, '2026-06-18 23:41:38.989+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (101, 8.77, '2026-06-15 17:55:32.052+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (102, 62.3, '2026-06-18 23:36:58.869+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (103, 92.26, '2026-06-18 23:50:34.412+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (104, -4.45, '2026-06-18 19:43:54.764+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (105, 41.03, '2026-06-15 23:15:37.86+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (106, 52.8, '2026-06-18 23:41:18.959+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (107, 215.39, '2026-06-18 23:36:43.794+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (108, 18.81, '2026-06-18 23:43:04.05+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (109, 238.09, '2026-06-18 23:35:18.756+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (110, 38.16, '2026-06-18 23:50:09.36+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (111, 57.16, '2026-06-15 18:00:12.117+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (112, 27.56, '2026-06-18 23:46:59.213+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (113, 30.88, '2026-06-18 23:38:28.837+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (114, 31.08, '2026-06-18 23:37:28.802+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (115, 22.3, '2026-06-15 17:57:12.077+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (116, 11.54, '2026-06-18 23:53:39.53+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (117, 4.41, '2026-06-15 17:57:07.075+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (118, 87.94, '2026-06-18 23:37:08.845+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (119, -18.75, '2026-06-18 23:40:14.003+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (120, 56.91, '2026-06-18 23:47:14.238+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (121, 212.47, '2026-06-18 23:51:44.442+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (122, 21.85, '2026-06-15 17:59:42.112+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (123, 28.86, '2026-06-18 23:35:58.747+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (124, 104.72, '2026-06-18 23:41:18.991+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (125, 210.21, '2026-06-18 23:47:39.252+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (126, 11.18, '2026-06-18 23:35:43.757+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (127, 10.77, '2026-06-18 23:48:59.286+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (128, 8.64, '2026-06-18 23:42:08.991+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (129, 18.54, '2026-06-18 23:52:04.445+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (130, 225.96, '2026-06-18 23:48:54.311+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (131, 222.07, '2026-06-18 23:37:18.818+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (132, 215.65, '2026-06-18 23:36:03.769+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (133, 43.08, '2026-06-15 18:01:52.136+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (134, -4.25, '2026-06-15 17:59:52.113+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (135, 239.13, '2026-06-18 23:36:58.812+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (136, 29.63, '2026-06-18 23:36:23.757+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (137, 38.03, '2026-06-18 23:53:14.525+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (138, 12.05, '2026-06-18 23:21:38.166+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (139, 23.1, '2026-06-18 23:36:58.858+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (140, 8.39, '2026-06-18 19:47:14.802+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (141, 41.87, '2026-06-18 23:40:08.912+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (142, 57.39, '2026-06-18 23:38:33.95+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (143, 0.11, '2026-06-18 23:41:13.952+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (144, 220.36, '2026-06-18 23:51:54.444+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (145, -7.07, '2026-06-18 23:54:09.509+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (146, 54.04, '2026-06-18 23:52:49.495+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (147, 22.32, '2026-06-18 23:47:04.295+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (148, 76.44, '2026-06-15 23:20:03.078+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (149, 68.65, '2026-06-18 23:35:58.789+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (150, 13.46, '2026-06-18 23:43:09.054+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (151, 35.04, '2026-06-18 23:49:39.354+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (152, 28.65, '2026-06-18 23:35:03.715+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (153, 32.29, '2026-06-18 23:21:03.164+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (154, 11.68, '2026-06-18 23:40:13.992+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (155, 77.39, '2026-06-18 23:41:54.009+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (156, 31.7, '2026-06-18 23:34:33.686+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (157, 55.03, '2026-06-18 23:41:24.003+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (158, 230.16, '2026-06-18 23:41:59.01+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (159, 27.24, '2026-06-18 19:40:54.735+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (160, 113.55, '2026-06-18 23:35:53.777+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (161, 35.47, '2026-06-18 19:40:39.729+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (162, 225.39, '2026-06-18 23:41:53.994+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (163, 4.52, '2026-06-18 23:54:04.573+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (164, 23.49, '2026-06-18 23:48:14.248+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (165, 11.2, '2026-06-18 23:50:19.382+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (166, 225.43, '2026-06-16 14:02:28.774+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (167, 81.16, '2026-06-18 23:50:14.361+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (168, 232.04, '2026-06-18 23:53:14.502+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (169, 12.12, '2026-06-18 23:24:48.316+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (170, 18.89, '2026-06-18 23:53:19.525+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (171, 233.97, '2026-06-16 13:54:43.527+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (172, 20.42, '2026-06-18 23:47:09.272+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (173, 21.87, '2026-06-18 23:47:04.222+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (174, 229.07, '2026-06-16 13:53:43.531+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (175, 22.78, '2026-06-18 19:47:04.805+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (176, 14.03, '2026-06-18 23:42:49.054+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (177, 42.86, '2026-06-18 23:52:49.508+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (178, 2.17, '2026-06-18 23:49:49.353+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (179, 22.19, '2026-06-15 17:55:42.058+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (180, 0.32, '2026-06-18 23:37:18.787+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (181, 76.5, '2026-06-18 23:35:38.775+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (182, 17.84, '2026-06-18 19:48:34.817+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (183, 219.65, '2026-06-18 23:41:23.977+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (184, 63.22, '2026-06-18 23:37:03.844+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (185, 5.34, '2026-06-18 23:40:23.912+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (186, 216.1, '2026-06-18 23:47:54.258+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (187, 29.08, '2026-06-18 23:49:29.341+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (188, 19.06, '2026-06-18 23:48:49.277+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (189, 58.41, '2026-06-18 19:45:54.79+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (190, 2.13, '2026-06-18 23:49:39.338+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (191, 24.34, '2026-06-18 23:51:29.408+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (192, 18.36, '2026-06-18 23:40:23.958+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (193, -6.24, '2026-06-15 17:56:02.061+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (194, 21.69, '2026-06-18 23:37:38.811+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (195, 71.74, '2026-06-18 23:36:23.804+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (196, 8.62, '2026-06-18 23:34:43.714+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (197, 18.1, '2026-06-15 18:03:22.155+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (198, 6.4, '2026-06-18 23:53:14.477+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (199, 14.17, '2026-06-18 23:39:53.998+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (200, 1.81, '2026-06-18 23:36:03.762+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (201, 23.93, '2026-06-18 23:40:48.934+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (202, 11.47, '2026-06-18 23:25:13.312+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (203, 20.65, '2026-06-18 23:37:03.833+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (204, 18.45, '2026-06-18 23:39:38.883+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (205, 59.95, '2026-06-18 23:49:29.348+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (206, 6.32, '2026-06-18 23:51:19.4+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (207, 19.66, '2026-06-18 23:50:59.442+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (208, -7.86, '2026-06-18 23:52:49.486+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (209, 11.21, '2026-06-18 23:43:09.032+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (210, 61.83, '2026-06-18 23:39:03.897+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (211, -9.3, '2026-06-18 19:42:54.754+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (212, -7.64, '2026-06-18 23:42:49.01+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (213, 57.96, '2026-06-18 23:51:19.459+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (214, 13.57, '2026-06-18 23:23:08.221+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (215, 0.1, '2026-06-18 19:46:59.802+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (216, -17.76, '2026-06-18 23:47:04.193+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (217, 59.62, '2026-06-15 23:16:22.889+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (218, 77.36, '2026-06-18 23:40:23.965+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (219, 22.55, '2026-06-18 23:34:23.676+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (220, 16.13, '2026-06-18 23:37:03.784+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (221, 237.59, '2026-06-18 23:41:33.998+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (222, 2.62, '2026-06-18 23:24:13.27+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (223, 245.74, '2026-06-18 23:38:38.869+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (224, 50.18, '2026-06-15 23:21:37.996+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (225, 75.63, '2026-06-15 23:18:32.918+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (226, 2.59, '2026-06-18 23:36:18.781+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (227, 222.85, '2026-06-16 13:59:08.635+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (228, 229.8, '2026-06-18 23:51:29.426+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (229, 78.2, '2026-06-15 23:21:23.02+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (230, 11.15, '2026-06-18 23:37:18.825+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (231, 18.71, '2026-06-18 23:41:59.036+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (232, 33.14, '2026-06-18 23:52:34.454+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (233, 71.66, '2026-06-18 23:36:33.838+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (234, 24.31, '2026-06-15 18:04:12.168+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (235, 15.04, '2026-06-18 19:43:19.755+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (236, 61.33, '2026-06-15 23:16:42.846+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (237, 74.8, '2026-06-18 23:37:58.869+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (238, 4.8, '2026-06-18 23:47:54.253+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (239, 83.55, '2026-06-15 23:19:17.931+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (240, 212.05, '2026-06-18 23:51:59.459+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (241, 4.8, '2026-06-18 23:52:54.459+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (242, 4.16, '2026-06-18 23:34:58.74+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (243, 67.54, '2026-06-18 23:35:33.765+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (244, 51.15, '2026-06-18 23:48:04.27+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (245, 37.31, '2026-06-18 23:52:39.465+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (246, 218.15, '2026-06-18 23:51:49.442+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (247, 10.56, '2026-06-18 23:47:09.214+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (248, 4.78, '2026-06-18 23:35:03.722+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (249, 32.11, '2026-06-18 23:38:28.876+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (250, 11.04, '2026-06-18 23:43:04.069+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (251, 4.03, '2026-06-18 23:37:23.814+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (252, 23.25, '2026-06-18 23:54:09.562+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (253, 72.83, '2026-06-18 23:53:34.551+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (254, 71.58, '2026-06-15 23:22:43.011+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (255, 33.43, '2026-06-18 23:36:48.839+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (256, 6.47, '2026-06-18 23:41:43.966+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (257, 72.35, '2026-06-18 23:50:59.433+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (258, 10.63, '2026-06-18 23:48:54.288+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (259, 30.58, '2026-06-18 23:37:58.826+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (260, 4.63, '2026-06-18 23:49:59.353+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (261, -3.54, '2026-06-18 23:41:38.999+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (262, 9.38, '2026-06-18 23:37:48.827+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (263, 4.48, '2026-06-18 23:38:08.84+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (264, 42.74, '2026-06-18 23:42:59.033+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (265, 45.2, '2026-06-18 23:39:08.869+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (266, 14.05, '2026-06-18 23:42:59.049+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (267, 55.37, '2026-06-18 23:38:53.886+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (268, 59.87, '2026-06-18 23:42:19.003+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (269, 61.42, '2026-06-18 23:47:34.264+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (270, 6.7, '2026-06-18 23:47:39.22+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (271, 30.05, '2026-06-18 23:51:34.412+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (272, 39.8, '2026-06-18 23:49:19.342+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (273, 11.85, '2026-06-18 23:34:48.728+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (274, 2.97, '2026-06-18 23:41:03.962+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (275, 13.44, '2026-06-18 23:35:48.762+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (276, 229.27, '2026-06-18 23:49:59.36+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (277, 29.93, '2026-06-18 19:46:24.794+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (278, -7.1, '2026-06-18 23:48:04.286+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (279, -7.28, '2026-06-18 23:48:24.255+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (280, 220.89, '2026-06-18 23:51:14.415+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (281, 21.92, '2026-06-18 23:49:39.359+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (282, 23.64, '2026-06-18 23:46:49.183+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (283, 90.97, '2026-06-18 23:38:38.851+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (284, 20.6, '2026-06-15 18:01:57.137+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (285, 12.84, '2026-06-18 23:47:59.233+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (286, 12.53, '2026-06-18 23:39:48.921+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (287, 11.93, '2026-06-18 23:47:19.252+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (288, 14.93, '2026-06-18 19:48:04.815+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (289, 17.86, '2026-06-18 19:40:04.723+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (290, 11.47, '2026-06-15 17:59:12.111+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (291, 34.21, '2026-06-18 23:51:04.411+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (292, 226.11, '2026-06-18 23:43:04.1+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (293, -11.07, '2026-06-15 18:00:02.112+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (294, 215.1, '2026-06-18 23:49:14.331+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (295, 8, '2026-06-18 19:46:19.794+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (296, 237.58, '2026-06-18 23:35:48.756+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (297, 216.68, '2026-06-16 13:54:18.531+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (298, 216.45, '2026-06-16 14:02:58.796+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (299, 218.99, '2026-06-18 23:38:13.847+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (300, -6.18, '2026-06-18 23:39:08.856+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (301, 70.71, '2026-06-18 23:53:04.483+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (302, 11.56, '2026-06-18 23:41:18.954+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (303, 2.87, '2026-06-18 23:40:48.94+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (304, 56.99, '2026-06-18 23:35:28.791+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (305, 40.34, '2026-06-18 23:37:38.817+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (306, 67.22, '2026-06-15 23:19:52.945+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (307, 25.83, '2026-06-18 23:47:39.272+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (308, 4.31, '2026-06-18 23:34:58.713+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (309, 47.57, '2026-06-18 23:37:23.859+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (310, 56.14, '2026-06-15 23:24:53.186+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (311, 274.79, '2026-06-16 13:56:28.583+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (312, 13.19, '2026-06-18 23:36:48.832+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (313, 6.99, '2026-06-18 23:51:54.424+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (314, 66.34, '2026-06-15 23:24:18.161+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (315, 71.78, '2026-06-18 23:50:39.408+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (316, 21.57, '2026-06-18 23:35:38.73+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (317, 227.72, '2026-06-16 13:55:58.61+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (318, 13.41, '2026-06-18 23:39:28.893+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (319, 13.54, '2026-06-18 23:24:33.301+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (320, 4.05, '2026-06-15 18:03:27.157+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (321, 43.17, '2026-06-18 23:50:29.374+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (322, 19.64, '2026-06-18 23:40:53.98+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (323, 0, '2026-06-18 23:52:29.486+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (324, 30.77, '2026-06-18 23:52:19.446+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (325, 67.8, '2026-06-15 23:25:13.219+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (326, 226.59, '2026-06-18 23:46:49.226+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (327, 4.45, '2026-06-18 23:40:03.923+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (328, 20.14, '2026-06-15 18:04:37.17+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (329, 81.56, '2026-06-15 23:19:07.96+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (330, 20.86, '2026-06-18 23:54:09.517+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (331, -3.01, '2026-06-18 23:35:28.769+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (332, 21.67, '2026-06-18 23:42:03.988+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (333, 18.22, '2026-06-18 23:36:53.837+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (334, 254.6, '2026-06-18 23:36:38.798+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (335, 25.47, '2026-06-18 23:46:54.297+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (336, 4.23, '2026-06-18 23:35:33.736+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (337, 24.53, '2026-06-18 23:50:39.398+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (338, 83.35, '2026-06-18 23:34:38.738+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (339, 44.79, '2026-06-18 23:41:53.981+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (340, 29.54, '2026-06-18 23:42:14.059+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (341, 234.04, '2026-06-16 13:55:33.569+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (342, 97.48, '2026-06-18 23:50:19.388+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (343, 232.39, '2026-06-18 23:35:28.754+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (344, 87.14, '2026-06-18 23:41:23.992+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (345, 55.37, '2026-06-15 23:19:02.954+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (346, 13.77, '2026-06-18 23:40:58.937+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (347, 22.69, '2026-06-18 23:53:39.494+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (348, 104.01, '2026-06-18 23:36:58.834+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (349, 2.91, '2026-06-15 18:02:07.14+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (350, 217.87, '2026-06-18 23:35:38.745+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (351, 33.56, '2026-06-18 23:51:59.474+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (352, 35.84, '2026-06-18 23:42:04.033+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (353, 3.71, '2026-06-18 23:53:59.52+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (354, 1.71, '2026-06-18 23:41:23.972+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (355, -29.06, '2026-06-18 19:42:49.753+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (356, 14.32, '2026-06-18 23:49:34.345+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (357, 30.57, '2026-06-18 23:51:49.422+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (358, 11.98, '2026-06-18 23:53:49.53+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (359, 70.01, '2026-06-18 23:50:54.429+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (360, 19.5, '2026-06-15 18:01:42.134+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (361, 7.93, '2026-06-18 23:53:34.501+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (362, 21.42, '2026-06-18 23:50:24.418+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (363, 23.22, '2026-06-18 23:53:19.486+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (364, 10.1, '2026-06-15 18:04:07.165+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (365, 14.18, '2026-06-18 23:24:53.335+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (366, 22.88, '2026-06-18 19:40:09.719+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (367, 77.86, '2026-06-18 23:46:54.308+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (368, -33.99, '2026-06-18 23:38:33.835+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (369, 24.35, '2026-06-18 23:52:34.514+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (370, 65.6, '2026-06-18 23:53:54.552+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (371, 62.04, '2026-06-18 23:43:09.073+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (372, 58.89, '2026-06-18 23:49:19.317+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (373, -2.34, '2026-06-18 23:51:24.423+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (374, 1.23, '2026-06-18 23:50:54.453+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (375, 233.51, '2026-06-16 13:59:13.802+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (376, -4.56, '2026-06-18 23:53:04.467+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (377, 43.42, '2026-06-18 23:42:09.06+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (378, 238.82, '2026-06-18 23:40:18.956+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (379, 210.84, '2026-06-18 23:42:49.044+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (380, -1.31, '2026-06-18 23:36:08.74+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (381, 175.22, '2026-06-18 23:36:18.788+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (382, 21.78, '2026-06-18 23:41:38.969+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (383, 43.78, '2026-06-18 23:42:49.03+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (384, -2.66, '2026-06-18 23:39:53.883+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (385, -36.38, '2026-06-15 17:58:37.107+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (386, 219.46, '2026-06-18 23:34:53.716+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (387, 57.31, '2026-06-15 23:15:57.927+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (388, 59.56, '2026-06-18 23:52:14.496+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (389, 3.96, '2026-06-18 23:48:29.279+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (390, 52.45, '2026-06-15 23:18:12.932+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (391, 3.1, '2026-06-18 23:42:29.016+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (392, 8.95, '2026-06-18 23:49:34.325+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (393, 14.91, '2026-06-18 23:41:03.99+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (394, 2.83, '2026-06-18 23:51:49.436+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (395, 226.64, '2026-06-18 23:42:04.016+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (396, 4.84, '2026-06-18 23:48:14.266+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (397, 232.77, '2026-06-16 13:58:33.636+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (398, 243.76, '2026-06-18 23:47:04.247+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (399, 11.96, '2026-06-18 23:41:03.976+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (400, 14.38, '2026-06-18 23:48:39.3+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (401, -3.29, '2026-06-15 17:55:57.059+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (402, 23.64, '2026-06-18 23:52:44.46+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (403, 225.25, '2026-06-18 23:37:13.819+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (404, 11.74, '2026-06-18 23:23:03.22+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (405, 11.89, '2026-06-18 23:43:04.037+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (406, 6.95, '2026-06-18 23:41:58.972+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (407, 0.87, '2026-06-18 23:51:04.4+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (408, 5.36, '2026-06-18 23:50:49.372+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (409, 23.01, '2026-06-18 23:48:59.342+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (410, 57.31, '2026-06-18 23:52:09.511+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (411, 21.38, '2026-06-18 23:51:44.423+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (412, 1.93, '2026-06-18 23:46:59.231+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (413, 12.77, '2026-06-18 23:35:03.744+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (414, -1.09, '2026-06-18 23:51:54.454+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (415, 12.38, '2026-06-18 23:42:04.027+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (416, 14.08, '2026-06-18 19:47:29.808+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (417, 179.06, '2026-06-18 23:37:03.8+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (418, 3.94, '2026-06-18 23:47:29.235+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (419, 225.69, '2026-06-16 13:55:43.605+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (420, 36.59, '2026-06-18 23:40:08.943+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (421, 57.07, '2026-06-18 23:49:54.398+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (422, 1.3, '2026-06-15 17:58:52.107+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (423, 31.14, '2026-06-18 23:48:54.298+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (424, 54.46, '2026-06-18 19:42:29.747+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (425, 3.45, '2026-06-18 23:36:13.766+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (426, 22.51, '2026-06-18 23:51:09.397+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (427, 11.95, '2026-06-18 23:40:18.962+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (428, 2, '2026-06-18 23:47:24.229+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (429, 43.21, '2026-06-18 23:35:08.715+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (430, 14.67, '2026-06-18 23:48:04.293+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (431, 2.99, '2026-06-18 23:24:18.264+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (432, 25.86, '2026-06-18 23:36:38.831+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (433, 33.07, '2026-06-18 23:47:54.241+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (434, 44.18, '2026-06-18 23:52:14.446+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (435, 217.34, '2026-06-18 23:50:49.399+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (436, 235.51, '2026-06-18 23:38:58.889+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (437, 19.89, '2026-06-18 23:40:48.964+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (438, -0.04, '2026-06-15 18:05:12.181+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (439, 210.16, '2026-06-16 14:00:33.729+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (440, 164.24, '2026-06-16 13:54:13.557+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (441, 38.85, '2026-06-18 23:36:33.776+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (442, 61.65, '2026-06-18 23:43:09.037+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (443, 28.75, '2026-06-18 23:49:44.335+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (444, 11.37, '2026-06-18 23:53:24.531+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (445, 13.67, '2026-06-18 23:25:23.327+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (446, 59.42, '2026-06-18 23:50:44.387+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (447, 42.57, '2026-06-18 23:52:29.497+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (448, 2.07, '2026-06-18 23:40:23.929+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (449, 47.21, '2026-06-18 23:38:28.868+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (450, 78.41, '2026-06-18 23:36:38.777+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (451, -3.2, '2026-06-18 19:39:19.717+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (452, 23.09, '2026-06-18 19:42:19.743+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (453, 26.41, '2026-06-15 18:00:27.118+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (454, 212.91, '2026-06-16 13:56:58.604+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (455, 39.32, '2026-06-18 23:51:49.461+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (456, 11.59, '2026-06-18 23:53:59.532+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (457, 252.75, '2026-06-16 13:59:38.768+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (458, 5.95, '2026-06-18 23:53:49.492+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (459, 30.03, '2026-06-18 23:37:08.836+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (460, 4.56, '2026-06-18 23:35:43.746+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (461, 30.84, '2026-06-18 23:42:59.028+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (462, 1.07, '2026-06-18 23:39:03.869+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (463, 1.76, '2026-06-18 23:34:28.761+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (464, 12.36, '2026-06-18 23:22:23.206+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (465, 211, '2026-06-18 23:51:24.432+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (466, 17.88, '2026-06-18 23:47:34.252+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (467, 224.69, '2026-06-16 14:00:23.732+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (468, -1.9, '2026-06-18 23:52:19.47+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (469, 22.15, '2026-06-18 23:52:14.487+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (470, 4.13, '2026-06-18 23:49:34.335+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (471, 3.93, '2026-06-18 23:52:09.459+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (472, 11.16, '2026-06-15 18:00:57.125+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (473, 14.08, '2026-06-18 23:49:04.338+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (474, -4.36, '2026-06-18 23:35:38.756+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (475, 74.02, '2026-06-18 23:53:09.516+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (476, 32.82, '2026-06-18 23:42:03.977+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (477, 19.86, '2026-06-18 19:40:29.732+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (478, 42.14, '2026-06-18 23:37:08.797+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (479, 12.26, '2026-06-18 23:49:39.321+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (480, 100.32, '2026-06-18 23:35:43.762+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (481, 36.67, '2026-06-18 23:40:58.967+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (482, -1.81, '2026-06-18 23:42:59.054+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (483, 12.45, '2026-06-18 23:23:43.252+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (484, 27.92, '2026-06-18 23:34:58.707+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (485, 74.23, '2026-06-15 23:20:07.963+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (486, 222.01, '2026-06-16 14:02:38.811+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (487, 32.31, '2026-06-18 23:41:43.98+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (488, -18.87, '2026-06-18 23:42:54.039+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (489, 0.72, '2026-06-18 23:42:59.037+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (490, 46.92, '2026-06-18 23:35:33.731+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (491, 50.61, '2026-06-18 23:47:14.214+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (492, 34.97, '2026-06-18 23:34:48.701+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (493, 40.88, '2026-06-18 23:41:58.979+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (494, 47.29, '2026-06-18 23:35:18.706+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (495, 24.02, '2026-06-18 23:48:14.288+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (496, 8.92, '2026-06-15 18:04:47.173+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (497, 13.92, '2026-06-18 23:41:23.984+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (498, 32.79, '2026-06-18 23:48:49.323+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (499, 41.98, '2026-06-18 19:46:09.792+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (500, 14.05, '2026-06-18 23:21:48.171+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (501, 32.84, '2026-06-18 23:51:44.414+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (502, 67.44, '2026-06-15 23:24:08.072+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (503, 23.32, '2026-06-18 23:37:48.885+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (504, 17.57, '2026-06-18 23:38:33.887+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (505, 39.65, '2026-06-18 23:42:34.014+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (506, 52.23, '2026-06-18 23:48:29.258+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (507, -3.66, '2026-06-18 23:53:59.498+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (508, 4.15, '2026-06-18 23:53:29.498+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (509, 1.97, '2026-06-18 23:49:14.302+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (510, 53.48, '2026-06-15 23:16:32.855+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (511, 14.45, '2026-06-18 23:54:04.523+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (512, -7.19, '2026-06-18 23:51:54.466+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (513, 2.47, '2026-06-18 19:46:49.798+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (514, 228.28, '2026-06-18 23:39:03.875+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (515, 12.26, '2026-06-18 23:42:44.016+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (516, 2.76, '2026-06-18 23:40:33.91+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (517, 20.77, '2026-06-18 23:35:58.784+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (518, 32.23, '2026-06-18 23:49:54.343+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (519, 24.02, '2026-06-18 23:42:04.04+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (520, 234.97, '2026-06-18 23:48:09.27+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (521, 214.64, '2026-06-18 23:39:13.904+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (522, 11.61, '2026-06-18 23:40:28.95+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (523, 55.2, '2026-06-18 23:36:48.797+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (524, 11.46, '2026-06-18 23:48:19.288+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (525, 70.91, '2026-06-15 23:17:17.889+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (526, 11.86, '2026-06-18 23:22:08.199+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (527, 236.83, '2026-06-18 23:41:43.993+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (528, 5.31, '2026-06-18 23:53:24.484+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (529, 18.9, '2026-06-18 23:39:08.904+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (530, 62.91, '2026-06-15 23:21:32.983+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (531, 5.16, '2026-06-18 23:38:23.828+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (532, 30.82, '2026-06-18 23:53:24.557+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (533, 50.28, '2026-06-18 23:38:08.858+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (534, 30.18, '2026-06-18 23:54:09.551+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (535, 65.5, '2026-06-18 23:34:53.738+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (536, 34.9, '2026-06-18 23:42:29.001+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (537, 225.8, '2026-06-18 23:41:13.976+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (538, 47.17, '2026-06-18 23:53:29.491+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (539, 28.83, '2026-06-18 23:48:39.278+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (540, 53.36, '2026-06-18 23:39:18.87+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (541, 12.6, '2026-06-18 23:40:28.914+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (542, 3.81, '2026-06-18 23:52:24.446+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (543, -0.38, '2026-06-18 23:49:29.356+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (544, 213.44, '2026-06-16 13:54:48.555+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (545, 238.04, '2026-06-16 13:53:58.565+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (546, 6.88, '2026-06-18 23:49:44.362+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (547, -6.84, '2026-06-15 18:01:22.129+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (548, 60.76, '2026-06-18 23:39:28.876+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (549, 87.58, '2026-06-18 23:35:58.776+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (550, 75.54, '2026-06-18 23:49:09.339+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (551, 64.9, '2026-06-18 23:50:04.4+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (552, -2.06, '2026-06-18 23:37:48.81+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (553, 13.56, '2026-06-18 23:42:34.045+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (554, 26.66, '2026-06-18 23:48:59.3+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (555, 68.37, '2026-06-15 23:17:22.891+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (556, 77.49, '2026-06-18 23:42:14.081+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (557, 4.16, '2026-06-18 23:38:13.842+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (558, 7.88, '2026-06-18 23:52:04.422+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (559, 25.29, '2026-06-18 23:48:39.305+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (560, 16.46, '2026-06-18 23:22:53.202+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (561, 52.63, '2026-06-15 23:20:28.033+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (562, -0.83, '2026-06-18 19:45:09.78+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (563, 226.15, '2026-06-18 23:53:29.504+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (564, 266.33, '2026-06-18 23:52:44.48+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (565, -13.59, '2026-06-18 23:42:19.011+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (566, -7.04, '2026-06-18 23:36:58.773+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (567, 238.05, '2026-06-18 23:40:48.948+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (568, 33.19, '2026-06-18 23:37:08.828+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (569, 38, '2026-06-15 23:22:33.023+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (570, -13.94, '2026-06-18 23:37:53.863+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (571, -24.85, '2026-06-18 23:34:48.684+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (572, 274.94, '2026-06-16 14:00:13.695+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (573, 71.05, '2026-06-18 23:37:28.902+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (574, 77.62, '2026-06-15 23:18:18.02+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (575, 40.53, '2026-06-18 23:51:24.475+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (576, 13.18, '2026-06-18 23:23:48.246+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (577, 6.58, '2026-06-18 23:49:09.303+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (578, 218.67, '2026-06-18 23:43:09.048+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (579, 23.64, '2026-06-18 23:47:49.289+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (580, 24.5, '2026-06-18 23:35:08.756+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (581, 65.08, '2026-06-15 23:22:28.013+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (582, 45.9, '2026-06-18 23:48:09.258+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (583, 10.74, '2026-06-18 23:39:23.872+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (584, 19.7, '2026-06-18 23:49:24.375+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (585, 4.77, '2026-06-18 23:40:18.944+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (586, 1.78, '2026-06-18 23:48:34.29+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (587, 32.52, '2026-06-18 23:37:48.821+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (588, 1.29, '2026-06-18 23:41:08.957+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (589, 5.94, '2026-06-18 23:50:59.38+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (590, 0.59, '2026-06-15 17:55:47.059+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (591, 10.22, '2026-06-15 18:00:42.128+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (592, 50.49, '2026-06-18 23:43:04.146+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (593, 262.24, '2026-06-16 13:56:33.644+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (594, 56.01, '2026-06-18 23:35:48.771+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (595, 62.49, '2026-06-18 23:47:09.223+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (596, 14.22, '2026-06-18 23:52:24.477+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (597, 12.73, '2026-06-18 23:21:33.158+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (598, 19.39, '2026-06-18 23:41:48.976+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (599, 214.51, '2026-06-18 23:38:03.854+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (600, 92.66, '2026-06-18 23:52:19.493+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (601, 4.7, '2026-06-18 19:45:04.783+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (602, 20.4, '2026-06-18 23:47:24.25+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (603, 25.64, '2026-06-18 23:49:34.33+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (604, 58.59, '2026-06-18 23:38:33.867+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (605, 14.22, '2026-06-18 23:39:33.901+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (606, 20.01, '2026-06-18 23:50:09.419+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (607, 18.67, '2026-06-18 19:40:19.724+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (608, 20.89, '2026-06-18 23:49:04.35+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (609, -8.63, '2026-06-18 23:36:03.746+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (610, 8.49, '2026-06-18 23:34:38.679+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (611, -13.32, '2026-06-15 18:00:47.127+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (612, 18.42, '2026-06-18 23:42:29.131+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (613, 34.77, '2026-06-18 23:49:09.328+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (614, -11.66, '2026-06-18 23:39:08.875+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (615, 59.56, '2026-06-18 23:47:29.225+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (616, 86.86, '2026-05-18 12:30:00.138+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (617, 230.85, '2026-06-16 14:00:48.736+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (618, 53.99, '2026-06-18 23:35:08.764+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (619, 104.63, '2026-06-18 23:49:24.32+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (620, -4.09, '2026-06-18 19:43:44.76+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (621, -4.72, '2026-06-18 19:42:34.751+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (622, 227.19, '2026-06-18 23:36:23.774+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (623, 0.91, '2026-06-18 23:36:28.772+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (624, 236.01, '2026-06-18 23:35:43.751+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (625, 14.15, '2026-06-18 23:21:58.166+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (626, 66.34, '2026-06-15 23:16:52.854+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (627, 13.58, '2026-06-18 23:37:38.832+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (628, 4.45, '2026-06-18 23:36:33.767+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (629, -1.94, '2026-06-18 23:34:33.676+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (630, 22.19, '2026-06-15 17:59:22.114+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (631, 59.66, '2026-06-18 19:48:24.816+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (632, 19.98, '2026-06-15 17:57:22.091+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (633, 13.16, '2026-06-18 23:38:38.881+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (634, 2.4, '2026-06-18 23:53:44.509+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (635, 27.36, '2026-06-18 23:41:23.96+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (636, -6.3, '2026-06-18 23:37:53.813+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (637, 3.26, '2026-06-18 23:47:14.219+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (638, 22.38, '2026-06-18 23:38:23.879+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (639, -8.44, '2026-06-18 23:49:09.296+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (640, 20.72, '2026-06-18 23:46:49.251+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (641, 3.07, '2026-06-18 23:52:24.463+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (642, 170.29, '2026-06-18 23:38:48.872+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (643, 231.2, '2026-06-16 14:02:48.795+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (644, 63.39, '2026-06-18 23:40:13.9+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (645, 23.6, '2026-06-18 23:53:59.507+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (646, 1.59, '2026-06-18 23:51:14.409+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (647, 60.11, '2026-06-15 18:05:07.18+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (648, 26.04, '2026-06-18 23:40:38.942+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (649, 236.51, '2026-06-18 23:51:34.43+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (650, 37.69, '2026-06-18 23:34:28.697+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (651, 69.41, '2026-06-18 23:40:43.961+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (652, 13.06, '2026-06-18 23:25:03.302+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (653, 1.36, '2026-06-18 23:37:03.794+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (654, -6.42, '2026-06-15 17:58:02.097+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (655, 24.04, '2026-06-18 23:24:28.276+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (656, 74.73, '2026-06-18 23:51:44.474+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (657, 19.41, '2026-06-18 23:42:18.997+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (658, 3.8, '2026-06-18 23:36:23.768+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (659, 53.24, '2026-06-18 23:35:18.788+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (660, 21.53, '2026-06-18 23:50:19.4+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (661, 18.53, '2026-06-18 23:37:38.803+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (662, 35.16, '2026-06-18 23:37:28.876+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (663, 228.63, '2026-06-18 23:37:58.852+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (664, 59.41, '2026-06-18 23:41:03.999+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (665, 2.36, '2026-06-18 23:48:04.275+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (666, 218.48, '2026-06-18 23:34:18.719+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (667, 44.87, '2026-06-15 23:21:27.995+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (668, 53.32, '2026-06-18 23:36:33.819+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (669, 92.97, '2026-06-15 23:20:23.091+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (670, 13.99, '2026-06-18 23:39:08.888+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (671, 215.54, '2026-06-16 14:00:38.712+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (672, 61.82, '2026-06-18 23:36:28.803+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (673, 223.57, '2026-06-18 23:38:23.857+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (674, 4.88, '2026-06-18 23:37:03.825+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (675, 26.97, '2026-06-18 23:48:29.331+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (676, 12.37, '2026-06-18 23:36:23.78+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (677, 24.08, '2026-06-18 23:37:23.846+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (678, 42.73, '2026-06-18 23:42:54.029+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (679, 4.86, '2026-06-18 23:42:24.027+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (680, 1.63, '2026-06-18 23:50:29.381+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (681, 22.52, '2026-06-15 18:00:22.12+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (682, -4.8, '2026-06-18 23:50:29.401+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (683, 59.1, '2026-06-18 23:48:44.336+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (684, 20.14, '2026-06-18 23:48:24.332+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (685, -5.14, '2026-06-18 23:37:13.8+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (686, 57.82, '2026-06-18 23:50:49.41+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (687, 18.83, '2026-06-15 18:02:37.149+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (688, 2.35, '2026-06-18 23:37:28.793+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (689, 87.78, '2026-06-18 23:42:24.07+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (690, 230.77, '2026-06-16 13:57:13.634+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (691, 27.15, '2026-06-18 23:48:59.293+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (692, 21.94, '2026-06-18 23:34:18.77+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (693, 73.9, '2026-06-18 23:41:19.013+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (694, 216.27, '2026-06-18 23:38:33.91+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (695, 2.43, '2026-06-18 23:52:54.48+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (696, 66.57, '2026-06-18 23:38:58.93+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (697, 235.41, '2026-06-16 14:03:23.799+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (698, 71.04, '2026-06-18 23:52:44.522+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (699, -17.53, '2026-06-18 23:52:09.486+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (700, 66.3, '2026-06-15 23:20:32.977+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (701, 72.09, '2026-06-18 23:53:49.54+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (702, 231.81, '2026-06-18 23:51:09.416+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (703, 70.84, '2026-06-18 23:42:04.046+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (704, 19.49, '2026-06-18 23:48:04.262+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (705, 63.27, '2026-06-15 23:23:03.031+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (706, 1.52, '2026-06-18 23:53:29.482+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (707, 8.24, '2026-06-18 19:44:19.771+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (708, -14.78, '2026-06-18 23:35:08.708+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (709, 48.04, '2026-06-18 23:51:14.404+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (710, 22.47, '2026-06-18 23:41:38.975+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (711, 230.71, '2026-06-16 14:00:53.8+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (712, 9.34, '2026-06-15 17:57:17.079+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (713, 2.66, '2026-06-18 23:42:14.017+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (714, 11.1, '2026-06-18 23:47:29.253+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (715, 2.45, '2026-06-18 23:50:14.368+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (716, 7.97, '2026-06-18 23:51:59.418+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (717, 218.42, '2026-06-18 23:53:24.525+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (718, 51.59, '2026-06-15 23:17:47.926+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (719, 12.7, '2026-06-18 23:48:49.31+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (720, 19.04, '2026-06-18 23:52:19.484+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (721, 20.7, '2026-06-18 23:52:04.478+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (722, 11.82, '2026-06-18 23:22:33.188+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (723, 223.43, '2026-06-18 23:49:09.318+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (724, -16.75, '2026-06-18 23:52:59.506+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (725, 162.62, '2026-06-16 14:02:53.784+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (726, 11.6, '2026-06-18 23:25:53.366+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (727, 72.11, '2026-06-18 23:48:09.295+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (728, 12.24, '2026-06-18 23:40:38.931+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (729, 12.64, '2026-06-18 23:50:54.477+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (730, 221.93, '2026-06-18 23:54:09.534+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (731, 68.49, '2026-06-18 23:38:48.914+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (732, 22.57, '2026-06-18 19:41:09.733+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (733, 239.01, '2026-06-18 23:40:38.97+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (734, 42.58, '2026-06-18 23:34:58.748+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (735, 211.9, '2026-06-18 23:50:09.377+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (736, 45.38, '2026-06-18 23:37:13.836+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (737, 39.64, '2026-06-18 23:47:49.245+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (738, 215.76, '2026-06-18 23:38:08.845+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (739, 74.25, '2026-06-15 23:22:58.031+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (740, -32.18, '2026-06-15 18:02:22.146+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (741, 232.62, '2026-06-18 23:34:43.709+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (742, -7.29, '2026-06-18 19:47:59.815+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (743, -12.7, '2026-06-15 18:03:57.161+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (744, 22.04, '2026-06-15 17:59:57.115+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (745, 13.85, '2026-06-18 23:51:24.397+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (746, 61.52, '2026-06-18 23:51:34.446+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (747, 245.6, '2026-06-18 23:52:54.487+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (748, 12.58, '2026-06-18 23:48:54.282+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (749, 50.74, '2026-06-15 23:24:58.113+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (750, 73.17, '2026-06-18 23:34:43.722+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (751, 3.2, '2026-06-18 23:37:28.829+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (752, 12.09, '2026-06-18 23:42:29.034+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (753, 21.3, '2026-06-18 23:35:28.782+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (754, 75.89, '2026-06-18 23:48:59.349+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (755, 27.38, '2026-06-18 23:37:33.807+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (756, 226.58, '2026-06-16 14:00:03.686+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (757, 89.65, '2026-06-18 23:35:23.745+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (758, 15.21, '2026-06-18 23:51:14.431+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (759, -4.97, '2026-06-18 23:53:24.492+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (760, 33.85, '2026-06-18 23:41:43.974+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (761, 61.31, '2026-06-18 23:37:58.885+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (762, 50.67, '2026-06-18 23:38:13.837+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (763, 56.69, '2026-06-18 23:54:04.592+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (764, 91.1, '2026-06-18 23:48:19.311+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (765, -15.35, '2026-06-18 23:50:09.395+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (766, 18.65, '2026-06-18 23:52:49.503+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (767, 215.92, '2026-06-18 23:42:44.041+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (768, 3.74, '2026-06-18 23:53:49.512+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (769, 28.83, '2026-06-18 23:42:09.023+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (770, 19.94, '2026-06-18 23:50:49.417+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (771, 2.23, '2026-06-18 23:41:53.987+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (772, 34.82, '2026-06-15 23:18:07.896+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (773, 0.74, '2026-06-18 23:53:14.497+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (774, 12.67, '2026-06-18 23:48:54.319+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (775, 53.29, '2026-06-18 23:39:58.952+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (776, 78.57, '2026-06-18 23:47:39.264+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (777, 13.52, '2026-06-18 23:48:14.277+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (778, 13.31, '2026-06-18 23:47:24.206+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (779, 4.67, '2026-06-18 23:51:09.409+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (780, 56.05, '2026-06-15 23:22:07.985+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (781, 227.5, '2026-06-18 23:48:49.305+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (782, 91.81, '2026-06-18 23:40:08.961+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (783, -17.2, '2026-06-18 23:34:18.662+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (784, 7.19, '2026-06-18 23:41:38.981+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (785, 4.18, '2026-06-18 23:48:09.265+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (786, 24.67, '2026-06-18 23:47:59.241+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (787, 22.08, '2026-06-18 23:34:33.738+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (788, 251.59, '2026-06-16 14:00:28.717+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (789, 26.64, '2026-06-18 23:41:28.997+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (790, 45.82, '2026-06-18 23:37:23.807+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (791, 3.11, '2026-06-18 23:54:09.529+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (792, 277.27, '2026-06-18 23:48:24.291+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (793, 68.13, '2026-06-18 23:41:08.977+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (794, 68.89, '2026-06-15 23:19:47.941+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (795, 61.69, '2026-06-18 23:41:23.966+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (796, 59.93, '2026-06-15 23:20:52.985+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (797, 13.04, '2026-06-18 23:53:14.507+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (798, 2.34, '2026-06-15 17:58:22.101+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (799, 54.38, '2026-06-15 23:24:23.137+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (800, -3.82, '2026-06-18 23:48:24.27+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (801, 43.05, '2026-06-18 23:51:09.434+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (802, 14.28, '2026-06-18 23:41:08.971+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (803, 36.01, '2026-06-18 23:49:14.317+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (804, 52.87, '2026-06-18 23:40:18.9+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (805, 225.91, '2026-06-18 23:47:59.262+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (806, 55.26, '2026-06-18 23:39:23.917+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (807, 70.23, '2026-06-18 23:39:13.935+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (808, 56.94, '2026-06-18 23:40:33.927+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (809, 6.13, '2026-06-18 23:41:48.967+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (810, 3.35, '2026-06-18 23:37:03.778+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (811, 222.11, '2026-06-18 23:38:53.87+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (812, 77.3, '2026-06-15 23:15:47.9+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (813, 23.9, '2026-06-18 23:53:54.561+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (814, 74.16, '2026-06-18 23:38:23.873+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (815, 232.83, '2026-06-18 23:47:29.242+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (816, 89.78, '2026-06-18 23:38:13.861+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (817, 23.16, '2026-06-18 23:51:24.466+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (818, 13.07, '2026-06-18 23:36:38.81+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (819, 23.4, '2026-06-18 23:42:09.05+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (820, 230.69, '2026-06-18 23:52:59.49+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (821, -2.68, '2026-06-18 23:38:08.82+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (822, -4.46, '2026-06-18 23:25:38.342+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (823, 212.21, '2026-06-18 23:37:23.822+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (824, 6.54, '2026-06-18 23:38:08.828+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (825, 10.24, '2026-06-18 23:49:24.314+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (826, 28.37, '2026-06-18 23:53:14.513+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (827, 41.44, '2026-06-18 23:35:58.74+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (828, 15.35, '2026-06-18 23:52:09.429+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (829, 76.99, '2026-06-18 23:36:13.802+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (830, 36.12, '2026-06-18 23:36:53.846+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (831, 29.14, '2026-06-18 23:38:33.928+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (832, 21.14, '2026-06-18 23:39:28.864+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (833, -24.41, '2026-06-18 19:43:49.763+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (834, 3.61, '2026-06-18 23:49:54.359+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (835, 86.32, '2026-06-18 23:52:04.469+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (836, 1.05, '2026-06-18 23:34:43.684+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (837, 29.36, '2026-06-18 23:39:03.858+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (838, 14.08, '2026-06-18 23:20:58.157+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (839, 12.44, '2026-06-18 23:37:53.854+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (840, -8.77, '2026-06-18 23:43:04.022+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (841, 4.53, '2026-06-18 23:47:44.225+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (842, 214.46, '2026-06-16 13:58:23.655+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (843, -8.77, '2026-06-18 23:52:14.467+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (844, 1.68, '2026-06-18 23:53:24.514+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (845, 7.78, '2026-06-18 23:52:39.45+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (846, 16.07, '2026-06-18 23:38:58.918+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (847, 38.11, '2026-06-15 18:03:32.159+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (848, 18.34, '2026-06-18 19:41:44.735+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (849, -3.89, '2026-06-18 23:38:43.861+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (850, 90.08, '2026-06-18 23:50:49.424+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (851, 6.22, '2026-06-18 23:39:28.871+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (852, 0.66, '2026-06-18 23:22:03.184+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (853, 223.15, '2026-06-16 13:56:43.596+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (854, 9.04, '2026-06-15 17:58:57.111+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (855, -4.86, '2026-06-15 18:00:37.126+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (856, 212.23, '2026-06-16 14:01:43.768+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (857, 82.26, '2026-06-18 23:36:03.784+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (858, 237.98, '2026-06-18 23:39:08.882+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (859, 21.88, '2026-06-18 23:50:04.389+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (860, 67.22, '2026-06-18 23:53:44.537+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (861, 22, '2026-06-18 23:40:39.004+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (862, 35.5, '2026-06-18 23:42:29.143+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (863, 3.51, '2026-06-18 23:47:39.243+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (864, 84.09, '2026-06-15 23:15:52.946+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (865, -2.83, '2026-06-18 23:34:53.689+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (866, 235.55, '2026-06-18 23:39:43.911+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (867, 61.01, '2026-06-18 23:48:44.299+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (868, 20.26, '2026-06-18 23:47:34.257+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (869, 237.23, '2026-06-16 14:01:08.737+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (870, 22.19, '2026-06-15 17:59:37.111+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (871, 13.29, '2026-06-18 23:39:43.9+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (872, 45.31, '2026-06-18 23:52:44.505+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (873, 22.67, '2026-06-18 23:50:19.365+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (874, 5.23, '2026-06-18 23:36:43.807+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (875, 27.46, '2026-06-18 23:42:34.008+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (876, 73.06, '2026-06-15 23:23:13.041+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (877, 19.36, '2026-06-18 23:53:39.54+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (878, 1.78, '2026-06-18 23:39:13.895+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (879, 21.5, '2026-06-18 23:51:29.449+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (880, 22.68, '2026-06-18 23:51:24.456+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (881, 2.29, '2026-06-18 23:39:38.894+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (882, 11.13, '2026-06-18 23:53:49.5+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (883, 54.39, '2026-06-18 19:43:09.753+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (884, 2.65, '2026-06-18 23:50:44.395+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (885, 236.46, '2026-06-18 23:52:04.453+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (886, 15.6, '2026-06-18 23:51:09.428+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (887, -7.33, '2026-06-18 23:37:23.791+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (888, 4.2, '2026-06-18 23:37:38.822+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (889, -1.34, '2026-06-15 17:59:17.113+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (890, 39.55, '2026-06-18 23:35:03.695+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (891, 195.51, '2026-06-16 13:59:18.711+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (892, 55.79, '2026-06-18 23:37:53.885+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (893, 14.16, '2026-06-18 23:51:29.433+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (894, 12.72, '2026-06-18 23:24:58.301+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (895, -7.35, '2026-06-18 19:47:34.81+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (896, 62.66, '2026-06-18 23:38:18.891+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (897, 29.14, '2026-06-18 23:36:08.748+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (898, 73.63, '2026-06-18 23:48:34.333+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (899, 60.5, '2026-06-18 23:40:03.889+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (900, 70.86, '2026-06-18 23:36:43.819+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (901, 17.17, '2026-06-18 23:39:13.874+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (902, 12.2, '2026-06-18 23:50:14.381+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (903, 18.17, '2026-06-18 23:50:34.362+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (904, 0.01, '2026-06-18 23:42:39.004+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (905, 23.96, '2026-06-18 23:54:09.524+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (906, 31.68, '2026-06-15 23:22:17.99+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (907, 53.3, '2026-06-18 23:36:13.817+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (908, 47.6, '2026-06-15 23:22:23.013+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (909, 5.42, '2026-06-18 23:49:34.353+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (910, 56.2, '2026-06-18 23:36:53.793+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (911, 13.02, '2026-06-18 23:49:44.356+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (912, 220.4, '2026-06-18 23:37:43.841+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (913, 213.35, '2026-06-18 23:46:59.242+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (914, 66.75, '2026-06-18 23:51:29.439+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (915, 222.09, '2026-06-16 13:58:18.687+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (916, 21.47, '2026-06-18 23:36:13.807+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (917, 11.62, '2026-06-18 23:38:28.862+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (918, 23.36, '2026-06-18 23:50:29.414+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (919, 3.95, '2026-06-18 23:49:29.33+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (920, 1.76, '2026-06-18 23:34:23.689+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (921, 70.07, '2026-06-15 23:19:42.968+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (922, 60.65, '2026-06-18 23:38:23.841+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (923, 33.73, '2026-06-18 23:22:48.203+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (924, 23.56, '2026-06-18 23:51:04.425+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (925, 12.86, '2026-06-18 23:46:59.254+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (926, 2.75, '2026-06-15 17:59:47.118+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (927, -3.05, '2026-06-18 23:34:13.722+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (928, 27.83, '2026-06-18 23:42:13.998+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (929, 9.96, '2026-06-18 23:50:34.37+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (930, 21.66, '2026-06-18 23:35:48.778+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (931, 53.67, '2026-06-18 23:36:58.794+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (932, 64.29, '2026-06-18 23:53:59.541+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (933, 43.56, '2026-06-18 23:53:29.518+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (934, 214.16, '2026-06-18 23:42:24.044+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (935, -9.9, '2026-06-18 23:51:29.4+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (936, 21.98, '2026-06-18 23:39:33.869+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (937, 211.58, '2026-06-18 23:49:19.329+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (938, 17.39, '2026-06-18 23:50:09.386+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (939, 22.42, '2026-06-18 23:39:43.876+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (940, 24.74, '2026-06-18 23:54:04.582+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (941, 74.13, '2026-06-18 23:49:34.365+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (942, 11.66, '2026-06-18 23:47:34.247+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (943, 7.77, '2026-06-18 23:38:43.881+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (944, 52.51, '2026-06-18 23:34:13.672+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (945, 15.69, '2026-06-18 23:41:03.983+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (946, 56.32, '2026-06-18 23:51:54.496+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (947, 13.22, '2026-06-18 23:53:04.514+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (948, 30.51, '2026-06-18 23:38:18.839+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (949, 61.52, '2026-06-18 23:42:39.068+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (950, 5.57, '2026-06-18 23:53:24.501+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (951, 15.17, '2026-06-15 17:58:27.101+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (952, 3.65, '2026-06-18 23:39:53.895+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (953, 212.99, '2026-06-16 13:59:03.663+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (954, 25.14, '2026-06-18 23:49:54.388+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (955, 33.93, '2026-06-18 23:51:29.414+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (956, 108.43, '2026-06-18 23:48:24.316+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (957, 62.25, '2026-06-18 23:53:29.532+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (958, -8.05, '2026-06-18 23:49:29.311+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (959, 24.86, '2026-06-18 23:40:28.931+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (960, -2.58, '2026-06-18 23:53:34.517+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (961, 15.44, '2026-06-18 23:43:09.06+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (962, 8.41, '2026-06-18 19:39:34.719+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (963, 4.47, '2026-06-18 23:40:13.959+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (964, 216.17, '2026-06-18 23:48:14.272+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (965, 11.99, '2026-06-18 19:41:59.743+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (966, 71.86, '2026-06-18 23:39:28.897+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (967, 94.15, '2026-06-18 23:49:49.34+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (968, 225.13, '2026-06-16 13:59:53.693+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (969, 1.95, '2026-06-18 23:51:09.389+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (970, -14.06, '2026-06-15 18:00:17.118+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (971, 21.01, '2026-06-18 23:21:18.159+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (972, 2.05, '2026-06-18 23:43:09.043+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (973, -18.48, '2026-06-15 18:03:17.156+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (974, 29.45, '2026-06-18 23:51:34.436+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (975, 191.29, '2026-06-18 23:34:48.715+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (976, 54.15, '2026-06-18 23:49:04.344+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (977, 29.62, '2026-06-18 23:42:24.004+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (978, 20.5, '2026-06-18 23:40:43.921+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (979, 30.01, '2026-06-18 23:38:38.893+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (980, 12.02, '2026-06-18 23:35:13.744+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (981, 4.33, '2026-06-18 23:40:53.947+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (982, 22.59, '2026-06-18 19:44:59.782+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (983, 22.52, '2026-06-15 17:57:52.093+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (984, -2.14, '2026-06-18 23:40:08.935+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (985, 12.96, '2026-06-18 23:48:59.324+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (986, 19.32, '2026-06-18 23:34:33.726+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (987, 17.35, '2026-06-18 23:34:18.733+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (988, 2.24, '2026-06-18 23:39:23.907+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (989, 26.32, '2026-06-18 23:40:08.905+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (990, 1.7, '2026-06-18 23:49:19.302+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (991, 63.88, '2026-06-18 23:51:49.429+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (992, 42.64, '2026-06-18 23:36:33.825+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (993, 36.9, '2026-06-18 23:37:43.872+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (994, 52.28, '2026-06-18 23:53:44.504+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (995, -6.01, '2026-06-18 23:39:43.931+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (996, 67.68, '2026-06-18 23:40:14.029+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (997, 19.2, '2026-06-18 23:34:23.711+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (998, 66.56, '2026-06-18 23:51:59.491+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (999, 48.29, '2026-06-18 23:36:23.763+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1000, 8.51, '2026-06-15 17:57:57.093+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1001, 20.64, '2026-06-18 23:41:13.997+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1002, 71.71, '2026-06-18 23:41:59.042+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1003, 45.21, '2026-06-18 23:46:54.235+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1004, 24.73, '2026-06-18 23:41:49.019+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1005, 222.72, '2026-06-16 13:56:03.568+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1006, 11.86, '2026-06-18 23:42:13.987+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1007, 20.41, '2026-06-18 23:54:09.541+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1008, 31, '2026-06-18 23:42:03.996+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1009, 33.58, '2026-06-18 23:49:39.333+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1010, 14.49, '2026-06-18 23:35:33.718+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1011, 23.19, '2026-06-18 23:39:54.029+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1012, 5.41, '2026-06-18 23:35:53.746+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1013, -19.25, '2026-06-18 23:36:38.786+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1014, 68.31, '2026-06-18 23:39:33.933+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1015, 56.69, '2026-06-15 23:24:28.132+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1016, 64.89, '2026-06-18 23:38:03.838+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1017, 8.09, '2026-06-18 23:46:54.224+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1018, 11.57, '2026-06-18 23:38:48.885+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1019, 70.73, '2026-06-18 23:40:03.97+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1020, -15.43, '2026-06-18 23:47:49.253+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1021, -1.39, '2026-06-18 19:40:14.725+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1022, 3.75, '2026-05-18 12:21:04.946+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1023, 2.12, '2026-06-18 23:41:28.974+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1024, 0.32, '2026-06-15 17:56:57.071+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1025, 12.51, '2026-06-18 23:38:03.862+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1026, 74.47, '2026-06-15 23:25:03.143+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1027, 85.68, '2026-06-18 23:41:13.993+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1028, 12.42, '2026-06-18 23:51:49.449+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1029, 4.3, '2026-06-18 23:48:39.289+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1030, 70.64, '2026-06-18 23:42:19.069+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1031, 218.02, '2026-06-16 13:57:33.606+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1032, 63.18, '2026-06-18 23:39:03.886+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1033, 11.18, '2026-06-18 23:38:43.875+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1034, 14.15, '2026-06-18 23:53:29.511+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1035, 71.16, '2026-06-15 23:20:17.957+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1036, 12.82, '2026-06-18 19:39:04.717+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1037, 12.97, '2026-06-15 18:01:37.132+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1038, 3.64, '2026-06-18 23:51:34.405+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1039, 1.15, '2026-06-18 23:52:34.446+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1040, 20.17, '2026-06-18 23:51:04.395+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1041, -4.66, '2026-06-15 18:03:12.155+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1042, 1.72, '2026-06-18 23:40:58.929+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1043, 38.42, '2026-06-18 23:51:39.458+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1044, 168.43, '2026-06-18 23:48:29.307+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1045, -3.35, '2026-06-18 23:48:09.242+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1046, -5.75, '2026-06-15 17:56:32.073+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1047, -7.11, '2026-06-18 23:40:08.895+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1048, -30.18, '2026-06-15 17:55:52.059+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1049, 59.62, '2026-06-18 23:34:23.682+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1050, 20.95, '2026-06-18 19:47:24.805+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1051, 19.63, '2026-06-18 23:41:03.934+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1052, 2.36, '2026-06-18 23:39:23.884+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1053, -0.23, '2026-06-18 23:40:53.967+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1054, 1, '2026-06-18 23:36:58.805+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1055, 192.96, '2026-06-18 23:34:58.718+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1056, 24.84, '2026-06-18 23:47:54.279+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1057, 14.21, '2026-06-18 23:24:23.308+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1058, 62.84, '2026-06-18 23:49:19.351+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1059, 30.69, '2026-06-18 23:41:08.952+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1060, 25.44, '2026-06-18 23:51:34.458+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1061, -6.15, '2026-06-18 23:40:33.934+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1062, 55.11, '2026-06-18 23:53:59.555+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1063, 18.44, '2026-06-18 23:41:08.984+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1064, 1.4, '2026-06-18 23:35:58.754+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1065, -29.34, '2026-06-15 17:57:47.094+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1066, 211.17, '2026-06-18 23:36:28.78+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1067, 90.62, '2026-06-18 23:36:08.796+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1068, 235.35, '2026-06-16 14:02:43.792+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1069, 18.35, '2026-06-18 23:51:39.45+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1070, 25.54, '2026-06-18 23:35:23.751+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1071, 11.69, '2026-06-18 23:24:43.293+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1072, -6.55, '2026-06-18 23:50:59.403+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1073, 7.14, '2026-06-18 23:48:24.263+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1074, 2.04, '2026-06-18 23:36:53.802+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1075, 65.53, '2026-06-18 23:35:18.772+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1076, 3.45, '2026-06-18 23:41:48.989+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1077, 27.81, '2026-06-18 23:38:03.829+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1078, 18.41, '2026-06-18 23:52:19.439+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1079, 12.83, '2026-06-18 23:52:04.463+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1080, 21, '2026-06-18 23:39:28.902+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1081, 12.27, '2026-06-18 23:51:14.391+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1082, 76.78, '2026-06-18 23:52:54.512+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1083, -4.14, '2026-06-15 18:04:02.165+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1084, 46.82, '2026-06-18 23:36:48.766+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1085, 24.11, '2026-06-18 23:53:19.496+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1086, 61.09, '2026-06-18 23:42:19.043+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1087, -1.4, '2026-06-18 23:35:03.756+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1088, 224.91, '2026-06-16 13:54:58.565+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1089, 243.58, '2026-06-18 23:40:33.941+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1090, 46.75, '2026-06-18 23:35:38.735+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1091, 62.68, '2026-06-18 23:50:04.367+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1092, 6.26, '2026-06-18 23:39:33.876+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1093, -6.26, '2026-06-15 17:56:42.069+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1094, 50.35, '2026-06-15 23:17:27.903+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1095, 63.11, '2026-06-18 23:37:13.855+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1096, -1.57, '2026-06-18 23:34:13.662+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1097, 25.19, '2026-06-18 23:41:34.022+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1098, 34.56, '2026-06-15 23:16:47.871+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1099, 1.06, '2026-06-18 23:52:24.437+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1100, 25.41, '2026-06-18 23:38:03.879+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1101, 21.81, '2026-06-18 23:52:44.454+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1102, 12.97, '2026-06-18 23:40:48.954+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1103, 39.65, '2026-06-18 23:48:09.282+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1104, 90.36, '2026-06-15 23:17:02.898+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1105, 212.56, '2026-06-18 23:53:44.514+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1106, 19.92, '2026-06-18 23:36:28.759+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1107, 5.25, '2026-06-15 18:03:02.154+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1108, 93.62, '2026-06-18 23:46:59.288+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1109, 22.37, '2026-06-18 23:34:43.73+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1110, 258.59, '2026-06-18 23:50:24.383+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1111, 1.07, '2026-06-18 23:37:08.783+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1112, 48.76, '2026-06-18 23:50:54.38+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1113, 43.98, '2026-06-18 23:35:18.739+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1114, 12.13, '2026-06-18 23:23:58.32+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1115, 37.61, '2026-06-15 23:17:12.865+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1116, 13.13, '2026-06-18 23:34:13.714+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1117, 12.18, '2026-06-18 23:23:13.232+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1118, 15.68, '2026-06-18 23:42:59.016+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1119, 24.98, '2026-06-18 23:53:14.486+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1120, 12.62, '2026-06-18 23:49:54.374+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1121, 1.14, '2026-06-18 23:37:13.811+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1122, 57.2, '2026-06-18 23:50:44.438+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1123, 18.57, '2026-06-18 23:50:19.35+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1124, 47.66, '2026-06-18 23:54:04.531+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1125, 18.79, '2026-06-18 23:34:23.706+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1126, 89.69, '2026-06-18 23:51:14.438+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1127, 3.41, '2026-06-18 23:37:08.803+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1128, 11.24, '2026-06-18 23:37:43.851+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1129, 9.28, '2026-06-18 23:52:14.431+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1130, 31.07, '2026-06-18 23:50:09.354+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1131, 2.81, '2026-06-18 23:34:18.706+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1132, 13.49, '2026-06-18 23:35:33.747+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1133, 226.31, '2026-06-18 23:41:48.996+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1134, -40.62, '2026-06-18 19:45:59.791+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1135, 17.4, '2026-06-18 23:49:54.381+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1136, 42.51, '2026-06-15 18:03:52.161+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1137, 14.25, '2026-06-18 23:50:44.41+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1138, 3.97, '2026-06-18 23:51:44.437+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1139, 11.22, '2026-06-18 23:47:24.24+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1140, 202.97, '2026-06-18 23:37:28.842+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1141, -6.39, '2026-06-15 17:58:17.103+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1142, 16.52, '2026-06-18 23:36:13.744+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1143, 211.94, '2026-06-18 23:51:39.44+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1144, -16.33, '2026-06-18 23:47:19.223+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1145, 22.14, '2026-06-18 23:39:13.92+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1146, 38.93, '2026-06-18 23:47:19.268+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1147, 21.62, '2026-06-18 23:35:38.766+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1148, 2.17, '2026-06-18 23:40:43.943+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1149, 238.12, '2026-06-18 23:35:58.76+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1150, 18.48, '2026-06-18 23:42:39.018+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1151, 62.72, '2026-06-15 23:17:32.858+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1152, 1, '2026-06-18 23:39:48.903+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1153, 89.49, '2026-06-18 23:39:28.908+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1154, 21.4, '2026-06-18 23:42:54.021+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1155, 38.15, '2026-06-18 23:38:08.865+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1156, 11.75, '2026-06-18 23:48:24.306+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1157, 55.35, '2026-06-18 23:36:18.817+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1158, 65.46, '2026-06-18 23:37:18.858+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1159, 2.25, '2026-06-18 23:50:24.364+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1160, 13.46, '2026-06-18 23:50:29.396+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1161, -1.3, '2026-06-18 23:39:58.883+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1162, 66.95, '2026-06-18 23:37:53.829+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1163, 219.43, '2026-06-16 13:56:08.617+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1164, 13.54, '2026-06-18 23:36:53.814+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1165, 14.2, '2026-06-18 23:38:18.857+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1166, 75.46, '2026-06-15 23:18:47.922+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1167, 14.65, '2026-06-18 23:40:28.922+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1168, 29.28, '2026-06-18 23:34:53.697+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1169, 5.46, '2026-06-18 23:41:33.96+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1170, 105.55, '2026-06-18 23:50:54.486+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1171, 60.06, '2026-06-18 23:37:33.877+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1172, 279.78, '2026-06-16 14:00:08.762+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1173, 24.32, '2026-06-18 23:40:53.935+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1174, 22.37, '2026-06-18 23:35:08.75+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1175, -12.3, '2026-06-18 23:37:53.821+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1176, 6.82, '2026-06-18 19:47:49.813+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1177, -7.11, '2026-06-18 23:34:48.707+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1178, 65.81, '2026-06-18 23:48:14.283+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1179, 18.27, '2026-06-18 23:47:09.199+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1180, 218.33, '2026-06-18 23:34:23.694+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1181, 6.62, '2026-06-15 17:56:22.061+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1182, 70.52, '2026-06-18 23:52:39.505+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1183, 11.81, '2026-06-18 23:22:38.228+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1184, 33.81, '2026-06-18 23:35:33.726+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1185, 33.07, '2026-06-18 23:49:59.347+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1186, 59.91, '2026-06-18 23:36:43.782+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1187, 68.64, '2026-06-18 23:39:38.924+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1188, 218.55, '2026-06-16 13:55:18.565+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1189, 6.93, '2026-06-15 17:55:37.057+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1190, 23.35, '2026-06-18 23:42:44.009+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1191, 14.17, '2026-06-18 23:39:43.92+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1192, 34.38, '2026-06-18 23:38:23.864+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1193, -5.56, '2026-06-18 23:35:08.7+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1194, 27.94, '2026-06-18 23:49:14.354+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1195, 11.75, '2026-06-15 17:59:32.11+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1196, 14.48, '2026-06-15 18:05:02.177+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1197, 50.74, '2026-06-18 23:51:39.408+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1198, 17.35, '2026-06-18 23:50:44.371+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1199, 11.61, '2026-06-18 23:41:13.985+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1200, 57.48, '2026-06-18 23:37:58.834+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1201, -9, '2026-06-18 23:53:29.476+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1202, 3.38, '2026-06-18 23:52:49.473+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1203, 2.67, '2026-06-18 23:48:44.31+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1204, 67.02, '2026-06-15 23:16:17.969+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1205, 236.82, '2026-06-16 13:54:38.639+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1206, -9.3, '2026-06-18 23:47:29.216+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1207, 48.24, '2026-06-18 23:51:54.431+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1208, 18.62, '2026-06-18 23:49:34.36+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1209, 3.04, '2026-06-18 23:42:34.02+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1210, 27.4, '2026-06-18 23:48:44.286+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1211, 37.66, '2026-06-18 23:52:29.48+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1212, 220.41, '2026-06-16 13:54:23.636+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1213, 60.36, '2026-06-18 23:53:24.605+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1214, 93.09, '2026-06-18 23:41:34.013+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1215, 217.4, '2026-06-16 14:01:53.79+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1216, 73.01, '2026-06-18 23:43:04.187+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1217, 15.46, '2026-06-15 17:58:07.099+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1218, 24.68, '2026-06-18 23:34:48.756+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1219, 48.66, '2026-06-18 19:46:34.797+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1220, 64.54, '2026-06-18 23:53:34.495+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1221, 18.68, '2026-06-18 23:38:13.831+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1222, 83.84, '2026-06-18 23:40:18.929+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1223, 56, '2026-06-18 23:38:03.87+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1224, 4.84, '2026-06-15 18:02:12.146+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1225, 3.87, '2026-06-18 23:50:09.343+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1226, 62.59, '2026-06-18 23:48:14.294+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1227, 13.86, '2026-06-18 19:42:44.751+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1228, 13.3, '2026-06-15 17:57:27.079+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1229, 34.9, '2026-06-18 23:42:34.081+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1230, 33.69, '2026-06-15 23:17:42.908+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1231, 14.19, '2026-05-18 12:30:00.29+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1232, 12.25, '2026-06-18 23:42:39.056+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1233, 10.78, '2026-06-18 23:38:13.854+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1234, 8.43, '2026-06-18 19:39:39.715+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1235, 54.74, '2026-06-18 23:39:54.041+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1236, 0.65, '2026-06-18 23:35:23.71+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1237, 21.4, '2026-06-18 23:34:13.74+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1238, 14.1, '2026-06-18 23:35:28.728+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1239, 11.64, '2026-06-18 23:35:13.714+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1240, 6.35, '2026-06-18 19:40:49.732+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1241, 31.96, '2026-06-18 23:42:34.062+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1242, -35.24, '2026-06-15 17:57:32.083+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1243, 1.36, '2026-06-18 19:42:39.747+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1244, 25.31, '2026-05-18 12:26:00.12+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1245, 12.87, '2026-06-18 23:38:33.964+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1246, 221.43, '2026-06-18 23:50:54.468+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1247, 21.8, '2026-06-18 23:37:43.834+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1248, 11.36, '2026-06-18 23:41:44.001+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1249, 55.63, '2026-06-18 23:41:33.979+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1250, 238.65, '2026-06-16 13:54:08.553+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1251, 56.62, '2026-06-18 23:52:54.501+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1252, 52.97, '2026-06-15 23:19:57.977+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1253, 13.64, '2026-06-18 19:39:59.723+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1254, 221.15, '2026-06-18 23:49:34.34+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1255, 14.69, '2026-06-18 23:38:13.868+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1256, 231.87, '2026-06-18 23:49:39.343+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1257, -6, '2026-06-18 23:53:19.479+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1258, 45.3, '2026-06-18 23:34:18.762+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1259, 20.17, '2026-06-18 23:52:09.502+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1260, 224.57, '2026-06-18 23:39:18.895+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1261, -0.2, '2026-06-18 23:38:18.825+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1262, -10.95, '2026-06-18 23:36:53.822+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1263, 6.8, '2026-06-18 23:38:53.846+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1264, 20.6, '2026-06-18 23:34:58.699+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1265, 8.23, '2026-06-18 19:46:39.794+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1266, -9.59, '2026-06-18 23:34:38.717+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1267, 26.94, '2026-06-18 23:39:48.929+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1268, 43.96, '2026-06-15 18:04:57.174+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1269, 51.31, '2026-06-18 23:41:28.958+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1270, 52.14, '2026-06-18 23:49:44.372+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1271, 13.61, '2026-06-18 23:41:23.951+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1272, 214.5, '2026-06-18 23:35:33.742+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1273, 53.94, '2026-06-18 23:48:49.285+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1274, 95.67, '2026-06-18 23:35:48.784+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1275, 215.61, '2026-06-16 13:59:33.678+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1276, 4.46, '2026-06-18 23:35:38.74+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1277, 17.01, '2026-06-18 23:47:39.227+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1278, 9.61, '2026-06-18 23:46:59.201+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1279, 61.75, '2026-06-18 23:42:34.097+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1280, 5.47, '2026-06-18 23:41:49.012+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1281, 3.07, '2026-06-18 23:48:24.281+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1282, 1.43, '2026-06-15 18:04:42.171+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1283, 8.73, '2026-06-18 23:36:53.787+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1284, -5.79, '2026-06-18 23:49:49.327+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1285, 229.71, '2026-06-18 23:48:44.319+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1286, 23.33, '2026-06-18 23:41:34.004+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1287, -5.03, '2026-06-18 23:47:34.214+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1288, 83.7, '2026-06-18 23:47:59.288+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1289, 5.63, '2026-06-18 23:23:28.249+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1290, 61.1, '2026-06-18 23:41:28.967+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1291, 68.76, '2026-06-15 23:15:27.912+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1292, 218.41, '2026-06-16 13:55:23.593+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1293, 12.77, '2026-06-18 23:23:18.255+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1294, 1.42, '2026-06-18 23:41:43.987+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1295, 24.93, '2026-06-18 23:36:03.791+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1296, 65.86, '2026-06-18 23:41:39.029+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1297, 13.42, '2026-06-18 23:26:03.377+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1298, 12.53, '2026-06-18 23:47:24.214+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1299, 7.25, '2026-06-18 23:52:49.462+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1300, 228.49, '2026-06-16 13:55:13.571+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1301, 43.24, '2026-06-18 23:39:54.021+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1302, 217.64, '2026-06-18 23:52:49.479+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1303, 41.74, '2026-06-15 23:16:37.911+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1304, 45.17, '2026-06-18 23:36:18.77+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1305, 17.52, '2026-06-18 19:45:44.786+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1306, 20.2, '2026-06-18 23:40:14.02+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1307, 230.25, '2026-06-16 13:55:08.635+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1308, 12.86, '2026-06-18 23:21:08.141+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1309, 246.39, '2026-06-16 13:57:18.66+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1310, 70.67, '2026-06-18 23:51:39.481+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1311, 12.19, '2026-06-18 23:34:38.711+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1312, 19.75, '2026-06-18 19:42:14.741+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1313, 12.33, '2026-06-18 23:52:39.485+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1314, 23.29, '2026-06-18 23:34:48.694+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1315, 56.38, '2026-06-18 23:49:59.386+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1316, 86.59, '2026-06-18 23:42:24.011+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1317, 276.45, '2026-06-18 23:48:59.312+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1318, 1.3, '2026-06-18 23:40:58.949+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1319, 0.83, '2026-06-18 23:35:23.729+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1320, 3.43, '2026-06-18 23:47:09.235+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1321, 13.29, '2026-06-18 23:25:33.323+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1322, 7.37, '2026-06-18 23:35:28.761+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1323, 33.22, '2026-06-18 23:38:48.859+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1324, 54.37, '2026-06-18 23:52:24.496+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1325, 17.74, '2026-06-18 23:42:14.044+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1326, 227.38, '2026-06-16 13:59:23.67+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1327, 3.87, '2026-06-15 17:56:47.069+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1328, 51.94, '2026-06-18 23:50:49.386+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1329, 53.79, '2026-06-18 23:38:58.868+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1330, 5.75, '2026-06-15 17:55:22.047+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1331, 13.19, '2026-06-18 23:36:43.801+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1332, 59.9, '2026-06-15 23:24:48.164+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1333, 13.49, '2026-06-18 23:47:44.276+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1334, 24.01, '2026-06-18 23:42:44.08+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1335, 34.45, '2026-06-18 23:53:14.492+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1336, 65.5, '2026-06-15 23:16:12.973+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1337, 57.74, '2026-06-18 23:42:39.089+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1338, 238.88, '2026-06-16 13:57:08.624+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1339, -7.19, '2026-06-15 18:02:27.145+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1340, 15.68, '2026-06-18 23:47:49.283+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1341, 18.8, '2026-06-18 23:46:49.215+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1342, 29.29, '2026-06-18 23:38:18.833+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1343, 4.01, '2026-06-18 23:52:44.474+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1344, -11.84, '2026-06-15 18:03:07.154+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1345, 214.94, '2026-06-18 23:38:43.868+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1346, 16.78, '2026-06-18 23:50:14.356+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1347, 57.82, '2026-06-18 23:48:49.315+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1348, 264.05, '2026-06-16 13:54:33.587+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1349, 83.52, '2026-06-18 23:40:33.983+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1350, 17.9, '2026-06-18 23:38:38.846+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1351, 46.45, '2026-06-18 23:34:53.704+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1352, 62.48, '2026-06-18 23:48:34.284+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1353, 217.25, '2026-06-16 14:00:18.683+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1354, 2.04, '2026-06-18 23:52:29.461+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1355, 1.8, '2026-06-18 23:47:44.264+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1356, 56.34, '2026-06-18 23:40:18.988+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1357, 19.42, '2026-06-18 23:40:08.953+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1358, -9.63, '2026-06-18 23:52:49.455+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1359, 47.64, '2026-06-18 23:36:03.753+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1360, 221.29, '2026-06-16 14:03:08.783+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1361, -8.72, '2026-06-18 23:50:24.402+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1362, 72.19, '2026-06-18 23:53:54.566+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1363, 12.81, '2026-06-18 23:52:59.499+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1364, 54.6, '2026-06-18 23:48:29.345+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1365, 219.79, '2026-06-18 23:47:34.24+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1366, 40.34, '2026-06-18 23:52:34.505+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1367, 212.73, '2026-06-18 23:40:58.956+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1368, 54.98, '2026-06-15 23:23:28.046+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1369, 5.74, '2026-06-18 23:53:09.473+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1370, 37.59, '2026-06-18 23:52:54.474+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1371, 74.85, '2026-06-18 23:38:43.894+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1372, 11.8, '2026-06-18 23:53:54.544+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1373, 22.99, '2026-06-18 23:38:43.842+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1374, 97.32, '2026-06-18 23:53:39.5+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1375, 13.52, '2026-06-18 23:49:19.335+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1376, 14.1, '2026-06-18 23:42:24.06+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1377, 14.19, '2026-06-18 23:50:59.423+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1378, 4.6, '2026-06-18 23:50:19.371+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1379, 86.66, '2026-06-15 23:25:18.129+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1380, 25.33, '2026-06-18 23:42:59.076+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1381, 18.72, '2026-06-18 23:41:13.944+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1382, -5.19, '2026-06-18 19:39:29.715+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1383, 12.92, '2026-06-18 23:52:54.494+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1384, 0.71, '2026-06-18 23:35:48.751+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1385, 16.01, '2026-06-18 23:49:04.315+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1386, 74.87, '2026-06-18 23:39:58.936+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1387, 21.92, '2026-06-18 23:47:59.283+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1388, -2.45, '2026-06-15 17:59:07.109+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1389, -1.56, '2026-06-18 23:53:44.492+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1390, 13.89, '2026-06-18 23:23:33.28+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1391, -3.93, '2026-06-15 18:02:17.146+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1392, 220.18, '2026-06-18 23:40:23.936+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1393, 5.85, '2026-06-15 18:02:57.151+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1394, 31.58, '2026-06-18 23:39:13.885+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1395, 8.09, '2026-06-18 23:35:58.732+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1396, 60.72, '2026-06-18 23:51:09.444+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1397, 113.85, '2026-06-18 23:42:44.065+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1398, 9.18, '2026-06-15 17:56:07.062+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1399, 12.57, '2026-06-18 23:49:39.348+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1400, 30.41, '2026-06-18 23:47:04.206+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1401, 53.33, '2026-06-18 23:39:58.892+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1402, 12.59, '2026-06-18 23:37:08.821+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1403, 215.96, '2026-06-16 13:56:53.594+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1404, -6.71, '2026-06-18 23:54:04.508+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1405, 13.6, '2026-06-18 23:41:18.984+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1406, 11.76, '2026-06-18 23:39:38.911+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1407, 16.14, '2026-06-18 23:35:03.707+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1408, 63.88, '2026-06-15 23:22:13.013+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1409, -19.8, '2026-06-18 23:38:18.865+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1410, 11.8, '2026-06-18 23:25:48.346+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1411, 62.69, '2026-06-18 23:35:13.75+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1412, 117.55, '2026-06-18 23:48:34.307+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1413, 217.62, '2026-06-18 23:50:34.388+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1414, 5.87, '2026-06-18 23:47:49.227+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1415, 14.01, '2026-06-18 23:22:58.217+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1416, 12.77, '2026-06-18 23:52:44.492+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1417, 17.59, '2026-06-18 23:51:19.393+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1418, 42.08, '2026-06-18 23:34:43.697+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1419, 13.36, '2026-06-18 23:21:28.172+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1420, 22.29, '2026-06-18 23:51:54.487+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1421, 231.09, '2026-06-16 13:56:23.584+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1422, 47.25, '2026-06-18 23:47:29.265+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1423, 73.91, '2026-06-18 23:39:43.891+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1424, -5.27, '2026-06-15 18:01:12.131+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1425, 21.22, '2026-06-18 23:40:58.972+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1426, 20.1, '2026-06-18 23:49:49.392+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1427, 54.29, '2026-06-18 23:53:49.556+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1428, 37.36, '2026-06-18 23:38:58.911+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1429, 12.32, '2026-06-18 23:37:48.865+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1430, -6.16, '2026-06-18 23:35:43.728+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1431, 11.21, '2026-06-18 23:40:23.943+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1432, 12.38, '2026-06-18 23:22:43.209+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1433, 28.75, '2026-06-18 23:39:58.941+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1434, -5.51, '2026-06-15 17:56:17.065+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1435, -2.25, '2026-06-18 23:38:58.879+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1436, 77.88, '2026-06-18 23:53:19.531+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1437, 13.84, '2026-06-18 23:48:34.301+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1438, 0.3, '2026-06-18 23:38:53.863+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1439, 32.73, '2026-06-18 23:39:53.904+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1440, 26.85, '2026-06-18 23:47:09.251+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1441, 28.3, '2026-06-18 23:36:18.761+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1442, 10.82, '2026-06-18 23:48:19.297+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1443, 16.35, '2026-06-18 23:42:34+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1444, 19.49, '2026-06-15 18:01:47.138+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1445, 15.05, '2026-06-18 23:52:29.454+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1446, 19.25, '2026-06-15 18:04:32.167+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1447, -4.24, '2026-06-18 19:42:09.738+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1448, 57.66, '2026-06-18 23:50:19.407+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1449, 11.36, '2026-06-18 19:44:14.769+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1450, 2, '2026-06-18 23:38:13.824+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1451, 20.46, '2026-06-18 23:36:48.845+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1452, 72.69, '2026-06-15 23:17:57.904+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1453, 12, '2026-06-18 23:20:23.175+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1454, 0.33, '2026-06-15 18:02:42.153+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1455, 233.58, '2026-06-18 23:49:49.365+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1456, 34.85, '2026-06-18 23:40:43.936+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1457, 6.47, '2026-06-18 19:45:39.785+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1458, 71.21, '2026-06-15 23:20:48.005+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1459, 62.33, '2026-06-18 23:35:53.805+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1460, 0.64, '2026-06-18 23:51:39.434+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1461, 8.14, '2026-06-18 23:51:24.407+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1462, 12.03, '2026-06-18 23:36:08.753+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1463, 14.2, '2026-06-18 23:46:54.269+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1464, 11.04, '2026-06-18 23:36:43.775+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1465, 53.87, '2026-06-18 23:47:44.258+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1466, 58.95, '2026-06-18 23:39:43.952+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1467, 211.21, '2026-06-16 13:57:53.672+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1468, 225.34, '2026-06-16 14:00:58.729+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1469, 12.36, '2026-06-18 23:50:04.383+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1470, 22.08, '2026-06-18 23:52:09.475+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1471, -16.6, '2026-06-18 23:51:19.413+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1472, 19.51, '2026-06-18 23:53:39.547+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1473, 56.85, '2026-06-18 23:47:04.307+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1474, 51.96, '2026-06-18 23:49:14.309+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1475, 214.03, '2026-06-16 13:56:18.619+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1476, 8.38, '2026-06-18 23:51:24.443+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1477, -1.38, '2026-06-18 23:36:33.758+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1478, 217.13, '2026-06-18 23:40:53.954+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1479, 31.95, '2026-06-18 23:42:39.012+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1480, 55.11, '2026-06-15 23:23:58.064+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1481, 12.98, '2026-06-18 23:34:58.727+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1482, -32.56, '2026-06-18 23:38:58.847+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1483, 239.78, '2026-06-16 13:53:53.521+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1484, 210.19, '2026-06-16 13:57:58.655+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1485, 5.8, '2026-06-18 19:46:44.798+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1486, 22.81, '2026-06-18 23:36:38.763+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1487, 80.85, '2026-06-18 23:35:43.782+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1488, 12.79, '2026-06-18 23:20:43.113+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1489, 7.53, '2026-06-18 23:48:34.276+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1490, 47.59, '2026-06-15 23:19:27.946+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1491, 21.2, '2026-06-18 23:42:14.07+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1492, 60.09, '2026-06-18 23:48:54.326+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1493, 76.59, '2026-06-18 23:47:54.287+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1494, 216.36, '2026-06-18 23:48:04.281+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1495, 21.06, '2026-06-18 19:47:54.813+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1496, 4.63, '2026-06-18 23:41:39.013+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1497, 20.95, '2026-06-18 19:43:24.757+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1498, 237.35, '2026-06-18 23:48:39.295+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1499, 256.89, '2026-06-18 23:52:39.475+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1500, 51.27, '2026-06-18 23:52:59.475+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1501, -4.95, '2026-06-18 23:52:09.446+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1502, 4.86, '2026-06-18 19:38:44.717+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1503, 26.93, '2026-06-18 23:53:54.52+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1504, 12.34, '2026-06-18 23:25:58.346+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1505, 20.34, '2026-06-18 23:41:18.964+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1506, 13.4, '2026-06-18 23:47:39.258+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1507, 27.93, '2026-06-18 23:51:14.398+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1508, 236.64, '2026-06-16 14:01:18.762+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1509, 11.84, '2026-06-18 23:50:49.404+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1510, 2.18, '2026-06-18 23:39:03.851+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1511, 14.07, '2026-06-18 23:46:49.236+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1512, 225.92, '2026-06-16 14:02:18.772+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1513, -7.03, '2026-06-18 23:38:03.817+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1514, 73.57, '2026-06-15 23:15:33.025+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1515, 1.72, '2026-06-18 23:52:34.468+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1516, 68.44, '2026-06-18 23:48:54.342+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1517, -2.46, '2026-06-18 19:38:54.717+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1518, 73.94, '2026-06-15 23:23:18.022+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1519, 15.42, '2026-06-18 23:36:23.75+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1520, 18.98, '2026-06-18 23:39:53.912+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1521, 15.88, '2026-06-18 23:50:39.372+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1522, 212.18, '2026-06-18 23:50:19.377+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1523, 29.58, '2026-06-18 23:40:28.975+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1524, 3.02, '2026-06-18 23:37:53.838+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1525, 55.92, '2026-06-15 23:18:22.96+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1526, 3.39, '2026-06-18 23:52:19.453+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1527, 65.29, '2026-06-18 23:34:18.778+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1528, 212.01, '2026-06-18 23:40:43.949+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1529, -33.32, '2026-06-15 17:56:37.065+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1530, -8.3, '2026-06-15 18:01:27.129+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1531, 22.41, '2026-06-18 23:49:59.332+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1532, 57.41, '2026-06-15 23:21:07.972+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1533, 66.67, '2026-06-15 23:24:13.112+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1534, 14.33, '2026-06-18 23:53:34.489+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1535, 237.91, '2026-06-18 23:35:53.764+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1536, 46.19, '2026-06-18 23:41:49.024+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1537, 2.43, '2026-06-18 23:41:58.999+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1538, 23.94, '2026-06-18 23:47:14.243+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1539, 3.88, '2026-06-18 23:35:53.757+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1540, 3.05, '2026-06-18 23:46:54.248+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1541, 217.72, '2026-06-16 13:58:58.646+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1542, 17.19, '2026-06-18 23:52:19.432+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1543, 20.25, '2026-06-18 23:35:03.768+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1544, 20.38, '2026-06-18 23:42:54.081+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1545, 25.21, '2026-06-18 23:40:23.923+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1546, -43.86, '2026-06-18 19:40:44.729+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1547, 46.52, '2026-06-18 19:41:49.737+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1548, 1.57, '2026-06-18 19:45:49.787+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1549, 225.2, '2026-06-16 14:03:13.791+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1550, 236.65, '2026-06-18 23:47:44.271+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1551, 4.02, '2026-06-18 23:39:18.886+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1552, 243.67, '2026-06-18 23:50:44.4+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1553, 20.8, '2026-06-18 23:51:19.439+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1554, 0.4, '2026-06-18 23:42:44.021+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1555, 52.6, '2026-06-18 23:38:38.907+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1556, -18.32, '2026-06-18 23:47:54.232+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1557, 87.22, '2026-06-18 23:52:24.485+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1558, 23.68, '2026-06-18 23:47:04.262+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1559, 2.24, '2026-06-18 23:50:34.382+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1560, 24.86, '2026-06-18 23:37:33.814+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1561, 22.11, '2026-06-18 23:52:29.447+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1562, 75.06, '2026-06-18 23:39:48.941+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1563, 14.33, '2026-06-18 23:42:18.988+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1564, 15.72, '2026-06-15 18:01:07.13+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1565, 58.46, '2026-06-18 23:49:54.349+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1566, 57.11, '2026-06-15 23:20:57.987+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1567, -24.6, '2026-06-18 23:35:48.728+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1568, 102.76, '2026-06-18 23:36:23.785+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1569, 59.96, '2026-06-18 23:40:48.969+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1570, 21.05, '2026-06-18 23:51:44.469+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1571, 38.71, '2026-06-18 23:50:44.38+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1572, 43.33, '2026-06-18 23:52:14.477+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1573, -44.93, '2026-06-15 18:02:47.154+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1574, 4.2, '2026-06-15 18:02:02.137+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1575, 48.79, '2026-06-18 23:37:43.827+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1576, 48.29, '2026-06-18 23:37:43.859+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1577, 69.78, '2026-06-18 23:52:44.466+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1578, 51.64, '2026-06-18 23:47:59.248+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1579, 54.8, '2026-06-18 23:53:49.507+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1580, 3.45, '2026-06-18 23:42:09.007+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1581, 22.98, '2026-06-18 23:35:13.756+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1582, 12.81, '2026-06-18 23:36:43.766+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1583, 22.72, '2026-06-18 23:35:43.773+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1584, 21.77, '2026-06-18 23:36:28.797+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1585, 40.33, '2026-06-18 23:51:49.456+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1586, 11.56, '2026-06-18 23:39:18.904+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1587, 13.67, '2026-06-18 19:46:14.795+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1588, 15.96, '2026-06-18 23:34:28.685+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1589, -21.32, '2026-06-18 19:39:49.722+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1590, 271.63, '2026-06-18 23:53:49.517+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1591, 26.13, '2026-06-18 23:38:53.858+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1592, 15.11, '2026-05-18 12:20:24.941+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1593, 210.24, '2026-06-16 13:58:13.641+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1594, 0.84, '2026-06-18 23:46:54.184+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1595, 11.38, '2026-06-18 23:49:54.332+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1596, 66.94, '2026-06-18 23:35:33.752+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1597, -6.11, '2026-06-18 19:47:09.801+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1598, 31.75, '2026-06-18 23:52:39.458+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1599, 224.26, '2026-06-16 14:03:33.787+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1600, 25.81, '2026-06-18 23:52:54.506+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1601, 45.88, '2026-06-18 23:38:08.834+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1602, 109.17, '2026-06-18 23:34:48.74+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1603, 40.84, '2026-06-18 23:46:54.282+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1604, 213.5, '2026-06-18 23:50:39.387+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1605, 214.7, '2026-06-18 23:42:39.038+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1606, -6.68, '2026-06-18 23:48:39.271+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1607, 4.85, '2026-06-18 23:41:33.986+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1608, 65.4, '2026-06-18 23:47:09.282+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1609, 57.39, '2026-06-18 23:35:28.713+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1610, 3.38, '2026-06-18 23:50:49.394+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1611, -7.3, '2026-06-18 19:45:29.788+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1612, 50.93, '2026-06-18 23:40:58.977+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1613, 23.15, '2026-06-18 23:52:39.498+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1614, 21.56, '2026-06-18 23:49:19.311+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1615, 15.1, '2026-06-18 23:53:09.524+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1616, 213.52, '2026-06-18 23:50:14.375+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1617, -8.14, '2026-06-18 19:39:44.719+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1618, 30, '2026-06-18 23:51:19.429+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1619, 2.84, '2026-06-18 23:37:33.821+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1620, 167.79, '2026-06-18 23:50:59.411+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1621, 12.81, '2026-06-18 23:47:19.278+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1622, 64.11, '2026-06-15 23:17:52.899+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1623, 14, '2026-06-18 23:53:54.508+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1624, 15.98, '2026-06-18 23:46:49.244+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1625, 11.84, '2026-06-18 23:37:08.792+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1626, 50.5, '2026-06-18 23:48:39.284+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1627, 234.89, '2026-06-16 13:53:48.594+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1628, 213.89, '2026-06-18 23:48:19.279+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1629, 213.76, '2026-06-18 23:47:24.235+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1630, 238.96, '2026-06-16 14:01:28.761+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1631, 47.87, '2026-06-18 23:53:19.491+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1632, 231.97, '2026-06-18 23:37:38.827+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1633, 76.51, '2026-06-18 23:42:59.089+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1634, 25.74, '2026-06-18 23:52:44.513+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1635, 216.41, '2026-06-18 23:39:58.919+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1636, 15.36, '2026-06-18 23:37:38.843+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1637, -2.46, '2026-06-18 23:38:48.864+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1638, 275.62, '2026-06-18 23:53:09.497+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1639, 11.63, '2026-06-18 23:34:53.721+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1640, 11.8, '2026-06-18 19:44:54.78+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1641, 72.11, '2026-06-15 23:25:08.141+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1642, 83.5, '2026-06-18 23:48:19.263+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1643, 23.08, '2026-06-18 23:48:29.339+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1644, 44.63, '2026-06-18 23:39:03.863+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1645, 237.22, '2026-06-18 23:49:44.351+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1646, 11.39, '2026-06-18 23:23:38.238+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1647, 28.18, '2026-06-18 23:53:44.525+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1648, 11.57, '2026-06-18 23:51:59.467+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1649, 11.59, '2026-06-18 23:54:04.562+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1650, 2.7, '2026-05-18 12:21:04.906+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1651, 4.12, '2026-06-18 23:42:04.006+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1652, 23.34, '2026-06-18 19:45:14.785+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1653, 30.53, '2026-06-18 23:48:19.257+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1654, 20.84, '2026-06-18 23:53:29.526+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1655, -24.28, '2026-06-18 23:37:33.798+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1656, -7.39, '2026-06-18 19:44:04.769+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1657, 13.81, '2026-06-18 23:39:58.901+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1658, 52.06, '2026-06-18 23:47:29.279+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1659, 221.27, '2026-06-18 23:35:23.734+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1660, 67.57, '2026-06-15 23:19:37.942+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1661, 236.46, '2026-06-18 23:47:49.264+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1662, 13.84, '2026-06-18 23:36:28.785+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1663, 234.54, '2026-06-18 23:36:08.768+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1664, 61, '2026-06-15 23:23:33.03+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1665, 61.46, '2026-06-15 23:22:38.006+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1666, 55.55, '2026-06-18 23:42:24.088+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1667, 53.25, '2026-06-18 23:47:49.294+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1668, 1.46, '2026-06-18 23:35:28.745+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1669, 23.11, '2026-06-18 23:53:34.541+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1670, 61.75, '2026-06-15 23:18:37.907+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1671, 24.12, '2026-06-18 23:47:44.252+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1672, 1.34, '2026-06-18 23:49:44.346+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1673, 263.26, '2026-06-18 23:47:19.232+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1674, 66.86, '2026-06-18 23:48:44.352+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1675, 2.31, '2026-06-18 23:42:54.014+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1676, 14.32, '2026-06-18 23:25:18.41+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1677, 217.71, '2026-06-18 23:47:09.242+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1678, 74.32, '2026-06-18 23:34:43.737+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1679, 30.73, '2026-06-18 23:26:08.386+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1680, 12.03, '2026-06-18 23:23:53.273+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1681, 12.52, '2026-06-18 23:47:14.231+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1682, 21.78, '2026-06-18 23:37:43.808+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1683, 31.13, '2026-06-18 23:36:13.75+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1684, 85.65, '2026-06-18 23:40:38.992+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1685, 71.67, '2026-06-18 23:41:14.004+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1686, 69.13, '2026-06-18 23:37:48.897+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1687, -4.25, '2026-06-18 23:36:18.803+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1688, -1.62, '2026-06-18 23:39:18.862+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1689, 51.35, '2026-06-18 23:40:13.933+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1690, 1.82, '2026-06-18 19:40:34.732+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1691, 21.79, '2026-06-18 19:43:39.758+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1692, 220.19, '2026-06-16 13:57:43.617+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1693, 20.18, '2026-06-18 23:50:39.403+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1694, 54.38, '2026-06-18 23:36:03.798+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1695, 162.48, '2026-06-18 23:36:33.79+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1696, 12.64, '2026-06-18 23:20:53.126+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1697, 33.11, '2026-06-18 23:46:59.187+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1698, 3.21, '2026-06-18 23:38:18.845+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1699, 64.8, '2026-06-18 23:51:04.434+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1700, 222.08, '2026-06-18 23:34:13.706+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1701, 8.84, '2026-06-18 23:49:34.316+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1702, 54.32, '2026-06-15 23:23:38.074+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1703, 56.6, '2026-06-18 23:49:49.398+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1704, 20.74, '2026-06-18 23:46:59.277+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1705, 72.33, '2026-06-18 23:52:34.523+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1706, 69.55, '2026-06-18 23:34:28.778+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1707, 66.07, '2026-06-18 23:40:48.959+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1708, 2.18, '2026-06-18 23:51:04.383+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1709, 24.97, '2026-06-18 23:36:28.766+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1710, 38.77, '2026-06-18 23:35:48.746+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1711, 16.67, '2026-06-18 23:47:19.2+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1712, 213.72, '2026-06-18 23:46:54.26+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1713, 35.41, '2026-06-15 18:04:17.167+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1714, 6.45, '2026-06-18 23:40:53.959+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1715, 34.45, '2026-06-18 23:39:08.896+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1716, 43.93, '2026-06-18 23:35:53.791+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1717, 10.2, '2026-06-18 23:48:34.266+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1718, -5.38, '2026-06-15 17:58:32.102+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1719, 53.38, '2026-06-15 23:18:27.878+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1720, 5.84, '2026-06-18 19:47:39.809+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1721, 14.15, '2026-06-18 23:37:23.827+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1722, 24.23, '2026-06-18 23:39:33.923+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1723, 51.15, '2026-06-18 23:52:49.468+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1724, 51.9, '2026-06-15 23:24:43.177+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1725, 36.09, '2026-06-18 23:37:48.876+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1726, -6.52, '2026-06-18 23:50:49.379+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1727, 23.16, '2026-06-18 23:41:23.997+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1728, 213.27, '2026-06-16 13:58:03.642+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1729, 13.63, '2026-06-18 23:50:44.425+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1730, 57.04, '2026-06-18 23:47:24.221+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1731, 160.52, '2026-06-18 23:49:24.339+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1732, 165.56, '2026-06-18 23:39:38.899+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1733, 23.89, '2026-06-18 23:41:19.005+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1734, 28.99, '2026-06-18 23:48:49.292+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1735, 5.46, '2026-06-18 23:41:33.969+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1736, 27.37, '2026-06-18 23:22:28.184+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1737, 224.96, '2026-06-18 23:38:28.855+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1738, 3.66, '2026-06-18 23:39:58.911+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1739, 12.64, '2026-06-18 23:48:04.238+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1740, 30.17, '2026-06-18 23:38:43.849+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1741, 68.5, '2026-06-15 23:24:03.068+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1742, 224.89, '2026-06-18 23:49:04.332+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1743, 16.86, '2026-06-18 23:38:33.853+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1744, -7.83, '2026-06-18 19:43:14.753+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1745, 7.99, '2026-06-15 17:56:12.061+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1746, 19.33, '2026-06-18 23:37:28.889+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1747, 27.28, '2026-06-18 23:49:14.346+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1748, 11.84, '2026-06-18 23:20:28.178+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1749, 11.14, '2026-06-18 23:40:38.981+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1750, 238, '2026-06-16 14:01:23.727+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1751, 34.52, '2026-06-18 23:40:48.929+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1752, 219.69, '2026-06-18 23:54:04.553+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1753, 58.67, '2026-06-18 23:51:59.436+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1754, 21.06, '2026-06-18 23:53:44.53+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1755, 211.85, '2026-06-18 23:36:53.808+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1756, 77.06, '2026-06-18 23:49:24.365+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1757, 76.15, '2026-06-18 23:36:48.853+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1758, 20.15, '2026-06-18 23:38:18.878+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1759, 72.45, '2026-06-15 23:19:33.031+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1760, 84.62, '2026-06-18 23:48:49.332+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1761, 11.65, '2026-06-18 23:42:19.032+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1762, 33.94, '2026-06-18 23:50:44.418+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1763, 54.42, '2026-06-18 23:50:54.519+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1764, 212.32, '2026-06-16 13:58:53.65+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1765, 75.36, '2026-06-18 23:47:24.256+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1766, 279.31, '2026-06-16 14:02:13.774+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1767, 8.94, '2026-06-18 19:42:24.747+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1768, 20.85, '2026-06-18 23:50:54.504+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1769, 236.93, '2026-06-16 13:57:28.678+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1770, 27.14, '2026-06-18 23:49:29.325+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1771, 86.22, '2026-06-18 23:49:59.372+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1772, 228.71, '2026-06-18 23:35:13.736+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1773, 8.62, '2026-06-18 23:51:54.436+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1774, 88.27, '2026-06-18 23:47:24.245+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1775, 23.58, '2026-06-18 23:47:59.254+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1776, 23.13, '2026-06-15 18:04:22.165+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1777, 16.08, '2026-06-18 19:41:39.733+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1778, 6.66, '2026-06-18 19:41:24.734+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1779, 7.79, '2026-06-18 23:35:53.74+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1780, 13.51, '2026-06-18 23:35:18.766+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1781, 1.26, '2026-06-18 23:52:39.47+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1782, 41.37, '2026-06-18 23:51:44.431+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1783, -17.55, '2026-06-18 23:38:48.843+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1784, 19.31, '2026-06-18 23:51:04.418+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1785, 11.37, '2026-06-18 23:36:33.807+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1786, 33.89, '2026-06-18 23:53:04.523+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1787, 228.84, '2026-06-18 23:40:28.941+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1788, 38.51, '2026-06-18 23:48:24.344+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1789, 4.53, '2026-06-18 23:38:23.849+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1790, 220.13, '2026-06-16 13:57:23.644+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1791, 32.02, '2026-06-18 23:39:18.879+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1792, 218.44, '2026-06-18 23:42:54.049+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1793, 63.46, '2026-06-18 23:42:09.042+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1794, -9.4, '2026-06-18 23:50:14.348+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1795, 19.3, '2026-06-18 23:41:54.017+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1796, 65.75, '2026-06-18 23:47:59.277+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1797, 62.7, '2026-06-18 23:34:13.75+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1798, 76.26, '2026-06-18 23:49:39.364+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1799, 55.92, '2026-06-15 23:19:12.969+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1800, 20.18, '2026-06-18 23:42:08.982+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1801, 225.86, '2026-06-18 23:39:53.987+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1802, 237.4, '2026-06-18 23:52:14.458+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1803, 12.01, '2026-06-18 23:24:38.305+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1804, 5.82, '2026-06-18 23:51:04.389+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1805, -5.31, '2026-06-18 23:40:23.904+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1806, 13.77, '2026-06-18 23:53:19.512+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1807, 55.11, '2026-06-15 23:24:33.135+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1808, 4.17, '2026-06-18 23:38:38.862+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1809, 1.03, '2026-06-18 23:48:59.306+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1810, 6.02, '2026-06-18 23:35:23.717+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1811, 56.1, '2026-06-18 23:42:49.078+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1812, 11.12, '2026-06-18 23:49:49.376+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1813, 21.35, '2026-06-18 23:34:38.729+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1814, 13.14, '2026-06-18 19:40:24.729+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1815, 213.49, '2026-06-18 23:50:04.378+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1816, 25.76, '2026-06-18 23:51:59.485+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1817, 25.65, '2026-06-18 23:40:43.971+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1818, 1.15, '2026-06-18 19:45:34.787+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1819, 47.73, '2026-06-18 23:49:29.363+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1820, 96.92, '2026-06-18 23:48:04.306+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1821, 13.07, '2026-06-18 23:26:13.351+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1822, 14.15, '2026-06-18 23:24:03.258+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1823, 30.34, '2026-06-18 23:37:18.795+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1824, 45.02, '2026-06-18 23:49:09.308+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1825, 214.45, '2026-06-16 13:58:08.693+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1826, 74.3, '2026-06-18 23:41:29.013+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1827, 217.1, '2026-06-16 13:55:53.591+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1828, 24.04, '2026-06-18 23:38:53.894+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1829, 97.36, '2026-06-18 23:47:44.282+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1830, 35.65, '2026-06-18 23:50:14.409+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1831, 20.72, '2026-06-18 19:39:54.722+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1832, 50.12, '2026-06-18 23:36:48.777+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1833, 83.2, '2026-06-18 23:34:28.747+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1834, 218.66, '2026-06-18 23:41:28.98+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1835, 17.79, '2026-06-18 23:36:38.772+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1836, 174.5, '2026-06-16 13:59:48.683+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1837, 22.39, '2026-06-18 23:36:23.796+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1838, 29.33, '2026-06-18 23:46:59.265+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1839, 21.39, '2026-06-18 23:43:04.171+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1840, 17.36, '2026-06-18 23:34:18.673+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1841, 4.49, '2026-06-18 23:42:44.031+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1842, 38.95, '2026-06-18 23:53:59.513+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1843, 245.76, '2026-06-16 13:59:58.736+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1844, -1.32, '2026-06-15 18:01:32.13+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1845, -3.84, '2026-06-18 23:34:13.694+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1846, 21.69, '2026-06-18 23:49:59.381+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1847, 17.17, '2026-06-18 23:53:54.497+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1848, 15.24, '2026-06-18 23:52:04.431+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1849, 11.36, '2026-06-18 23:40:33.951+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1850, 8.63, '2026-06-18 23:53:04.474+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1851, 1.49, '2026-06-18 23:48:54.303+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1852, 69.57, '2026-06-15 23:21:02.987+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1853, 34.43, '2026-05-18 12:20:25.005+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1854, 2.11, '2026-06-18 19:48:09.812+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1855, 13.56, '2026-06-18 23:22:13.236+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1856, 4.55, '2026-06-15 18:03:42.161+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1857, -5.91, '2026-06-18 23:41:18.945+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1858, 5.87, '2026-06-15 18:00:32.122+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1859, 24.45, '2026-06-18 23:37:18.845+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1860, 220.22, '2026-06-18 23:40:13.977+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1861, 12.27, '2026-06-18 23:41:49.004+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1862, 17.02, '2026-06-18 23:53:09.48+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1863, 273.81, '2026-06-18 23:35:03.731+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1864, 57.26, '2026-06-18 23:34:33.746+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1865, 5.37, '2026-06-18 19:38:39.719+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1866, 79.41, '2026-06-18 23:49:49.384+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1867, -19.19, '2026-06-18 19:47:44.811+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1868, 33.88, '2026-06-18 23:34:33.692+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1869, -25.26, '2026-06-18 19:44:24.771+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1870, -2.35, '2026-06-18 23:39:33.886+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1871, 56.17, '2026-06-18 23:50:59.397+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1872, 15.63, '2026-06-18 23:48:29.293+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1873, 1.55, '2026-06-18 23:37:28.816+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1874, 12.43, '2026-06-18 23:39:03.881+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1875, 8.67, '2026-06-18 19:40:59.734+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1876, 12.39, '2026-06-18 23:48:09.276+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1877, 7.46, '2026-06-18 23:51:44.459+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1878, -3.13, '2026-06-18 23:51:34.422+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1879, 28.6, '2026-06-18 23:49:44.34+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1880, 18.83, '2026-06-18 19:45:19.785+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1881, 18.36, '2026-06-18 23:53:49.548+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1882, 4.45, '2026-06-18 23:34:53.71+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1883, 6.31, '2026-06-18 23:40:18.916+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1884, 9.15, '2026-06-18 23:38:28.83+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1885, 0.9, '2026-06-18 23:37:48.842+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1886, 13.72, '2026-06-18 23:40:43.954+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1887, 7.27, '2026-06-18 23:38:48.903+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1888, 1.3, '2026-06-18 23:51:29.42+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1889, 42.37, '2026-06-18 23:34:53.727+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1890, 3.43, '2026-06-18 23:39:48.878+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1891, 220.69, '2026-06-18 23:53:59.527+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1892, 35.2, '2026-06-18 23:52:04.438+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1893, 75.59, '2026-06-15 23:22:03.032+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1894, -9.65, '2026-06-15 17:57:42.09+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1895, 23.93, '2026-06-18 23:48:09.289+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1896, 57.27, '2026-06-15 23:17:37.899+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1897, 12.94, '2026-06-18 23:25:43.345+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1898, 227.68, '2026-06-16 13:58:48.609+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1899, -4.82, '2026-06-18 23:37:43.817+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1900, 210.56, '2026-06-18 23:41:18.973+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1901, 233.29, '2026-06-18 23:53:54.535+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1902, 68.76, '2026-06-18 23:42:29.161+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1903, 216.89, '2026-06-16 13:54:53.533+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1904, 16.24, '2026-06-15 18:01:17.13+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1905, 18.77, '2026-06-18 23:21:23.162+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1906, 70.7, '2026-06-15 23:20:12.931+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1907, 13.61, '2026-06-18 23:47:49.273+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1908, 18.37, '2026-06-18 23:40:08.92+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1909, 63.33, '2026-06-15 23:18:43.014+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1910, 223.94, '2026-06-18 23:37:53.848+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1911, 20.87, '2026-06-18 23:39:08.864+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1912, 17.7, '2026-06-18 23:52:14.439+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1913, 24.96, '2026-06-18 23:39:43.941+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1914, 67.85, '2026-06-18 23:47:39.28+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1915, 40.42, '2026-06-18 23:36:18.828+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1916, 31.48, '2026-06-18 23:53:09.486+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1917, 25.16, '2026-06-18 23:42:54.057+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1918, 47.13, '2026-06-18 23:35:23.723+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1919, 0.34, '2026-06-18 23:53:14.518+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1920, 38.58, '2026-06-18 23:35:43.74+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1921, 3.01, '2026-06-18 19:46:54.8+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1922, 66.43, '2026-06-18 23:42:54.087+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1923, 52.05, '2026-06-18 23:36:38.838+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1924, -2.23, '2026-06-18 23:42:49.018+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1925, 215.52, '2026-06-18 23:53:34.509+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1926, 210.38, '2026-06-18 23:53:39.522+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1927, 23.7, '2026-06-18 23:52:34.46+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1928, 61, '2026-06-18 23:51:24.413+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1929, 70.25, '2026-06-15 23:16:27.846+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1930, 2.36, '2026-06-18 23:48:49.299+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1931, 5.23, '2026-06-18 23:40:13.92+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1932, 16.91, '2026-06-18 23:47:04.235+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1933, 8.31, '2026-06-18 23:22:18.243+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1934, 12.9, '2026-06-18 23:41:03.943+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1935, 51.98, '2026-06-18 23:38:08.878+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1936, 229.01, '2026-06-18 23:42:09.014+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1937, 43.57, '2026-06-18 23:48:19.304+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1938, 266.21, '2026-06-18 23:40:03.932+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1939, 56.1, '2026-06-15 23:15:42.949+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1940, 67.24, '2026-06-18 23:38:48.897+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1941, 22.03, '2026-06-18 23:40:33.973+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1942, 3.57, '2026-06-18 19:44:34.771+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1943, 13.29, '2026-06-18 23:25:08.304+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1944, 214.9, '2026-06-18 23:52:19.458+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1945, 1.47, '2026-06-18 23:42:28.995+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1946, 62.31, '2026-06-18 23:49:04.355+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1947, 62.1, '2026-06-18 23:49:14.363+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1948, 12.58, '2026-06-18 23:40:03.945+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1949, 19.73, '2026-06-18 23:37:13.795+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1950, 24.71, '2026-06-18 23:42:24.08+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1951, 18.92, '2026-06-18 23:34:53.732+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1952, 2.9, '2026-06-18 23:36:43.788+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1953, 53.39, '2026-06-15 23:18:52.917+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1954, 11.57, '2026-06-18 23:50:24.392+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1955, 231.81, '2026-06-18 23:39:33.895+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1956, 7.99, '2026-06-18 23:35:33.758+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1957, 2.85, '2026-06-18 23:36:33.785+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1958, 58.62, '2026-06-15 23:19:22.963+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1959, 16.52, '2026-06-18 23:40:23.949+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1960, 51.12, '2026-06-18 23:42:54.071+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1961, 41.8, '2026-06-18 23:41:08.991+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1962, 20.74, '2026-06-18 23:36:43.814+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1963, 57.59, '2026-06-18 23:48:39.316+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1964, 231.86, '2026-06-18 23:41:03.97+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1965, 41.23, '2026-06-18 23:39:33.881+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1966, -1.89, '2026-06-18 23:48:34.322+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1967, 229.86, '2026-06-16 14:01:33.82+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1968, 220.44, '2026-06-16 14:02:23.793+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1969, 210.46, '2026-06-16 14:02:33.77+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1970, 12.73, '2026-06-18 23:49:09.323+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1971, 213.74, '2026-06-18 23:53:04.504+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1972, 71.7, '2026-06-18 23:35:03.778+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1973, 12.5, '2026-06-18 23:41:28.99+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1974, 3.74, '2026-06-18 23:36:08.761+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1975, 209.87, '2026-06-16 13:59:43.693+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1976, 16.3, '2026-06-18 23:47:34.221+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1977, 19.73, '2026-06-18 23:40:03.905+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1978, 2.79, '2026-06-18 23:39:13.91+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1979, 42.32, '2026-06-15 18:03:37.161+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1980, 4.09, '2026-06-18 19:43:29.76+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1981, 9.88, '2026-06-15 17:55:27.049+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1982, 22.47, '2026-06-15 17:57:37.084+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1983, 230.6, '2026-06-18 23:51:19.421+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1984, 12.74, '2026-06-18 23:35:53.733+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1985, 12.03, '2026-06-18 23:34:23.7+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1986, 72.63, '2026-06-18 23:53:04.538+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1987, 29.16, '2026-06-18 23:34:38.694+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1988, 17.88, '2026-06-18 19:41:54.74+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1989, 45.89, '2026-06-18 23:48:14.26+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1990, 6.02, '2026-06-18 19:44:49.775+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1991, 234.6, '2026-06-18 23:42:19.02+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1992, 33.7, '2026-06-18 23:52:34.488+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1993, 20.71, '2026-06-18 23:40:03.961+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1994, -4.22, '2026-06-18 23:36:53.771+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1995, 198.44, '2026-06-16 13:56:38.593+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1996, 46.23, '2026-06-18 23:49:59.339+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1997, 17.26, '2026-06-15 18:02:32.147+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1998, 45.94, '2026-06-18 23:37:03.789+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (1999, 17.63, '2026-06-18 19:39:09.714+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2000, 11.98, '2026-06-18 23:52:29.473+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2001, 6.01, '2026-06-18 23:53:44.499+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2002, 19.89, '2026-06-18 23:39:48.886+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2003, 29.71, '2026-06-18 23:49:29.318+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2004, -5.55, '2026-06-18 23:39:23.864+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2005, -8.54, '2026-06-18 19:44:09.768+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2006, 12.55, '2026-06-18 23:47:54.265+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2007, 7.02, '2026-06-18 23:40:53.926+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2008, 215.18, '2026-06-18 23:49:54.366+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2009, 25.61, '2026-06-18 23:43:09.066+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2010, 32.85, '2026-06-18 23:20:33.135+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2011, -17.23, '2026-06-18 23:50:14.385+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2012, 67.96, '2026-06-18 23:40:39.013+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2013, 28.28, '2026-06-18 23:36:58.822+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2014, 42.59, '2026-06-15 18:00:52.125+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2015, 34.2, '2026-06-18 23:21:53.169+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2016, 4.75, '2026-06-18 19:41:34.739+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2017, 9.29, '2026-06-18 23:48:19.271+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2018, 39.8, '2026-06-18 23:41:03.953+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2019, 11.73, '2026-06-18 23:36:03.738+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2020, 31.65, '2026-06-18 23:34:18.681+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2021, 66.89, '2026-06-18 23:37:38.85+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2022, -2.18, '2026-06-18 19:41:14.734+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2023, 21.99, '2026-06-18 23:38:08.851+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2024, 4.6, '2026-06-18 23:38:03.847+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2025, 71.36, '2026-06-18 23:52:59.537+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2026, 12.25, '2026-06-18 23:51:09.422+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2027, 2.34, '2026-06-18 23:35:13.706+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2028, 215.77, '2026-06-16 13:55:38.572+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2029, -5.77, '2026-06-18 23:37:13.827+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2030, 65.01, '2026-06-15 23:21:53.033+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2031, -7.33, '2026-06-18 23:35:13.726+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2032, 222.51, '2026-06-18 23:39:48.911+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2033, 11.11, '2026-06-18 23:39:23.896+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2034, -13.24, '2026-06-18 23:42:23.993+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2035, 3.87, '2026-06-18 19:42:59.757+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2036, -1.28, '2026-06-18 23:50:54.404+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2037, 9.29, '2026-06-18 23:52:29.44+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2038, 274.53, '2026-06-16 13:58:38.698+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2039, 54.63, '2026-06-18 23:38:28.842+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2040, 51.98, '2026-06-15 23:18:02.915+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2041, 8.14, '2026-06-18 23:49:04.29+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2042, 11.67, '2026-06-18 23:48:44.328+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2043, 221.05, '2026-06-16 14:01:58.74+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2044, 2.08, '2026-06-18 23:35:18.779+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2045, 32.37, '2026-06-18 23:53:34.526+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2046, 1.01, '2026-06-18 23:50:34.404+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2047, 40.27, '2026-06-18 23:37:33.864+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2048, 24.11, '2026-06-18 23:52:24.49+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2049, 61.64, '2026-06-15 23:23:23.077+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2050, 11.74, '2026-06-18 23:36:28.753+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2051, 232.6, '2026-06-18 23:37:08.813+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2052, 234.36, '2026-06-16 13:55:48.596+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2053, 77.57, '2026-06-15 23:21:18.179+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2054, 22.8, '2026-06-18 23:48:19.249+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2055, 19.36, '2026-06-18 23:48:44.344+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2056, 18.7, '2026-06-18 23:36:48.811+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2057, 19.81, '2026-06-18 23:39:03.892+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2058, 20.52, '2026-06-18 19:38:49.717+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2059, 228.69, '2026-06-16 13:55:28.579+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2060, 23.55, '2026-06-18 23:50:04.395+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2061, 71.43, '2026-06-18 23:39:38.938+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2062, 59.88, '2026-06-15 23:21:12.98+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2063, 0.37, '2026-06-18 23:36:28.79+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2064, 22.85, '2026-06-18 23:41:13.959+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2065, -3.14, '2026-06-18 23:35:38.722+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2066, -6.23, '2026-06-15 18:02:52.15+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2067, 235.86, '2026-06-18 23:52:29.468+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2068, 18.29, '2026-06-18 23:48:04.301+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2069, 32.04, '2026-06-18 23:34:13.684+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2070, 2.18, '2026-06-15 17:59:02.105+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2071, 2.12, '2026-06-18 23:34:38.699+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2072, -2.34, '2026-06-18 23:37:13.787+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2073, 13.77, '2026-06-18 23:52:54.466+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2074, 14.19, '2026-06-18 23:40:33.919+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2075, -0.73, '2026-06-18 23:40:28.906+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2076, 34.05, '2026-06-18 23:41:58.989+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2077, 21.81, '2026-06-18 23:49:09.333+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2078, 80.07, '2026-06-18 23:47:19.29+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2079, 19.51, '2026-06-18 23:49:19.346+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2080, -4.38, '2026-06-15 17:56:27.067+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2081, -20.71, '2026-06-18 19:44:44.772+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2082, 4.75, '2026-06-18 23:49:04.326+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2083, 12.45, '2026-06-18 23:47:59.269+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2084, 18.36, '2026-06-18 23:48:39.31+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2085, -4, '2026-06-18 23:41:53.969+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2086, 54.66, '2026-06-15 23:21:48.002+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2087, 2.39, '2026-06-15 17:58:42.104+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2088, 53.75, '2026-06-18 23:48:09.25+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2089, 18.43, '2026-06-18 23:41:29.007+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2090, 50.58, '2026-06-18 23:47:34.227+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2091, 76.62, '2026-06-18 23:47:44.297+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2092, 11.21, '2026-06-18 23:49:24.355+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2093, -22.2, '2026-06-15 17:58:12.103+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2094, 10.22, '2026-06-18 19:41:04.738+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2095, 57.56, '2026-06-18 23:38:33.981+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2096, 11.77, '2026-06-18 23:35:53.772+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2097, 18.22, '2026-06-18 23:49:39.327+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2098, 76.75, '2026-06-18 23:40:43.977+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2099, 35.99, '2026-06-18 23:51:14.426+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2100, 3.62, '2026-06-18 23:49:19.323+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2101, 12.52, '2026-06-18 23:35:08.74+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2102, 51.77, '2026-06-18 23:51:09.403+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2103, 209.86, '2026-06-16 14:02:08.745+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2104, 3.58, '2026-06-18 23:52:14.452+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2105, 38.2, '2026-06-18 23:42:49.069+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2106, 20.48, '2026-06-18 23:47:29.272+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2107, 39.68, '2026-06-18 23:51:19.45+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2108, 84.19, '2026-06-18 23:41:59.03+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2109, 58.28, '2026-06-18 23:50:09.437+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2110, 2.82, '2026-06-15 17:56:52.074+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2111, 98.51, '2026-06-18 23:39:18.913+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2112, 30.68, '2026-06-18 23:39:38.888+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2113, 12.76, '2026-06-18 23:51:14.42+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2114, -28.6, '2026-06-18 19:48:29.816+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2115, 96.18, '2026-06-18 23:42:44.093+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2116, 32.89, '2026-06-18 23:51:19.406+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2117, 77.44, '2026-06-15 23:16:07.923+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2118, 217.35, '2026-06-18 23:42:14.031+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2119, 33.7, '2026-06-18 23:37:28.859+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2120, 54.92, '2026-06-18 23:54:09.57+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2121, 21.78, '2026-06-18 23:39:38.933+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2122, 30.83, '2026-06-18 23:43:04.116+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2123, 2.69, '2026-06-18 23:37:18.81+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2124, 71.84, '2026-06-18 23:40:18.972+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2125, 13.77, '2026-06-18 23:35:38.75+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2126, 52.55, '2026-06-18 23:42:29.01+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2127, -0.79, '2026-06-18 23:53:34.481+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2128, 23.31, '2026-06-18 23:47:19.218+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2129, 53.23, '2026-06-18 23:51:39.429+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2130, 13.67, '2026-06-18 23:41:59.022+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2131, 21, '2026-06-18 23:52:39.492+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2132, 43.24, '2026-06-18 23:52:24.455+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2133, 80.8, '2026-06-18 23:38:28.884+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2134, 11.33, '2026-06-18 23:39:43.886+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2135, 22.24, '2026-06-18 23:52:59.522+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2136, 45.94, '2026-06-18 23:51:39.468+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2137, 61.27, '2026-06-18 23:39:08.914+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2138, 237.34, '2026-06-18 23:35:08.73+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2139, 59.17, '2026-06-18 23:47:14.248+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2140, 232.24, '2026-06-16 13:57:48.652+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2141, 18.96, '2026-06-18 23:39:18.928+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2142, 12.15, '2026-06-18 23:52:19.464+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2143, 232.28, '2026-06-16 14:01:48.756+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2144, 213.63, '2026-06-18 23:39:23.89+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2145, 1.16, '2026-06-18 23:34:23.666+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2146, 10.03, '2026-06-18 23:53:19.52+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2147, 13.56, '2026-06-18 23:23:23.224+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2148, 5.02, '2026-06-18 23:20:48.145+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2149, 52.79, '2026-06-05 00:38:00.735+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2150, 12.33, '2026-06-18 23:38:58.86+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2151, 22.77, '2026-06-18 19:43:59.767+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2152, 59.59, '2026-06-18 23:35:23.755+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2153, 26.03, '2026-06-18 23:39:23.879+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2154, 2.81, '2026-06-15 17:55:17.051+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2155, -1.36, '2026-06-18 19:43:04.761+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2156, 3.62, '2026-06-18 23:49:24.331+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2157, -17.97, '2026-06-18 23:40:28.96+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2158, 14.35, '2026-06-18 23:35:23.739+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2159, 11.89, '2026-06-18 23:20:38.143+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2160, 27.6, '2026-06-18 23:40:03.955+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2161, 84.84, '2026-06-18 23:37:38.837+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2162, 17.49, '2026-06-18 19:48:19.819+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2163, 50.73, '2026-06-15 23:16:02.991+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2164, 21.52, '2026-06-18 23:41:44.016+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2165, -17.32, '2026-06-18 19:43:34.761+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2166, 63.29, '2026-06-15 23:18:57.964+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2167, -17.61, '2026-06-18 23:37:23.832+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2168, 47.73, '2026-06-18 23:37:23.799+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2169, 230.44, '2026-06-18 23:34:33.709+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2170, 61.72, '2026-06-15 23:24:38.158+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2171, 239.77, '2026-06-16 13:55:03.646+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2172, 210.57, '2026-06-16 14:00:43.695+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2173, 269.03, '2026-06-16 14:03:03.763+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2174, 61, '2026-06-18 23:41:44.009+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2175, 62.78, '2026-06-18 23:47:04.278+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2176, -1.84, '2026-06-18 23:52:59.481+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2177, 217.15, '2026-06-16 13:54:28.564+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2178, 246.52, '2026-06-18 23:38:18.85+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2179, 5.15, '2026-06-18 23:51:54.416+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2180, 16.37, '2026-06-15 18:04:27.166+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2181, 3.99, '2026-06-18 23:37:18.837+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2182, 216.67, '2026-06-18 23:52:24.47+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2183, -6.26, '2026-06-18 23:49:44.326+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2184, 9.06, '2026-06-15 18:04:52.175+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2185, 14.22, '2026-06-18 23:37:03.812+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2186, 26.17, '2026-06-18 23:21:13.152+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2187, 9.74, '2026-06-18 23:35:08.723+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2188, 8.36, '2026-06-15 17:57:02.071+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2189, 4.94, '2026-06-18 23:38:43.885+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2190, 2.28, '2026-06-18 23:53:54.528+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2191, 68.4, '2026-06-18 23:36:38.821+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2192, 37.07, '2026-06-18 23:47:54.273+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2193, 5.77, '2026-06-18 23:49:24.307+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2194, 73.82, '2026-06-18 23:38:23.885+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2195, 56.81, '2026-06-18 23:35:28.736+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2196, 32.97, '2026-06-18 23:50:24.371+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2197, 2.74, '2026-06-18 23:47:29.209+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2198, 52.06, '2026-06-18 19:46:29.796+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2199, 101.1, '2026-06-18 23:47:39.233+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2200, 23.87, '2026-06-18 23:36:08.788+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2201, 77.28, '2026-06-18 23:42:14.005+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2202, 5.09, '2026-06-18 19:46:04.794+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2203, 69.4, '2026-06-18 23:41:54.025+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2204, 61.92, '2026-06-18 23:35:13.72+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2205, -9.14, '2026-06-15 17:58:47.108+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2206, 2.93, '2026-06-18 23:39:38.874+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2207, 2.57, '2026-06-18 23:37:58.844+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2208, 31.21, '2026-06-18 23:48:44.276+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2209, -5.77, '2026-06-15 18:01:02.127+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2210, 2.47, '2026-06-18 23:35:18.75+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2211, 25.76, '2026-06-18 23:48:54.334+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2212, -1.24, '2026-06-18 23:50:04.338+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2213, 1.02, '2026-06-18 23:50:39.365+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2214, 1.56, '2026-06-18 23:49:09.313+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2215, 214.41, '2026-06-18 23:49:29.336+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2216, 51.27, '2026-06-18 23:50:59.453+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2217, 87.72, '2026-06-18 23:48:59.334+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2218, -39.72, '2026-06-18 23:40:38.916+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2219, 25.42, '2026-06-18 23:39:13.929+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2220, 25.31, '2026-06-18 23:35:18.725+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2221, 13.22, '2026-06-18 23:53:44.519+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2222, 210.56, '2026-06-18 23:40:08.927+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2223, 246.61, '2026-06-18 23:53:19.504+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2224, 83.38, '2026-06-18 23:52:04.485+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2225, 36.99, '2026-06-15 23:23:43.027+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2226, 28.14, '2026-06-18 23:47:14.207+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2227, 11.4, '2026-06-18 23:48:29.323+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2228, -1.35, '2026-06-18 23:46:49.195+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2229, 0.65, '2026-06-18 23:51:59.446+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2230, 260.16, '2026-06-18 23:42:34.028+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2231, 65.42, '2026-06-18 23:34:48.766+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2232, 14.39, '2026-06-18 23:35:48.739+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2233, 263.32, '2026-06-18 23:37:33.829+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2234, 13.73, '2026-06-18 23:50:34.394+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2235, 264.28, '2026-06-18 23:37:48.85+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2236, 23.17, '2026-06-18 23:38:43.855+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2237, 12.08, '2026-06-18 23:26:18.366+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2238, 35.25, '2026-06-18 23:51:34.417+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2239, 197.88, '2026-06-16 13:56:13.729+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2240, 20.34, '2026-06-18 23:53:24.597+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2241, 5.67, '2026-06-18 23:38:53.853+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2242, 55.61, '2026-06-18 23:36:08.783+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2243, 12.21, '2026-06-18 23:25:28.32+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2244, -8.48, '2026-06-18 23:52:59.462+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2245, 13.75, '2026-06-18 23:38:58.901+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2246, 64.8, '2026-06-18 23:51:34.468+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2247, 250.14, '2026-06-16 14:01:13.809+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2248, 18.79, '2026-06-18 19:48:14.814+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2249, 231.53, '2026-06-16 13:59:28.696+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2250, 94.9, '2026-06-18 23:53:39.555+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2251, 11.2, '2026-06-18 23:50:39.393+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2252, -0.44, '2026-06-18 23:38:28.847+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2253, 44.97, '2026-06-18 23:51:59.426+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2254, 20, '2026-06-18 23:37:58.814+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2255, 85.85, '2026-06-18 23:39:18.936+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2256, 220.8, '2026-06-18 23:36:48.824+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2257, 18.91, '2026-06-18 23:41:53.976+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2258, -2.36, '2026-06-18 19:44:39.769+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2259, 58.39, '2026-06-18 23:50:24.428+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2260, 60.94, '2026-06-15 23:16:57.874+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2261, 210.84, '2026-06-18 23:41:08.963+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2262, 230.2, '2026-06-18 23:51:04.405+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2263, 47.63, '2026-06-18 23:46:49.204+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2264, 8.82, '2026-06-18 23:53:39.487+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2265, 64.26, '2026-06-18 23:51:49.468+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2266, 58.38, '2026-06-15 23:23:48.047+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2267, 71.16, '2026-06-18 23:38:53.899+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2268, 14.29, '2026-06-18 23:47:19.211+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2269, 60.84, '2026-06-18 23:42:49.064+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2270, 13.6, '2026-06-18 23:49:59.365+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2271, 221.98, '2026-06-18 23:48:34.295+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2272, 19.99, '2026-06-18 23:38:23.835+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2273, 13.1, '2026-06-18 23:48:14.255+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2274, 11.14, '2026-06-18 23:42:44.053+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2275, 235.25, '2026-06-16 13:57:38.625+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2276, 25.6, '2026-06-18 23:50:14.398+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2277, 12.85, '2026-06-18 19:47:19.804+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2278, 176.67, '2026-06-18 23:52:34.475+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2279, 51.96, '2026-06-18 23:50:34.377+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2280, 4.74, '2026-06-18 23:34:43.703+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2281, 276.53, '2026-06-18 23:36:13.773+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2282, 50.69, '2026-06-15 23:20:37.99+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2283, 19.01, '2026-06-18 23:50:04.362+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2284, 13.04, '2026-06-18 23:41:54.001+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2285, 1.29, '2026-06-18 23:41:08.939+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2286, 56.63, '2026-06-15 17:59:27.11+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2287, 23.97, '2026-06-18 23:41:39.024+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2288, -4.78, '2026-06-18 23:38:38.838+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2289, 62.32, '2026-06-18 23:50:29.423+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2290, 39.59, '2026-06-18 23:41:48.983+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2291, 48.3, '2026-06-18 23:40:03.914+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2292, 32.66, '2026-06-18 23:47:49.237+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2293, -0.97, '2026-06-18 23:34:58.691+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2294, 69.8, '2026-06-18 23:53:09.534+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2295, 16.09, '2026-06-18 23:47:14.2+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2296, -2.61, '2026-06-18 23:34:28.732+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2297, 19.45, '2026-06-18 23:38:38.899+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2298, 16.19, '2026-06-18 23:35:43.735+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2299, 60.64, '2026-06-15 23:23:53.068+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2300, 4.06, '2026-06-18 23:40:38.955+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2301, 3.15, '2026-06-18 23:54:04.543+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2302, 1.71, '2026-06-18 23:50:24.378+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2303, 71.78, '2026-06-15 23:21:57.971+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2304, 58.69, '2026-06-18 23:40:28.99+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2305, 59.91, '2026-06-18 23:47:09.263+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2306, 218.23, '2026-06-18 23:42:29.025+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2307, 3.39, '2026-06-18 23:50:39.382+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2308, 77.32, '2026-06-15 23:22:53.022+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2309, 196.24, '2026-06-18 23:47:14.223+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2310, 24.17, '2026-06-18 23:47:44.289+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2311, 20.39, '2026-06-18 23:49:44.366+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2312, 8.62, '2026-06-18 23:42:19.055+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2313, -8.09, '2026-06-18 23:36:13.755+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2314, 25.18, '2026-06-18 23:53:59.548+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2315, 212.1, '2026-06-16 13:58:43.715+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2316, -6.44, '2026-06-18 23:39:33.907+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2317, 57.09, '2026-06-15 23:17:07.873+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2318, 22.5, '2026-06-18 19:45:24.785+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2319, 13.18, '2026-06-18 23:37:58.861+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2320, 54.28, '2026-06-15 23:20:42.968+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2321, 238.93, '2026-06-16 14:01:38.776+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2322, 2.27, '2026-06-18 23:42:49.038+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2323, 14.08, '2026-06-18 23:49:49.333+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2324, 238.5, '2026-06-16 14:01:03.74+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2325, 221.62, '2026-06-16 13:54:03.562+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2326, 32.5, '2026-06-18 23:50:29.357+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2327, 29.73, '2026-06-18 23:41:08.946+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2328, 48.38, '2026-06-15 18:03:47.162+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2329, 13.64, '2026-06-18 23:34:33.716+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2330, 3.34, '2026-06-18 23:41:13.967+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2331, -34.86, '2026-06-18 23:36:18.746+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2332, 24.91, '2026-06-18 23:38:48.852+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2333, 58.1, '2026-06-15 23:22:48.003+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2334, 14.39, '2026-06-18 23:24:08.288+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2335, 6.21, '2026-06-18 23:47:34.232+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2336, 11.38, '2026-06-18 23:35:58.767+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2337, 96, '2026-06-18 23:40:53.993+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2338, 40.5, '2026-06-18 23:49:04.321+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2339, 21.79, '2026-06-18 23:34:43.691+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2340, -3, '2026-06-18 23:42:39.028+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2341, 81.1, '2026-06-18 23:40:33.965+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2342, 53.17, '2026-06-18 23:40:58.942+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2343, 53.13, '2026-06-18 23:34:58.733+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2344, 26.85, '2026-06-18 23:36:58.784+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2345, 4.5, '2026-06-18 23:50:04.373+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2346, 13.86, '2026-06-18 23:36:03.776+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2347, 219.52, '2026-06-18 23:52:09.468+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2348, 90.78, '2026-06-18 23:46:49.257+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2349, 10, '2026-06-18 19:41:29.735+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2350, 0.87, '2026-06-18 23:39:48.891+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2351, 0.18, '2026-06-18 23:54:59.541+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2352, 25.9, '2026-06-18 23:54:59.567+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2353, -0.08, '2026-06-18 23:54:59.572+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2354, 3.42, '2026-06-18 23:54:59.583+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2355, 231.37, '2026-06-18 23:54:59.593+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2356, 11.6, '2026-06-18 23:54:59.601+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2357, 94.46, '2026-06-18 23:54:59.609+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2358, 23.72, '2026-06-18 23:54:59.617+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2359, 55.02, '2026-06-18 23:54:59.629+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2360, -14.79, '2026-06-18 23:55:04.544+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2361, 41.01, '2026-06-18 23:55:04.553+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2362, 29.39, '2026-06-18 23:55:04.562+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2363, 14.47, '2026-06-18 23:55:04.574+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2364, 218.33, '2026-06-18 23:55:04.583+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2365, 13.15, '2026-06-18 23:55:04.593+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2366, 117.97, '2026-06-18 23:55:04.599+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2367, 23.57, '2026-06-18 23:55:04.613+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2368, 86.27, '2026-06-18 23:55:04.622+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2369, 22.63, '2026-06-18 23:55:09.551+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2370, 16.97, '2026-06-18 23:55:09.564+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2371, 53.39, '2026-06-18 23:55:09.57+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2372, 4, '2026-06-18 23:55:09.578+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2373, 231.05, '2026-06-18 23:55:09.584+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2374, 12.32, '2026-06-18 23:55:09.594+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2375, 30.96, '2026-06-18 23:55:09.599+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2376, 27.34, '2026-06-18 23:55:09.606+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2377, 50.29, '2026-06-18 23:55:09.617+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2378, 15.61, '2026-06-18 23:55:14.555+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2379, 28.35, '2026-06-18 23:55:14.562+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2380, 35.58, '2026-06-18 23:55:14.568+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2381, 3.69, '2026-06-18 23:55:14.574+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2382, 229.26, '2026-06-18 23:55:14.579+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2383, 11.17, '2026-06-18 23:55:14.584+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2384, 83.75, '2026-06-18 23:55:14.59+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2385, 19.62, '2026-06-18 23:55:14.595+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2386, 79.37, '2026-06-18 23:55:14.6+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2387, -44.27, '2026-06-18 23:55:19.556+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2388, 45.83, '2026-06-18 23:55:19.57+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2389, 27.87, '2026-06-18 23:55:19.581+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2390, 4.41, '2026-06-18 23:55:19.593+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2391, 218.05, '2026-06-18 23:55:19.599+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2392, 13.98, '2026-06-18 23:55:19.604+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2393, 63.18, '2026-06-18 23:55:19.612+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2394, 22.17, '2026-06-18 23:55:19.617+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2395, 67.6, '2026-06-18 23:55:19.623+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2396, 5.38, '2026-06-18 23:55:24.56+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2397, 32.02, '2026-06-18 23:55:24.569+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2398, 24.25, '2026-06-18 23:55:24.576+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2399, 2.07, '2026-06-18 23:55:24.581+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2400, 219.82, '2026-06-18 23:55:24.587+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2401, 27.03, '2026-06-18 23:55:24.595+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2402, 76.39, '2026-06-18 23:55:24.602+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2403, 20.44, '2026-06-18 23:55:24.61+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2404, 57.51, '2026-06-18 23:55:24.615+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2405, -1.19, '2026-06-18 23:55:29.563+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2406, 30.25, '2026-06-18 23:55:29.568+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2407, 47.93, '2026-06-18 23:55:29.574+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2408, 0.97, '2026-06-18 23:55:29.579+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2409, 228, '2026-06-18 23:55:29.584+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2410, 12.1, '2026-06-18 23:55:29.59+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2411, 17.61, '2026-06-18 23:55:29.594+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2412, 25.55, '2026-06-18 23:55:29.599+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2413, 62.37, '2026-06-18 23:55:29.605+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2414, -2.81, '2026-06-18 23:55:34.568+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2415, 27.45, '2026-06-18 23:55:34.576+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2416, 49.62, '2026-06-18 23:55:34.581+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2417, 3.17, '2026-06-18 23:55:34.587+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2418, 193.37, '2026-06-18 23:55:34.593+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2419, 13.26, '2026-06-18 23:55:34.6+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2420, 83.85, '2026-06-18 23:55:34.608+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2421, 18.65, '2026-06-18 23:55:34.618+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2422, 42.47, '2026-06-18 23:55:34.628+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2423, 10.28, '2026-06-18 23:55:39.573+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2424, 48.35, '2026-06-18 23:55:39.581+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2425, 30.96, '2026-06-18 23:55:39.588+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2426, 4.18, '2026-06-18 23:55:39.595+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2427, 219.88, '2026-06-18 23:55:39.6+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2428, 12.94, '2026-06-18 23:55:39.607+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2429, -9.15, '2026-06-18 23:55:39.613+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2430, 18.84, '2026-06-18 23:55:39.629+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2431, 56.37, '2026-06-18 23:55:39.639+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2432, -18.26, '2026-06-18 23:55:44.578+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2433, 44.02, '2026-06-18 23:55:44.587+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2434, 7.45, '2026-06-18 23:55:44.597+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2435, 2.62, '2026-06-18 23:55:44.615+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2436, 222.13, '2026-06-18 23:55:44.623+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2437, 13.4, '2026-06-18 23:55:44.632+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2438, -14.14, '2026-06-18 23:55:44.638+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2439, 14.95, '2026-06-18 23:55:44.653+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2440, 64.32, '2026-06-18 23:55:44.668+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2441, -11, '2026-06-18 23:55:49.579+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2442, 15.74, '2026-06-18 23:55:49.588+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2443, 63.8, '2026-06-18 23:55:49.598+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2444, 4.12, '2026-06-18 23:55:49.604+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2445, 225.5, '2026-06-18 23:55:49.613+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2446, -2.31, '2026-06-18 23:55:49.621+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2447, 14.47, '2026-06-18 23:55:49.634+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2448, 24.67, '2026-06-18 23:55:49.644+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2449, 64.13, '2026-06-18 23:55:49.652+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2450, 12.5, '2026-06-18 23:55:54.585+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2451, 19.86, '2026-06-18 23:55:54.593+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2452, 30.58, '2026-06-18 23:55:54.606+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2453, 3.85, '2026-06-18 23:55:54.615+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2454, 254.27, '2026-06-18 23:55:54.624+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2455, 13.71, '2026-06-18 23:55:54.64+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2456, 35, '2026-06-18 23:55:54.651+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2457, 22.05, '2026-06-18 23:55:54.665+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2458, 36.03, '2026-06-18 23:55:54.678+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2459, -44.89, '2026-06-18 23:55:59.585+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2460, -4.85, '2026-06-18 23:55:59.602+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2461, 60.01, '2026-06-18 23:55:59.616+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2462, 14.05, '2026-06-18 23:55:59.627+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2463, 226.06, '2026-06-18 23:55:59.636+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2464, 14.12, '2026-06-18 23:55:59.648+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2465, 34.98, '2026-06-18 23:55:59.655+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2466, 22.63, '2026-06-18 23:55:59.664+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2467, 69.77, '2026-06-18 23:55:59.671+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2468, 8.15, '2026-06-18 23:56:04.587+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2469, 24.24, '2026-06-18 23:56:04.594+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2470, 29.12, '2026-06-18 23:56:04.6+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2471, 2.83, '2026-06-18 23:56:04.605+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2472, 250.42, '2026-06-18 23:56:04.61+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2473, -6.18, '2026-06-18 23:56:04.617+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2474, 44.62, '2026-06-18 23:56:04.626+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2475, 1.33, '2026-06-18 23:56:04.634+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2476, 59.13, '2026-06-18 23:56:04.647+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2477, 3.38, '2026-06-18 23:56:09.592+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2478, 20.32, '2026-06-18 23:56:09.6+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2479, 49.45, '2026-06-18 23:56:09.606+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2480, 4.44, '2026-06-18 23:56:09.612+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2481, 221.5, '2026-06-18 23:56:09.618+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2482, 13.67, '2026-06-18 23:56:09.624+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2483, 64.05, '2026-06-18 23:56:09.629+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2484, 18.71, '2026-06-18 23:56:09.636+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2485, 42.39, '2026-06-18 23:56:09.645+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2486, 61.01, '2026-06-18 23:56:14.595+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2487, 34.68, '2026-06-18 23:56:14.611+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2488, 51.96, '2026-06-18 23:56:14.621+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2489, 4.29, '2026-06-18 23:56:14.634+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2490, 235.38, '2026-06-18 23:56:14.646+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2491, 12.51, '2026-06-18 23:56:14.653+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2492, 41.46, '2026-06-18 23:56:14.664+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2493, 22.11, '2026-06-18 23:56:14.671+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2494, 67.68, '2026-06-18 23:56:14.684+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2495, 19.87, '2026-06-18 23:56:19.655+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2496, 5.21, '2026-06-18 23:56:19.69+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2497, 34.53, '2026-06-18 23:56:19.703+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2498, 4.68, '2026-06-18 23:56:19.728+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2499, 254.91, '2026-06-18 23:56:19.739+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2500, 11.38, '2026-06-18 23:56:19.754+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2501, 11.86, '2026-06-18 23:56:19.765+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2502, 19.35, '2026-06-18 23:56:19.774+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2503, 50.6, '2026-06-18 23:56:19.786+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2504, 9.99, '2026-06-18 23:56:24.608+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2505, 43.16, '2026-06-18 23:56:24.621+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2506, 87.02, '2026-06-18 23:56:24.653+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2507, 2.01, '2026-06-18 23:56:24.71+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2508, 225.28, '2026-06-18 23:56:24.737+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2509, 13.76, '2026-06-18 23:56:24.77+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2510, 81.18, '2026-06-18 23:56:24.819+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2511, 18.55, '2026-06-18 23:56:24.861+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2512, 52.04, '2026-06-18 23:56:24.918+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2513, -5.85, '2026-06-18 23:56:29.602+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2514, -12.64, '2026-06-18 23:56:29.61+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2515, 46.08, '2026-06-18 23:56:29.621+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2516, 4.14, '2026-06-18 23:56:29.631+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2517, 233.17, '2026-06-18 23:56:29.636+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2518, 9.61, '2026-06-18 23:56:29.642+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2519, 40.06, '2026-06-18 23:56:29.65+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2520, 40.54, '2026-06-18 23:56:29.657+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2521, 38.92, '2026-06-18 23:56:29.665+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2522, 19.63, '2026-06-18 23:56:34.608+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2523, 7.69, '2026-06-18 23:56:34.616+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2524, 50.75, '2026-06-18 23:56:34.621+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2525, 2.71, '2026-06-18 23:56:34.627+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2526, 225.92, '2026-06-18 23:56:34.632+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2527, 13.03, '2026-06-18 23:56:34.637+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2528, 74.06, '2026-06-18 23:56:34.642+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2529, 24.35, '2026-06-18 23:56:34.647+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2530, 89.22, '2026-06-18 23:56:34.653+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2531, -2.04, '2026-06-18 23:56:39.61+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2532, 18.24, '2026-06-18 23:56:39.617+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2533, 37.43, '2026-06-18 23:56:39.622+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2534, 3.44, '2026-06-18 23:56:39.63+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2535, 221.44, '2026-06-18 23:56:39.635+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2536, 14.07, '2026-06-18 23:56:39.64+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2537, 30.65, '2026-06-18 23:56:39.646+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2538, 24.91, '2026-06-18 23:56:39.652+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2539, 74.2, '2026-06-18 23:56:39.658+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2540, 54.91, '2026-06-18 23:56:44.616+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2541, 12.57, '2026-06-18 23:56:44.63+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2542, 24.01, '2026-06-18 23:56:44.638+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2543, 3.32, '2026-06-18 23:56:44.645+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2544, 230.37, '2026-06-18 23:56:44.652+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2545, 13.17, '2026-06-18 23:56:44.658+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2546, 15.18, '2026-06-18 23:56:44.664+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2547, 21.46, '2026-06-18 23:56:44.67+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2548, 70.73, '2026-06-18 23:56:44.675+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2549, -8.67, '2026-06-18 23:56:49.617+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2550, 24.7, '2026-06-18 23:56:49.624+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2551, 55.47, '2026-06-18 23:56:49.63+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2552, 4.03, '2026-06-18 23:56:49.636+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2553, 214.07, '2026-06-18 23:56:49.644+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2554, -3.14, '2026-06-18 23:56:49.651+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2555, 24.56, '2026-06-18 23:56:49.658+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2556, 24.36, '2026-06-18 23:56:49.668+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2557, 73.33, '2026-06-18 23:56:49.674+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2558, 21.38, '2026-06-18 23:56:54.615+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2559, 8.01, '2026-06-18 23:56:54.621+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2560, 40.83, '2026-06-18 23:56:54.629+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2561, 1.93, '2026-06-18 23:56:54.635+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2562, 214.5, '2026-06-18 23:56:54.641+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2563, 13.14, '2026-06-18 23:56:54.648+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2564, 83.15, '2026-06-18 23:56:54.654+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2565, 22.65, '2026-06-18 23:56:54.661+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2566, 97.79, '2026-06-18 23:56:54.668+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2567, 41.76, '2026-06-18 23:56:59.62+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2568, -2.47, '2026-06-18 23:56:59.631+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2569, 60.23, '2026-06-18 23:56:59.645+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2570, 3.7, '2026-06-18 23:56:59.653+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2571, 214.45, '2026-06-18 23:56:59.662+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2572, 12.29, '2026-06-18 23:56:59.671+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2573, 46.54, '2026-06-18 23:56:59.682+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2574, 20.55, '2026-06-18 23:56:59.689+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2575, 61.76, '2026-06-18 23:56:59.697+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2576, 46.13, '2026-06-18 23:57:04.626+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2577, 2.01, '2026-06-18 23:57:04.647+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2578, 23.09, '2026-06-18 23:57:04.661+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2579, -15.28, '2026-06-18 23:57:04.673+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2580, 218.73, '2026-06-18 23:57:04.688+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2581, 13.79, '2026-06-18 23:57:04.698+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2582, 35.03, '2026-06-18 23:57:04.705+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2583, 23.77, '2026-06-18 23:57:04.715+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2584, 51.19, '2026-06-18 23:57:04.722+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2585, 13.32, '2026-06-18 23:57:09.631+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2586, 6.22, '2026-06-18 23:57:09.64+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2587, 57.89, '2026-06-18 23:57:09.65+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2588, -5.1, '2026-06-18 23:57:09.658+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2589, 174.98, '2026-06-18 23:57:09.672+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2590, 13.8, '2026-06-18 23:57:09.69+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2591, 39.48, '2026-06-18 23:57:09.705+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2592, 20.86, '2026-06-18 23:57:09.722+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2593, 67.47, '2026-06-18 23:57:09.739+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2594, 13.01, '2026-06-18 23:57:14.635+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2595, 9.61, '2026-06-18 23:57:14.644+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2596, 20.97, '2026-06-18 23:57:14.651+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2597, 4.06, '2026-06-18 23:57:14.657+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2598, 235.06, '2026-06-18 23:57:14.663+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2599, 12.45, '2026-06-18 23:57:14.669+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2600, 87.67, '2026-06-18 23:57:14.675+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2601, 3.91, '2026-06-18 23:57:14.682+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2602, 76.25, '2026-06-18 23:57:14.69+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2603, -8.57, '2026-06-18 23:57:19.636+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2604, 23.1, '2026-06-18 23:57:19.643+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2605, 72.96, '2026-06-18 23:57:19.651+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2606, 3.57, '2026-06-18 23:57:19.658+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2607, 216.44, '2026-06-18 23:57:19.665+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2608, 24.67, '2026-06-18 23:57:19.67+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2609, 25.25, '2026-06-18 23:57:19.678+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2610, 25.49, '2026-06-18 23:57:19.687+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2611, 61, '2026-06-18 23:57:19.692+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2612, -33.74, '2026-06-18 23:57:24.639+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2613, 6.21, '2026-06-18 23:57:24.654+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2614, 62.05, '2026-06-18 23:57:24.663+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2615, -7.17, '2026-06-18 23:57:24.669+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2616, 233.15, '2026-06-18 23:57:24.678+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2617, 11.47, '2026-06-18 23:57:24.685+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2618, 0.58, '2026-06-18 23:57:24.691+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2619, 22.65, '2026-06-18 23:57:24.698+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2620, 74.52, '2026-06-18 23:57:24.703+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2621, -2.75, '2026-06-18 23:57:29.644+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2622, -3.03, '2026-06-18 23:57:29.652+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2623, 3.83, '2026-06-18 23:57:29.659+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2624, 3.74, '2026-06-18 23:57:29.675+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2625, 226.55, '2026-06-18 23:57:29.683+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2626, 12.31, '2026-06-18 23:57:29.689+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2627, 30.6, '2026-06-18 23:57:29.695+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2628, 24.68, '2026-06-18 23:57:29.7+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2629, 65.46, '2026-06-18 23:57:29.705+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2630, 23.51, '2026-06-18 23:57:34.649+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2631, 25.91, '2026-06-18 23:57:34.656+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2632, 30.94, '2026-06-18 23:57:34.662+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2633, 3.6, '2026-06-18 23:57:34.668+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2634, 238.03, '2026-06-18 23:57:34.673+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2635, 11.35, '2026-06-18 23:57:34.68+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2636, 87.31, '2026-06-18 23:57:34.685+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2637, 6.34, '2026-06-18 23:57:34.69+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2638, 62.15, '2026-06-18 23:57:34.698+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2639, -44.07, '2026-06-18 23:57:39.653+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2640, 47.8, '2026-06-18 23:57:39.666+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2641, 52.34, '2026-06-18 23:57:39.682+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2642, 2.45, '2026-06-18 23:57:39.691+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2643, 213.66, '2026-06-18 23:57:39.698+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2644, 13.71, '2026-06-18 23:57:39.705+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2645, 66.59, '2026-06-18 23:57:39.712+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2646, 14.58, '2026-06-18 23:57:39.718+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2647, 53.87, '2026-06-18 23:57:39.726+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2648, 8.96, '2026-06-18 23:57:44.658+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2649, 6.44, '2026-06-18 23:57:44.667+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2650, 69.1, '2026-06-18 23:57:44.673+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2651, 3.61, '2026-06-18 23:57:44.684+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2652, 206.08, '2026-06-18 23:57:44.693+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2653, 13.58, '2026-06-18 23:57:44.704+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2654, 9.9, '2026-06-18 23:57:44.711+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2655, 2.53, '2026-06-18 23:57:44.72+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2656, 42.74, '2026-06-18 23:57:44.732+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2657, -9.49, '2026-06-18 23:57:49.661+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2658, 33.17, '2026-06-18 23:57:49.672+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2659, 35.93, '2026-06-18 23:57:49.676+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2660, -2.98, '2026-06-18 23:57:49.682+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2661, 216.13, '2026-06-18 23:57:49.69+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2662, 11.28, '2026-06-18 23:57:49.697+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2663, 109.82, '2026-06-18 23:57:49.703+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2664, 21.27, '2026-06-18 23:57:49.715+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2665, 75.48, '2026-06-18 23:57:49.727+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2666, 17.27, '2026-06-18 23:57:54.662+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2667, 19.21, '2026-06-18 23:57:54.669+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2668, 58.78, '2026-06-18 23:57:54.674+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2669, 3.93, '2026-06-18 23:57:54.68+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2670, 237.75, '2026-06-18 23:57:54.685+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2671, 12.81, '2026-06-18 23:57:54.691+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2672, 79.45, '2026-06-18 23:57:54.697+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2673, 22.22, '2026-06-18 23:57:54.702+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2674, 68.24, '2026-06-18 23:57:54.707+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2675, -5.12, '2026-06-18 23:57:59.667+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2676, 8.88, '2026-06-18 23:57:59.679+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2677, 53.13, '2026-06-18 23:57:59.685+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2678, -0.92, '2026-06-18 23:57:59.694+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2679, 257.52, '2026-06-18 23:57:59.703+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2680, 10.06, '2026-06-18 23:57:59.713+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2681, 0.56, '2026-06-18 23:57:59.725+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2682, 20.69, '2026-06-18 23:57:59.731+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2683, 50.19, '2026-06-18 23:57:59.738+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2684, 25.19, '2026-06-18 23:58:04.671+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2685, 24.71, '2026-06-18 23:58:04.683+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2686, 59, '2026-06-18 23:58:04.691+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2687, 1.85, '2026-06-18 23:58:04.699+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2688, 222.04, '2026-06-18 23:58:04.708+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2689, 13.66, '2026-06-18 23:58:04.714+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2690, 20.66, '2026-06-18 23:58:04.721+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2691, 20.11, '2026-06-18 23:58:04.726+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2692, 60.03, '2026-06-18 23:58:04.731+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2693, 32.62, '2026-06-18 23:58:09.677+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2694, 33.45, '2026-06-18 23:58:09.686+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2695, 58.92, '2026-06-18 23:58:09.694+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2696, 0.66, '2026-06-18 23:58:09.713+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2697, 228.96, '2026-06-18 23:58:09.747+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2698, 19.46, '2026-06-18 23:58:09.767+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2699, 13.65, '2026-06-18 23:58:09.79+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2700, 0.48, '2026-06-18 23:58:09.808+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2701, 66.66, '2026-06-18 23:58:09.831+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2702, -30.31, '2026-06-18 23:58:14.682+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2703, 12.18, '2026-06-18 23:58:14.699+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2704, 22.95, '2026-06-18 23:58:14.709+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2705, 3.04, '2026-06-18 23:58:14.717+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2706, 208.84, '2026-06-18 23:58:14.726+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2707, 14.15, '2026-06-18 23:58:14.737+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2708, -13.36, '2026-06-18 23:58:14.746+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2709, 23.54, '2026-06-18 23:58:14.768+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2710, 64.21, '2026-06-18 23:58:14.78+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2711, -23.33, '2026-06-19 00:31:09.113+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2712, 34.77, '2026-06-19 00:31:09.261+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2713, 33.41, '2026-06-19 00:31:09.287+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2714, 3.13, '2026-06-19 00:31:09.307+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2715, 214.4, '2026-06-19 00:31:09.33+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2716, 13.22, '2026-06-19 00:31:09.354+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2717, 12.9, '2026-06-19 00:31:09.375+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2718, 19.26, '2026-06-19 00:31:09.392+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2719, 64.75, '2026-06-19 00:31:09.412+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2720, 21.74, '2026-06-19 00:31:14.073+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2721, 6.68, '2026-06-19 00:31:14.095+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2722, 48.94, '2026-06-19 00:31:14.12+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2723, 1.11, '2026-06-19 00:31:14.14+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2724, 220.62, '2026-06-19 00:31:14.163+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2725, 12.68, '2026-06-19 00:31:14.184+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2726, 11.15, '2026-06-19 00:31:14.208+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2727, 25.62, '2026-06-19 00:31:14.228+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2728, 45.27, '2026-06-19 00:31:14.247+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2729, 38.35, '2026-06-19 00:31:19.079+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2730, 52.2, '2026-06-19 00:31:19.098+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2731, 46.09, '2026-06-19 00:31:19.112+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2732, 1.75, '2026-06-19 00:31:19.124+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2733, 226.08, '2026-06-19 00:31:19.134+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2734, 13.11, '2026-06-19 00:31:19.143+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2735, -19.58, '2026-06-19 00:31:19.154+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2736, 25.49, '2026-06-19 00:31:19.174+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2737, 54.1, '2026-06-19 00:31:19.186+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2738, 56.5, '2026-06-19 00:31:24.081+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2739, 21.52, '2026-06-19 00:31:24.105+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2740, 34.73, '2026-06-19 00:31:24.118+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2741, -4.35, '2026-06-19 00:31:24.13+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2742, 235.14, '2026-06-19 00:31:24.146+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2743, 11.49, '2026-06-19 00:31:24.16+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2744, 98.24, '2026-06-19 00:31:24.172+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2745, 21.78, '2026-06-19 00:31:24.197+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2746, 65.52, '2026-06-19 00:31:24.211+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2747, 53.68, '2026-06-19 00:31:29.085+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2748, 41.92, '2026-06-19 00:31:29.117+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2749, -6.24, '2026-06-19 00:31:29.144+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2750, 9.35, '2026-06-19 00:31:29.175+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2751, 219.43, '2026-06-19 00:31:29.216+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2752, 13.19, '2026-06-19 00:31:29.232+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2753, 36.53, '2026-06-19 00:31:29.25+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2754, 21.45, '2026-06-19 00:31:29.261+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2755, 67.82, '2026-06-19 00:31:29.275+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2756, 23.2, '2026-06-19 00:31:34.087+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2757, 53, '2026-06-19 00:31:34.108+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2758, 41.4, '2026-06-19 00:31:34.134+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2759, 1.23, '2026-06-19 00:31:34.156+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2760, 213.02, '2026-06-19 00:31:34.174+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2761, 13.97, '2026-06-19 00:31:34.201+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2762, 44.66, '2026-06-19 00:31:34.222+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2763, 24.45, '2026-06-19 00:31:34.239+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2764, 38.52, '2026-06-19 00:31:34.255+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2765, -2.77, '2026-06-19 00:31:39.097+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2766, -2.43, '2026-06-19 00:31:39.123+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2767, 24.96, '2026-06-19 00:31:39.152+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2768, 2.05, '2026-06-19 00:31:39.173+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2769, 273.9, '2026-06-19 00:31:39.198+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2770, 11.61, '2026-06-19 00:31:39.253+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2771, -10.94, '2026-06-19 00:31:39.273+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2772, 20.3, '2026-06-19 00:31:39.335+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2773, 38.28, '2026-06-19 00:31:39.36+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2774, 18.55, '2026-06-19 00:31:44.108+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2775, 10.77, '2026-06-19 00:31:44.129+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2776, 59.67, '2026-06-19 00:31:44.144+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2777, 3.73, '2026-06-19 00:31:44.158+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2778, 211.73, '2026-06-19 00:31:44.172+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2779, 11.47, '2026-06-19 00:31:44.185+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2780, -8.45, '2026-06-19 00:31:44.2+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2781, 20.18, '2026-06-19 00:31:44.228+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2782, 74.87, '2026-06-19 00:31:44.242+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2783, -8.6, '2026-06-19 00:31:49.102+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2784, 21.37, '2026-06-19 00:31:49.113+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2785, 43.44, '2026-06-19 00:31:49.125+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2786, 4.84, '2026-06-19 00:31:49.141+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2787, 237.01, '2026-06-19 00:31:49.154+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2788, 12.16, '2026-06-19 00:31:49.168+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2789, 85.79, '2026-06-19 00:31:49.183+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2790, 21.1, '2026-06-19 00:31:49.2+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2791, 59.81, '2026-06-19 00:31:49.213+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2792, 1, '2026-06-19 00:31:54.109+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2793, 30.1, '2026-06-19 00:31:54.14+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2794, 42.51, '2026-06-19 00:31:54.153+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2795, 15.01, '2026-06-19 00:31:54.167+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2796, 238.73, '2026-06-19 00:31:54.19+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2797, 13.59, '2026-06-19 00:31:54.203+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2798, -3.25, '2026-06-19 00:31:54.216+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2799, 35.97, '2026-06-19 00:31:54.231+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2800, 67.96, '2026-06-19 00:31:54.243+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2801, 10.18, '2026-06-19 00:31:59.113+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2802, 41.78, '2026-06-19 00:31:59.134+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2803, 56.11, '2026-06-19 00:31:59.153+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2804, 3.7, '2026-06-19 00:31:59.166+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2805, 229.76, '2026-06-19 00:31:59.181+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2806, 14.33, '2026-06-19 00:31:59.191+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2807, 71.34, '2026-06-19 00:31:59.199+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2808, 18.11, '2026-06-19 00:31:59.21+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2809, 35.44, '2026-06-19 00:31:59.224+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2810, 24.23, '2026-06-19 00:32:04.112+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2811, 12.71, '2026-06-19 00:32:04.136+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2812, 57.31, '2026-06-19 00:32:04.149+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2813, 8.07, '2026-06-19 00:32:04.162+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2814, 227.92, '2026-06-19 00:32:04.175+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2815, 11.63, '2026-06-19 00:32:04.185+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2816, 61.29, '2026-06-19 00:32:04.196+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2817, 23.66, '2026-06-19 00:32:04.206+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2818, 53.18, '2026-06-19 00:32:04.217+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2819, 0.46, '2026-06-19 00:32:09.114+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2820, 39.44, '2026-06-19 00:32:09.151+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2821, 27.39, '2026-06-19 00:32:09.174+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2822, 8.31, '2026-06-19 00:32:09.187+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2823, 225.55, '2026-06-19 00:32:09.203+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2824, 12.45, '2026-06-19 00:32:09.212+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2825, 110.5, '2026-06-19 00:32:09.222+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2826, 18.22, '2026-06-19 00:32:09.247+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2827, 52.37, '2026-06-19 00:32:09.257+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2828, 17.76, '2026-06-19 00:32:14.117+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2829, 15.31, '2026-06-19 00:32:14.149+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2830, 50.03, '2026-06-19 00:32:14.159+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2831, 3.67, '2026-06-19 00:32:14.171+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2832, 227.47, '2026-06-19 00:32:14.183+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2833, 13.85, '2026-06-19 00:32:14.194+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2834, 108.42, '2026-06-19 00:32:14.207+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2835, 17.48, '2026-06-19 00:32:14.225+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2836, 76.03, '2026-06-19 00:32:14.245+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2837, 9.82, '2026-06-19 00:32:19.124+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2838, 32.62, '2026-06-19 00:32:19.16+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2839, 50.27, '2026-06-19 00:32:19.176+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2840, 2.65, '2026-06-19 00:32:19.193+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2841, 221.3, '2026-06-19 00:32:19.206+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2842, 12.14, '2026-06-19 00:32:19.221+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2843, 59.39, '2026-06-19 00:32:19.234+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2844, 23.21, '2026-06-19 00:32:19.243+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2845, 71.19, '2026-06-19 00:32:19.254+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2846, 3.22, '2026-06-19 00:32:24.13+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2847, 25.19, '2026-06-19 00:32:24.148+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2848, 18.58, '2026-06-19 00:32:24.16+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2849, 2.28, '2026-06-19 00:32:24.177+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2850, 214.6, '2026-06-19 00:32:24.187+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2851, 11.24, '2026-06-19 00:32:24.196+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2852, 1.17, '2026-06-19 00:32:24.207+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2853, 19.53, '2026-06-19 00:32:24.219+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2854, 55.05, '2026-06-19 00:32:24.226+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2855, 7.61, '2026-06-19 00:32:29.136+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2856, 28.94, '2026-06-19 00:32:29.152+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2857, 96.88, '2026-06-19 00:32:29.167+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2858, 0.83, '2026-06-19 00:32:29.192+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2859, 239.79, '2026-06-19 00:32:29.202+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2860, 13.53, '2026-06-19 00:32:29.214+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2861, 27.9, '2026-06-19 00:32:29.225+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2862, 20.83, '2026-06-19 00:32:29.236+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2863, 69.78, '2026-06-19 00:32:29.246+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2864, 5.54, '2026-06-19 00:32:34.136+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2865, 15.55, '2026-06-19 00:32:34.154+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2866, 34.93, '2026-06-19 00:32:34.17+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2867, 23.6, '2026-06-19 00:32:34.182+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2868, 210.22, '2026-06-19 00:32:34.202+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2869, 13.48, '2026-06-19 00:32:34.216+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2870, 69.31, '2026-06-19 00:32:34.234+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2871, 20.18, '2026-06-19 00:32:34.252+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2872, 64.49, '2026-06-19 00:32:34.265+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2873, 11.31, '2026-06-19 00:32:39.138+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2874, 19.79, '2026-06-19 00:32:39.154+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2875, 28.74, '2026-06-19 00:32:39.169+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2876, 4.75, '2026-06-19 00:32:39.188+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2877, 217.39, '2026-06-19 00:32:39.206+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2878, 14.24, '2026-06-19 00:32:39.222+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2879, -14.76, '2026-06-19 00:32:39.239+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2880, 20.5, '2026-06-19 00:32:39.275+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2881, 72.68, '2026-06-19 00:32:39.293+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2882, 5.96, '2026-06-19 00:32:44.143+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2883, 20.06, '2026-06-19 00:32:44.166+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2884, 58.04, '2026-06-19 00:32:44.183+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2885, 1.17, '2026-06-19 00:32:44.199+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2886, 221.2, '2026-06-19 00:32:44.218+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2887, 10.1, '2026-06-19 00:32:44.237+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2888, 0.92, '2026-06-19 00:32:44.262+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2889, 43.33, '2026-06-19 00:32:44.282+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2890, 61.64, '2026-06-19 00:32:44.311+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2891, 17.43, '2026-06-19 00:32:49.148+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2892, -1.77, '2026-06-19 00:32:49.163+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2893, 73.67, '2026-06-19 00:32:49.182+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2894, 3.57, '2026-06-19 00:32:49.202+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2895, 233.53, '2026-06-19 00:32:49.214+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2896, 11.97, '2026-06-19 00:32:49.227+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2897, 79.72, '2026-06-19 00:32:49.239+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2898, 34.04, '2026-06-19 00:32:49.253+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2899, 58.2, '2026-06-19 00:32:49.27+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2900, 2.62, '2026-06-19 00:32:54.151+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2901, 24.42, '2026-06-19 00:32:54.185+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2902, 41.6, '2026-06-19 00:32:54.204+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2903, 4.7, '2026-06-19 00:32:54.227+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2904, 239.7, '2026-06-19 00:32:54.244+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2905, 13.44, '2026-06-19 00:32:54.259+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2906, 9.17, '2026-06-19 00:32:54.275+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2907, 22.28, '2026-06-19 00:32:54.292+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2908, 54.57, '2026-06-19 00:32:54.308+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2909, 6.57, '2026-06-19 00:32:59.158+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2910, 20.01, '2026-06-19 00:32:59.174+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2911, 64.18, '2026-06-19 00:32:59.188+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2912, -19.36, '2026-06-19 00:32:59.206+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2913, 190.02, '2026-06-19 00:32:59.23+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2914, 12.12, '2026-06-19 00:32:59.258+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2915, 47.44, '2026-06-19 00:32:59.277+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2916, 19.95, '2026-06-19 00:32:59.294+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2917, 62.88, '2026-06-19 00:32:59.314+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2918, 12.11, '2026-06-19 10:47:55.715+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2919, 12.9, '2026-06-19 10:47:55.908+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2920, 53.99, '2026-06-19 10:47:55.929+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2921, 2.05, '2026-06-19 10:47:55.95+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2922, 169.02, '2026-06-19 10:47:55.97+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2923, 10.32, '2026-06-19 10:47:56.037+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2924, 35.04, '2026-06-19 10:47:56.058+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2925, 24.49, '2026-06-19 10:47:56.078+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2926, 71.86, '2026-06-19 10:47:56.091+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2927, 13.46, '2026-06-19 10:48:00.641+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2928, 24.31, '2026-06-19 10:48:00.677+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2929, 63.48, '2026-06-19 10:48:00.7+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2930, 2.56, '2026-06-19 10:48:00.72+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2931, 275.4, '2026-06-19 10:48:00.74+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2932, -5.63, '2026-06-19 10:48:00.775+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2933, 42.69, '2026-06-19 10:48:00.812+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2934, 37.52, '2026-06-19 10:48:00.834+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2935, 60.37, '2026-06-19 10:48:00.863+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2936, 8.84, '2026-06-19 10:48:05.641+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2937, 13.23, '2026-06-19 10:48:05.663+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2938, 22.19, '2026-06-19 10:48:05.693+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2939, 2.75, '2026-06-19 10:48:05.723+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2940, 238.45, '2026-06-19 10:48:05.757+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2941, 13.13, '2026-06-19 10:48:05.783+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2942, 84.63, '2026-06-19 10:48:05.8+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2943, 22.89, '2026-06-19 10:48:05.818+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2944, 75.49, '2026-06-19 10:48:05.85+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2945, 20.08, '2026-06-19 10:48:10.644+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2946, 26.97, '2026-06-19 10:48:10.663+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2947, 23.34, '2026-06-19 10:48:10.681+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2948, 2.06, '2026-06-19 10:48:10.697+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2949, 233.23, '2026-06-19 10:48:10.707+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2950, 14.06, '2026-06-19 10:48:10.717+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2951, 23.37, '2026-06-19 10:48:10.727+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2952, 23.53, '2026-06-19 10:48:10.738+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2953, 74.24, '2026-06-19 10:48:10.749+00', 11);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2954, -4.73, '2026-06-19 10:48:15.647+00', 1);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2955, 26.82, '2026-06-19 10:48:15.659+00', 2);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2956, 84.39, '2026-06-19 10:48:15.673+00', 3);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2957, 3.88, '2026-06-19 10:48:15.695+00', 4);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2958, 259.1, '2026-06-19 10:48:15.706+00', 5);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2959, 13.54, '2026-06-19 10:48:15.72+00', 6);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2960, 43.66, '2026-06-19 10:48:15.736+00', 7);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2961, 44.73, '2026-06-19 10:48:15.745+00', 8);
INSERT INTO public.measurement (id, value, "timestamp", "sensorId") VALUES (2962, 32.19, '2026-06-19 10:48:15.758+00', 11);


--
-- Data for Name: sensor; Type: TABLE DATA; Schema: public; Owner: kristina
--

INSERT INTO public.sensor (id, name, location, unit) VALUES (2, 'Senzor Temperature Jug', 'Hala 1 - Jug', '°C');
INSERT INTO public.sensor (id, name, location, unit) VALUES (3, 'Senzor Vlažnosti Vazduha', 'Magacin sirovina', '%');
INSERT INTO public.sensor (id, name, location, unit) VALUES (4, 'Senzor Pritiska Kotla', 'Kotlarnica', 'bar');
INSERT INTO public.sensor (id, name, location, unit) VALUES (5, 'Glavni Napon Napajanja', 'Trafo stanica', 'V');
INSERT INTO public.sensor (id, name, location, unit) VALUES (6, 'Pomoćni Napon Baterije', 'UPS Soba', 'V');
INSERT INTO public.sensor (id, name, location, unit) VALUES (7, 'Nivo Vlažnosti Solarnih Panela', 'Krov objekta', '%');
INSERT INTO public.sensor (id, name, location, unit) VALUES (8, 'Ambijentalna Temperatura', 'Upravna zgrada', '°C');
INSERT INTO public.sensor (id, name, location, unit) VALUES (11, 'Hidraulična Presa H3', 'Skladiste', 'bar');
INSERT INTO public.sensor (id, name, location, unit) VALUES (1, 'Senzor Temperature Sever', 'Hala 1 - Sever', '°C');


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: kristina
--

INSERT INTO public."user" (id, username, password, email, "fullName", "avatarUrl", role) VALUES (1, 'ognjen', '$2a$12$MS4i/.1sgfvfUVo/Yg0pB.BtPf1l6whHwNo2uP1wIj8Tbz3xOgJiu', 'ognjen@iot.rs', 'Ognjen Antić', 'https://cdn-icons-png.flaticon.com/512/149/149071.png', 'OPERATOR');
INSERT INTO public."user" (id, username, password, email, "fullName", "avatarUrl", role) VALUES (2, 'milica', '$2a$12$B9VdJG0rhm3ir8YJq1.xgOhCR/co/3JV65TjvytURGXmuhZ.kMC3W', 'milica@iot.rs', 'Milica Stanković', 'data:image/png;base64,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', 'OPERATOR');
INSERT INTO public."user" (id, username, password, email, "fullName", "avatarUrl", role) VALUES (4, 'marko', '$2b$10$xOFd9.Z1rbNFRqzhQSqBT..9WLQI/Xu/EgfbVSYIeNBRnvSFZooNC', 'marko@iot.rs', 'Marko Mitic', 'https://cdn-icons-png.flaticon.com/512/149/149071.png', 'OPERATOR');
INSERT INTO public."user" (id, username, password, email, "fullName", "avatarUrl", role) VALUES (3, 'kristina', '$2a$12$.IUqhcPqwnGmuUBOXNiA8eu0uajC8qb6EYUd9UJyJpoVQnpgYuJZ2', 'kristina@iot.rs', 'Kristina Kocić', 'https://cdn-icons-png.flaticon.com/512/149/149071.png', 'ADMIN');


--
-- Name: chunk_column_stats_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: kristina
--

SELECT pg_catalog.setval('_timescaledb_catalog.chunk_column_stats_id_seq', 1, false);


--
-- Name: chunk_constraint_name; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: kristina
--

SELECT pg_catalog.setval('_timescaledb_catalog.chunk_constraint_name', 1, false);


--
-- Name: chunk_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: kristina
--

SELECT pg_catalog.setval('_timescaledb_catalog.chunk_id_seq', 1, false);


--
-- Name: continuous_agg_migrate_plan_step_step_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: kristina
--

SELECT pg_catalog.setval('_timescaledb_catalog.continuous_agg_migrate_plan_step_step_id_seq', 1, false);


--
-- Name: dimension_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: kristina
--

SELECT pg_catalog.setval('_timescaledb_catalog.dimension_id_seq', 1, false);


--
-- Name: dimension_slice_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: kristina
--

SELECT pg_catalog.setval('_timescaledb_catalog.dimension_slice_id_seq', 1, false);


--
-- Name: hypertable_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: kristina
--

SELECT pg_catalog.setval('_timescaledb_catalog.hypertable_id_seq', 1, false);


--
-- Name: bgw_job_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_config; Owner: kristina
--

SELECT pg_catalog.setval('_timescaledb_config.bgw_job_id_seq', 1000, false);


--
-- Name: alarm_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kristina
--

SELECT pg_catalog.setval('public.alarm_id_seq', 20, true);


--
-- Name: incident_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kristina
--

SELECT pg_catalog.setval('public.incident_id_seq', 92, true);


--
-- Name: measurement_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kristina
--

SELECT pg_catalog.setval('public.measurement_id_seq', 2971, true);


--
-- Name: sensor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kristina
--

SELECT pg_catalog.setval('public.sensor_id_seq', 11, true);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kristina
--

SELECT pg_catalog.setval('public.user_id_seq', 4, true);


--
-- Name: incident PK_5f90b28b0b8238d89ee8edcf96e; Type: CONSTRAINT; Schema: public; Owner: kristina
--

ALTER TABLE ONLY public.incident
    ADD CONSTRAINT "PK_5f90b28b0b8238d89ee8edcf96e" PRIMARY KEY (id);


--
-- Name: measurement PK_742ff3cc0dcbbd34533a9071dfd; Type: CONSTRAINT; Schema: public; Owner: kristina
--

ALTER TABLE ONLY public.measurement
    ADD CONSTRAINT "PK_742ff3cc0dcbbd34533a9071dfd" PRIMARY KEY (id);


--
-- Name: user PK_cace4a159ff9f2512dd42373760; Type: CONSTRAINT; Schema: public; Owner: kristina
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT "PK_cace4a159ff9f2512dd42373760" PRIMARY KEY (id);


--
-- Name: sensor PK_ccc38b9aa8b3e198b6503d5eee9; Type: CONSTRAINT; Schema: public; Owner: kristina
--

ALTER TABLE ONLY public.sensor
    ADD CONSTRAINT "PK_ccc38b9aa8b3e198b6503d5eee9" PRIMARY KEY (id);


--
-- Name: alarm PK_ea806c911b4b0617f2e306094e7; Type: CONSTRAINT; Schema: public; Owner: kristina
--

ALTER TABLE ONLY public.alarm
    ADD CONSTRAINT "PK_ea806c911b4b0617f2e306094e7" PRIMARY KEY (id);


--
-- Name: user UQ_78a916df40e02a9deb1c4b75edb; Type: CONSTRAINT; Schema: public; Owner: kristina
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT "UQ_78a916df40e02a9deb1c4b75edb" UNIQUE (username);


--
-- Name: user UQ_e12875dfb3b1d92d7d7c5377e22; Type: CONSTRAINT; Schema: public; Owner: kristina
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT "UQ_e12875dfb3b1d92d7d7c5377e22" UNIQUE (email);


--
-- Name: IDX_ef9170e785a489c4b787721cb5; Type: INDEX; Schema: public; Owner: kristina
--

CREATE INDEX "IDX_ef9170e785a489c4b787721cb5" ON public.measurement USING btree ("sensorId", "timestamp");


--
-- Name: measurement FK_15c864ea53c5f14b3db6104268e; Type: FK CONSTRAINT; Schema: public; Owner: kristina
--

ALTER TABLE ONLY public.measurement
    ADD CONSTRAINT "FK_15c864ea53c5f14b3db6104268e" FOREIGN KEY ("sensorId") REFERENCES public.sensor(id) ON DELETE CASCADE;


--
-- Name: alarm FK_34b2481446a175fd5c221198c41; Type: FK CONSTRAINT; Schema: public; Owner: kristina
--

ALTER TABLE ONLY public.alarm
    ADD CONSTRAINT "FK_34b2481446a175fd5c221198c41" FOREIGN KEY ("sensorId") REFERENCES public.sensor(id) ON DELETE CASCADE;


--
-- Name: incident FK_80aceae985068560895a08ef41f; Type: FK CONSTRAINT; Schema: public; Owner: kristina
--

ALTER TABLE ONLY public.incident
    ADD CONSTRAINT "FK_80aceae985068560895a08ef41f" FOREIGN KEY ("sensorId") REFERENCES public.sensor(id);


--
-- Name: incident FK_ab5df665211c9b5319442c946fb; Type: FK CONSTRAINT; Schema: public; Owner: kristina
--

ALTER TABLE ONLY public.incident
    ADD CONSTRAINT "FK_ab5df665211c9b5319442c946fb" FOREIGN KEY ("assignedToId") REFERENCES public."user"(id);


--
-- PostgreSQL database dump complete
--

SET session_replication_role = 'origin';