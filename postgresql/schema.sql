--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE fox;
ALTER ROLE fox WITH SUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:mE2ugwf2iGNC5sP1ZlFEzA==$8bNOG7uFLuqXyxRDY+NLzZhz7kp1nZrLQq4qqWq430Y=:psXonrXKJ0wMeu7QBoEeI3/XQU7/8ouD3iS+lHzF6VQ=';
-- CREATE ROLE gate_io;
-- ALTER ROLE gate_io WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:tFgXG3lcrGqVuxiqFTKoCw==$ViZe4hIlVt9nke5X4fG0QsjeY6Hz4ZGv/R4+rKdHYd4=:kr4HYg1+J/ePUrVQ0ygMSB+2ohtjnvXdkGo+vyF2BFg=';
-- CREATE ROLE postgres;
-- ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS;
-- CREATE ROLE test;
-- ALTER ROLE test WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS CONNECTION LIMIT 3 PASSWORD 'SCRAM-SHA-256$4096:QZ7YJzvcOprFlvb/+0lddA==$Y4g+f245tOuBNel20AayXnCJMIX+6XuVdFMEHASZ4LM=:yNgAbPYZzIGp1OnC9l0u3enrzYGkNH7KDgnD5oDMXMo=';






--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

--
-- PostgreSQL database dump
--

-- Dumped from database version 14.10 (Ubuntu 14.10-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.10 (Ubuntu 14.10-0ubuntu0.22.04.1)

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
-- PostgreSQL database dump complete
--

--
-- Database "gate_io" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 14.10 (Ubuntu 14.10-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.10 (Ubuntu 14.10-0ubuntu0.22.04.1)

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
-- Name: gate_io; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE gate_io WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'C.UTF-8';


ALTER DATABASE gate_io OWNER TO postgres;

\connect gate_io

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
-- Name: dev; Type: SCHEMA; Schema: -; Owner: fox
--

CREATE SCHEMA dev;


ALTER SCHEMA dev OWNER TO fox;

--
-- Name: prod; Type: SCHEMA; Schema: -; Owner: fox
--

CREATE SCHEMA prod;


ALTER SCHEMA prod OWNER TO fox;

--
-- Name: test; Type: SCHEMA; Schema: -; Owner: fox
--

CREATE SCHEMA test;


ALTER SCHEMA test OWNER TO fox;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: all_pamp_stocks; Type: TABLE; Schema: prod; Owner: fox
--

CREATE TABLE prod.all_pamp_stocks (
    id integer NOT NULL,
    currency_pair text,
    last text,
    lowest_ask text,
    highest_bid text,
    change_percentage text,
    change_utc0 text,
    change_utc8 text,
    base_volume text,
    quote_volume text,
    high_24h text,
    low_24h text,
    etf_net_value text,
    etf_pre_net_value text,
    etf_pre_timestamp bigint,
    etf_leverage text,
    algorithm_id smallint NOT NULL,
    bot_name text NOT NULL,
    user_id bigint NOT NULL,
    unix_time integer
);


ALTER TABLE prod.all_pamp_stocks OWNER TO fox;

--
-- Name: all_pamp_stocks_id_seq; Type: SEQUENCE; Schema: prod; Owner: fox
--

CREATE SEQUENCE prod.all_pamp_stocks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE prod.all_pamp_stocks_id_seq OWNER TO fox;

--
-- Name: all_pamp_stocks_id_seq; Type: SEQUENCE OWNED BY; Schema: prod; Owner: fox
--

ALTER SEQUENCE prod.all_pamp_stocks_id_seq OWNED BY prod.all_pamp_stocks.id;


--
-- Name: arithmetic_mean; Type: TABLE; Schema: prod; Owner: fox
--

CREATE TABLE prod.arithmetic_mean (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    seconds real NOT NULL,
    times bigint NOT NULL,
    unix_time integer NOT NULL,
    bot_name text,
    algorithm_id integer
);


ALTER TABLE prod.arithmetic_mean OWNER TO fox;

--
-- Name: arithmetic_mean_id_seq; Type: SEQUENCE; Schema: prod; Owner: fox
--

CREATE SEQUENCE prod.arithmetic_mean_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE prod.arithmetic_mean_id_seq OWNER TO fox;

--
-- Name: arithmetic_mean_id_seq; Type: SEQUENCE OWNED BY; Schema: prod; Owner: fox
--

ALTER SEQUENCE prod.arithmetic_mean_id_seq OWNED BY prod.arithmetic_mean.id;


--
-- Name: bots; Type: TABLE; Schema: prod; Owner: fox
--

CREATE TABLE prod.bots (
    id smallint NOT NULL,
    name text NOT NULL
);


ALTER TABLE prod.bots OWNER TO fox;

--
-- Name: bots_id_seq; Type: SEQUENCE; Schema: prod; Owner: fox
--

CREATE SEQUENCE prod.bots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE prod.bots_id_seq OWNER TO fox;

--
-- Name: bots_id_seq; Type: SEQUENCE OWNED BY; Schema: prod; Owner: fox
--

ALTER SEQUENCE prod.bots_id_seq OWNED BY prod.bots.id;


--
-- Name: note; Type: TABLE; Schema: prod; Owner: fox
--

CREATE TABLE prod.note (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    text text,
    currency text NOT NULL,
    unix_time integer
);


ALTER TABLE prod.note OWNER TO fox;

--
-- Name: note_id_seq; Type: SEQUENCE; Schema: prod; Owner: fox
--

CREATE SEQUENCE prod.note_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE prod.note_id_seq OWNER TO fox;

--
-- Name: note_id_seq; Type: SEQUENCE OWNED BY; Schema: prod; Owner: fox
--

ALTER SEQUENCE prod.note_id_seq OWNED BY prod.note.id;


--
-- Name: token; Type: TABLE; Schema: prod; Owner: gate_io
--

CREATE TABLE prod.token (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    token text,
    unix_time integer
);


ALTER TABLE prod.token OWNER TO gate_io;

--
-- Name: token_id_seq; Type: SEQUENCE; Schema: prod; Owner: gate_io
--

CREATE SEQUENCE prod.token_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE prod.token_id_seq OWNER TO gate_io;

--
-- Name: token_id_seq; Type: SEQUENCE OWNED BY; Schema: prod; Owner: gate_io
--

ALTER SEQUENCE prod.token_id_seq OWNED BY prod.token.id;


--
-- Name: user; Type: TABLE; Schema: prod; Owner: fox
--

CREATE TABLE prod."user" (
    id integer NOT NULL,
    t_user_id bigint NOT NULL,
    t_chat_id bigint,
    t_first_name text,
    t_last_name text,
    t_username text,
    t_is_bot boolean,
    t_language_code character varying(4),
    unix_time integer
);


ALTER TABLE prod."user" OWNER TO fox;

--
-- Name: user_id_seq; Type: SEQUENCE; Schema: prod; Owner: fox
--

CREATE SEQUENCE prod.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE prod.user_id_seq OWNER TO fox;

--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: prod; Owner: fox
--

ALTER SEQUENCE prod.user_id_seq OWNED BY prod."user".id;


--
-- Name: all_pamp_stocks id; Type: DEFAULT; Schema: prod; Owner: fox
--

ALTER TABLE ONLY prod.all_pamp_stocks ALTER COLUMN id SET DEFAULT nextval('prod.all_pamp_stocks_id_seq'::regclass);


--
-- Name: arithmetic_mean id; Type: DEFAULT; Schema: prod; Owner: fox
--

ALTER TABLE ONLY prod.arithmetic_mean ALTER COLUMN id SET DEFAULT nextval('prod.arithmetic_mean_id_seq'::regclass);


--
-- Name: bots id; Type: DEFAULT; Schema: prod; Owner: fox
--

ALTER TABLE ONLY prod.bots ALTER COLUMN id SET DEFAULT nextval('prod.bots_id_seq'::regclass);


--
-- Name: note id; Type: DEFAULT; Schema: prod; Owner: fox
--

ALTER TABLE ONLY prod.note ALTER COLUMN id SET DEFAULT nextval('prod.note_id_seq'::regclass);


--
-- Name: token id; Type: DEFAULT; Schema: prod; Owner: gate_io
--

ALTER TABLE ONLY prod.token ALTER COLUMN id SET DEFAULT nextval('prod.token_id_seq'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: prod; Owner: fox
--

ALTER TABLE ONLY prod."user" ALTER COLUMN id SET DEFAULT nextval('prod.user_id_seq'::regclass);


--
-- Name: all_pamp_stocks all_pamp_stocks_pkey; Type: CONSTRAINT; Schema: prod; Owner: fox
--

ALTER TABLE ONLY prod.all_pamp_stocks
    ADD CONSTRAINT all_pamp_stocks_pkey PRIMARY KEY (id);


--
-- Name: arithmetic_mean arithmetic_mean_pkey; Type: CONSTRAINT; Schema: prod; Owner: fox
--

ALTER TABLE ONLY prod.arithmetic_mean
    ADD CONSTRAINT arithmetic_mean_pkey PRIMARY KEY (id);


--
-- Name: bots bot_name_unique; Type: CONSTRAINT; Schema: prod; Owner: fox
--

ALTER TABLE ONLY prod.bots
    ADD CONSTRAINT bot_name_unique UNIQUE (name) INCLUDE (name);


--
-- Name: bots bots_pkey; Type: CONSTRAINT; Schema: prod; Owner: fox
--

ALTER TABLE ONLY prod.bots
    ADD CONSTRAINT bots_pkey PRIMARY KEY (name) INCLUDE (name);


--
-- Name: note note_pkey; Type: CONSTRAINT; Schema: prod; Owner: fox
--

ALTER TABLE ONLY prod.note
    ADD CONSTRAINT note_pkey PRIMARY KEY (id);


--
-- Name: user t_user_id_unique; Type: CONSTRAINT; Schema: prod; Owner: fox
--

ALTER TABLE ONLY prod."user"
    ADD CONSTRAINT t_user_id_unique UNIQUE (t_user_id);


--
-- Name: token token_pkey; Type: CONSTRAINT; Schema: prod; Owner: gate_io
--

ALTER TABLE ONLY prod.token
    ADD CONSTRAINT token_pkey PRIMARY KEY (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: prod; Owner: fox
--

ALTER TABLE ONLY prod."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: arithmetic_mean arithmetic_mean_bot_name_fkey; Type: FK CONSTRAINT; Schema: prod; Owner: fox
--

ALTER TABLE ONLY prod.arithmetic_mean
    ADD CONSTRAINT arithmetic_mean_bot_name_fkey FOREIGN KEY (bot_name) REFERENCES prod.bots(name) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- Name: DATABASE gate_io; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON DATABASE gate_io TO gate_io WITH GRANT OPTION;


--
-- Name: SCHEMA dev; Type: ACL; Schema: -; Owner: fox
--

GRANT ALL ON SCHEMA dev TO gate_io WITH GRANT OPTION;


--
-- Name: SCHEMA prod; Type: ACL; Schema: -; Owner: fox
--

GRANT ALL ON SCHEMA prod TO gate_io WITH GRANT OPTION;


--
-- Name: SCHEMA test; Type: ACL; Schema: -; Owner: fox
--

GRANT ALL ON SCHEMA test TO test WITH GRANT OPTION;


--
-- Name: TABLE all_pamp_stocks; Type: ACL; Schema: prod; Owner: fox
--

GRANT ALL ON TABLE prod.all_pamp_stocks TO gate_io;


--
-- Name: SEQUENCE all_pamp_stocks_id_seq; Type: ACL; Schema: prod; Owner: fox
--

GRANT ALL ON SEQUENCE prod.all_pamp_stocks_id_seq TO gate_io;


--
-- Name: TABLE arithmetic_mean; Type: ACL; Schema: prod; Owner: fox
--

GRANT ALL ON TABLE prod.arithmetic_mean TO gate_io;


--
-- Name: SEQUENCE arithmetic_mean_id_seq; Type: ACL; Schema: prod; Owner: fox
--

GRANT ALL ON SEQUENCE prod.arithmetic_mean_id_seq TO gate_io;


--
-- Name: TABLE bots; Type: ACL; Schema: prod; Owner: fox
--

GRANT ALL ON TABLE prod.bots TO gate_io;


--
-- Name: SEQUENCE bots_id_seq; Type: ACL; Schema: prod; Owner: fox
--

GRANT ALL ON SEQUENCE prod.bots_id_seq TO gate_io;


--
-- Name: TABLE note; Type: ACL; Schema: prod; Owner: fox
--

GRANT ALL ON TABLE prod.note TO gate_io;


--
-- Name: SEQUENCE note_id_seq; Type: ACL; Schema: prod; Owner: fox
--

GRANT ALL ON SEQUENCE prod.note_id_seq TO gate_io;


--
-- Name: TABLE "user"; Type: ACL; Schema: prod; Owner: fox
--

GRANT ALL ON TABLE prod."user" TO gate_io;


--
-- Name: SEQUENCE user_id_seq; Type: ACL; Schema: prod; Owner: fox
--

GRANT ALL ON SEQUENCE prod.user_id_seq TO gate_io;


--
-- PostgreSQL database dump complete
--

--
-- Database "postgres" dump
--

\connect postgres

--
-- PostgreSQL database dump
--

-- Dumped from database version 14.10 (Ubuntu 14.10-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.10 (Ubuntu 14.10-0ubuntu0.22.04.1)

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
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

