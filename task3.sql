/*
3. Создать минимум 3 учётных записи в базе данных, настроить им доступы к необходимым процедурам и продемонстрировать их выполнение/невыполнение по уровню доступа: 
    1. Администратор — имеет права использовать все хранимые процедуры, 
    2. Сервисная учётная запись — имеет права на хранимые процедуры, которые использую SELECT, UPDATE и INSERT 
    3. Пользователь — имеет права только на хранимые процедуры, использующие SELECT
*/
SET search_path TO library;
-- Создание ролей

-- Администратор
CREATE ROLE admin LOGIN PASSWORD 'admin123';
-- Сервисная учетная запись
CREATE ROLE service LOGIN PASSWORD 'service123';
-- Обычный пользователь
CREATE ROLE app_user LOGIN PASSWORD 'user123';

GRANT USAGE ON SCHEMA library TO admin, service, app_user;

-- Запрет прямого доступа

REVOKE EXECUTE ON ALL PROCEDURES IN SCHEMA library FROM PUBLIC;

-- Разрешение на доступ
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA library TO admin;

-- SELECT процедуры
GRANT EXECUTE ON PROCEDURE find_books_by_title(TEXT, INOUT REFCURSOR) TO service;
GRANT EXECUTE ON PROCEDURE find_reader_by_email(TEXT, INOUT REFCURSOR) TO service;

-- INSERT процедуры
GRANT EXECUTE ON PROCEDURE insert_book(TEXT,INT,INT) TO service;
GRANT EXECUTE ON PROCEDURE insert_reader(TEXT,TEXT) TO service;
GRANT EXECUTE ON PROCEDURE insert_author(TEXT) TO service;
GRANT EXECUTE ON PROCEDURE insert_genre(TEXT) TO service;
GRANT EXECUTE ON PROCEDURE insert_book_genre(INT,INT) TO service;
GRANT EXECUTE ON PROCEDURE insert_loan(INT,INT) TO service;
GRANT EXECUTE ON PROCEDURE return_book(INT) TO service;

-- UPDATE процедуры
GRANT EXECUTE ON PROCEDURE update_book(INT,TEXT,INT) TO service;
GRANT EXECUTE ON PROCEDURE update_reader_email(INT,TEXT) TO service;

-- SELECT процедуры для пользователя
GRANT EXECUTE ON PROCEDURE find_books_by_title(TEXT, INOUT REFCURSOR) TO app_user;
GRANT EXECUTE ON PROCEDURE find_reader_by_email(TEXT, INOUT REFCURSOR) TO app_user;

-- Администратор
SET ROLE admin;
CALL insert_book('Тестовая книга', 1, 2024);
CALL update_book(1, 'Обновленная книга', 2025);
CALL delete_book(1);
BEGIN;
CALL find_books_by_title('Война','mycursor');
FETCH ALL FROM mycursor;
COMMIT;
RESET ROLE;

-- Сервисная учетная запись
SET ROLE service;
-- разрешено
CALL insert_book('Service book', 1, 2023);
CALL update_book(2, 'Service update', 2020);
BEGIN;
CALL find_books_by_title('Идиот','mycursor');
FETCH ALL FROM mycursor;
COMMIT;
-- запрещено
--CALL delete_book(2); -- нет доступа к процедуре delete_book 
RESET ROLE;

-- Обычный пользователь
SET ROLE app_user;
-- разрешено
BEGIN;
CALL find_books_by_title('Анна', 'mycursor');
FETCH ALL FROM mycursor;
COMMIT;
-- запрещено
--CALL insert_book('User book', 1, 2022); -- нет доступа к процедуре insert_book 
--CALL update_book(1, 'Hack', 2000); -- нет доступа к процедуре update_book 
--CALL delete_book(1); -- нет доступа к процедуре delete_book 
RESET ROLE;