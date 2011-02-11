--
-- PostgreSQL database dump
--

-- Dumped from database version 9.0.3
-- Dumped by pg_dump version 9.0.3
-- Started on 2011-02-11 15:19:01 CST

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 317 (class 2612 OID 11574)
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO postgres;

SET search_path = public, pg_catalog;

--
-- TOC entry 18 (class 1255 OID 16442)
-- Dependencies: 5
-- Name: cl_id(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cl_id(a character varying) RETURNS bigint
    LANGUAGE sql
    AS $_$SELECT id FROM term WHERE cl = $1$_$;


ALTER FUNCTION public.cl_id(a character varying) OWNER TO postgres;

--
-- TOC entry 20 (class 1255 OID 16457)
-- Dependencies: 5
-- Name: id_cl(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION id_cl(i bigint) RETURNS character varying
    LANGUAGE sql
    AS $_$SELECT cl FROM term WHERE id = $1$_$;


ALTER FUNCTION public.id_cl(i bigint) OWNER TO postgres;

--
-- TOC entry 19 (class 1255 OID 16456)
-- Dependencies: 5 317
-- Name: mark_normal(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mark_normal(t character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
IF NOT EXISTS( SELECT 1 FROM term WHERE cl = t ) THEN
	INSERT INTO term (cl, proved_normal) VALUES (t, 't');
ELSE
	UPDATE term SET proved_normal = 't' WHERE cl = t;
END IF;
END;
$$;


ALTER FUNCTION public.mark_normal(t character varying) OWNER TO postgres;

--
-- TOC entry 22 (class 1255 OID 16451)
-- Dependencies: 317 5
-- Name: memoize(character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION memoize(a character varying, b character varying, n integer) RETURNS void
    LANGUAGE plpgsql
    AS $$DECLARE
x bigint;
y bigint;
forward_d integer;
forward_y bigint;
BEGIN
IF NOT EXISTS( SELECT 1 FROM term WHERE cl = a ) THEN
	INSERT INTO term (cl) VALUES (a);
END IF;
IF NOT EXISTS( SELECT 1 FROM term WHERE cl = b ) THEN
	INSERT INTO term (cl) VALUES (b);
END IF;
x := cl_id(a);
y := cl_id(b);
SELECT INTO forward_y, forward_d reduct, d FROM f WHERE redex = y;
IF FOUND THEN
	y := forward_y;
	n := n + forward_d;
END IF;

IF NOT EXISTS( SELECT 1 FROM f WHERE redex = x AND reduct = y ) THEN
	INSERT INTO f (redex, reduct, d) VALUES (x, y, n);
END IF;
UPDATE f SET reduct = y, d = d + n
	FROM term WHERE reduct = x;
END;$$;


ALTER FUNCTION public.memoize(a character varying, b character varying, n integer) OWNER TO postgres;

--
-- TOC entry 21 (class 1255 OID 16461)
-- Dependencies: 5
-- Name: reset(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION reset() RETURNS void
    LANGUAGE sql
    AS $$delete from f;
delete from term;
insert into term (cl, proved_normal) values
	('s', 't'), ('k', 't'), ('i', 't');$$;


ALTER FUNCTION public.reset() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 1512 (class 1259 OID 16421)
-- Dependencies: 1792 5
-- Name: f; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE f (
    redex bigint NOT NULL,
    reduct bigint NOT NULL,
    d integer NOT NULL,
    CONSTRAINT positive_d CHECK ((d > 0))
);


ALTER TABLE public.f OWNER TO postgres;

--
-- TOC entry 1510 (class 1259 OID 16396)
-- Dependencies: 5
-- Name: sq_term; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sq_term
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sq_term OWNER TO postgres;

--
-- TOC entry 1812 (class 0 OID 0)
-- Dependencies: 1510
-- Name: sq_term; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('sq_term', 1, false);


--
-- TOC entry 1509 (class 1259 OID 16393)
-- Dependencies: 1791 5
-- Name: term; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE term (
    id bigint NOT NULL,
    cl text NOT NULL,
    proved_normal boolean DEFAULT false
);


ALTER TABLE public.term OWNER TO postgres;

--
-- TOC entry 1511 (class 1259 OID 16398)
-- Dependencies: 5 1509
-- Name: term_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE term_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.term_id_seq OWNER TO postgres;

--
-- TOC entry 1813 (class 0 OID 0)
-- Dependencies: 1511
-- Name: term_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE term_id_seq OWNED BY term.id;


--
-- TOC entry 1814 (class 0 OID 0)
-- Dependencies: 1511
-- Name: term_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('term_id_seq', 6656, true);


--
-- TOC entry 1790 (class 2604 OID 16400)
-- Dependencies: 1511 1509
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE term ALTER COLUMN id SET DEFAULT nextval('term_id_seq'::regclass);


--
-- TOC entry 1806 (class 0 OID 16421)
-- Dependencies: 1512
-- Data for Name: f; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY f (redex, reduct, d) FROM stdin;
\.


--
-- TOC entry 1805 (class 0 OID 16393)
-- Dependencies: 1509
-- Data for Name: term; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY term (id, cl, proved_normal) FROM stdin;
6654	s	t
6655	k	t
6656	i	t
\.


--
-- TOC entry 1802 (class 2606 OID 16455)
-- Dependencies: 1512 1512 1512
-- Name: pkey_f; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY f
    ADD CONSTRAINT pkey_f PRIMARY KEY (redex, reduct);


--
-- TOC entry 1796 (class 2606 OID 16405)
-- Dependencies: 1509 1509
-- Name: pkey_term_id; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY term
    ADD CONSTRAINT pkey_term_id PRIMARY KEY (id);


--
-- TOC entry 1798 (class 2606 OID 16410)
-- Dependencies: 1509 1509
-- Name: unique_term_cl; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY term
    ADD CONSTRAINT unique_term_cl UNIQUE (cl);


--
-- TOC entry 1799 (class 1259 OID 16429)
-- Dependencies: 1512
-- Name: fki_redex; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fki_redex ON f USING btree (redex);


--
-- TOC entry 1800 (class 1259 OID 16435)
-- Dependencies: 1512
-- Name: fki_reduct; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fki_reduct ON f USING btree (reduct);


--
-- TOC entry 1793 (class 1259 OID 16437)
-- Dependencies: 1509
-- Name: id_term_cl; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX id_term_cl ON term USING btree (cl);


--
-- TOC entry 1794 (class 1259 OID 16420)
-- Dependencies: 1509
-- Name: idx_term_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX idx_term_id ON term USING btree (id);


--
-- TOC entry 1803 (class 2606 OID 16424)
-- Dependencies: 1795 1512 1509
-- Name: redex; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY f
    ADD CONSTRAINT redex FOREIGN KEY (redex) REFERENCES term(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 1804 (class 2606 OID 16430)
-- Dependencies: 1509 1512 1795
-- Name: reduct; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY f
    ADD CONSTRAINT reduct FOREIGN KEY (reduct) REFERENCES term(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 1811 (class 0 OID 0)
-- Dependencies: 5
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2011-02-11 15:19:01 CST

--
-- PostgreSQL database dump complete
--

