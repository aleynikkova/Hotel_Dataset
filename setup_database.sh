#!/bin/bash
# Скрипт для создания и настройки базы данных Hotel Booking System
# Использует финальную схему БД без миграций

# Настройки подключения
DB_NAME="postgres"
DB_USER="postgres"
DB_PASSWORD="Mazda220505"

echo "🚀 Настройка базы данных Hotel Booking System..."
echo ""

# Очистка существующих данных
echo "1️⃣ Очистка существующих таблиц..."
PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_NAME <<EOF
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS room_amenities CASCADE;
DROP TABLE IF EXISTS amenities CASCADE;
DROP TABLE IF EXISTS rooms CASCADE;
DROP TABLE IF EXISTS roomtypes CASCADE;
DROP TABLE IF EXISTS hotels CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TYPE IF EXISTS user_role CASCADE;
DROP FUNCTION IF EXISTS calculate_booking_price CASCADE;
DROP FUNCTION IF EXISTS calculate_total_price_trigger CASCADE;
DROP FUNCTION IF EXISTS check_booking_availability CASCADE;
DROP FUNCTION IF EXISTS validate_review_rights CASCADE;
DROP FUNCTION IF EXISTS get_available_rooms CASCADE;
DROP FUNCTION IF EXISTS get_hotel_statistics CASCADE;
DROP FUNCTION IF EXISTS can_add_review CASCADE;
DROP PROCEDURE IF EXISTS cancel_expired_bookings CASCADE;
EOF
echo "✅ Очистка выполнена"
echo ""

echo "2️⃣ Создание финальной схемы БД (таблицы, функции, триггеры, представления)..."
PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_NAME -f database/init_schema.sql -q
echo "✅ Схема создана"
echo ""

echo "3️⃣ Загрузка тестовых данных..."
PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_NAME -f database/test_data.sql -q
echo "✅ Тестовые данные загружены"
echo ""

echo "🎉 База данных полностью готова к работе!"
echo ""
echo "📋 Тестовые аккаунты:"
echo "   Системный админ:  admin@hotel.com / admin123"
echo "   Админ отеля:      admin.plaza@hotel.ru / hotel123"
echo "   Гость:            dmitry.vasilev@gmail.com / password123"
echo ""
echo "📋 Тестовые пользователи:"
echo "   Системный админ: admin@hotel.com / admin123"
echo "   Админ отеля: admin.plaza@hotel.ru / hotel123"
echo "   Гости: используйте email из вашей таблицы guests / password123"
