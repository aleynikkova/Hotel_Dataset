
\restrict 6H7w1F7l55sccaDAkd87M7M19VL8ipk45E8EVnFuLHmodekZfcLHm4xccG4zVKQ


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

CREATE TYPE public.user_role AS ENUM (
    'guest',
    'hotel_admin',
    'system_admin'
);


CREATE FUNCTION public.calculate_booking_price(p_room_id integer, p_check_in date, p_check_out date) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_price_per_night DECIMAL(10, 2);
    v_nights INTEGER;
    v_total DECIMAL(10, 2);
BEGIN
    --получаем цену за ночь из roomtypes (3NF compliance)
    SELECT rt.price_per_night INTO v_price_per_night
    FROM rooms r
    JOIN roomtypes rt ON r.roomtype_id = rt.roomtype_id
    WHERE r.room_id = p_room_id;
    
    IF v_price_per_night IS NULL THEN
        RAISE EXCEPTION 'Номер с ID % не найден', p_room_id;
    END IF;
    
    --вычисляем количество ночей
    v_nights := p_check_out - p_check_in;
    
    IF v_nights <= 0 THEN
        RAISE EXCEPTION 'Дата выезда должна быть позже даты заезда';
    END IF;
    
    --рассчитываем общую стоимость
    v_total := v_price_per_night * v_nights;
    
    RETURN v_total;
END;
$$;


CREATE FUNCTION public.calculate_total_price_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_price_per_night DECIMAL(10, 2);
    v_nights INTEGER;
BEGIN
    SELECT rt.price_per_night INTO v_price_per_night
    FROM rooms r
    JOIN roomtypes rt ON r.roomtype_id = rt.roomtype_id
    WHERE r.room_id = NEW.room_id;
    
    v_nights := NEW.check_out_date - NEW.check_in_date;
    
    IF v_nights <= 0 THEN
        RAISE EXCEPTION 'Дата выезда должна быть позже даты заезда';
    END IF;
    
    NEW.total_price := v_price_per_night * v_nights;
    
    RETURN NEW;
END;
$$;

CREATE PROCEDURE public.cancel_expired_bookings()
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_cancelled_count INTEGER;
BEGIN
    -- Отменяем бронирования со статусом pending, у которых дата заезда прошла
    UPDATE bookings
    SET status = 'cancelled'
    WHERE status = 'pending'
        AND check_in_date < CURRENT_DATE;
    
    GET DIAGNOSTICS v_cancelled_count = ROW_COUNT;
    
    RAISE NOTICE 'Отменено % просроченных бронирований', v_cancelled_count;
END;
$$;


CREATE FUNCTION public.check_booking_availability() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_conflict_count INTEGER;
BEGIN
    --проверяем пересечения с существующими бронированиями
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
    
    --проверяем, что номер доступен
    IF NOT EXISTS (SELECT 1 FROM rooms WHERE room_id = NEW.room_id AND is_available = TRUE) THEN
        RAISE EXCEPTION 'Номер недоступен для бронирования';
    END IF;
    
    RETURN NEW;
END;
$$;



CREATE FUNCTION public.check_room_availability(p_room_id integer, p_check_in date, p_check_out date, p_exclude_booking_id integer DEFAULT NULL::integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_conflict_count INTEGER;
BEGIN
    --проверяем, нет ли пересечений с существующими бронированиями
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


CREATE FUNCTION public.get_hotel_average_rating(p_hotel_id integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_avg_rating DECIMAL(3, 2);
BEGIN
    SELECT COALESCE(ROUND(AVG(rev.rating)::numeric, 2), 0)
    INTO v_avg_rating
    FROM reviews rev
    JOIN bookings b ON rev.booking_id = b.booking_id
    JOIN rooms r ON b.room_id = r.room_id
    WHERE r.hotel_id = p_hotel_id;
    
    RETURN v_avg_rating;
END;
$$;


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


CREATE FUNCTION public.set_booking_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.booking_date IS NULL THEN
        NEW.booking_date := CURRENT_TIMESTAMP;
    END IF;
    
    RETURN NEW;
END;
$$;


CREATE FUNCTION public.validate_review_rights() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_booking_user_id INTEGER;
    v_booking_status VARCHAR(20);
BEGIN
    --получаем user_id и статус бронирования
    SELECT user_id, status INTO v_booking_user_id, v_booking_status
    FROM bookings
    WHERE booking_id = NEW.booking_id;
    
    --проверка что бронирование существует
    IF v_booking_user_id IS NULL THEN
        RAISE EXCEPTION 'Бронирование не найдено';
    END IF;
    
    --проверяем, что проживание завершено
    IF v_booking_status != 'completed' THEN
        RAISE EXCEPTION 'Отзыв можно оставить только после завершения проживания';
    END IF;
    
    --проверяем, что отзыв еще не был оставлен
    IF EXISTS (SELECT 1 FROM reviews WHERE booking_id = NEW.booking_id AND review_id != COALESCE(NEW.review_id, 0)) THEN
        RAISE EXCEPTION 'Отзыв на это бронирование уже существует';
    END IF;
    
    --устанавливаем дату отзыва
    IF NEW.review_date IS NULL THEN
        NEW.review_date := CURRENT_TIMESTAMP;
    END IF;
    
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;


CREATE TABLE public.amenities (
    amenity_id integer NOT NULL,
    amenity_name character varying(255)
);


CREATE SEQUENCE public.amenities_amenity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.amenities_amenity_id_seq OWNED BY public.amenities.amenity_id;


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


COMMENT ON TABLE public.bookings IS 'Бронирования номеров (user_id → users)';


COMMENT ON COLUMN public.bookings.user_id IS 'Пользователь из новой системы аутентификации';


CREATE SEQUENCE public.bookings_booking_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bookings_booking_id_seq OWNED BY public.bookings.booking_id;


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


CREATE SEQUENCE public.hotels_hotel_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hotels_hotel_id_seq OWNED BY public.hotels.hotel_id;


CREATE TABLE public.reviews (
    review_id integer NOT NULL,
    booking_id integer,
    rating integer,
    comment text,
    review_date timestamp without time zone
);


CREATE SEQUENCE public.reviews_review_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reviews_review_id_seq OWNED BY public.reviews.review_id;


CREATE TABLE public.room_amenities (
    room_amenity_id integer NOT NULL,
    room_id integer,
    amenity_id integer
);


CREATE SEQUENCE public.room_amenities_room_amenity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.room_amenities_room_amenity_id_seq OWNED BY public.room_amenities.room_amenity_id;


CREATE TABLE public.rooms (
    room_id integer NOT NULL,
    hotel_id integer,
    roomtype_id integer,
    room_number character varying(10),
    floor integer,
    is_available boolean DEFAULT true
);


CREATE SEQUENCE public.rooms_room_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rooms_room_id_seq OWNED BY public.rooms.room_id;


CREATE TABLE public.roomtypes (
    roomtype_id integer NOT NULL,
    type_name character varying(100),
    description text,
    price_per_night numeric(10,2)
);


CREATE SEQUENCE public.roomtypes_roomtype_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roomtypes_roomtype_id_seq OWNED BY public.roomtypes.roomtype_id;


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


CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


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

ALTER TABLE ONLY public.amenities ALTER COLUMN amenity_id SET DEFAULT nextval('public.amenities_amenity_id_seq'::regclass);


ALTER TABLE ONLY public.bookings ALTER COLUMN booking_id SET DEFAULT nextval('public.bookings_booking_id_seq'::regclass);


ALTER TABLE ONLY public.hotels ALTER COLUMN hotel_id SET DEFAULT nextval('public.hotels_hotel_id_seq'::regclass);


ALTER TABLE ONLY public.reviews ALTER COLUMN review_id SET DEFAULT nextval('public.reviews_review_id_seq'::regclass);


ALTER TABLE ONLY public.room_amenities ALTER COLUMN room_amenity_id SET DEFAULT nextval('public.room_amenities_room_amenity_id_seq'::regclass);


ALTER TABLE ONLY public.rooms ALTER COLUMN room_id SET DEFAULT nextval('public.rooms_room_id_seq'::regclass);


ALTER TABLE ONLY public.roomtypes ALTER COLUMN roomtype_id SET DEFAULT nextval('public.roomtypes_roomtype_id_seq'::regclass);


ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


ALTER TABLE ONLY public.amenities
    ADD CONSTRAINT amenities_pkey PRIMARY KEY (amenity_id);


ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (booking_id);


ALTER TABLE ONLY public.hotels
    ADD CONSTRAINT hotels_pkey PRIMARY KEY (hotel_id);


ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (review_id);


ALTER TABLE ONLY public.room_amenities
    ADD CONSTRAINT room_amenities_pkey PRIMARY KEY (room_amenity_id);


ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (room_id);


ALTER TABLE ONLY public.roomtypes
    ADD CONSTRAINT roomtypes_pkey PRIMARY KEY (roomtype_id);


ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


CREATE INDEX idx_hotels_admin ON public.hotels USING btree (admin_id);


CREATE INDEX idx_rooms_available ON public.rooms USING btree (is_available);


CREATE INDEX idx_users_email ON public.users USING btree (email);


CREATE INDEX idx_users_role ON public.users USING btree (role);


CREATE TRIGGER calculate_booking_price BEFORE INSERT OR UPDATE OF room_id, check_in_date, check_out_date ON public.bookings FOR EACH ROW EXECUTE FUNCTION public.calculate_total_price_trigger();


COMMENT ON TRIGGER calculate_booking_price ON public.bookings IS 'Автоматически рассчитывает total_price на основе цены номера и количества ночей';


CREATE TRIGGER check_room_before_booking BEFORE INSERT OR UPDATE OF room_id, check_in_date, check_out_date ON public.bookings FOR EACH ROW EXECUTE FUNCTION public.check_booking_availability();

COMMENT ON TRIGGER check_room_before_booking ON public.bookings IS 'Проверяет доступность номера в указанный период перед созданием/обновлением бронирования';


CREATE TRIGGER validate_review BEFORE INSERT ON public.reviews FOR EACH ROW EXECUTE FUNCTION public.validate_review_rights();


COMMENT ON TRIGGER validate_review ON public.reviews IS 'Проверяет права пользователя на добавление отзыва';


ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(room_id);

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


ALTER TABLE ONLY public.hotels
    ADD CONSTRAINT hotels_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.users(user_id) ON DELETE SET NULL;


ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(booking_id);


ALTER TABLE ONLY public.room_amenities
    ADD CONSTRAINT room_amenities_amenity_id_fkey FOREIGN KEY (amenity_id) REFERENCES public.amenities(amenity_id);


ALTER TABLE ONLY public.room_amenities
    ADD CONSTRAINT room_amenities_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(room_id);


ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_hotel_id_fkey FOREIGN KEY (hotel_id) REFERENCES public.hotels(hotel_id);

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_roomtype_id_fkey FOREIGN KEY (roomtype_id) REFERENCES public.roomtypes(roomtype_id);


ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_hotel_id_fkey FOREIGN KEY (hotel_id) REFERENCES public.hotels(hotel_id);


\unrestrict 6H7w1F7l55sccaDAkd87M7M19VL8ipk45E8EVnFuLHmodekZfcLHm4xccG4zVKQ

