--
-- PostgreSQL database dump
--

\restrict 6H7w1F7l55sccaDAkd87M7M19VL8ipk45E8EVnFuLHmodekZfcLHm4xccG4zVKQ

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

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

--
-- Name: user_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_role AS ENUM (
    'guest',
    'hotel_admin',
    'system_admin'
);


--
-- Name: calculate_booking_price(integer, date, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_booking_price(p_room_id integer, p_check_in date, p_check_out date) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_price_per_night DECIMAL(10, 2);
    v_nights INTEGER;
    v_total DECIMAL(10, 2);
BEGIN
    -- Получаем цену за ночь из rooms (или из roomtypes если в rooms NULL)
    SELECT COALESCE(r.price_per_night, rt.price_per_night) INTO v_price_per_night
    FROM rooms r
    LEFT JOIN roomtypes rt ON r.roomtype_id = rt.roomtype_id
    WHERE r.room_id = p_room_id;
    
    IF v_price_per_night IS NULL THEN
        RAISE EXCEPTION 'Номер с ID % не найден', p_room_id;
    END IF;
    
    -- Вычисляем количество ночей
    v_nights := p_check_out - p_check_in;
    
    IF v_nights <= 0 THEN
        RAISE EXCEPTION 'Дата выезда должна быть позже даты заезда';
    END IF;
    
    -- Рассчитываем общую стоимость
    v_total := v_price_per_night * v_nights;
    
    RETURN v_total;
END;
$$;


--
-- Name: FUNCTION calculate_booking_price(p_room_id integer, p_check_in date, p_check_out date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.calculate_booking_price(p_room_id integer, p_check_in date, p_check_out date) IS 'Рассчитывает общую стоимость бронирования на основе цены номера и количества ночей';


--
-- Name: calculate_total_price_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_total_price_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_price_per_night DECIMAL(10, 2);
    v_nights INTEGER;
BEGIN
    -- Получаем цену номера из типа номера (3NF compliance)
    SELECT rt.price_per_night INTO v_price_per_night
    FROM rooms r
    JOIN roomtypes rt ON r.roomtype_id = rt.roomtype_id
    WHERE r.room_id = NEW.room_id;
    
    -- Рассчитываем количество ночей
    v_nights := NEW.check_out_date - NEW.check_in_date;
    
    -- Проверяем корректность дат
    IF v_nights <= 0 THEN
        RAISE EXCEPTION 'Дата выезда должна быть позже даты заезда';
    END IF;
    
    -- Рассчитываем общую стоимость
    NEW.total_price := v_price_per_night * v_nights;
    
    RETURN NEW;
END;
$$;


--
-- Name: can_add_review(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.can_add_review(p_user_id integer, p_booking_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_booking_exists BOOLEAN;
    v_is_checked_out BOOLEAN;
    v_has_review BOOLEAN;
BEGIN
    -- Проверяем, принадлежит ли бронирование пользователю
    SELECT EXISTS(
        SELECT 1 FROM bookings
        WHERE booking_id = p_booking_id
            AND user_id = p_user_id
    ) INTO v_booking_exists;
    
    IF NOT v_booking_exists THEN
        RETURN FALSE;
    END IF;
    
    -- Проверяем, завершено ли проживание
    SELECT status = 'checked_out' INTO v_is_checked_out
    FROM bookings
    WHERE booking_id = p_booking_id;
    
    IF NOT v_is_checked_out THEN
        RETURN FALSE;
    END IF;
    
    -- Проверяем, нет ли уже отзыва
    SELECT EXISTS(
        SELECT 1 FROM reviews
        WHERE booking_id = p_booking_id
    ) INTO v_has_review;
    
    RETURN NOT v_has_review;
END;
$$;


--
-- Name: cancel_expired_bookings(); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.cancel_expired_bookings()
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_cancelled_count INTEGER;
BEGIN
    -- Отменяем бронирования со статусом pending, у которых дата заезда прошла
    UPDATE bookings
    SET status = 'cancelled',
        updated_at = CURRENT_TIMESTAMP
    WHERE status = 'pending'
        AND check_in_date < CURRENT_DATE;
    
    GET DIAGNOSTICS v_cancelled_count = ROW_COUNT;
    
    RAISE NOTICE 'Отменено % просроченных бронирований', v_cancelled_count;
END;
$$;


--
-- Name: check_booking_availability(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_booking_availability() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_conflict_count INTEGER;
BEGIN
    -- Проверяем пересечения с существующими бронированиями
    SELECT COUNT(*) INTO v_conflict_count
    FROM bookings
    WHERE room_id = NEW.room_id
        AND booking_id != COALESCE(NEW.booking_id, 0)  -- Исключаем текущее бронирование при UPDATE
        AND status NOT IN ('cancelled')
        AND (
            (check_in_date <= NEW.check_in_date AND check_out_date > NEW.check_in_date)
            OR (check_in_date < NEW.check_out_date AND check_out_date >= NEW.check_out_date)
            OR (check_in_date >= NEW.check_in_date AND check_out_date <= NEW.check_out_date)
        );
    
    IF v_conflict_count > 0 THEN
        RAISE EXCEPTION 'Номер уже забронирован на выбранные даты';
    END IF;
    
    -- Проверяем, что номер доступен
    IF NOT EXISTS (SELECT 1 FROM rooms WHERE room_id = NEW.room_id AND is_available = TRUE) THEN
        RAISE EXCEPTION 'Номер недоступен для бронирования';
    END IF;
    
    RETURN NEW;
END;
$$;


--
-- Name: check_room_availability(integer, date, date, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_room_availability(p_room_id integer, p_check_in date, p_check_out date, p_exclude_booking_id integer DEFAULT NULL::integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_conflict_count INTEGER;
BEGIN
    -- Проверяем, нет ли пересечений с существующими бронированиями
    SELECT COUNT(*) INTO v_conflict_count
    FROM bookings
    WHERE room_id = p_room_id
        AND status NOT IN ('cancelled')
        AND (booking_id != p_exclude_booking_id OR p_exclude_booking_id IS NULL)
        AND (
            (check_in_date <= p_check_in AND check_out_date > p_check_in)
            OR (check_in_date < p_check_out AND check_out_date >= p_check_out)
            OR (check_in_date >= p_check_in AND check_out_date <= p_check_out)
        );
    
    RETURN v_conflict_count = 0;
END;
$$;


--
-- Name: get_available_rooms(date, date, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_available_rooms(p_check_in date, p_check_out date, p_hotel_id integer DEFAULT NULL::integer) RETURNS TABLE(room_id integer, hotel_id integer, hotel_name character varying, roomtype_id integer, type_name character varying, room_number character varying, floor integer, price_per_night numeric, is_available boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.room_id,
        r.hotel_id,
        h.name AS hotel_name,
        r.roomtype_id,
        rt.type_name,
        r.room_number,
        r.floor,
        rt.price_per_night,
        r.is_available
    FROM rooms r
    JOIN hotels h ON r.hotel_id = h.hotel_id
    JOIN roomtypes rt ON r.roomtype_id = rt.roomtype_id
    WHERE r.is_available = TRUE
    AND (p_hotel_id IS NULL OR r.hotel_id = p_hotel_id)
    AND NOT EXISTS (
        SELECT 1 FROM bookings b
        WHERE b.room_id = r.room_id
        AND b.status IN ('confirmed', 'checked_in')
        AND (
            (b.check_in_date <= p_check_in AND b.check_out_date > p_check_in)
            OR (b.check_in_date < p_check_out AND b.check_out_date >= p_check_out)
            OR (b.check_in_date >= p_check_in AND b.check_out_date <= p_check_out)
        )
    );
END;
$$;


--
-- Name: get_available_rooms(integer, date, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_available_rooms(p_hotel_id integer, p_check_in date, p_check_out date) RETURNS TABLE(room_id integer, room_number character varying, type_name character varying, price_per_night numeric, total_price numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.room_id,
        r.room_number,
        rt.type_name,
        rt.price_per_night,
        (rt.price_per_night * (p_check_out - p_check_in)) AS total_price
    FROM rooms r
    JOIN roomtypes rt ON r.roomtype_id = rt.roomtype_id
    WHERE r.hotel_id = p_hotel_id
        AND r.is_available = TRUE
        AND NOT EXISTS (
            SELECT 1 FROM bookings b
            WHERE b.room_id = r.room_id
                AND b.status IN ('confirmed', 'checked_in')
                AND (
                    (b.check_in_date <= p_check_in AND b.check_out_date > p_check_in)
                    OR (b.check_in_date < p_check_out AND b.check_out_date >= p_check_out)
                    OR (b.check_in_date >= p_check_in AND b.check_out_date <= p_check_out)
                )
        );
END;
$$;


--
-- Name: get_hotel_average_rating(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_hotel_average_rating(p_hotel_id integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_avg_rating DECIMAL(3, 2);
BEGIN
    SELECT COALESCE(ROUND(AVG(rating)::numeric, 2), 0)
    INTO v_avg_rating
    FROM reviews
    WHERE hotel_id = p_hotel_id AND is_approved = TRUE;
    
    RETURN v_avg_rating;
END;
$$;


--
-- Name: get_hotel_occupancy_stats(integer, date, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_hotel_occupancy_stats(p_hotel_id integer, p_start_date date, p_end_date date) RETURNS TABLE(total_rooms bigint, booked_rooms bigint, available_rooms bigint, occupancy_rate numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH room_stats AS (
        SELECT COUNT(*) as total
        FROM rooms
        WHERE hotel_id = p_hotel_id AND is_available = TRUE
    ),
    booking_stats AS (
        SELECT COUNT(DISTINCT room_id) as booked
        FROM bookings b
        INNER JOIN rooms r ON b.room_id = r.room_id
        WHERE r.hotel_id = p_hotel_id
            AND b.status IN ('confirmed', 'checked_in')
            AND b.check_in_date <= p_end_date
            AND b.check_out_date >= p_start_date
    )
    SELECT 
        rs.total,
        COALESCE(bs.booked, 0) as booked,
        rs.total - COALESCE(bs.booked, 0) as available,
        CASE 
            WHEN rs.total > 0 THEN ROUND((COALESCE(bs.booked, 0)::DECIMAL / rs.total) * 100, 2)
            ELSE 0
        END as rate
    FROM room_stats rs, booking_stats bs;
END;
$$;


--
-- Name: FUNCTION get_hotel_occupancy_stats(p_hotel_id integer, p_start_date date, p_end_date date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.get_hotel_occupancy_stats(p_hotel_id integer, p_start_date date, p_end_date date) IS 'Статистика загрузки отеля за период';


--
-- Name: set_booking_date(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_booking_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.booking_date IS NULL THEN
        NEW.booking_date := CURRENT_TIMESTAMP;
    END IF;
    
    IF NEW.created_at IS NULL THEN
        NEW.created_at := CURRENT_TIMESTAMP;
    END IF;
    
    RETURN NEW;
END;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


--
-- Name: validate_review_rights(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_review_rights() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_booking_user_id INTEGER;
    v_booking_status VARCHAR(20);
BEGIN
    -- Получаем user_id и статус бронирования
    SELECT user_id, status INTO v_booking_user_id, v_booking_status
    FROM bookings
    WHERE booking_id = NEW.booking_id;
    
    -- Проверка что бронирование существует
    IF v_booking_user_id IS NULL THEN
        RAISE EXCEPTION 'Бронирование не найдено';
    END IF;
    
    -- Проверяем, что проживание завершено
    IF v_booking_status != 'completed' THEN
        RAISE EXCEPTION 'Отзыв можно оставить только после завершения проживания';
    END IF;
    
    -- Проверяем, что отзыв еще не был оставлен
    IF EXISTS (SELECT 1 FROM reviews WHERE booking_id = NEW.booking_id AND review_id != COALESCE(NEW.review_id, 0)) THEN
        RAISE EXCEPTION 'Отзыв на это бронирование уже существует';
    END IF;
    
    -- Устанавливаем дату отзыва
    IF NEW.review_date IS NULL THEN
        NEW.review_date := CURRENT_TIMESTAMP;
    END IF;
    
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: amenities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.amenities (
    amenity_id integer NOT NULL,
    amenity_name character varying(255)
);


--
-- Name: amenities_amenity_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.amenities_amenity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: amenities_amenity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.amenities_amenity_id_seq OWNED BY public.amenities.amenity_id;


--
-- Name: bookings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookings (
    booking_id integer NOT NULL,
    room_id integer,
    check_in_date date,
    check_out_date date,
    booking_date timestamp without time zone,
    total_price numeric(10,2),
    status character varying(20),
    user_id integer
);


--
-- Name: TABLE bookings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.bookings IS 'Бронирования номеров (user_id → users)';


--
-- Name: COLUMN bookings.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.bookings.user_id IS 'Пользователь из новой системы аутентификации';


--
-- Name: bookings_booking_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookings_booking_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookings_booking_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookings_booking_id_seq OWNED BY public.bookings.booking_id;


--
-- Name: hotels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hotels (
    hotel_id integer NOT NULL,
    name character varying(255),
    address character varying(500),
    city character varying(100),
    country character varying(100),
    phone character varying(20),
    email character varying(255),
    star_rating numeric(2,1),
    description text,
    admin_id integer,
    is_active boolean DEFAULT true
);


--
-- Name: COLUMN hotels.admin_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.hotels.admin_id IS 'Администратор отеля из таблицы users';


--
-- Name: hotels_hotel_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hotels_hotel_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hotels_hotel_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hotels_hotel_id_seq OWNED BY public.hotels.hotel_id;


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reviews (
    review_id integer NOT NULL,
    booking_id integer,
    rating integer,
    comment text,
    review_date timestamp without time zone
);


--
-- Name: TABLE reviews; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.reviews IS 'Отзывы гостей (hotel_id получается через bookings)';


--
-- Name: reviews_review_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reviews_review_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reviews_review_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reviews_review_id_seq OWNED BY public.reviews.review_id;


--
-- Name: room_amenities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_amenities (
    room_amenity_id integer NOT NULL,
    room_id integer,
    amenity_id integer
);


--
-- Name: room_amenities_room_amenity_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.room_amenities_room_amenity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: room_amenities_room_amenity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.room_amenities_room_amenity_id_seq OWNED BY public.room_amenities.room_amenity_id;


--
-- Name: rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rooms (
    room_id integer NOT NULL,
    hotel_id integer,
    roomtype_id integer,
    room_number character varying(10),
    floor integer,
    is_available boolean DEFAULT true
);


--
-- Name: rooms_room_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rooms_room_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rooms_room_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rooms_room_id_seq OWNED BY public.rooms.room_id;


--
-- Name: roomtypes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roomtypes (
    roomtype_id integer NOT NULL,
    type_name character varying(100),
    description text,
    price_per_night numeric(10,2)
);


--
-- Name: roomtypes_roomtype_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roomtypes_roomtype_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roomtypes_roomtype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roomtypes_roomtype_id_seq OWNED BY public.roomtypes.roomtype_id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    phone character varying(20),
    role public.user_role DEFAULT 'guest'::public.user_role NOT NULL,
    is_active boolean DEFAULT true,
    hotel_id integer,
    CONSTRAINT email_format CHECK (((email)::text ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text))
);


--
-- Name: TABLE users; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.users IS 'Пользователи системы (гости, админы отелей, системные админы)';


--
-- Name: COLUMN users.password_hash; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.password_hash IS 'Bcrypt hash пароля (НЕ хранится в открытом виде!)';


--
-- Name: COLUMN users.role; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.role IS 'Роль пользователя: guest, hotel_admin, system_admin';


--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: v_active_bookings; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_active_bookings AS
 SELECT b.booking_id,
    b.user_id,
    (((u.first_name)::text || ' '::text) || (u.last_name)::text) AS guest_name,
    b.room_id,
    r.room_number,
    h.name AS hotel_name,
    b.check_in_date,
    b.check_out_date,
    b.total_price,
    b.status
   FROM (((public.bookings b
     JOIN public.users u ON ((b.user_id = u.user_id)))
     JOIN public.rooms r ON ((b.room_id = r.room_id)))
     JOIN public.hotels h ON ((r.hotel_id = h.hotel_id)))
  WHERE ((b.status)::text = ANY ((ARRAY['confirmed'::character varying, 'checked_in'::character varying])::text[]));


--
-- Name: v_available_rooms_today; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_available_rooms_today AS
 SELECT room_id,
    hotel_id,
    hotel_name,
    roomtype_id,
    type_name,
    room_number,
    floor,
    price_per_night,
    is_available
   FROM public.get_available_rooms(CURRENT_DATE, ((CURRENT_DATE + '1 day'::interval))::date, NULL::integer) get_available_rooms(room_id, hotel_id, hotel_name, roomtype_id, type_name, room_number, floor, price_per_night, is_available);


--
-- Name: v_current_stays; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_current_stays AS
 SELECT b.booking_id,
    (((u.first_name)::text || ' '::text) || (u.last_name)::text) AS guest_name,
    u.email AS guest_email,
    h.name AS hotel_name,
    r.room_number,
    b.check_in_date,
    b.check_out_date,
    (CURRENT_DATE - b.check_in_date) AS days_stayed,
    (b.check_out_date - CURRENT_DATE) AS days_remaining,
    b.total_price
   FROM (((public.bookings b
     JOIN public.users u ON ((b.user_id = u.user_id)))
     JOIN public.rooms r ON ((b.room_id = r.room_id)))
     JOIN public.hotels h ON ((r.hotel_id = h.hotel_id)))
  WHERE (((b.status)::text = 'confirmed'::text) AND (b.check_in_date <= CURRENT_DATE) AND (b.check_out_date > CURRENT_DATE));


--
-- Name: VIEW v_current_stays; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.v_current_stays IS 'Текущие проживающие гости';


--
-- Name: v_hotel_statistics; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_hotel_statistics AS
 SELECT h.hotel_id,
    h.name AS hotel_name,
    h.city,
    h.star_rating,
    count(DISTINCT r.room_id) AS total_rooms,
    count(DISTINCT
        CASE
            WHEN r.is_available THEN r.room_id
            ELSE NULL::integer
        END) AS available_rooms,
    count(DISTINCT b.booking_id) AS total_bookings,
    count(DISTINCT
        CASE
            WHEN ((b.status)::text = 'confirmed'::text) THEN b.booking_id
            ELSE NULL::integer
        END) AS confirmed_bookings,
    count(DISTINCT
        CASE
            WHEN ((b.status)::text = 'cancelled'::text) THEN b.booking_id
            ELSE NULL::integer
        END) AS cancelled_bookings,
    COALESCE(sum(
        CASE
            WHEN ((b.status)::text <> 'cancelled'::text) THEN b.total_price
            ELSE NULL::numeric
        END), (0)::numeric) AS total_revenue,
    COALESCE(round(avg(rev.rating), 2), (0)::numeric) AS average_rating,
    count(DISTINCT rev.review_id) AS reviews_count
   FROM (((public.hotels h
     LEFT JOIN public.rooms r ON ((h.hotel_id = r.hotel_id)))
     LEFT JOIN public.bookings b ON ((r.room_id = b.room_id)))
     LEFT JOIN public.reviews rev ON ((b.booking_id = rev.booking_id)))
  GROUP BY h.hotel_id, h.name, h.city, h.star_rating;


--
-- Name: VIEW v_hotel_statistics; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.v_hotel_statistics IS 'Статистика по отелям: номера, бронирования, доход, рейтинг';


--
-- Name: v_rooms_full; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_rooms_full AS
 SELECT r.room_id,
    r.hotel_id,
    h.name AS hotel_name,
    h.city,
    r.roomtype_id,
    rt.type_name,
    rt.description AS room_description,
    r.room_number,
    r.floor,
    rt.price_per_night,
    r.is_available
   FROM ((public.rooms r
     JOIN public.hotels h ON ((r.hotel_id = h.hotel_id)))
     JOIN public.roomtypes rt ON ((r.roomtype_id = rt.roomtype_id)));


--
-- Name: v_users_info; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_users_info AS
 SELECT u.user_id,
    u.email,
    u.first_name,
    u.last_name,
    u.phone,
    u.role,
    u.hotel_id,
    h.name AS hotel_name
   FROM (public.users u
     LEFT JOIN public.hotels h ON ((u.hotel_id = h.hotel_id)));


--
-- Name: amenities amenity_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.amenities ALTER COLUMN amenity_id SET DEFAULT nextval('public.amenities_amenity_id_seq'::regclass);


--
-- Name: bookings booking_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings ALTER COLUMN booking_id SET DEFAULT nextval('public.bookings_booking_id_seq'::regclass);


--
-- Name: hotels hotel_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hotels ALTER COLUMN hotel_id SET DEFAULT nextval('public.hotels_hotel_id_seq'::regclass);


--
-- Name: reviews review_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews ALTER COLUMN review_id SET DEFAULT nextval('public.reviews_review_id_seq'::regclass);


--
-- Name: room_amenities room_amenity_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_amenities ALTER COLUMN room_amenity_id SET DEFAULT nextval('public.room_amenities_room_amenity_id_seq'::regclass);


--
-- Name: rooms room_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms ALTER COLUMN room_id SET DEFAULT nextval('public.rooms_room_id_seq'::regclass);


--
-- Name: roomtypes roomtype_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roomtypes ALTER COLUMN roomtype_id SET DEFAULT nextval('public.roomtypes_roomtype_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Name: amenities amenities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.amenities
    ADD CONSTRAINT amenities_pkey PRIMARY KEY (amenity_id);


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (booking_id);


--
-- Name: hotels hotels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hotels
    ADD CONSTRAINT hotels_pkey PRIMARY KEY (hotel_id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (review_id);


--
-- Name: room_amenities room_amenities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_amenities
    ADD CONSTRAINT room_amenities_pkey PRIMARY KEY (room_amenity_id);


--
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (room_id);


--
-- Name: roomtypes roomtypes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roomtypes
    ADD CONSTRAINT roomtypes_pkey PRIMARY KEY (roomtype_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: idx_hotels_admin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_hotels_admin ON public.hotels USING btree (admin_id);


--
-- Name: idx_rooms_available; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rooms_available ON public.rooms USING btree (is_available);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: idx_users_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_role ON public.users USING btree (role);


--
-- Name: bookings calculate_booking_price; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER calculate_booking_price BEFORE INSERT OR UPDATE OF room_id, check_in_date, check_out_date ON public.bookings FOR EACH ROW EXECUTE FUNCTION public.calculate_total_price_trigger();


--
-- Name: TRIGGER calculate_booking_price ON bookings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER calculate_booking_price ON public.bookings IS 'Автоматически рассчитывает total_price на основе цены номера и количества ночей';


--
-- Name: bookings check_room_before_booking; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER check_room_before_booking BEFORE INSERT OR UPDATE OF room_id, check_in_date, check_out_date ON public.bookings FOR EACH ROW EXECUTE FUNCTION public.check_booking_availability();


--
-- Name: TRIGGER check_room_before_booking ON bookings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER check_room_before_booking ON public.bookings IS 'Проверяет доступность номера в указанный период перед созданием/обновлением бронирования';


--
-- Name: reviews validate_review; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER validate_review BEFORE INSERT ON public.reviews FOR EACH ROW EXECUTE FUNCTION public.validate_review_rights();


--
-- Name: TRIGGER validate_review ON reviews; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER validate_review ON public.reviews IS 'Проверяет права пользователя на добавление отзыва';


--
-- Name: bookings bookings_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(room_id);


--
-- Name: bookings bookings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: hotels hotels_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hotels
    ADD CONSTRAINT hotels_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.users(user_id) ON DELETE SET NULL;


--
-- Name: reviews reviews_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(booking_id);


--
-- Name: room_amenities room_amenities_amenity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_amenities
    ADD CONSTRAINT room_amenities_amenity_id_fkey FOREIGN KEY (amenity_id) REFERENCES public.amenities(amenity_id);


--
-- Name: room_amenities room_amenities_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_amenities
    ADD CONSTRAINT room_amenities_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(room_id);


--
-- Name: rooms rooms_hotel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_hotel_id_fkey FOREIGN KEY (hotel_id) REFERENCES public.hotels(hotel_id);


--
-- Name: rooms rooms_roomtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_roomtype_id_fkey FOREIGN KEY (roomtype_id) REFERENCES public.roomtypes(roomtype_id);


--
-- Name: users users_hotel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_hotel_id_fkey FOREIGN KEY (hotel_id) REFERENCES public.hotels(hotel_id);


--
-- PostgreSQL database dump complete
--

\unrestrict 6H7w1F7l55sccaDAkd87M7M19VL8ipk45E8EVnFuLHmodekZfcLHm4xccG4zVKQ

