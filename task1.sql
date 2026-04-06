/*
1. Спроектировать и заполнить реляционную базу данных 
с минимум 5-ю связными таблицами, используя первичные 
и внешние ключи для библиотечной информационной системы. 
На выбор можно использовать любую реляционную СУБД, кроме SQLite.
*/
-- СОЗДАНИЕ СХЕМЫ
CREATE SCHEMA library;
SET search_path TO library;

-- 1. Авторы
CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

-- 2. Жанры
CREATE TABLE genres (
    genre_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

-- 3. Книги
CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INT REFERENCES authors(author_id),
    year INT
);

-- 4. Связь книги-жанры
CREATE TABLE book_genres (
    book_id INT REFERENCES books(book_id),
    genre_id INT REFERENCES genres(genre_id),
    PRIMARY KEY (book_id, genre_id)
);

-- 5. Читатели
CREATE TABLE readers (
    reader_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE
);

-- 6. Выдачи
CREATE TABLE loans (
    loan_id SERIAL PRIMARY KEY,
    book_id INT REFERENCES books(book_id),
    reader_id INT REFERENCES readers(reader_id),
    loan_date DATE NOT NULL,
    return_date DATE
);

-- заполнение

INSERT INTO authors (name) VALUES
('Лев Толстой'),
('Фёдор Достоевский');

INSERT INTO genres (name) VALUES
('Роман'),
('Драма');

INSERT INTO books (title, author_id, year) VALUES
('Война и мир', 1, 1869),
('Преступление и наказание', 2, 1866);

INSERT INTO book_genres VALUES
(1, 1),
(2, 1);

INSERT INTO readers (name, email) VALUES
('Иван Иванов', 'ivan@mail.com'),
('Анна Петрова', 'annap@mail.com');

-- добавление книги

CREATE OR REPLACE PROCEDURE insert_book(
    p_title TEXT,
    p_author_id INT,
    p_year INT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO books(title, author_id, year)
    VALUES (p_title, p_author_id, p_year);
END;
$$;

-- выдача книги

CREATE OR REPLACE PROCEDURE insert_loan(
    p_book_id INT,
    p_reader_id INT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO loans(book_id, reader_id, loan_date)
    VALUES (p_book_id, p_reader_id, CURRENT_DATE);
END;
$$;

-- возврат книги

CREATE OR REPLACE PROCEDURE return_book(
    p_loan_id INT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE loans
    SET return_date = CURRENT_DATE
    WHERE loan_id = p_loan_id;
END;
$$;

-- добавление читателя

CREATE OR REPLACE PROCEDURE insert_reader(
    p_name TEXT,
    p_email TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO readers(name, email)
    VALUES (p_name, p_email);
END;
$$;

-- Тестирование

CALL insert_book('Family', 2, 1869);
CALL insert_reader('Петр Сидоров', 'petrs@mail.com');
CALL insert_loan(1, 1);
CALL return_book(1);