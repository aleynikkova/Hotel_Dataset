# Hotel Booking System

## Быстрый запуск

### 1. Настройка базы данных

```bash
./setup_database.sh
```

### 2. Запуск backend

```bash
cd backend
python -m venv venv
source venv/bin/activate  # или venv\Scripts\activate на Windows
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 3. Запуск frontend

```bash
cd frontend
python -m http.server 3000
```

### 4. Открыть в браузере

http://localhost:3000

## Тестовые аккаунты

- **Системный админ:** admin@hotel.com / admin123
- **Админ отеля:** admin.plaza@hotel.ru / hotel123  
- **Гость:** dmitry.vasilev@gmail.com / password123
