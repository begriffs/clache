--
-- PostgreSQL database dump
--

-- Dumped from database version 9.0.3
-- Dumped by pg_dump version 9.0.3
-- Started on 2011-03-12 10:59:19 CST

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 315 (class 2612 OID 11574)
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO postgres;

SET search_path = public, pg_catalog;

--
-- TOC entry 18 (class 1255 OID 16428)
-- Dependencies: 6 315
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
-- TOC entry 19 (class 1255 OID 16429)
-- Dependencies: 6 315
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
-- TOC entry 20 (class 1255 OID 16430)
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

--
-- TOC entry 21 (class 1255 OID 16431)
-- Dependencies: 315 6
-- Name: shortest(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION shortest(t character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
winner character varying;
BEGIN
select into winner a from (
	select f2.a as a
	from f as f1, f as f2
	where f1.a = t and f1.b = f2.b
	UNION
	select t as a
	UNION
	select b as a from f where f.a = t
	UNION
	select a from f where b = t
) as others
order by length(a)
limit 1;
return winner;
END;
$$;


ALTER FUNCTION public.shortest(t character varying) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 1507 (class 1259 OID 16432)
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
-- TOC entry 1508 (class 1259 OID 16438)
-- Dependencies: 1786 6
-- Name: term; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE term (
    cl text NOT NULL,
    normal boolean DEFAULT false NOT NULL
);


ALTER TABLE public.term OWNER TO postgres;

--
-- TOC entry 1793 (class 0 OID 16432)
-- Dependencies: 1507
-- Data for Name: f; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY f (a, b, d) FROM stdin;
\.


--
-- TOC entry 1794 (class 0 OID 16438)
-- Dependencies: 1508
-- Data for Name: term; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY term (cl, normal) FROM stdin;
s	t
k	t
i	t
\.


--
-- TOC entry 1787 (class 1259 OID 34021)
-- Dependencies: 1507
-- Name: idx_f_a; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX idx_f_a ON f USING hash (a);


--
-- TOC entry 1788 (class 1259 OID 34022)
-- Dependencies: 1507
-- Name: idx_f_b; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX idx_f_b ON f USING hash (b);


--
-- TOC entry 1789 (class 1259 OID 34020)
-- Dependencies: 1507 1507 1507
-- Name: idx_f_unique; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX idx_f_unique ON f USING btree (md5(a), md5(b));


--
-- TOC entry 1790 (class 1259 OID 16451)
-- Dependencies: 1507 1507
-- Name: idx_shortest; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX idx_shortest ON f USING btree (length(a));

ALTER TABLE f CLUSTER ON idx_shortest;


--
-- TOC entry 1791 (class 1259 OID 34023)
-- Dependencies: 1508
-- Name: idx_term_cl; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX idx_term_cl ON term USING hash (cl);


--
-- TOC entry 1792 (class 1259 OID 34024)
-- Dependencies: 1508 1508
-- Name: idx_term_unique; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX idx_term_unique ON term USING btree (md5(cl));


--
-- TOC entry 1799 (class 0 OID 0)
-- Dependencies: 6
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2011-03-12 10:59:20 CST

--
-- PostgreSQL database dump complete
--

