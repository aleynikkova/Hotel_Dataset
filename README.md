# Сервис бронирования отелей

Курсовой проект по дисциплине "Базы данных" - Информационная система для управления бронированиями отелей.

## Технологический стек

- **Backend**: FastAPI (Python 3.10+)
- **Frontend**: HTML5, CSS3, JavaScript (ES6+), Bootstrap 5
- **База данных**: PostgreSQL 14+
- **Аутентификация**: JWT tokens
- **ORM**: SQLAlchemy 2.0

## Структура проекта

```
КП_БД/
├── backend/              # Серверная часть приложения
│   ├── app/
│   │   ├── api/         # API endpoints
│   │   ├── core/        # Конфигурация, безопасность
│   │   ├── models/      # SQLAlchemy модели
│   │   ├── schemas/     # Pydantic схемы
│   │   └── main.py      # Точка входа FastAPI
│   ├── requirements.txt
│   └── .env.example
├── frontend/            # Клиентская часть
│   ├── index.html
│   ├── css/
│   ├── js/
│   └── assets/
├── database/            # SQL скрипты
│   ├── init_schema.sql  # Создание структуры БД
│   ├── triggers.sql     # Триггеры
│   ├── functions.sql    # Функции и процедуры
│   ├── views.sql        # Представления
│   └── test_data.sql    # Тестовые данные
└── docs/                # Документация
    └── technical_specification.md

```

## Функциональность

### Роли пользователей

1. **Гость** - создание бронирований, просмотр отелей, добавление отзывов
2. **Администратор отеля** - управление номерами, бронированиями своего отеля
3. **Системный администратор** - полный доступ к системе

### Основные возможности

- Регистрация и аутентификация пользователей
- Управление отелями, номерами, типами номеров и удобствами
- Система бронирований с проверкой доступности
- Отзывы о пройденных проживаниях
- Формирование отчётов по загрузке и бронированиям
- Разграничение прав доступа по ролям

## Установка и запуск

### Предварительные требования

- Python 3.10+
- PostgreSQL 14+
- pip

### 1. Клонирование репозитория

```bash
git clone <repository-url>
cd КП_БД
```

### 2. Настройка базы данных

```bash
# Создайте БД в PostgreSQL
psql -U postgres
CREATE DATABASE hotel_booking;
\q

# Выполните скрипты инициализации
psql -U postgres -d hotel_booking -f database/init_schema.sql
psql -U postgres -d hotel_booking -f database/functions.sql
psql -U postgres -d hotel_booking -f database/triggers.sql
psql -U postgres -d hotel_booking -f database/views.sql
psql -U postgres -d hotel_booking -f database/test_data.sql
```

### 3. Настройка backend

```bash
cd backend

# Создайте виртуальное окружение
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# или
venv\Scripts\activate  # Windows

# Установите зависимости
pip install -r requirements.txt

# Настройте переменные окружения
cp .env.example .env
# Отредактируйте .env файл с вашими настройками БД

# Запустите сервер
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 4. Запуск frontend

```bash
# Откройте frontend/index.html в браузере
# или используйте локальный сервер:
cd frontend
python3 -m http.server 3000
```

Приложение будет доступно:
- Backend API: http://localhost:8000
- API документация: http://localhost:8000/docs
- Frontend: http://localhost:3000

## Тестовые пользователи

После загрузки тестовых данных доступны следующие пользователи:

| Роль | Email | Пароль |
|------|-------|--------|
| Системный админ | admin@hotel.com | admin123 |
| Админ отеля | hotel_admin@hotel.com | hotel123 |
| Гость | guest@example.com | guest123 |

## Разработка

Проект разрабатывается командой из 2 человек.

## Авторы

- [Ваше имя]
- [Имя сокомандницы]

## Лицензия

Учебный проект
