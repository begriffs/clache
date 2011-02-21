--
-- PostgreSQL database dump
--

-- Dumped from database version 9.0.3
-- Dumped by pg_dump version 9.0.3
-- Started on 2011-02-21 16:57:17 CST

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 314 (class 2612 OID 11574)
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO postgres;

SET search_path = public, pg_catalog;

--
-- TOC entry 20 (class 1255 OID 25386)
-- Dependencies: 314 6
-- Name: mark_normal(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mark_normal(t character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
IF NOT EXISTS( SELECT 1 FROM term WHERE cl = t ) THEN
	INSERT INTO term (cl, normal) VALUES (t, 't');
ELSE
	UPDATE term SET normal = 't' WHERE cl = t;
END IF;
END;
$$;


ALTER FUNCTION public.mark_normal(t character varying) OWNER TO postgres;

--
-- TOC entry 18 (class 1255 OID 25469)
-- Dependencies: 314 6
-- Name: memoize(character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION memoize(x character varying, y character varying, n integer) RETURNS void
    LANGUAGE plpgsql
    AS $$DECLARE
m bigint;
z character varying;
BEGIN
IF NOT EXISTS( SELECT 1 FROM term WHERE cl = x ) THEN
	INSERT INTO term (cl) VALUES (x);
END IF;
IF NOT EXISTS( SELECT 1 FROM term WHERE cl = y ) THEN
	INSERT INTO term (cl) VALUES (y);
END IF;

SELECT INTO z, m b, d FROM f WHERE f.a = y;
IF FOUND THEN
	y := z;
	n := n + m;
END IF;

IF NOT EXISTS( SELECT 1 FROM f WHERE f.a = x AND f.b = y ) THEN
	INSERT INTO f (a, b, d) VALUES (x, y, n);
END IF;
UPDATE f SET b = y, d = d + n WHERE f.b = x;
END;$$;


ALTER FUNCTION public.memoize(x character varying, y character varying, n integer) OWNER TO postgres;

--
-- TOC entry 19 (class 1255 OID 25388)
-- Dependencies: 6
-- Name: reset(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION reset() RETURNS void
    LANGUAGE sql
    AS $$
delete from f;
delete from term;
insert into term (cl, normal) values
	('s', 't'), ('k', 't'), ('i', 't');
$$;


ALTER FUNCTION public.reset() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 1507 (class 1259 OID 25441)
-- Dependencies: 6
-- Name: f; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE f (
    a text NOT NULL,
    b text NOT NULL,
    d bigint NOT NULL
);


ALTER TABLE public.f OWNER TO postgres;

--
-- TOC entry 1506 (class 1259 OID 25431)
-- Dependencies: 1785 6
-- Name: term; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE term (
    cl text NOT NULL,
    normal boolean DEFAULT false NOT NULL
);


ALTER TABLE public.term OWNER TO postgres;

--
-- TOC entry 1796 (class 0 OID 25441)
-- Dependencies: 1507
-- Data for Name: f; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY f (a, b, d) FROM stdin;
\.


--
-- TOC entry 1795 (class 0 OID 25431)
-- Dependencies: 1506
-- Data for Name: term; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY term (cl, normal) FROM stdin;
s	t
k	t
i	t
\.


--
-- TOC entry 1792 (class 2606 OID 25448)
-- Dependencies: 1507 1507 1507
-- Name: pkey_f; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY f
    ADD CONSTRAINT pkey_f PRIMARY KEY (a, b);


--
-- TOC entry 1788 (class 2606 OID 25450)
-- Dependencies: 1506 1506
-- Name: pkey_term; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY term
    ADD CONSTRAINT pkey_term PRIMARY KEY (cl);


--
-- TOC entry 1789 (class 1259 OID 25451)
-- Dependencies: 1507
-- Name: idx_f_a; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX idx_f_a ON f USING btree (a);


--
-- TOC entry 1790 (class 1259 OID 25452)
-- Dependencies: 1507
-- Name: idx_f_b; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX idx_f_b ON f USING btree (b);


--
-- TOC entry 1786 (class 1259 OID 25440)
-- Dependencies: 1506
-- Name: idx_term_cl; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX idx_term_cl ON term USING btree (cl);


--
-- TOC entry 1793 (class 2606 OID 25453)
-- Dependencies: 1787 1506 1507
-- Name: fkey_f_a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY f
    ADD CONSTRAINT fkey_f_a FOREIGN KEY (a) REFERENCES term(cl) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 1794 (class 2606 OID 25463)
-- Dependencies: 1787 1507 1506
-- Name: fkey_f_b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY f
    ADD CONSTRAINT fkey_f_b FOREIGN KEY (b) REFERENCES term(cl) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 1801 (class 0 OID 0)
-- Dependencies: 6
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2011-02-21 16:57:17 CST

--
-- PostgreSQL database dump complete
--

