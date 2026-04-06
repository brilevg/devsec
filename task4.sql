/*
4.	*Создать лог-таблицы и лог-триггеры — таблицы, которые дублируют спроектированные таблицы с окончанием «_log», которые пополняются данными через созданные триггеры на каждую таблицу. 
    Триггеры срабатывают на INSERT, UPDATE, DELETE. Дополнительные столбцы в лог-таблицах:
    1.	user_name – имя пользователя, который вызвал действие
    2.	update_time – дата-время действия
    3.	action – наименование действия, из-за которого пишется запись в таблицу

*/


SET search_path TO library;


-- log таблицы


CREATE TABLE authors_log (
    author_id INT,
    name TEXT,
    user_name TEXT,
    update_time TIMESTAMP,
    action TEXT
);

CREATE TABLE books_log (
    book_id INT,
    title TEXT,
    author_id INT,
    year INT,
    user_name TEXT,
    update_time TIMESTAMP,
    action TEXT
);

CREATE TABLE genres_log (
    genre_id INT,
    name TEXT,
    user_name TEXT,
    update_time TIMESTAMP,
    action TEXT
);

CREATE TABLE readers_log (
    reader_id INT,
    name TEXT,
    email TEXT,
    user_name TEXT,
    update_time TIMESTAMP,
    action TEXT
);

CREATE TABLE book_genres_log (
    book_id INT,
    genre_id INT,
    user_name TEXT,
    update_time TIMESTAMP,
    action TEXT
);

CREATE TABLE loans_log (
    loan_id INT,
    book_id INT,
    reader_id INT,
    loan_date DATE,
    return_date DATE,
    user_name TEXT,
    update_time TIMESTAMP,
    action TEXT
);

-- функции для триггеров

-- AUTHORS
CREATE OR REPLACE FUNCTION authors_log()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO authors_log
        VALUES (NEW.author_id, NEW.name, session_user, NOW(), 'INSERT');
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO authors_log
        VALUES (NEW.author_id, NEW.name, session_user, NOW(), 'UPDATE');
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO authors_log
        VALUES (OLD.author_id, OLD.name, session_user, NOW(), 'DELETE');
        RETURN OLD;
    END IF;
END;
$$;

-- BOOKS
CREATE OR REPLACE FUNCTION books_log()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO books_log
        VALUES (NEW.book_id, NEW.title, NEW.author_id, NEW.year, session_user, NOW(), 'INSERT');
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO books_log
        VALUES (NEW.book_id, NEW.title, NEW.author_id, NEW.year, session_user, NOW(), 'UPDATE');
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO books_log
        VALUES (OLD.book_id, OLD.title, OLD.author_id, OLD.year, session_user, NOW(), 'DELETE');
        RETURN OLD;
    END IF;
END;
$$;

-- GENRES
CREATE OR REPLACE FUNCTION genres_log()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO genres_log
        VALUES (NEW.genre_id, NEW.name, session_user, NOW(), 'INSERT');
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO genres_log
        VALUES (NEW.genre_id, NEW.name, session_user, NOW(), 'UPDATE');
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO genres_log
        VALUES (OLD.genre_id, OLD.name, session_user, NOW(), 'DELETE');
        RETURN OLD;
    END IF;
END;
$$;

-- READERS
CREATE OR REPLACE FUNCTION readers_log()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO readers_log
        VALUES (NEW.reader_id, NEW.name, NEW.email, session_user, NOW(), 'INSERT');
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO readers_log
        VALUES (NEW.reader_id, NEW.name, NEW.email, session_user, NOW(), 'UPDATE');
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO readers_log
        VALUES (OLD.reader_id, OLD.name, OLD.email, session_user, NOW(), 'DELETE');
        RETURN OLD;
    END IF;
END;
$$;

-- BOOK_GENRES
CREATE OR REPLACE FUNCTION book_genres_log()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO book_genres_log
        VALUES (NEW.book_id, NEW.genre_id, session_user, NOW(), 'INSERT');
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO book_genres_log
        VALUES (NEW.book_id, NEW.genre_id, session_user, NOW(), 'UPDATE');
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO book_genres_log
        VALUES (OLD.book_id, OLD.genre_id, session_user, NOW(), 'DELETE');
        RETURN OLD;
    END IF;
END;
$$;

-- LOANS
CREATE OR REPLACE FUNCTION loans_log()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO loans_log
        VALUES (NEW.loan_id, NEW.book_id, NEW.reader_id, NEW.loan_date, NEW.return_date, session_user, NOW(), 'INSERT');
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO loans_log
        VALUES (NEW.loan_id, NEW.book_id, NEW.reader_id, NEW.loan_date, NEW.return_date, session_user, NOW(), 'UPDATE');
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO loans_log
        VALUES (OLD.loan_id, OLD.book_id, OLD.reader_id, OLD.loan_date, OLD.return_date, session_user, NOW(), 'DELETE');
        RETURN OLD;
    END IF;
END;
$$;

-- триггеры

CREATE TRIGGER authors_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON authors
FOR EACH ROW EXECUTE FUNCTION authors_log();

CREATE TRIGGER books_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON books
FOR EACH ROW EXECUTE FUNCTION books_log();

CREATE TRIGGER genres_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON genres
FOR EACH ROW EXECUTE FUNCTION genres_log();

CREATE TRIGGER readers_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON readers
FOR EACH ROW EXECUTE FUNCTION readers_log();

CREATE TRIGGER book_genres_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON book_genres
FOR EACH ROW EXECUTE FUNCTION book_genres_log();

CREATE TRIGGER loans_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON loans
FOR EACH ROW EXECUTE FUNCTION loans_log();


-- процедуры для просмотра логов


CREATE OR REPLACE PROCEDURE get_authors_log(INOUT ref refcursor)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    OPEN ref FOR SELECT * FROM authors_log;
END;
$$;

CREATE OR REPLACE PROCEDURE get_books_log(INOUT ref refcursor)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    OPEN ref FOR SELECT * FROM books_log;
END;
$$;

CREATE OR REPLACE PROCEDURE get_readers_log(INOUT ref refcursor)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    OPEN ref FOR SELECT * FROM readers_log;
END;
$$;


-- тестирование
-- действия
CALL insert_author('Тестовый автор');

CALL delete_reader(1);

-- просмотр логов (ТОЛЬКО через процедуры!)
BEGIN;
CALL get_authors_log('c1');
FETCH ALL FROM c1;
COMMIT;

BEGIN;
CALL get_books_log('c2');
FETCH ALL FROM c2;
COMMIT;

BEGIN;
CALL get_readers_log('c3');
FETCH ALL FROM c3;
COMMIT;
