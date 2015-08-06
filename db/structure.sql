--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: enum_colorfamily; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE enum_colorfamily AS ENUM (
    'yellow',
    'red',
    'orange',
    'green',
    'black',
    'white',
    'gold',
    'silver',
    'brown',
    'beige',
    'gray',
    'pink',
    'purple',
    'blue',
    'unassigned'
);


--
-- Name: aggregateminmaxprice_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION aggregateminmaxprice_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN
UPDATE "Product" SET
	"minPriceCents" = (SELECT MIN(coalesce(nullif(v."salePriceCents", 0), v."listPriceCents"))
				       FROM "Variant" v
				       WHERE v."status" = 1 AND v."ProductId" = NEW."ProductId"),
	"maxPriceCents" = (SELECT MAX(coalesce(nullif(v."salePriceCents", 0), v."listPriceCents"))
				       FROM "Variant" v
				       WHERE v."status" = 1 AND v."ProductId" = NEW."ProductId")
WHERE "id" = NEW."ProductId"; 
RETURN NEW; 
END $$;


--
-- Name: setfulltextsearchweights_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION setfulltextsearchweights_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN 
NEW."tsv" := setweight(to_tsvector('pg_catalog.english', coalesce(unaccent(NEW."searchText"),'')), 'A'); 
RETURN NEW; 
END $$;


--
-- Name: updatesalepercent_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION updatesalepercent_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN
UPDATE "Product"
SET "salePercent" =
  (SELECT Round((MAX((vs."listPriceCents"::Numeric - vs."salePriceCents"::Numeric) / vs."listPriceCents"::Numeric)) * 100, 0) AS "percent"
   FROM "Variant" vs
   WHERE vs."status" = 1
     AND vs."salePriceCents" IS NOT NULL
     AND vs."listPriceCents" > vs."salePriceCents"
     AND vs."ProductId" = NEW."ProductId"
   GROUP BY vs."ProductId" )
WHERE "id" = NEW."ProductId"; 
RETURN NEW; 
END $$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: Address; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Address" (
    "addressType" integer NOT NULL,
    address1 character varying(255) NOT NULL,
    address2 character varying(255),
    city character varying(255) NOT NULL,
    state character varying(255) NOT NULL,
    zip character varying(255) NOT NULL,
    status integer,
    id integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "UserId" integer,
    "phoneNumber" character varying(255) NOT NULL
);


--
-- Name: Address_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Address_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Address_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Address_id_seq" OWNED BY "Address".id;


--
-- Name: Brand; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Brand" (
    name character varying(255) NOT NULL,
    status integer,
    id integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "PartnerId" integer
);


--
-- Name: Brand_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Brand_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Brand_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Brand_id_seq" OWNED BY "Brand".id;


--
-- Name: Category; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Category" (
    name character varying(255) NOT NULL,
    "parentId" integer,
    "orderBy" integer,
    status integer,
    id integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: Category_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Category_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Category_id_seq" OWNED BY "Category".id;


--
-- Name: InvalidateProduct; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "InvalidateProduct" (
    "productId" integer NOT NULL,
    "partnerId" integer NOT NULL,
    "batchId" character varying(255)
);


--
-- Name: InvalidateProductCategory; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "InvalidateProductCategory" (
    "productId" integer NOT NULL,
    "partnerId" integer NOT NULL,
    "batchId" character varying(255)
);


--
-- Name: InvalidateVariant; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "InvalidateVariant" (
    "variantId" integer NOT NULL,
    "partnerId" integer NOT NULL,
    "batchId" character varying(255)
);


--
-- Name: InvalidateVariantImg; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "InvalidateVariantImg" (
    "variantImgId" integer NOT NULL,
    "partnerId" integer NOT NULL,
    "batchId" character varying(255)
);


--
-- Name: ItemCountShippingCost; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "ItemCountShippingCost" (
    "itemCount" integer NOT NULL,
    "shippingPrice" integer NOT NULL,
    status integer NOT NULL,
    id integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "PartnerDetailId" integer
);


--
-- Name: ItemCountShippingCost_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "ItemCountShippingCost_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ItemCountShippingCost_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "ItemCountShippingCost_id_seq" OWNED BY "ItemCountShippingCost".id;


--
-- Name: Order; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Order" (
    "shippingCents" integer NOT NULL,
    "taxCents" integer NOT NULL,
    "orderTotalCents" integer NOT NULL,
    notes character varying(255),
    "appliedCommissionCents" integer NOT NULL,
    status integer NOT NULL,
    "shareWithPublisher" boolean NOT NULL,
    "apiKey" character varying(255) NOT NULL,
    "sourceUrl" character varying(255),
    id integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "BillingAddressId" integer,
    "ShippingAddressId" integer,
    "UserId" integer,
    "PaymentId" integer,
    "dequeuedAt" double precision
);


--
-- Name: OrderItem; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "OrderItem" (
    quantity integer NOT NULL,
    "listPriceCents" integer,
    "salePriceCents" integer,
    id integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "OrderId" integer,
    "VariantId" integer,
    "sourceUrl" character varying(255) NOT NULL,
    "widgetUuid" character varying(255) NOT NULL,
    "apiKey" character varying(255) NOT NULL,
    status integer,
    "commissionCents" integer NOT NULL,
    notes text
);


--
-- Name: OrderItem_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "OrderItem_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: OrderItem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "OrderItem_id_seq" OWNED BY "OrderItem".id;


--
-- Name: Order_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Order_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Order_id_seq" OWNED BY "Order".id;


--
-- Name: Partner; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Partner" (
    name character varying(255) NOT NULL,
    status integer NOT NULL,
    id integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    commission integer NOT NULL,
    "daysToWait" integer,
    "policyUrl" character varying(255),
    "linkshareId" character varying(255)
);


--
-- Name: PartnerDetail; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "PartnerDetail" (
    state character varying(255) NOT NULL,
    zip character varying(255),
    "shippingType" integer NOT NULL,
    "salesTax" integer NOT NULL,
    "freeShippingAbove" integer NOT NULL,
    "siteWideDiscount" integer NOT NULL,
    status integer NOT NULL,
    id integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "PartnerId" integer
);


--
-- Name: PartnerDetail_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "PartnerDetail_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: PartnerDetail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "PartnerDetail_id_seq" OWNED BY "PartnerDetail".id;


--
-- Name: PartnerImport; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "PartnerImport" (
    "LastImport" timestamp with time zone NOT NULL,
    id integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "PartnerId" integer
);


--
-- Name: PartnerImport_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "PartnerImport_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: PartnerImport_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "PartnerImport_id_seq" OWNED BY "PartnerImport".id;


--
-- Name: Partner_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Partner_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Partner_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Partner_id_seq" OWNED BY "Partner".id;


--
-- Name: Payment; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Payment" (
    type integer NOT NULL,
    number character varying(255) NOT NULL,
    "expirationMonth" integer NOT NULL,
    "expirationYear" integer NOT NULL,
    name character varying(255) NOT NULL,
    status integer,
    id integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "UserId" integer,
    cvv character varying(255)
);


--
-- Name: Payment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Payment_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Payment_id_seq" OWNED BY "Payment".id;


--
-- Name: Product; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Product" (
    name character varying(255) NOT NULL,
    description text NOT NULL,
    status integer,
    sku character varying(255) NOT NULL,
    "colorSubstitute" character varying(255),
    "sourceUrl" text,
    "pageViews" integer,
    "validatedAtOld" timestamp with time zone,
    "searchText" text,
    id integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "BrandId" integer,
    "descriptionSearchText" text,
    tsv tsvector,
    "salePercent" integer,
    "minPriceCents" integer,
    "maxPriceCents" integer,
    "validatedAt" double precision
);


--
-- Name: ProductCategory; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "ProductCategory" (
    "validatedAtOld" timestamp with time zone,
    status integer,
    id integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "CategoryId" integer,
    "ProductId" integer,
    "validatedAt" double precision
);


--
-- Name: ProductCategory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "ProductCategory_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ProductCategory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "ProductCategory_id_seq" OWNED BY "ProductCategory".id;


--
-- Name: Product_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Product_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Product_id_seq" OWNED BY "Product".id;


--
-- Name: Role; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Role" (
    name character varying(255) NOT NULL,
    status integer,
    id integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: Role_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Role_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Role_id_seq" OWNED BY "Role".id;


--
-- Name: User; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "User" (
    email character varying(255) NOT NULL,
    password text NOT NULL,
    salt character varying(255),
    "facebookId" character varying(255),
    "firstName" character varying(255) NOT NULL,
    "middleName" character varying(255),
    "lastName" character varying(255) NOT NULL,
    status integer,
    "commissionCents" integer,
    id integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "apiKey" character varying(255),
    url character varying(255)[],
    "pendingCommissionCents" integer,
    "totalCommissionCents" integer,
    focus character varying(255)[]
);


--
-- Name: UserRole; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "UserRole" (
    status integer,
    id integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "RoleId" integer,
    "UserId" integer
);


--
-- Name: UserRole_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "UserRole_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserRole_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "UserRole_id_seq" OWNED BY "UserRole".id;


--
-- Name: User_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "User_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: User_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "User_id_seq" OWNED BY "User".id;


--
-- Name: Variant; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Variant" (
    color character varying(255),
    "colorSubstitute" character varying(255),
    size character varying(255),
    "listPriceCents" integer,
    "salePriceCents" integer,
    sku character varying(255) NOT NULL,
    status integer,
    "sourceUrl" character varying(255),
    "validatedAtOld" timestamp with time zone,
    id integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "ProductId" integer,
    "validatedAt" double precision,
    "colorFamily" enum_colorfamily[],
    "partnerData" character varying(255)
);


--
-- Name: VariantImg; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "VariantImg" (
    url character varying(255) NOT NULL,
    "sourceUrl" character varying(255) NOT NULL,
    "sortOrder" integer,
    "validatedAtOld" timestamp with time zone,
    status integer,
    id integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "VariantId" integer,
    "validatedAt" double precision
);


--
-- Name: VariantImg_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "VariantImg_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: VariantImg_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "VariantImg_id_seq" OWNED BY "VariantImg".id;


--
-- Name: Variant_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Variant_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Variant_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Variant_id_seq" OWNED BY "Variant".id;


--
-- Name: active_admin_comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE active_admin_comments (
    id integer NOT NULL,
    resource_id character varying(255) NOT NULL,
    resource_type character varying(255) NOT NULL,
    author_id integer,
    author_type character varying(255),
    body text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    namespace character varying(255)
);


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE active_admin_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE active_admin_comments_id_seq OWNED BY active_admin_comments.id;


--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE admin_users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: admin_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admin_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admin_users_id_seq OWNED BY admin_users.id;


--
-- Name: brandfilters; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE brandfilters (
    filtertype character varying(7),
    filtername character varying(255),
    filterid integer
);


--
-- Name: categoryfilters; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categoryfilters (
    filtertype character varying(7),
    filtername character varying(255),
    filterid integer
);


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    handler text NOT NULL,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying(255),
    queue character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: partnerdetailid; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE partnerdetailid (
    id integer
);


--
-- Name: partnerfilters; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE partnerfilters (
    filtertype character varying(7),
    filtername character varying(255),
    filterid integer
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sessions (
    id integer NOT NULL,
    session_id character varying(255) NOT NULL,
    data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sessions_id_seq OWNED BY sessions.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Address" ALTER COLUMN id SET DEFAULT nextval('"Address_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Brand" ALTER COLUMN id SET DEFAULT nextval('"Brand_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Category" ALTER COLUMN id SET DEFAULT nextval('"Category_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "ItemCountShippingCost" ALTER COLUMN id SET DEFAULT nextval('"ItemCountShippingCost_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Order" ALTER COLUMN id SET DEFAULT nextval('"Order_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "OrderItem" ALTER COLUMN id SET DEFAULT nextval('"OrderItem_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Partner" ALTER COLUMN id SET DEFAULT nextval('"Partner_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "PartnerDetail" ALTER COLUMN id SET DEFAULT nextval('"PartnerDetail_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "PartnerImport" ALTER COLUMN id SET DEFAULT nextval('"PartnerImport_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Payment" ALTER COLUMN id SET DEFAULT nextval('"Payment_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Product" ALTER COLUMN id SET DEFAULT nextval('"Product_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "ProductCategory" ALTER COLUMN id SET DEFAULT nextval('"ProductCategory_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Role" ALTER COLUMN id SET DEFAULT nextval('"Role_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "User" ALTER COLUMN id SET DEFAULT nextval('"User_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "UserRole" ALTER COLUMN id SET DEFAULT nextval('"UserRole_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Variant" ALTER COLUMN id SET DEFAULT nextval('"Variant_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "VariantImg" ALTER COLUMN id SET DEFAULT nextval('"VariantImg_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY active_admin_comments ALTER COLUMN id SET DEFAULT nextval('active_admin_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_users ALTER COLUMN id SET DEFAULT nextval('admin_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions ALTER COLUMN id SET DEFAULT nextval('sessions_id_seq'::regclass);


--
-- Name: Address_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Address"
    ADD CONSTRAINT "Address_pkey" PRIMARY KEY (id);


--
-- Name: Brand_PartnerId_name_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Brand"
    ADD CONSTRAINT "Brand_PartnerId_name_unique" UNIQUE ("PartnerId", name);


--
-- Name: Brand_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Brand"
    ADD CONSTRAINT "Brand_pkey" PRIMARY KEY (id);


--
-- Name: Category_name_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Category"
    ADD CONSTRAINT "Category_name_key" UNIQUE (name);


--
-- Name: Category_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Category"
    ADD CONSTRAINT "Category_pkey" PRIMARY KEY (id);


--
-- Name: ItemCountShippingCost_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "ItemCountShippingCost"
    ADD CONSTRAINT "ItemCountShippingCost_pkey" PRIMARY KEY (id);


--
-- Name: OrderItem_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "OrderItem"
    ADD CONSTRAINT "OrderItem_pkey" PRIMARY KEY (id);


--
-- Name: Order_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Order"
    ADD CONSTRAINT "Order_pkey" PRIMARY KEY (id);


--
-- Name: PartnerDetail_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "PartnerDetail"
    ADD CONSTRAINT "PartnerDetail_pkey" PRIMARY KEY (id);


--
-- Name: PartnerImport_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "PartnerImport"
    ADD CONSTRAINT "PartnerImport_pkey" PRIMARY KEY (id);


--
-- Name: Partner_name_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Partner"
    ADD CONSTRAINT "Partner_name_key" UNIQUE (name);


--
-- Name: Partner_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Partner"
    ADD CONSTRAINT "Partner_pkey" PRIMARY KEY (id);


--
-- Name: Payment_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Payment"
    ADD CONSTRAINT "Payment_pkey" PRIMARY KEY (id);


--
-- Name: ProductCategory_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "ProductCategory"
    ADD CONSTRAINT "ProductCategory_pkey" PRIMARY KEY (id);


--
-- Name: Product_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Product"
    ADD CONSTRAINT "Product_pkey" PRIMARY KEY (id);


--
-- Name: Role_name_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Role"
    ADD CONSTRAINT "Role_name_key" UNIQUE (name);


--
-- Name: Role_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Role"
    ADD CONSTRAINT "Role_pkey" PRIMARY KEY (id);


--
-- Name: UserRole_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "UserRole"
    ADD CONSTRAINT "UserRole_pkey" PRIMARY KEY (id);


--
-- Name: User_facebookId_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "User"
    ADD CONSTRAINT "User_facebookId_key" UNIQUE ("facebookId");


--
-- Name: User_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: VariantImg_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "VariantImg"
    ADD CONSTRAINT "VariantImg_pkey" PRIMARY KEY (id);


--
-- Name: Variant_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Variant"
    ADD CONSTRAINT "Variant_pkey" PRIMARY KEY (id);


--
-- Name: admin_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY active_admin_comments
    ADD CONSTRAINT admin_notes_pkey PRIMARY KEY (id);


--
-- Name: admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: InvalidateProductCategory_batchId_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "InvalidateProductCategory_batchId_idx" ON "InvalidateProductCategory" USING btree ("batchId");


--
-- Name: InvalidateProductCategory_partnerId_batchId_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "InvalidateProductCategory_partnerId_batchId_idx" ON "InvalidateProductCategory" USING btree ("partnerId", "batchId" NULLS FIRST);


--
-- Name: InvalidateProductCategory_partnerId_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "InvalidateProductCategory_partnerId_idx" ON "InvalidateProductCategory" USING btree ("partnerId");


--
-- Name: InvalidateProductCategory_productId_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "InvalidateProductCategory_productId_idx" ON "InvalidateProductCategory" USING btree ("productId");


--
-- Name: InvalidateProduct_batchId_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "InvalidateProduct_batchId_idx" ON "InvalidateProduct" USING btree ("batchId");


--
-- Name: InvalidateProduct_partnerId_batchId_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "InvalidateProduct_partnerId_batchId_idx" ON "InvalidateProduct" USING btree ("partnerId", "batchId" NULLS FIRST);


--
-- Name: InvalidateProduct_partnerId_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "InvalidateProduct_partnerId_idx" ON "InvalidateProduct" USING btree ("partnerId");


--
-- Name: InvalidateProduct_productId_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "InvalidateProduct_productId_idx" ON "InvalidateProduct" USING btree ("productId");


--
-- Name: InvalidateVariantImg_batchId_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "InvalidateVariantImg_batchId_idx" ON "InvalidateVariantImg" USING btree ("batchId");


--
-- Name: InvalidateVariantImg_partnerId_batchId_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "InvalidateVariantImg_partnerId_batchId_idx" ON "InvalidateVariantImg" USING btree ("partnerId", "batchId" NULLS FIRST);


--
-- Name: InvalidateVariantImg_partnerId_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "InvalidateVariantImg_partnerId_idx" ON "InvalidateVariantImg" USING btree ("partnerId");


--
-- Name: InvalidateVariantImg_variantId_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "InvalidateVariantImg_variantId_idx" ON "InvalidateVariantImg" USING btree ("variantImgId");


--
-- Name: InvalidateVariant_batchId_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "InvalidateVariant_batchId_idx" ON "InvalidateVariant" USING btree ("batchId");


--
-- Name: InvalidateVariant_partnerId_batchId_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "InvalidateVariant_partnerId_batchId_idx" ON "InvalidateVariant" USING btree ("partnerId", "batchId" NULLS FIRST);


--
-- Name: InvalidateVariant_partnerId_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "InvalidateVariant_partnerId_idx" ON "InvalidateVariant" USING btree ("partnerId");


--
-- Name: InvalidateVariant_variantId_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "InvalidateVariant_variantId_idx" ON "InvalidateVariant" USING btree ("variantId");


--
-- Name: Order_createdAt_idx_status_3; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "Order_createdAt_idx_status_3" ON "Order" USING btree ("createdAt" NULLS FIRST) WHERE (status = 3);


--
-- Name: Order_dequeuedAt_idx_dequeuedAt_not_null; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "Order_dequeuedAt_idx_dequeuedAt_not_null" ON "Order" USING btree ("dequeuedAt") WHERE ("dequeuedAt" IS NOT NULL);


--
-- Name: Partner_name_idx_status_1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "Partner_name_idx_status_1" ON "Partner" USING btree (name NULLS FIRST) WHERE (status = 1);


--
-- Name: Product_BrandId_createdAt_status_1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "Product_BrandId_createdAt_status_1" ON "Product" USING btree ("BrandId", "createdAt") WHERE (status = 1);


--
-- Name: Product_createdAt_idx_status_1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "Product_createdAt_idx_status_1" ON "Product" USING btree ("createdAt" DESC) WHERE (status = 1);


--
-- Name: Product_maxPriceCents_idx_status_1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "Product_maxPriceCents_idx_status_1" ON "Product" USING btree ("maxPriceCents") WHERE (status = 1);


--
-- Name: Product_minPriceCents_idx_status_1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "Product_minPriceCents_idx_status_1" ON "Product" USING btree ("minPriceCents") WHERE (status = 1);


--
-- Name: Product_salePercent_Desc_idx_status_1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "Product_salePercent_Desc_idx_status_1" ON "Product" USING btree ("salePercent" DESC) WHERE (status = 1);


--
-- Name: Product_sku_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "Product_sku_idx" ON "Product" USING btree (sku NULLS FIRST);


--
-- Name: Variant_sku_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "Variant_sku_idx" ON "Variant" USING btree (sku NULLS FIRST);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: fki_Brand_PartnerId_fkey_status_1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "fki_Brand_PartnerId_fkey_status_1" ON "Brand" USING btree ("PartnerId") WHERE (status = 1);


--
-- Name: fki_ProductCategory_CategoryId_fkey_status_1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "fki_ProductCategory_CategoryId_fkey_status_1" ON "ProductCategory" USING btree ("CategoryId") WHERE (status = 1);


--
-- Name: fki_ProductCategory_ProductId_fkey_status_1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "fki_ProductCategory_ProductId_fkey_status_1" ON "ProductCategory" USING btree ("ProductId") WHERE (status = 1);


--
-- Name: fki_Product_BrandId_fkey_status_1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "fki_Product_BrandId_fkey_status_1" ON "Product" USING btree ("BrandId") WHERE (status = 1);


--
-- Name: fki_VariantImg_VariantId_fkey; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "fki_VariantImg_VariantId_fkey" ON "VariantImg" USING btree ("VariantId");


--
-- Name: fki_VariantImg_VariantId_fkey_status_1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "fki_VariantImg_VariantId_fkey_status_1" ON "VariantImg" USING btree ("VariantId") WHERE (status = 1);


--
-- Name: fki_Variant_ProductId_fkey; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "fki_Variant_ProductId_fkey" ON "Variant" USING btree ("ProductId");


--
-- Name: fki_Variant_ProductId_fkey_status_1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "fki_Variant_ProductId_fkey_status_1" ON "Variant" USING btree ("ProductId") WHERE (status = 1);


--
-- Name: index_active_admin_comments_on_author_type_and_author_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_active_admin_comments_on_author_type_and_author_id ON active_admin_comments USING btree (author_type, author_id);


--
-- Name: index_active_admin_comments_on_namespace; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_active_admin_comments_on_namespace ON active_admin_comments USING btree (namespace);


--
-- Name: index_admin_notes_on_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_admin_notes_on_resource_type_and_resource_id ON active_admin_comments USING btree (resource_type, resource_id);


--
-- Name: index_admin_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_admin_users_on_email ON admin_users USING btree (email);


--
-- Name: index_admin_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_admin_users_on_reset_password_token ON admin_users USING btree (reset_password_token);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sessions_on_session_id ON sessions USING btree (session_id);


--
-- Name: index_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sessions_on_updated_at ON sessions USING btree (updated_at);


--
-- Name: tsv_idx_status_1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tsv_idx_status_1 ON "Product" USING gin (tsv) WHERE (status = 1);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: minmaxpriceupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER minmaxpriceupdate AFTER INSERT OR UPDATE ON "Variant" FOR EACH ROW EXECUTE PROCEDURE aggregateminmaxprice_trigger();


--
-- Name: salepercentupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER salepercentupdate AFTER INSERT OR UPDATE ON "Variant" FOR EACH ROW EXECUTE PROCEDURE updatesalepercent_trigger();


--
-- Name: tsvectorupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE ON "Product" FOR EACH ROW EXECUTE PROCEDURE setfulltextsearchweights_trigger();


--
-- Name: Brand_PartnerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Brand"
    ADD CONSTRAINT "Brand_PartnerId_fkey" FOREIGN KEY ("PartnerId") REFERENCES "Partner"(id);


--
-- Name: ProductCategory_CategoryId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "ProductCategory"
    ADD CONSTRAINT "ProductCategory_CategoryId_fkey" FOREIGN KEY ("CategoryId") REFERENCES "Category"(id);


--
-- Name: ProductCategory_ProductId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "ProductCategory"
    ADD CONSTRAINT "ProductCategory_ProductId_fkey" FOREIGN KEY ("ProductId") REFERENCES "Product"(id);


--
-- Name: Product_BrandId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Product"
    ADD CONSTRAINT "Product_BrandId_fkey" FOREIGN KEY ("BrandId") REFERENCES "Brand"(id);


--
-- Name: VariantImg_VariantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "VariantImg"
    ADD CONSTRAINT "VariantImg_VariantId_fkey" FOREIGN KEY ("VariantId") REFERENCES "Variant"(id);


--
-- Name: Variant_ProductId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Variant"
    ADD CONSTRAINT "Variant_ProductId_fkey" FOREIGN KEY ("ProductId") REFERENCES "Product"(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20150513084502');

INSERT INTO schema_migrations (version) VALUES ('20150513084504');

INSERT INTO schema_migrations (version) VALUES ('20150513084505');

INSERT INTO schema_migrations (version) VALUES ('20150513084920');

INSERT INTO schema_migrations (version) VALUES ('20150514043126');

