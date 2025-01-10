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
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: driving_route_sites_ordering; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.driving_route_sites_ordering AS ENUM (
    'order_by_distance',
    'custom_order'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."__EFMigrationsHistory" (
    migration_id character varying(150) NOT NULL,
    product_version character varying(32) NOT NULL
);


--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    service_name character varying NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activities (
    id bigint NOT NULL,
    company_id bigint,
    name character varying DEFAULT ''::character varying NOT NULL,
    has_value boolean DEFAULT true NOT NULL,
    value_label character varying
);


--
-- Name: activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.activities_id_seq OWNED BY public.activities.id;


--
-- Name: activities_sites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activities_sites (
    site_id bigint NOT NULL,
    activity_id bigint NOT NULL
);


--
-- Name: activity_executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activity_executions (
    id bigint NOT NULL,
    activity_id bigint,
    drive_id bigint,
    value numeric,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: activity_executions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.activity_executions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activity_executions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.activity_executions_id_seq OWNED BY public.activity_executions.id;


--
-- Name: administrators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.administrators (
    id bigint NOT NULL,
    email character varying,
    password_digest character varying,
    first_name character varying,
    last_name character varying,
    remember_token character varying,
    remember_token_expires_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: administrators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.administrators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: administrators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.administrators_id_seq OWNED BY public.administrators.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: audits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audits (
    id bigint NOT NULL,
    auditable_id integer,
    auditable_type character varying,
    associated_id integer,
    associated_type character varying,
    user_id integer,
    user_type character varying,
    username character varying,
    action character varying,
    audited_changes json,
    version integer DEFAULT 0,
    comment character varying,
    remote_address character varying,
    request_uuid character varying,
    created_at timestamp without time zone
);


--
-- Name: audits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audits_id_seq OWNED BY public.audits.id;


--
-- Name: companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.companies (
    id bigint NOT NULL,
    name character varying NOT NULL,
    options json DEFAULT '{}'::json NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    contact_email character varying NOT NULL,
    address character varying DEFAULT ''::character varying NOT NULL,
    zip_code character varying DEFAULT ''::character varying NOT NULL,
    city character varying DEFAULT ''::character varying NOT NULL,
    slug character varying,
    nr character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: drivers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drivers (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    company_id integer,
    discarded_at timestamp without time zone
);


--
-- Name: drives; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drives (
    id bigint NOT NULL,
    start timestamp without time zone NOT NULL,
    "end" timestamp without time zone NOT NULL,
    distance_km double precision DEFAULT 0.0 NOT NULL,
    salt_refilled boolean DEFAULT false NOT NULL,
    salt_amount_tonns double precision DEFAULT 0.0 NOT NULL,
    salted boolean DEFAULT false NOT NULL,
    plowed boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    driver_id integer NOT NULL,
    customer_id bigint,
    site_id bigint,
    discarded_at timestamp without time zone,
    tour_id uuid,
    vehicle_id bigint,
    app_drive_id integer,
    first_sync_at timestamp without time zone,
    last_sync_at timestamp without time zone
);


--
-- Name: tours; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tours (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone,
    driver_id bigint NOT NULL,
    discarded_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    vehicle_id bigint,
    first_sync_at timestamp without time zone,
    last_sync_at timestamp without time zone
);


--
-- Name: billing_daily_usage_reports; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.billing_daily_usage_reports AS
 SELECT date_trunc('day'::text, tours_report.start_time) AS date_trunc,
    tours_report.name,
    sum(tours_report.number_of_drives) AS nr_of_drives,
    count(*) AS nr_of_tours,
    tours_report.company_id
   FROM ( SELECT c.name,
            t2.start_time,
            count(DISTINCT d.site_id) AS number_of_drives,
            c.id AS company_id
           FROM (((public.drives d
             JOIN public.drivers dr ON ((dr.id = d.driver_id)))
             JOIN public.companies c ON ((dr.company_id = c.id)))
             JOIN public.tours t2 ON (((d.tour_id = t2.id) AND (t2.discarded_at IS NULL))))
          WHERE (d.discarded_at IS NULL)
          GROUP BY c.name, c.id, t2.start_time, t2.id
          ORDER BY c.name, t2.start_time) tours_report
  GROUP BY tours_report.name, tours_report.company_id, (date_trunc('day'::text, tours_report.start_time));


--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.companies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.companies_id_seq OWNED BY public.companies.id;


--
-- Name: company_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.company_members (
    id bigint NOT NULL,
    user_id bigint,
    company_id bigint,
    role character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: company_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.company_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: company_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.company_members_id_seq OWNED BY public.company_members.id;


--
-- Name: company_report_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.company_report_assignments (
    id uuid NOT NULL,
    report_template_id uuid NOT NULL,
    company_id text NOT NULL
);


--
-- Name: customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customers (
    id bigint NOT NULL,
    name character varying NOT NULL,
    company_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    street character varying DEFAULT ''::character varying NOT NULL,
    nr character varying DEFAULT ''::character varying NOT NULL,
    zip character varying DEFAULT ''::character varying NOT NULL,
    city character varying DEFAULT ''::character varying NOT NULL,
    first_name character varying DEFAULT ''::character varying NOT NULL,
    company_name character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customers_id_seq OWNED BY public.customers.id;


--
-- Name: driver_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.driver_applications (
    id bigint NOT NULL,
    user_id bigint,
    recipient character varying NOT NULL,
    token character varying NOT NULL,
    accepted_by_id bigint,
    accepted_to_id bigint,
    accepted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: driver_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.driver_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: driver_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.driver_applications_id_seq OWNED BY public.driver_applications.id;


--
-- Name: driver_logins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.driver_logins (
    id bigint NOT NULL,
    driver_id bigint,
    user_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: driver_logins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.driver_logins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: driver_logins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.driver_logins_id_seq OWNED BY public.driver_logins.id;


--
-- Name: drivers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drivers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drivers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drivers_id_seq OWNED BY public.drivers.id;


--
-- Name: drives_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drives_id_seq OWNED BY public.drives.id;


--
-- Name: pricing_flat_rates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pricing_flat_rates (
    id bigint NOT NULL,
    flat_ratable_type character varying,
    flat_ratable_id bigint,
    price_cents integer DEFAULT 0 NOT NULL,
    price_currency character varying NOT NULL,
    valid_from date NOT NULL,
    rate_type character varying DEFAULT 'custom'::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    active boolean DEFAULT false
);


--
-- Name: pricing_hourly_rates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pricing_hourly_rates (
    id bigint NOT NULL,
    hourly_ratable_type character varying,
    hourly_ratable_id bigint,
    price_cents integer DEFAULT 0 NOT NULL,
    price_currency character varying NOT NULL,
    valid_from date NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: site_activity_flat_rates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_activity_flat_rates (
    id bigint NOT NULL,
    site_id bigint,
    activity_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sites (
    id bigint NOT NULL,
    name character varying,
    street character varying DEFAULT ''::character varying NOT NULL,
    nr character varying DEFAULT ''::character varying NOT NULL,
    zip character varying DEFAULT ''::character varying NOT NULL,
    city character varying DEFAULT ''::character varying NOT NULL,
    customer_id bigint,
    active boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    display_name character varying DEFAULT ''::character varying NOT NULL,
    first_name character varying DEFAULT ''::character varying NOT NULL,
    area_json json DEFAULT '{}'::json NOT NULL
);


--
-- Name: vehicle_activity_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicle_activity_assignments (
    id bigint NOT NULL,
    vehicle_id bigint,
    activity_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: vehicles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicles (
    id bigint NOT NULL,
    name character varying,
    discarded_at timestamp without time zone,
    company_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    default_driving_route_id integer
);


--
-- Name: drives_with_pricings; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.drives_with_pricings AS
 SELECT DISTINCT drive_grouped.tour_id,
    drive_grouped.customer_id,
    s.display_name AS site_name,
    timezone('Europe/Zurich'::text, timezone('utc'::text, drive_grouped.start)) AS start,
    drive_grouped.vehicle_id,
    v.name AS vehicle,
    a.name AS activity,
    ae.value AS activitiy_value,
    phr.price_cents AS hourly_rate,
    pfr.price_cents AS site_flat_rate,
    (drive_grouped."end" - drive_grouped.start) AS duration,
    drive_grouped.total_drives_duration,
    (t.end_time - t.start_time) AS tour_duration,
        CASE
            WHEN (drive_grouped.first_in_tour = 1) THEN true
            ELSE false
        END AS first_item,
    date_part('epoch'::text, (drive_grouped."end" - drive_grouped.start)) AS duration_seconds,
    v.company_id,
    d.name AS driver_name,
    d.id AS driver_id,
    a.value_label AS activity_value_label,
    a.has_value AS has_activity_value,
    drive_grouped.num_billed_empty_drives,
    (
        CASE
            WHEN ((((t.end_time - t.start_time) - drive_grouped.total_drives_duration) < '00:00:00'::interval) OR (NOT (drive_grouped.first_in_tour = 1))) THEN '00:00:00'::interval
            ELSE ((t.end_time - t.start_time) - drive_grouped.total_drives_duration)
        END / (drive_grouped.num_billed_empty_drives)::double precision) AS billed_empty_drive_time,
    vphr.price_cents AS vehicle_price,
    date_part('epoch'::text, (
        CASE
            WHEN ((((t.end_time - t.start_time) - drive_grouped.total_drives_duration) < '00:00:00'::interval) OR (NOT (drive_grouped.first_in_tour = 1))) THEN '00:00:00'::interval
            ELSE ((t.end_time - t.start_time) - drive_grouped.total_drives_duration)
        END / (drive_grouped.num_billed_empty_drives)::double precision)) AS billed_empty_drive_time_seconds,
    vpfr.price_cents AS vehicle_flatrate_price
   FROM ((((((((((((( SELECT sum(drive_with_tour_info.first_in_tour) OVER (PARTITION BY drive_with_tour_info.tour_id) AS num_billed_empty_drives,
            drive_with_tour_info.id,
            drive_with_tour_info.start,
            drive_with_tour_info."end",
            drive_with_tour_info.created_at,
            drive_with_tour_info.updated_at,
            drive_with_tour_info.driver_id,
            drive_with_tour_info.customer_id,
            drive_with_tour_info.site_id,
            drive_with_tour_info.discarded_at,
            drive_with_tour_info.tour_id,
            drive_with_tour_info.vehicle_id,
            drive_with_tour_info.first_in_tour,
            drive_with_tour_info.total_drives_duration
           FROM ( SELECT drives.id,
                    drives.start,
                    drives."end",
                    drives.created_at,
                    drives.updated_at,
                    drives.driver_id,
                    drives.customer_id,
                    drives.site_id,
                    drives.discarded_at,
                    drives.tour_id,
                    drives.vehicle_id,
                        CASE
                            WHEN (row_number() OVER (PARTITION BY drives.tour_id, drives.site_id ORDER BY drives.start) = 1) THEN 1
                            ELSE 0
                        END AS first_in_tour,
                    sum((drives."end" - drives.start)) OVER (PARTITION BY drives.tour_id) AS total_drives_duration
                   FROM public.drives
                  WHERE (drives.discarded_at IS NULL)) drive_with_tour_info) drive_grouped
     JOIN public.activity_executions ae ON ((ae.drive_id = drive_grouped.id)))
     JOIN public.activities a ON ((a.id = ae.activity_id)))
     JOIN public.tours t ON ((t.id = drive_grouped.tour_id)))
     JOIN public.vehicles v ON ((v.id = drive_grouped.vehicle_id)))
     JOIN public.sites s ON ((s.id = drive_grouped.site_id)))
     JOIN public.drivers d ON ((d.id = drive_grouped.driver_id)))
     LEFT JOIN public.site_activity_flat_rates safr ON (((safr.site_id = drive_grouped.site_id) AND (safr.activity_id = ae.activity_id))))
     LEFT JOIN public.pricing_flat_rates pfr ON ((pfr.id = ( SELECT pricing_flat_rates.id
           FROM public.pricing_flat_rates
          WHERE (((pricing_flat_rates.flat_ratable_type)::text = 'SiteActivityFlatRate'::text) AND (pricing_flat_rates.flat_ratable_id = safr.id) AND ((pricing_flat_rates.rate_type)::text = 'activity_fee'::text) AND (pricing_flat_rates.valid_from < drive_grouped.start) AND (pfr.active = true))
          ORDER BY pricing_flat_rates.valid_from DESC
         LIMIT 1))))
     LEFT JOIN public.vehicle_activity_assignments vaa ON (((vaa.vehicle_id = drive_grouped.vehicle_id) AND (vaa.activity_id = ae.activity_id))))
     LEFT JOIN public.pricing_hourly_rates phr ON ((phr.id = ( SELECT pricing_hourly_rates.id
           FROM public.pricing_hourly_rates
          WHERE (((pricing_hourly_rates.hourly_ratable_type)::text = 'VehicleActivityAssignment'::text) AND (pricing_hourly_rates.hourly_ratable_id = vaa.id) AND (pricing_hourly_rates.valid_from < drive_grouped.start))
          ORDER BY pricing_hourly_rates.valid_from DESC
         LIMIT 1))))
     LEFT JOIN public.pricing_hourly_rates vphr ON ((vphr.id = ( SELECT pricing_hourly_rates.id
           FROM public.pricing_hourly_rates
          WHERE (((pricing_hourly_rates.hourly_ratable_type)::text = 'Vehicle'::text) AND (pricing_hourly_rates.hourly_ratable_id = drive_grouped.vehicle_id) AND (pricing_hourly_rates.valid_from < drive_grouped.start))
          ORDER BY pricing_hourly_rates.valid_from DESC
         LIMIT 1))))
     LEFT JOIN public.pricing_flat_rates vpfr ON ((vpfr.id = ( SELECT pricing_flat_rates.id
           FROM public.pricing_flat_rates
          WHERE (((pricing_flat_rates.flat_ratable_type)::text = 'Site'::text) AND (pricing_flat_rates.flat_ratable_id = drive_grouped.site_id) AND (pricing_flat_rates.active = true) AND ((pricing_flat_rates.rate_type)::text = 'travel_expense'::text) AND (pricing_flat_rates.valid_from <= drive_grouped.start))
          ORDER BY pricing_flat_rates.valid_from DESC
         LIMIT 1))))
  WHERE (t.discarded_at IS NULL)
  ORDER BY (timezone('Europe/Zurich'::text, timezone('utc'::text, drive_grouped.start))) DESC
  WITH NO DATA;


--
-- Name: driving_route_site_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.driving_route_site_entries (
    id bigint NOT NULL,
    site_id bigint NOT NULL,
    driving_route_id bigint NOT NULL,
    "position" integer NOT NULL,
    CONSTRAINT position_gte_zero CHECK (("position" >= 0))
);


--
-- Name: driving_route_site_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.driving_route_site_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: driving_route_site_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.driving_route_site_entries_id_seq OWNED BY public.driving_route_site_entries.id;


--
-- Name: driving_routes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.driving_routes (
    id bigint NOT NULL,
    name character varying NOT NULL,
    company_id bigint NOT NULL,
    site_ordering public.driving_route_sites_ordering NOT NULL,
    discarded_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: driving_routes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.driving_routes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: driving_routes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.driving_routes_id_seq OWNED BY public.driving_routes.id;


--
-- Name: driving_routes_vehicles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.driving_routes_vehicles (
    driving_route_id bigint NOT NULL,
    vehicle_id bigint NOT NULL
);


--
-- Name: oauth_access_grants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_grants (
    id bigint NOT NULL,
    resource_owner_id bigint NOT NULL,
    application_id bigint NOT NULL,
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    scopes character varying
);


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_access_grants_id_seq OWNED BY public.oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_tokens (
    id bigint NOT NULL,
    resource_owner_id bigint,
    application_id bigint NOT NULL,
    token character varying NOT NULL,
    refresh_token character varying,
    expires_in integer,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    scopes character varying,
    previous_refresh_token character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_access_tokens_id_seq OWNED BY public.oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_applications (
    id bigint NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    redirect_uri text NOT NULL,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    confidential boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    default_app boolean DEFAULT false
);


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_applications_id_seq OWNED BY public.oauth_applications.id;


--
-- Name: oauth_openid_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_openid_requests (
    id bigint NOT NULL,
    access_grant_id bigint NOT NULL,
    nonce character varying NOT NULL
);


--
-- Name: oauth_openid_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_openid_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_openid_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_openid_requests_id_seq OWNED BY public.oauth_openid_requests.id;


--
-- Name: policy_terms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.policy_terms (
    id bigint NOT NULL,
    key character varying,
    required boolean,
    short_description text,
    description text,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    version_date timestamp without time zone DEFAULT '2021-10-12 21:19:21.925162'::timestamp without time zone NOT NULL
);


--
-- Name: policy_terms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.policy_terms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: policy_terms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.policy_terms_id_seq OWNED BY public.policy_terms.id;


--
-- Name: pricing_flat_rates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pricing_flat_rates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pricing_flat_rates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pricing_flat_rates_id_seq OWNED BY public.pricing_flat_rates.id;


--
-- Name: pricing_hourly_rates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pricing_hourly_rates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pricing_hourly_rates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pricing_hourly_rates_id_seq OWNED BY public.pricing_hourly_rates.id;


--
-- Name: reasonability_check_warnings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reasonability_check_warnings (
    id bigint NOT NULL,
    warnings json,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    record_type character varying,
    record_id uuid
);


--
-- Name: reasonability_check_warnings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reasonability_check_warnings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reasonability_check_warnings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reasonability_check_warnings_id_seq OWNED BY public.reasonability_check_warnings.id;


--
-- Name: recordings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recordings (
    id bigint NOT NULL,
    start_time timestamp without time zone NOT NULL,
    driver_id bigint
);


--
-- Name: recordings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recordings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recordings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recordings_id_seq OWNED BY public.recordings.id;


--
-- Name: report_parameters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.report_parameters (
    id uuid NOT NULL,
    report_template_id uuid NOT NULL,
    parameter_type text NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    is_range boolean NOT NULL,
    display_name text DEFAULT ''::text NOT NULL,
    selection_list_config jsonb
);


--
-- Name: report_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.report_templates (
    id uuid NOT NULL,
    access_scope integer NOT NULL,
    name text NOT NULL,
    report_definition text NOT NULL,
    summary text DEFAULT ''::text NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: site_activity_flat_rates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_activity_flat_rates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_activity_flat_rates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_activity_flat_rates_id_seq OWNED BY public.site_activity_flat_rates.id;


--
-- Name: site_infos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_infos (
    id bigint NOT NULL,
    site_id bigint NOT NULL,
    discarded_at timestamp without time zone,
    content text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: site_infos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_infos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_infos_id_seq OWNED BY public.site_infos.id;


--
-- Name: sites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sites_id_seq OWNED BY public.sites.id;


--
-- Name: standby_dates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.standby_dates (
    id bigint NOT NULL,
    day date NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    driver_id integer NOT NULL
);


--
-- Name: standby_dates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.standby_dates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: standby_dates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.standby_dates_id_seq OWNED BY public.standby_dates.id;


--
-- Name: term_acceptances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.term_acceptances (
    id bigint NOT NULL,
    user_id bigint,
    policy_term_id bigint,
    term_version integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    invalidated_at timestamp without time zone
);


--
-- Name: term_acceptances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.term_acceptances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: term_acceptances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.term_acceptances_id_seq OWNED BY public.term_acceptances.id;


--
-- Name: tours_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tours_reports (
    id bigint NOT NULL,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    created_by_id integer,
    company_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    customer_id bigint
);


--
-- Name: tours_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tours_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tours_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tours_reports_id_seq OWNED BY public.tours_reports.id;


--
-- Name: user_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_actions (
    id bigint NOT NULL,
    activity character varying,
    user_id bigint,
    target_type character varying,
    target_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_actions_id_seq OWNED BY public.user_actions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    invitation_token character varying,
    invitation_created_at timestamp without time zone,
    invitation_sent_at timestamp without time zone,
    invitation_accepted_at timestamp without time zone,
    invitation_limit integer,
    invited_by_type character varying,
    invited_by_id bigint,
    invitations_count integer DEFAULT 0
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
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
-- Name: vehicle_activity_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vehicle_activity_assignments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vehicle_activity_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vehicle_activity_assignments_id_seq OWNED BY public.vehicle_activity_assignments.id;


--
-- Name: vehicles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vehicles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vehicles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vehicles_id_seq OWNED BY public.vehicles.id;


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: activities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities ALTER COLUMN id SET DEFAULT nextval('public.activities_id_seq'::regclass);


--
-- Name: activity_executions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_executions ALTER COLUMN id SET DEFAULT nextval('public.activity_executions_id_seq'::regclass);


--
-- Name: administrators id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.administrators ALTER COLUMN id SET DEFAULT nextval('public.administrators_id_seq'::regclass);


--
-- Name: audits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audits ALTER COLUMN id SET DEFAULT nextval('public.audits_id_seq'::regclass);


--
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies ALTER COLUMN id SET DEFAULT nextval('public.companies_id_seq'::regclass);


--
-- Name: company_members id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.company_members ALTER COLUMN id SET DEFAULT nextval('public.company_members_id_seq'::regclass);


--
-- Name: customers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers ALTER COLUMN id SET DEFAULT nextval('public.customers_id_seq'::regclass);


--
-- Name: driver_applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.driver_applications ALTER COLUMN id SET DEFAULT nextval('public.driver_applications_id_seq'::regclass);


--
-- Name: driver_logins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.driver_logins ALTER COLUMN id SET DEFAULT nextval('public.driver_logins_id_seq'::regclass);


--
-- Name: drivers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drivers ALTER COLUMN id SET DEFAULT nextval('public.drivers_id_seq'::regclass);


--
-- Name: drives id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drives ALTER COLUMN id SET DEFAULT nextval('public.drives_id_seq'::regclass);


--
-- Name: driving_route_site_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.driving_route_site_entries ALTER COLUMN id SET DEFAULT nextval('public.driving_route_site_entries_id_seq'::regclass);


--
-- Name: driving_routes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.driving_routes ALTER COLUMN id SET DEFAULT nextval('public.driving_routes_id_seq'::regclass);


--
-- Name: oauth_access_grants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('public.oauth_access_grants_id_seq'::regclass);


--
-- Name: oauth_access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.oauth_access_tokens_id_seq'::regclass);


--
-- Name: oauth_applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications ALTER COLUMN id SET DEFAULT nextval('public.oauth_applications_id_seq'::regclass);


--
-- Name: oauth_openid_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_openid_requests ALTER COLUMN id SET DEFAULT nextval('public.oauth_openid_requests_id_seq'::regclass);


--
-- Name: policy_terms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.policy_terms ALTER COLUMN id SET DEFAULT nextval('public.policy_terms_id_seq'::regclass);


--
-- Name: pricing_flat_rates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pricing_flat_rates ALTER COLUMN id SET DEFAULT nextval('public.pricing_flat_rates_id_seq'::regclass);


--
-- Name: pricing_hourly_rates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pricing_hourly_rates ALTER COLUMN id SET DEFAULT nextval('public.pricing_hourly_rates_id_seq'::regclass);


--
-- Name: reasonability_check_warnings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reasonability_check_warnings ALTER COLUMN id SET DEFAULT nextval('public.reasonability_check_warnings_id_seq'::regclass);


--
-- Name: recordings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recordings ALTER COLUMN id SET DEFAULT nextval('public.recordings_id_seq'::regclass);


--
-- Name: site_activity_flat_rates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_activity_flat_rates ALTER COLUMN id SET DEFAULT nextval('public.site_activity_flat_rates_id_seq'::regclass);


--
-- Name: site_infos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_infos ALTER COLUMN id SET DEFAULT nextval('public.site_infos_id_seq'::regclass);


--
-- Name: sites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites ALTER COLUMN id SET DEFAULT nextval('public.sites_id_seq'::regclass);


--
-- Name: standby_dates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.standby_dates ALTER COLUMN id SET DEFAULT nextval('public.standby_dates_id_seq'::regclass);


--
-- Name: term_acceptances id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.term_acceptances ALTER COLUMN id SET DEFAULT nextval('public.term_acceptances_id_seq'::regclass);


--
-- Name: tours_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tours_reports ALTER COLUMN id SET DEFAULT nextval('public.tours_reports_id_seq'::regclass);


--
-- Name: user_actions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_actions ALTER COLUMN id SET DEFAULT nextval('public.user_actions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: vehicle_activity_assignments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_activity_assignments ALTER COLUMN id SET DEFAULT nextval('public.vehicle_activity_assignments_id_seq'::regclass);


--
-- Name: vehicles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles ALTER COLUMN id SET DEFAULT nextval('public.vehicles_id_seq'::regclass);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: activity_executions activity_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_executions
    ADD CONSTRAINT activity_executions_pkey PRIMARY KEY (id);


--
-- Name: administrators administrators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.administrators
    ADD CONSTRAINT administrators_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: audits audits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audits
    ADD CONSTRAINT audits_pkey PRIMARY KEY (id);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: company_members company_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.company_members
    ADD CONSTRAINT company_members_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: driver_applications driver_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.driver_applications
    ADD CONSTRAINT driver_applications_pkey PRIMARY KEY (id);


--
-- Name: driver_logins driver_logins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.driver_logins
    ADD CONSTRAINT driver_logins_pkey PRIMARY KEY (id);


--
-- Name: drivers drivers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_pkey PRIMARY KEY (id);


--
-- Name: drives drives_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drives
    ADD CONSTRAINT drives_pkey PRIMARY KEY (id);


--
-- Name: driving_route_site_entries driving_route_site_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.driving_route_site_entries
    ADD CONSTRAINT driving_route_site_entries_pkey PRIMARY KEY (id);


--
-- Name: driving_route_site_entries driving_route_site_entries_position_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.driving_route_site_entries
    ADD CONSTRAINT driving_route_site_entries_position_unique UNIQUE (driving_route_id, "position") DEFERRABLE INITIALLY DEFERRED;


--
-- Name: driving_routes driving_routes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.driving_routes
    ADD CONSTRAINT driving_routes_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants oauth_access_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications oauth_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: oauth_openid_requests oauth_openid_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_openid_requests
    ADD CONSTRAINT oauth_openid_requests_pkey PRIMARY KEY (id);


--
-- Name: __EFMigrationsHistory pk___ef_migrations_history; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT pk___ef_migrations_history PRIMARY KEY (migration_id);


--
-- Name: company_report_assignments pk_company_report_assignments; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.company_report_assignments
    ADD CONSTRAINT pk_company_report_assignments PRIMARY KEY (report_template_id, id);


--
-- Name: report_parameters pk_report_parameters; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_parameters
    ADD CONSTRAINT pk_report_parameters PRIMARY KEY (report_template_id, id);


--
-- Name: report_templates pk_report_templates; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_templates
    ADD CONSTRAINT pk_report_templates PRIMARY KEY (id);


--
-- Name: policy_terms policy_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.policy_terms
    ADD CONSTRAINT policy_terms_pkey PRIMARY KEY (id);


--
-- Name: pricing_flat_rates pricing_flat_rates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pricing_flat_rates
    ADD CONSTRAINT pricing_flat_rates_pkey PRIMARY KEY (id);


--
-- Name: pricing_hourly_rates pricing_hourly_rates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pricing_hourly_rates
    ADD CONSTRAINT pricing_hourly_rates_pkey PRIMARY KEY (id);


--
-- Name: reasonability_check_warnings reasonability_check_warnings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reasonability_check_warnings
    ADD CONSTRAINT reasonability_check_warnings_pkey PRIMARY KEY (id);


--
-- Name: recordings recordings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recordings
    ADD CONSTRAINT recordings_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: site_activity_flat_rates site_activity_flat_rates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_activity_flat_rates
    ADD CONSTRAINT site_activity_flat_rates_pkey PRIMARY KEY (id);


--
-- Name: site_infos site_infos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_infos
    ADD CONSTRAINT site_infos_pkey PRIMARY KEY (id);


--
-- Name: sites sites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_pkey PRIMARY KEY (id);


--
-- Name: standby_dates standby_dates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.standby_dates
    ADD CONSTRAINT standby_dates_pkey PRIMARY KEY (id);


--
-- Name: term_acceptances term_acceptances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.term_acceptances
    ADD CONSTRAINT term_acceptances_pkey PRIMARY KEY (id);


--
-- Name: tours tours_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tours
    ADD CONSTRAINT tours_pkey PRIMARY KEY (id);


--
-- Name: tours_reports tours_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tours_reports
    ADD CONSTRAINT tours_reports_pkey PRIMARY KEY (id);


--
-- Name: user_actions user_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_actions
    ADD CONSTRAINT user_actions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vehicle_activity_assignments vehicle_activity_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_activity_assignments
    ADD CONSTRAINT vehicle_activity_assignments_pkey PRIMARY KEY (id);


--
-- Name: vehicles vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (id);


--
-- Name: associated_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX associated_index ON public.audits USING btree (associated_type, associated_id);


--
-- Name: auditable_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auditable_index ON public.audits USING btree (auditable_type, auditable_id);


--
-- Name: idx_driving_route_id_vehicle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_driving_route_id_vehicle_id ON public.driving_routes_vehicles USING btree (driving_route_id, vehicle_id);


--
-- Name: idx_vehicle_id_driving_route_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vehicle_id_driving_route_id ON public.driving_routes_vehicles USING btree (vehicle_id, driving_route_id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_activities_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_company_id ON public.activities USING btree (company_id);


--
-- Name: index_activities_on_company_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_activities_on_company_id_and_name ON public.activities USING btree (company_id, name);


--
-- Name: index_activities_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_name ON public.activities USING btree (name);


--
-- Name: index_activities_sites_on_activity_id_and_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_sites_on_activity_id_and_site_id ON public.activities_sites USING btree (activity_id, site_id);


--
-- Name: index_activities_sites_on_site_id_and_activity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_sites_on_site_id_and_activity_id ON public.activities_sites USING btree (site_id, activity_id);


--
-- Name: index_activity_executions_on_activity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_executions_on_activity_id ON public.activity_executions USING btree (activity_id);


--
-- Name: index_activity_executions_on_drive_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_executions_on_drive_id ON public.activity_executions USING btree (drive_id);


--
-- Name: index_audits_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_audits_on_created_at ON public.audits USING btree (created_at);


--
-- Name: index_audits_on_request_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_audits_on_request_uuid ON public.audits USING btree (request_uuid);


--
-- Name: index_companies_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_on_name ON public.companies USING btree (name);


--
-- Name: index_companies_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_on_slug ON public.companies USING btree (slug);


--
-- Name: index_company_members_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_company_members_on_company_id ON public.company_members USING btree (company_id);


--
-- Name: index_company_members_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_company_members_on_user_id ON public.company_members USING btree (user_id);


--
-- Name: index_company_members_on_user_id_and_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_company_members_on_user_id_and_company_id ON public.company_members USING btree (user_id, company_id);


--
-- Name: index_customers_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_customers_on_company_id ON public.customers USING btree (company_id);


--
-- Name: index_customers_on_company_name_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_customers_on_company_name_and_name ON public.customers USING btree (company_name, name);


--
-- Name: index_driver_applications_on_accepted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_driver_applications_on_accepted_by_id ON public.driver_applications USING btree (accepted_by_id);


--
-- Name: index_driver_applications_on_accepted_to_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_driver_applications_on_accepted_to_id ON public.driver_applications USING btree (accepted_to_id);


--
-- Name: index_driver_applications_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_driver_applications_on_token ON public.driver_applications USING btree (token);


--
-- Name: index_driver_applications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_driver_applications_on_user_id ON public.driver_applications USING btree (user_id);


--
-- Name: index_driver_logins_on_driver_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_driver_logins_on_driver_id ON public.driver_logins USING btree (driver_id);


--
-- Name: index_driver_logins_on_driver_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_driver_logins_on_driver_id_and_user_id ON public.driver_logins USING btree (driver_id, user_id);


--
-- Name: index_driver_logins_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_driver_logins_on_user_id ON public.driver_logins USING btree (user_id);


--
-- Name: index_drivers_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_drivers_on_discarded_at ON public.drivers USING btree (discarded_at);


--
-- Name: index_drives_on_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_drives_on_customer_id ON public.drives USING btree (customer_id);


--
-- Name: index_drives_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_drives_on_discarded_at ON public.drives USING btree (discarded_at);


--
-- Name: index_drives_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_drives_on_site_id ON public.drives USING btree (site_id);


--
-- Name: index_drives_on_start_and_end; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_drives_on_start_and_end ON public.drives USING btree (start, "end");


--
-- Name: index_drives_on_tour_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_drives_on_tour_id ON public.drives USING btree (tour_id);


--
-- Name: index_drives_on_tour_id_and_app_drive_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_drives_on_tour_id_and_app_drive_id ON public.drives USING btree (tour_id, app_drive_id);


--
-- Name: index_drives_on_vehicle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_drives_on_vehicle_id ON public.drives USING btree (vehicle_id);


--
-- Name: index_drives_with_pricings_on_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_drives_with_pricings_on_customer_id ON public.drives_with_pricings USING btree (customer_id);


--
-- Name: index_drives_with_pricings_on_start; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_drives_with_pricings_on_start ON public.drives_with_pricings USING btree (start);


--
-- Name: index_driving_route_site_entries_on_driving_route_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_driving_route_site_entries_on_driving_route_id ON public.driving_route_site_entries USING btree (driving_route_id);


--
-- Name: index_driving_route_site_entries_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_driving_route_site_entries_on_site_id ON public.driving_route_site_entries USING btree (site_id);


--
-- Name: index_driving_routes_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_driving_routes_on_company_id ON public.driving_routes USING btree (company_id);


--
-- Name: index_driving_routes_on_company_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_driving_routes_on_company_id_and_name ON public.driving_routes USING btree (company_id, name);


--
-- Name: index_driving_routes_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_driving_routes_on_discarded_at ON public.driving_routes USING btree (discarded_at);


--
-- Name: index_flat_rates_on_rable_id_ratable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flat_rates_on_rable_id_ratable_type ON public.pricing_flat_rates USING btree (flat_ratable_type, flat_ratable_id);


--
-- Name: index_flat_rates_on_rable_id_ratable_type_rate_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flat_rates_on_rable_id_ratable_type_rate_type ON public.pricing_flat_rates USING btree (flat_ratable_id, flat_ratable_type, rate_type);


--
-- Name: index_hourly_rates_on_hourly_priceable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hourly_rates_on_hourly_priceable_id ON public.pricing_hourly_rates USING btree (hourly_ratable_type, hourly_ratable_id);


--
-- Name: index_oauth_access_grants_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_application_id ON public.oauth_access_grants USING btree (application_id);


--
-- Name: index_oauth_access_grants_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_resource_owner_id ON public.oauth_access_grants USING btree (resource_owner_id);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON public.oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_application_id ON public.oauth_access_tokens USING btree (application_id);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON public.oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON public.oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON public.oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON public.oauth_applications USING btree (uid);


--
-- Name: index_oauth_openid_requests_on_access_grant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_openid_requests_on_access_grant_id ON public.oauth_openid_requests USING btree (access_grant_id);


--
-- Name: index_reasonability_check_warnings_on_record; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reasonability_check_warnings_on_record ON public.reasonability_check_warnings USING btree (record_type, record_id);


--
-- Name: index_recordings_on_driver_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_recordings_on_driver_id ON public.recordings USING btree (driver_id);


--
-- Name: index_site_activity_flat_rates_on_activity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_site_activity_flat_rates_on_activity_id ON public.site_activity_flat_rates USING btree (activity_id);


--
-- Name: index_site_activity_flat_rates_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_site_activity_flat_rates_on_site_id ON public.site_activity_flat_rates USING btree (site_id);


--
-- Name: index_site_infos_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_site_infos_on_site_id ON public.site_infos USING btree (site_id);


--
-- Name: index_sites_on_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sites_on_customer_id ON public.sites USING btree (customer_id);


--
-- Name: index_sites_on_display_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sites_on_display_name ON public.sites USING btree (display_name);


--
-- Name: index_standby_dates_on_day; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_standby_dates_on_day ON public.standby_dates USING btree (day);


--
-- Name: index_term_acceptances_on_policy_term_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_term_acceptances_on_policy_term_id ON public.term_acceptances USING btree (policy_term_id);


--
-- Name: index_term_acceptances_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_term_acceptances_on_user_id ON public.term_acceptances USING btree (user_id);


--
-- Name: index_tours_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tours_on_discarded_at ON public.tours USING btree (discarded_at);


--
-- Name: index_tours_on_driver_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tours_on_driver_id ON public.tours USING btree (driver_id);


--
-- Name: index_tours_on_start_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tours_on_start_time ON public.tours USING btree (start_time);


--
-- Name: index_tours_on_vehicle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tours_on_vehicle_id ON public.tours USING btree (vehicle_id);


--
-- Name: index_tours_reports_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tours_reports_on_company_id ON public.tours_reports USING btree (company_id);


--
-- Name: index_tours_reports_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tours_reports_on_created_by_id ON public.tours_reports USING btree (created_by_id);


--
-- Name: index_tours_reports_on_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tours_reports_on_customer_id ON public.tours_reports USING btree (customer_id);


--
-- Name: index_user_actions_on_target; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_actions_on_target ON public.user_actions USING btree (target_type, target_id);


--
-- Name: index_user_actions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_actions_on_user_id ON public.user_actions USING btree (user_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_invitation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_invitation_token ON public.users USING btree (invitation_token);


--
-- Name: index_users_on_invitations_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_invitations_count ON public.users USING btree (invitations_count);


--
-- Name: index_users_on_invited_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_invited_by ON public.users USING btree (invited_by_type, invited_by_id);


--
-- Name: index_users_on_invited_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_invited_by_id ON public.users USING btree (invited_by_id);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_vehicle_activity_assignments_on_activity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vehicle_activity_assignments_on_activity_id ON public.vehicle_activity_assignments USING btree (activity_id);


--
-- Name: index_vehicle_activity_assignments_on_vehicle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vehicle_activity_assignments_on_vehicle_id ON public.vehicle_activity_assignments USING btree (vehicle_id);


--
-- Name: index_vehicles_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vehicles_on_company_id ON public.vehicles USING btree (company_id);


--
-- Name: index_vehicles_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vehicles_on_discarded_at ON public.vehicles USING btree (discarded_at);


--
-- Name: index_vehicles_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vehicles_on_name ON public.vehicles USING btree (name);


--
-- Name: route_site_entries_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX route_site_entries_index ON public.driving_route_site_entries USING btree ("position", driving_route_id);


--
-- Name: uniq_index_driver_logins_on_driver_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_index_driver_logins_on_driver_id ON public.driver_logins USING btree (driver_id);


--
-- Name: user_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_index ON public.audits USING btree (user_id, user_type);


--
-- Name: company_report_assignments fk_company_report_assignments_report_templates_report_template; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.company_report_assignments
    ADD CONSTRAINT fk_company_report_assignments_report_templates_report_template FOREIGN KEY (report_template_id) REFERENCES public.report_templates(id) ON DELETE CASCADE;


--
-- Name: drives fk_drives_driver; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drives
    ADD CONSTRAINT fk_drives_driver FOREIGN KEY (driver_id) REFERENCES public.drivers(id);


--
-- Name: user_actions fk_rails_03991e1c48; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_actions
    ADD CONSTRAINT fk_rails_03991e1c48 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: driver_applications fk_rails_03be14eb0d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.driver_applications
    ADD CONSTRAINT fk_rails_03be14eb0d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: term_acceptances fk_rails_103454c07d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.term_acceptances
    ADD CONSTRAINT fk_rails_103454c07d FOREIGN KEY (policy_term_id) REFERENCES public.policy_terms(id);


--
-- Name: drivers fk_rails_1ae84e42c0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT fk_rails_1ae84e42c0 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: driving_routes fk_rails_1b21510d03; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.driving_routes
    ADD CONSTRAINT fk_rails_1b21510d03 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: activity_executions fk_rails_20a458f6f0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_executions
    ADD CONSTRAINT fk_rails_20a458f6f0 FOREIGN KEY (drive_id) REFERENCES public.drives(id);


--
-- Name: term_acceptances fk_rails_28dd86c8c1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.term_acceptances
    ADD CONSTRAINT fk_rails_28dd86c8c1 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: driving_route_site_entries fk_rails_31ef759a4b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.driving_route_site_entries
    ADD CONSTRAINT fk_rails_31ef759a4b FOREIGN KEY (driving_route_id) REFERENCES public.driving_routes(id);


--
-- Name: oauth_access_grants fk_rails_330c32d8d9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT fk_rails_330c32d8d9 FOREIGN KEY (resource_owner_id) REFERENCES public.users(id);


--
-- Name: activities fk_rails_346b6d4b3a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT fk_rails_346b6d4b3a FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: activity_executions fk_rails_45be1babbd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_executions
    ADD CONSTRAINT fk_rails_45be1babbd FOREIGN KEY (activity_id) REFERENCES public.activities(id);


--
-- Name: site_activity_flat_rates fk_rails_48b5fa29bc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_activity_flat_rates
    ADD CONSTRAINT fk_rails_48b5fa29bc FOREIGN KEY (activity_id) REFERENCES public.activities(id);


--
-- Name: vehicle_activity_assignments fk_rails_603ae4bc2a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_activity_assignments
    ADD CONSTRAINT fk_rails_603ae4bc2a FOREIGN KEY (activity_id) REFERENCES public.activities(id);


--
-- Name: oauth_access_tokens fk_rails_732cb83ab7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT fk_rails_732cb83ab7 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- Name: oauth_openid_requests fk_rails_77114b3b09; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_openid_requests
    ADD CONSTRAINT fk_rails_77114b3b09 FOREIGN KEY (access_grant_id) REFERENCES public.oauth_access_grants(id) ON DELETE CASCADE;


--
-- Name: site_activity_flat_rates fk_rails_810dc9ba60; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_activity_flat_rates
    ADD CONSTRAINT fk_rails_810dc9ba60 FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: sites fk_rails_83848d88c8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT fk_rails_83848d88c8 FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: tours_reports fk_rails_8558bdf31a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tours_reports
    ADD CONSTRAINT fk_rails_8558bdf31a FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: vehicle_activity_assignments fk_rails_8db6af0f75; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_activity_assignments
    ADD CONSTRAINT fk_rails_8db6af0f75 FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id);


--
-- Name: driver_logins fk_rails_90ba4002d1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.driver_logins
    ADD CONSTRAINT fk_rails_90ba4002d1 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: tours fk_rails_9f946117f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tours
    ADD CONSTRAINT fk_rails_9f946117f6 FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id);


--
-- Name: drives fk_rails_afad278dad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drives
    ADD CONSTRAINT fk_rails_afad278dad FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: driver_applications fk_rails_b2a054d943; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.driver_applications
    ADD CONSTRAINT fk_rails_b2a054d943 FOREIGN KEY (accepted_by_id) REFERENCES public.users(id);


--
-- Name: oauth_access_grants fk_rails_b4b53e07b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT fk_rails_b4b53e07b8 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: driver_applications fk_rails_cbdf7e739e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.driver_applications
    ADD CONSTRAINT fk_rails_cbdf7e739e FOREIGN KEY (accepted_to_id) REFERENCES public.companies(id);


--
-- Name: site_infos fk_rails_d027f2e8c9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_infos
    ADD CONSTRAINT fk_rails_d027f2e8c9 FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: tours fk_rails_d4c281e8ca; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tours
    ADD CONSTRAINT fk_rails_d4c281e8ca FOREIGN KEY (driver_id) REFERENCES public.drivers(id);


--
-- Name: drives fk_rails_d654b81cf5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drives
    ADD CONSTRAINT fk_rails_d654b81cf5 FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id);


--
-- Name: oauth_access_tokens fk_rails_ee63f25419; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT fk_rails_ee63f25419 FOREIGN KEY (resource_owner_id) REFERENCES public.users(id);


--
-- Name: drives fk_rails_f3a0ac43d6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drives
    ADD CONSTRAINT fk_rails_f3a0ac43d6 FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: drives fk_rails_f6cb6fcfda; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drives
    ADD CONSTRAINT fk_rails_f6cb6fcfda FOREIGN KEY (tour_id) REFERENCES public.tours(id);


--
-- Name: driver_logins fk_rails_fe5b83ef83; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.driver_logins
    ADD CONSTRAINT fk_rails_fe5b83ef83 FOREIGN KEY (driver_id) REFERENCES public.drivers(id);


--
-- Name: driving_route_site_entries fk_rails_fec71ee359; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.driving_route_site_entries
    ADD CONSTRAINT fk_rails_fec71ee359 FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: report_parameters fk_report_parameters_report_templates_report_template_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_parameters
    ADD CONSTRAINT fk_report_parameters_report_templates_report_template_id FOREIGN KEY (report_template_id) REFERENCES public.report_templates(id) ON DELETE CASCADE;


--
-- Name: standby_dates fk_standby_dates_driver; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.standby_dates
    ADD CONSTRAINT fk_standby_dates_driver FOREIGN KEY (driver_id) REFERENCES public.drivers(id);


--
-- Name: vehicles fk_vehicles_driving_routes; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT fk_vehicles_driving_routes FOREIGN KEY (default_driving_route_id) REFERENCES public.driving_routes(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20180120224743'),
('20180120234220'),
('20180123170327'),
('20180130073422'),
('20180130170054'),
('20180202200521'),
('20180202200723'),
('20180213170121'),
('20180213170946'),
('20180215204427'),
('20180220214435'),
('20180326183704'),
('20180404202750'),
('20180525153622'),
('20180606204046'),
('20180617112257'),
('20180627153725'),
('20180703160322'),
('20180703161736'),
('20180717212623'),
('20180825212409'),
('20180910055646'),
('20181005181834'),
('20181116190750'),
('20181116191006'),
('20181117014649'),
('20181117212817'),
('20190102211908'),
('20190110181300'),
('20190113223312'),
('20190113224639'),
('20190325194314'),
('20190401193302'),
('20190409200758'),
('20190424195708'),
('20190429214009'),
('20190501191539'),
('20190614180722'),
('20190622184440'),
('20190921190935'),
('20190925204951'),
('20191202202811'),
('20200909204054'),
('20201020204148'),
('20201117131630'),
('20201119153338'),
('20201203130517'),
('20201209074212'),
('20210125222847'),
('20210125223440'),
('20210131202817'),
('20210202153616'),
('20210203104838'),
('20210204121252'),
('20210204165631'),
('20210209102042'),
('20210214202829'),
('20210214215351'),
('20210214215352'),
('20210216111236'),
('20210609081250'),
('20210729193815'),
('20210831203507'),
('20210912090730'),
('20211007205529'),
('20211012191503'),
('20211012221221'),
('20211020191604'),
('20220629185842'),
('20230114220000'),
('20230114223102'),
('20230125230025'),
('20230327150059'),
('20231223111451'),
('20240102232703'),
('20240102234431');


