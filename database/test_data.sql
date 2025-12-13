--
-- PostgreSQL database dump
--

\restrict li1A34HhGIXplYxkbZubFf3P0B1cSKf84S08cY32Qqn1WNnOQTONYrNfxi2s8il

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
-- Data for Name: amenities; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.amenities VALUES (1, 'Бесплатный Wi-Fi');
INSERT INTO public.amenities VALUES (2, 'Кондиционер');
INSERT INTO public.amenities VALUES (3, 'Телевизор с кабельными каналами');
INSERT INTO public.amenities VALUES (4, 'Мини-бар');
INSERT INTO public.amenities VALUES (5, 'Сейф');
INSERT INTO public.amenities VALUES (6, 'Фен');
INSERT INTO public.amenities VALUES (7, 'Халаты и тапочки');
INSERT INTO public.amenities VALUES (8, 'Кофемашина');
INSERT INTO public.amenities VALUES (9, 'Вид на море');
INSERT INTO public.amenities VALUES (10, 'Вид на горы');
INSERT INTO public.amenities VALUES (11, 'Балкон');
INSERT INTO public.amenities VALUES (12, 'Джакузи');
INSERT INTO public.amenities VALUES (13, 'Бассейн');
INSERT INTO public.amenities VALUES (14, 'Спа-услуги');
INSERT INTO public.amenities VALUES (15, 'Завтрак включен');
INSERT INTO public.amenities VALUES (16, 'Smart TV');


--
-- Data for Name: hotels; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.hotels VALUES (6, 'River Side', 'ул. Баумана, 30', 'Казань', 'Россия', '+7-843-666-7788', 'booking@riverside.ru', 4.0, 'Отель с видом на реку', NULL, true);
INSERT INTO public.hotels VALUES (7, 'Historic Manor', 'ул. Великая, 5', 'Великий Новгород', 'Россия', '+7-816-777-8899', 'manor@history.ru', 3.0, 'Отель в историческом здании', NULL, true);
INSERT INTO public.hotels VALUES (8, 'Spa Paradise', 'ул. Курортная, 20', 'Анапа', 'Россия', '+7-861-888-9900', 'spa@paradise.ru', 4.0, 'Спа-отель с лечебными программами', NULL, true);
INSERT INTO public.hotels VALUES (10, 'Airport Hotel', 'ул. Авиационная, 10', 'Калининград', 'Россия', '+7-401-111-2233', 'airport@hotel.ru', 3.0, 'Удобный отель рядом с аэропортом', NULL, true);
INSERT INTO public.hotels VALUES (11, 'Winter Palace', 'Дворцовая наб., 38', 'Санкт-Петербург', 'Россия', '+7-812-222-3344', 'winter@palace.ru', 5.0, 'Элитный отель с видом на Эрмитаж', NULL, true);
INSERT INTO public.hotels VALUES (12, 'Golden Ring', 'ул. Свободы, 45', 'Ярославль', 'Россия', '+7-485-333-4455', 'golden@ring.ru', 3.0, 'Отель в Золотом кольце России', NULL, true);
INSERT INTO public.hotels VALUES (13, 'Forest Retreat', 'ул. Лесная, 8', 'Кострома', 'Россия', '+7-494-444-5566', 'forest@retreat.ru', 4.0, 'Эко-отель в сосновом бору', NULL, true);
INSERT INTO public.hotels VALUES (14, 'Lakeside Resort', 'ул. Озерная, 12', 'Петрозаводск', 'Россия', '+7-814-555-6677', 'lakeside@resort.ru', 4.0, 'Курорт на берегу озера', NULL, true);
INSERT INTO public.hotels VALUES (15, 'Metropol', 'Театральный пр-д, 1', 'Москва', 'Россия', '+7-495-666-7788', 'info@metropol.ru', 5.0, 'Легендарный отель с богатой историей', NULL, true);
INSERT INTO public.hotels VALUES (4, 'Mountain Lodge', 'ул. Горная, 15', 'Красная Поляна', 'Россия', '+7-862-444-5566', 'lodge@mountain.ru', 4.0, 'Горный отель у подъемников', 22, true);
INSERT INTO public.hotels VALUES (31, 'Нева Палас', 'Невский проспект, д. 120', 'Санкт-Петербург', 'Россия', '+7-812-345-67-89', 'booking@nevapalace.ru', 5.0, 'Исторический отель на главной улице Санкт-Петербурга. Из окон открывается вид на Казанский собор.', NULL, true);
INSERT INTO public.hotels VALUES (1, 'Отель Премиум Москва', 'ул. Тверская, д. 10', 'Москва', 'Россия', '+7-495-111-2233', 'info@grandhotel.ru', 5.0, 'Роскошный пятизвездочный отель в центре Москвы', NULL, true);
INSERT INTO public.hotels VALUES (2, 'Hotel Plaza', 'ул. Арбат, 25', 'Москва', 'Россия', '+7-495-222-3344', 'book@plaza.ru', 4.0, 'Комфортабельный отель в историческом центре', 20, true);
INSERT INTO public.hotels VALUES (3, 'Sea View Resort', 'ул. Приморская, 50', 'Сочи', 'Россия', '+7-862-333-4455', 'resort@seaview.com', 4.5, 'Курортный комплекс с私人 пляжем', 21, true);
INSERT INTO public.hotels VALUES (32, 'Test Hotel API', 'Тестовая улица, 1', 'Москва', 'Россия', '+7-495-000-0000', 'test@testhotel.ru', 4.0, 'Тестовый отель', NULL, true);
INSERT INTO public.hotels VALUES (9, 'City Center', 'ул. Ленина, 76', 'Екатеринбург', 'Россия', '+7-343-999-0011', 'reception@citycenter.ru', 3.0, 'Отель в деловом центре города', NULL, true);
INSERT INTO public.hotels VALUES (34, 'крутой отель', 'Новая улица д. 7', 'Самара', 'Россия', '+77777777777', 'etopochta@mail.ru', 2.0, 'все у нас круто', NULL, true);
INSERT INTO public.hotels VALUES (5, 'Business Inn', 'Невский пр-т, 101', 'Санкт-Петербург', 'Россия', '+7-812-555-6677', 'info@businessinn.spb.ru', 3.0, 'Отель для деловых поездок', NULL, true);
INSERT INTO public.hotels VALUES (35, 'отельчик', 'отельная улица 7', 'Екатеринбург', 'Россия', '+7823947104', 'hotel@list.ru', 5.0, 'very good', NULL, true);


--
-- Data for Name: roomtypes; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.roomtypes VALUES (1, 'Эконом одноместный', 'Небольшой уютный номер с одной кроватью', 2500.00);
INSERT INTO public.roomtypes VALUES (2, 'Эконом двухместный', 'Номер с двумя отдельными кроватями', 3500.00);
INSERT INTO public.roomtypes VALUES (3, 'Стандарт одноместный', 'Комфортабельный номер с двуспальной кроватью', 4500.00);
INSERT INTO public.roomtypes VALUES (4, 'Стандарт двухместный', 'Просторный номер с двумя кроватями', 5500.00);
INSERT INTO public.roomtypes VALUES (6, 'Семейный номер', 'Большой номер с дополнительной детской кроватью', 6500.00);
INSERT INTO public.roomtypes VALUES (7, 'Люкс', 'Роскошный номер с гостиной зоной', 12000.00);
INSERT INTO public.roomtypes VALUES (8, 'Президентский люкс', 'Апартаменты высшего класса', 25000.00);
INSERT INTO public.roomtypes VALUES (9, 'Номер с видом на море', 'Номер с панорамным видом на море', 8500.00);
INSERT INTO public.roomtypes VALUES (10, 'Номер с балконом', 'Номер с собственным балконом', 6000.00);
INSERT INTO public.roomtypes VALUES (11, 'Джуниор сьют', 'Улучшенный номер с мини-кухней', 9500.00);
INSERT INTO public.roomtypes VALUES (12, 'Делюкс', 'Просторный номер повышенной комфортности', 8000.00);
INSERT INTO public.roomtypes VALUES (13, 'Апартаменты', 'Полноценные апартаменты с кухней', 15000.00);
INSERT INTO public.roomtypes VALUES (14, 'Студия', 'Номер с совмещенной гостиной и спальней', 5000.00);
INSERT INTO public.roomtypes VALUES (15, 'Хостел (место)', 'Койка в общем номере', 1500.00);
INSERT INTO public.roomtypes VALUES (5, 'Бизнес-класс', 'Номер для деловых поездок с рабочим столом', 400.00);


--
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.rooms VALUES (1, 1, 7, '101', 1, true);
INSERT INTO public.rooms VALUES (2, 1, 4, '102', 1, true);
INSERT INTO public.rooms VALUES (3, 1, 5, '201', 2, true);
INSERT INTO public.rooms VALUES (4, 1, 6, '202', 2, true);
INSERT INTO public.rooms VALUES (5, 2, 8, '301', 3, true);
INSERT INTO public.rooms VALUES (6, 2, 5, '302', 3, true);
INSERT INTO public.rooms VALUES (7, 2, 3, '401', 4, true);
INSERT INTO public.rooms VALUES (8, 3, 9, '101', 1, true);
INSERT INTO public.rooms VALUES (9, 3, 9, '102', 1, true);
INSERT INTO public.rooms VALUES (10, 3, 6, '201', 2, true);
INSERT INTO public.rooms VALUES (11, 3, 7, '202', 2, true);
INSERT INTO public.rooms VALUES (12, 4, 10, '101', 1, true);
INSERT INTO public.rooms VALUES (13, 4, 6, '102', 1, true);
INSERT INTO public.rooms VALUES (14, 4, 4, '201', 2, true);
INSERT INTO public.rooms VALUES (15, 5, 5, '101', 1, true);
INSERT INTO public.rooms VALUES (16, 5, 5, '102', 1, true);
INSERT INTO public.rooms VALUES (17, 5, 3, '201', 2, true);
INSERT INTO public.rooms VALUES (18, 6, 4, '101', 1, true);
INSERT INTO public.rooms VALUES (19, 7, 7, '201', 2, true);
INSERT INTO public.rooms VALUES (20, 8, 12, '301', 3, true);
INSERT INTO public.rooms VALUES (22, 10, 3, '201', 2, true);
INSERT INTO public.rooms VALUES (23, 11, 8, '101', 1, true);
INSERT INTO public.rooms VALUES (24, 12, 4, '201', 2, true);
INSERT INTO public.rooms VALUES (25, 13, 6, '101', 1, true);
INSERT INTO public.rooms VALUES (26, 14, 9, '201', 2, true);
INSERT INTO public.rooms VALUES (27, 15, 5, '301', 3, true);
INSERT INTO public.rooms VALUES (28, 7, 1, '28', 2, true);
INSERT INTO public.rooms VALUES (29, 5, 9, '37', 3, true);
INSERT INTO public.rooms VALUES (30, 5, 9, '48', 4, true);
INSERT INTO public.rooms VALUES (33, 5, 12, '221', 1, true);
INSERT INTO public.rooms VALUES (31, 5, 6, '30', 1, true);
INSERT INTO public.rooms VALUES (34, 5, 1, 'TEST101', 1, true);
INSERT INTO public.rooms VALUES (35, 5, 1, 'TEST101', 1, true);
INSERT INTO public.rooms VALUES (21, 9, 2, '101', 2, true);
INSERT INTO public.rooms VALUES (38, 5, 11, '78', 5, true);
INSERT INTO public.rooms VALUES (32, 5, 15, '30', 2, true);
INSERT INTO public.rooms VALUES (39, 35, 7, '777', 3, true);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.users VALUES (22, 'admin.mountain@hotel.ru', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5oDhGx0JqHX3O', 'Менеджер', 'Маунтин', '+7-862-444-5566', 'hotel_admin', true, NULL);
INSERT INTO public.users VALUES (24, 'nastya.yes@list.ru', '$2b$12$G9IeBnQxBcFeNoPBejqjd.a1xOw4edj7GpPlz91/geo9YDpA4zfcG', 'Анастасия', 'Алейникова', '+79856967202', 'hotel_admin', true, 4);
INSERT INTO public.users VALUES (26, 'dimukhametovan@mail.ru', '$2b$12$YeOEqtKA3q4me4YX80ITxuX0Gou7ndywqCVX/3ZsuP47hpzWBjDFC', 'Анастасия', 'Димухаметова', '+79165137042', 'hotel_admin', true, 35);
INSERT INTO public.users VALUES (20, 'admin.plaza@hotel.ru', '$2b$12$hRpqH8zRltrIyIgIOIObx.FIWpCfphNoMV81SV/NP38mkNGssz1da', 'Менеджер', 'Плаза', '+7-495-222-3344', 'hotel_admin', true, 2);
INSERT INTO public.users VALUES (25, 'test.guest@test.ru', '$2b$12$Uy2rBN9qvtYeHDd1LZOA/Ov4MQ3e1oxPv.IupYiHjPbkLlPeLapHS', 'Тест', 'Гость', '+79001112233', 'guest', true, NULL);
INSERT INTO public.users VALUES (5, 'dmitry.vasilev@gmail.com', '$2b$12$G.wbPq1UFA4oraSoaWrnMu0VNf1azj1e0Bp09Dkv1HFOkSuXh8LMG', 'Дмитрий', 'Васильев', '+79165555555', 'guest', true, NULL);
INSERT INTO public.users VALUES (23, 'hotel_admin@hotel.com', '$2b$12$ZfEHR0N171uXThZM1/jhzu483EY0I4BqrwdnPz3V1t2aCnwpk8aZ6', 'Менеджер', 'Business', NULL, 'hotel_admin', true, 5);
INSERT INTO public.users VALUES (19, 'admin@hotel.com', '$2b$12$vLdCLbvohnRcNst2ee0Q6O6cOmpEHv0TL6c431o7HDyg/NBReml2W', 'Системный', 'Администратор', NULL, 'system_admin', true, NULL);
INSERT INTO public.users VALUES (21, 'admin.seaview@hotel.ru', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5oDhGx0JqHX3O', 'Менеджер', 'Сивью', '+7-862-333-4455', 'hotel_admin', true, 14);
INSERT INTO public.users VALUES (1, 'ivan.petrov@mail.ru', '$2b$12$f6iHODGIzW3UZUtMUvixkeHVSnjo.w/hLU7LZd2j8HPCyu3pTL1Sq', 'Иван', 'Петров', '+79161111111', 'guest', true, NULL);
INSERT INTO public.users VALUES (2, 'maria.sidorova@gmail.com', '$2b$12$f6iHODGIzW3UZUtMUvixkeHVSnjo.w/hLU7LZd2j8HPCyu3pTL1Sq', 'Мария', 'Сидорова', '+79162222222', 'guest', true, NULL);
INSERT INTO public.users VALUES (3, 'alex.kozlov@yandex.ru', '$2b$12$f6iHODGIzW3UZUtMUvixkeHVSnjo.w/hLU7LZd2j8HPCyu3pTL1Sq', 'Алексей', 'Козлов', '+79163333333', 'guest', true, NULL);
INSERT INTO public.users VALUES (4, 'elena.nikolaeva@mail.ru', '$2b$12$f6iHODGIzW3UZUtMUvixkeHVSnjo.w/hLU7LZd2j8HPCyu3pTL1Sq', 'Елена', 'Николаева', '+79164444444', 'guest', true, NULL);
INSERT INTO public.users VALUES (6, 'olga.pavlova@yandex.ru', '$2b$12$f6iHODGIzW3UZUtMUvixkeHVSnjo.w/hLU7LZd2j8HPCyu3pTL1Sq', 'Ольга', 'Павлова', '+79166666666', 'guest', true, NULL);
INSERT INTO public.users VALUES (7, 'sergey.morozov@mail.ru', '$2b$12$f6iHODGIzW3UZUtMUvixkeHVSnjo.w/hLU7LZd2j8HPCyu3pTL1Sq', 'Сергей', 'Морозов', '+79167777777', 'guest', true, NULL);
INSERT INTO public.users VALUES (8, 'anna.volkova@gmail.com', '$2b$12$f6iHODGIzW3UZUtMUvixkeHVSnjo.w/hLU7LZd2j8HPCyu3pTL1Sq', 'Анна', 'Волкова', '+79168888888', 'guest', true, NULL);
INSERT INTO public.users VALUES (9, 'pavel.semenov@yandex.ru', '$2b$12$f6iHODGIzW3UZUtMUvixkeHVSnjo.w/hLU7LZd2j8HPCyu3pTL1Sq', 'Павел', 'Семенов', '+79169999999', 'guest', true, NULL);
INSERT INTO public.users VALUES (10, 'yulia.lebedeva@mail.ru', '$2b$12$f6iHODGIzW3UZUtMUvixkeHVSnjo.w/hLU7LZd2j8HPCyu3pTL1Sq', 'Юлия', 'Лебедева', '+79161010101', 'guest', true, NULL);
INSERT INTO public.users VALUES (11, 'artem.egorov@gmail.com', '$2b$12$f6iHODGIzW3UZUtMUvixkeHVSnjo.w/hLU7LZd2j8HPCyu3pTL1Sq', 'Артем', 'Егоров', '+79161111112', 'guest', true, NULL);
INSERT INTO public.users VALUES (12, 'natalia.kovaleva@yandex.ru', '$2b$12$f6iHODGIzW3UZUtMUvixkeHVSnjo.w/hLU7LZd2j8HPCyu3pTL1Sq', 'Наталья', 'Ковалева', '+79161111113', 'guest', true, NULL);
INSERT INTO public.users VALUES (13, 'mikhail.orlov@mail.ru', '$2b$12$f6iHODGIzW3UZUtMUvixkeHVSnjo.w/hLU7LZd2j8HPCyu3pTL1Sq', 'Михаил', 'Орлов', '+79161111114', 'guest', true, NULL);
INSERT INTO public.users VALUES (14, 'victoria.andreeva@gmail.com', '$2b$12$f6iHODGIzW3UZUtMUvixkeHVSnjo.w/hLU7LZd2j8HPCyu3pTL1Sq', 'Виктория', 'Андреева', '+79161111115', 'guest', true, NULL);
INSERT INTO public.users VALUES (15, 'andrey.sokolov@yandex.ru', '$2b$12$f6iHODGIzW3UZUtMUvixkeHVSnjo.w/hLU7LZd2j8HPCyu3pTL1Sq', 'Андрей', 'Соколов', '+79161111116', 'guest', true, NULL);
INSERT INTO public.users VALUES (16, 'anna@gmail.com', '$2b$12$f6iHODGIzW3UZUtMUvixkeHVSnjo.w/hLU7LZd2j8HPCyu3pTL1Sq', 'Анна', 'Иванова', '9661552352', 'guest', true, NULL);
INSERT INTO public.users VALUES (18, 'voron.alex@gmail.com', '$2b$12$f6iHODGIzW3UZUtMUvixkeHVSnjo.w/hLU7LZd2j8HPCyu3pTL1Sq', 'Александр', 'Воронежцев', '+79855523525', 'guest', true, NULL);


--
-- Data for Name: bookings; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.bookings VALUES (2, 2, '2024-01-10', '2024-01-12', '2024-01-01 14:30:00', 11000.00, 'completed', 2);
INSERT INTO public.bookings VALUES (3, 8, '2024-02-01', '2024-02-07', '2024-01-20 16:45:00', 51000.00, 'available', 3);
INSERT INTO public.bookings VALUES (4, 12, '2024-01-25', '2024-01-28', '2024-01-15 09:20:00', 18000.00, 'completed', 4);
INSERT INTO public.bookings VALUES (17, 13, '2024-01-13', '2024-01-17', '2025-12-11 00:17:00.595092', 9000.00, 'pending', 5);
INSERT INTO public.bookings VALUES (16, 7, '2024-03-01', '2024-03-03', '2025-11-29 14:46:44.286829', 15000.00, 'completed', 5);
INSERT INTO public.bookings VALUES (6, 9, '2024-02-14', '2024-02-16', '2024-02-01 13:40:00', 17000.00, 'cancelled', 6);
INSERT INTO public.bookings VALUES (7, 5, '2024-01-20', '2024-01-25', '2024-01-10 15:25:00', 125000.00, 'completed', 7);
INSERT INTO public.bookings VALUES (8, 6, '2024-02-05', '2024-02-10', '2024-01-25 12:10:00', 37500.00, 'confirmed', 8);
INSERT INTO public.bookings VALUES (9, 7, '2024-03-01', '2024-03-03', '2024-02-20 08:50:00', 9000.00, 'pending', 9);
INSERT INTO public.bookings VALUES (10, 10, '2024-01-30', '2024-02-05', '2024-01-18 17:35:00', 39000.00, 'occupied', 10);
INSERT INTO public.bookings VALUES (11, 11, '2024-02-20', '2024-02-25', '2024-02-10 14:20:00', 27500.00, 'confirmed', 11);
INSERT INTO public.bookings VALUES (12, 13, '2024-03-15', '2024-03-20', '2024-03-01 10:05:00', 22500.00, 'pending', 12);
INSERT INTO public.bookings VALUES (13, 14, '2024-01-18', '2024-01-22', '2024-01-08 19:15:00', 30000.00, 'completed', 13);
INSERT INTO public.bookings VALUES (18, 2, '2025-12-25', '2025-12-30', '2025-12-11 23:46:48.193384', 27500.00, 'confirmed', 1);
INSERT INTO public.bookings VALUES (1, 1, '2024-01-15', '2024-01-20', '2024-01-05 10:00:00', 60000.00, 'completed', 1);
INSERT INTO public.bookings VALUES (15, 16, '2024-03-05', '2024-03-08', '2024-02-25 11:55:00', 16500.00, 'completed', 15);
INSERT INTO public.bookings VALUES (14, 15, '2024-02-08', '2024-02-12', '2024-01-30 16:40:00', 20000.00, 'checked_in', 14);
INSERT INTO public.bookings VALUES (19, 15, '2025-12-14', '2025-12-16', '2025-12-12 18:58:46.432751', 800.00, 'cancelled', 24);
INSERT INTO public.bookings VALUES (20, 16, '2025-12-14', '2025-12-16', '2025-12-12 19:05:44.653857', 800.00, 'cancelled', 24);
INSERT INTO public.bookings VALUES (5, 3, '2024-03-10', '2024-03-15', '2024-02-28 11:15:00', 37500.00, 'completed', 5);
INSERT INTO public.bookings VALUES (21, 30, '2025-12-13', '2025-12-14', '2025-12-13 00:38:28.59744', 8500.00, 'completed', 24);
INSERT INTO public.bookings VALUES (22, 21, '2025-12-14', '2025-12-20', '2025-12-13 01:40:51.59323', 21000.00, 'completed', 1);
INSERT INTO public.bookings VALUES (36, 1, '2025-12-20', '2025-12-23', NULL, 36000.00, 'pending', 5);
INSERT INTO public.bookings VALUES (37, 27, '2025-12-14', '2025-12-20', NULL, 2400.00, 'completed', 1);
INSERT INTO public.bookings VALUES (38, 14, '2025-12-27', '2025-12-29', NULL, 11000.00, 'completed', 2);


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.reviews VALUES (18, 21, 5, 'все ок', '2025-12-13 00:39:34.237472');
INSERT INTO public.reviews VALUES (19, 22, 3, 'ну такое', '2025-12-13 01:41:55.478982');
INSERT INTO public.reviews VALUES (20, 37, 4, '', '2025-12-13 04:06:10.615787');
INSERT INTO public.reviews VALUES (21, 38, 5, '', '2025-12-13 04:14:24.36922');
INSERT INTO public.reviews VALUES (2, 2, 4, 'Хороший номер за свои деньги, удобное расположение.', '2024-01-13 14:30:00');
INSERT INTO public.reviews VALUES (4, 4, 3, 'Номер хороший, но балкон оказался меньше чем на фото.', '2024-01-29 16:45:00');
INSERT INTO public.reviews VALUES (7, 7, 2, 'За такие деньги ожидали большего, сервис хромает.', '2024-01-26 11:10:00');
INSERT INTO public.reviews VALUES (8, 8, 4, 'Уютный номер, приветливый персонал.', '2024-02-11 15:25:00');
INSERT INTO public.reviews VALUES (9, 9, 3, 'Все нормально, но ничего особенного.', '2024-03-04 13:40:00');
INSERT INTO public.reviews VALUES (11, 11, 4, 'Хорошее соотношение цена/качество.', '2024-02-26 14:05:00');
INSERT INTO public.reviews VALUES (12, 12, 5, 'Семейный номер просторный, детям понравилось.', '2024-03-21 10:50:00');
INSERT INTO public.reviews VALUES (13, 13, 4, 'Удобно для деловой поездки, рядом с центром.', '2024-01-23 12:35:00');
INSERT INTO public.reviews VALUES (14, 14, 3, 'Нормальный отель, но далеко от моря.', '2024-02-13 16:20:00');
INSERT INTO public.reviews VALUES (15, 15, 5, 'Все понравилось))', '2024-03-09 19:45:00');
INSERT INTO public.reviews VALUES (6, 6, 5, 'Романтический отпуск удался! Спасибо отелю.', '2024-02-17 18:30:00');
INSERT INTO public.reviews VALUES (3, 3, 5, 'Незабываемый вид на море! Обязательно вернемся.', '2024-02-08 10:15:00');
INSERT INTO public.reviews VALUES (10, 10, 5, 'Прекрасное спа, отдохнули великолепно!', '2024-02-06 17:55:00');
INSERT INTO public.reviews VALUES (1, 1, 5, 'Прекрасный отель, отличный сервис! Люкс оправдал ожидания.', '2024-01-21 12:00:00');
INSERT INTO public.reviews VALUES (16, 16, 2, NULL, '2024-03-09 00:00:00');
INSERT INTO public.reviews VALUES (17, 5, 5, 'Test', '2025-12-13 00:33:47.478014');


--
-- Data for Name: room_amenities; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.room_amenities VALUES (1, 1, 1);
INSERT INTO public.room_amenities VALUES (2, 1, 2);
INSERT INTO public.room_amenities VALUES (3, 1, 3);
INSERT INTO public.room_amenities VALUES (4, 1, 4);
INSERT INTO public.room_amenities VALUES (5, 1, 5);
INSERT INTO public.room_amenities VALUES (6, 1, 6);
INSERT INTO public.room_amenities VALUES (7, 1, 7);
INSERT INTO public.room_amenities VALUES (8, 1, 8);
INSERT INTO public.room_amenities VALUES (9, 1, 15);
INSERT INTO public.room_amenities VALUES (10, 2, 1);
INSERT INTO public.room_amenities VALUES (11, 2, 2);
INSERT INTO public.room_amenities VALUES (12, 2, 3);
INSERT INTO public.room_amenities VALUES (13, 2, 6);
INSERT INTO public.room_amenities VALUES (14, 2, 15);
INSERT INTO public.room_amenities VALUES (15, 3, 1);
INSERT INTO public.room_amenities VALUES (16, 3, 2);
INSERT INTO public.room_amenities VALUES (17, 3, 3);
INSERT INTO public.room_amenities VALUES (18, 3, 4);
INSERT INTO public.room_amenities VALUES (19, 3, 5);
INSERT INTO public.room_amenities VALUES (20, 3, 6);
INSERT INTO public.room_amenities VALUES (21, 3, 8);
INSERT INTO public.room_amenities VALUES (22, 3, 15);
INSERT INTO public.room_amenities VALUES (23, 8, 1);
INSERT INTO public.room_amenities VALUES (24, 8, 2);
INSERT INTO public.room_amenities VALUES (25, 8, 3);
INSERT INTO public.room_amenities VALUES (26, 8, 6);
INSERT INTO public.room_amenities VALUES (27, 8, 9);
INSERT INTO public.room_amenities VALUES (28, 8, 15);
INSERT INTO public.room_amenities VALUES (29, 9, 1);
INSERT INTO public.room_amenities VALUES (30, 9, 2);
INSERT INTO public.room_amenities VALUES (31, 9, 3);
INSERT INTO public.room_amenities VALUES (32, 9, 6);
INSERT INTO public.room_amenities VALUES (33, 9, 9);
INSERT INTO public.room_amenities VALUES (34, 9, 15);
INSERT INTO public.room_amenities VALUES (35, 12, 1);
INSERT INTO public.room_amenities VALUES (36, 12, 2);
INSERT INTO public.room_amenities VALUES (37, 12, 3);
INSERT INTO public.room_amenities VALUES (38, 12, 6);
INSERT INTO public.room_amenities VALUES (39, 12, 11);
INSERT INTO public.room_amenities VALUES (40, 4, 1);
INSERT INTO public.room_amenities VALUES (41, 4, 2);
INSERT INTO public.room_amenities VALUES (42, 4, 3);
INSERT INTO public.room_amenities VALUES (43, 4, 6);
INSERT INTO public.room_amenities VALUES (44, 5, 1);
INSERT INTO public.room_amenities VALUES (45, 5, 2);
INSERT INTO public.room_amenities VALUES (46, 5, 3);
INSERT INTO public.room_amenities VALUES (47, 5, 4);
INSERT INTO public.room_amenities VALUES (48, 5, 5);
INSERT INTO public.room_amenities VALUES (49, 6, 1);
INSERT INTO public.room_amenities VALUES (50, 6, 2);
INSERT INTO public.room_amenities VALUES (51, 6, 3);
INSERT INTO public.room_amenities VALUES (52, 7, 1);
INSERT INTO public.room_amenities VALUES (53, 7, 2);
INSERT INTO public.room_amenities VALUES (54, 7, 3);
INSERT INTO public.room_amenities VALUES (55, 10, 1);
INSERT INTO public.room_amenities VALUES (56, 10, 2);
INSERT INTO public.room_amenities VALUES (57, 10, 3);
INSERT INTO public.room_amenities VALUES (58, 11, 1);
INSERT INTO public.room_amenities VALUES (59, 11, 2);
INSERT INTO public.room_amenities VALUES (60, 11, 3);
INSERT INTO public.room_amenities VALUES (61, 13, 1);
INSERT INTO public.room_amenities VALUES (62, 13, 2);
INSERT INTO public.room_amenities VALUES (63, 13, 3);
INSERT INTO public.room_amenities VALUES (65, 14, 2);
INSERT INTO public.room_amenities VALUES (66, 14, 3);
INSERT INTO public.room_amenities VALUES (70, 16, 1);
INSERT INTO public.room_amenities VALUES (71, 16, 2);
INSERT INTO public.room_amenities VALUES (72, 16, 3);
INSERT INTO public.room_amenities VALUES (73, 17, 1);
INSERT INTO public.room_amenities VALUES (74, 17, 2);
INSERT INTO public.room_amenities VALUES (75, 17, 3);
INSERT INTO public.room_amenities VALUES (76, 18, 1);
INSERT INTO public.room_amenities VALUES (77, 18, 2);
INSERT INTO public.room_amenities VALUES (78, 18, 3);
INSERT INTO public.room_amenities VALUES (79, 19, 1);
INSERT INTO public.room_amenities VALUES (80, 19, 2);
INSERT INTO public.room_amenities VALUES (81, 19, 3);
INSERT INTO public.room_amenities VALUES (83, 29, 2);
INSERT INTO public.room_amenities VALUES (64, 30, 1);
INSERT INTO public.room_amenities VALUES (82, 29, 1);
INSERT INTO public.room_amenities VALUES (84, 30, 10);
INSERT INTO public.room_amenities VALUES (88, 15, 1);
INSERT INTO public.room_amenities VALUES (89, 15, 2);
INSERT INTO public.room_amenities VALUES (90, 15, 3);
INSERT INTO public.room_amenities VALUES (111, 33, 8);
INSERT INTO public.room_amenities VALUES (112, 33, 9);
INSERT INTO public.room_amenities VALUES (113, 33, 11);
INSERT INTO public.room_amenities VALUES (114, 33, 12);
INSERT INTO public.room_amenities VALUES (115, 31, 1);
INSERT INTO public.room_amenities VALUES (116, 31, 4);
INSERT INTO public.room_amenities VALUES (117, 31, 5);
INSERT INTO public.room_amenities VALUES (118, 31, 6);
INSERT INTO public.room_amenities VALUES (119, 31, 7);
INSERT INTO public.room_amenities VALUES (120, 34, 1);
INSERT INTO public.room_amenities VALUES (121, 34, 2);
INSERT INTO public.room_amenities VALUES (122, 35, 1);
INSERT INTO public.room_amenities VALUES (123, 35, 2);
INSERT INTO public.room_amenities VALUES (144, 38, 2);
INSERT INTO public.room_amenities VALUES (145, 38, 5);
INSERT INTO public.room_amenities VALUES (146, 38, 6);
INSERT INTO public.room_amenities VALUES (147, 38, 10);
INSERT INTO public.room_amenities VALUES (148, 38, 16);
INSERT INTO public.room_amenities VALUES (149, 32, 1);
INSERT INTO public.room_amenities VALUES (150, 32, 4);
INSERT INTO public.room_amenities VALUES (151, 32, 5);
INSERT INTO public.room_amenities VALUES (152, 32, 6);
INSERT INTO public.room_amenities VALUES (153, 32, 7);
INSERT INTO public.room_amenities VALUES (164, 39, 1);
INSERT INTO public.room_amenities VALUES (165, 39, 2);
INSERT INTO public.room_amenities VALUES (166, 39, 4);
INSERT INTO public.room_amenities VALUES (167, 39, 13);
INSERT INTO public.room_amenities VALUES (168, 39, 14);


--
-- Name: amenities_amenity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.amenities_amenity_id_seq', 16, true);


--
-- Name: bookings_booking_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bookings_booking_id_seq', 38, true);


--
-- Name: hotels_hotel_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.hotels_hotel_id_seq', 35, true);


--
-- Name: reviews_review_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reviews_review_id_seq', 21, true);


--
-- Name: room_amenities_room_amenity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.room_amenities_room_amenity_id_seq', 173, true);


--
-- Name: rooms_room_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rooms_room_id_seq', 40, true);


--
-- Name: roomtypes_roomtype_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roomtypes_roomtype_id_seq', 15, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_id_seq', 26, true);


--
-- PostgreSQL database dump complete
--

\unrestrict li1A34HhGIXplYxkbZubFf3P0B1cSKf84S08cY32Qqn1WNnOQTONYrNfxi2s8il

