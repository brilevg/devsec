/*
2. Подготовить хранимые процедуры для работы с таблицами через передаваемые аргументы: 
    1. SELECT процедуры для поиска по значению 
    2. UPDATE процедуры для обновления 
    3. INSERT для добавления новых строк в таблицу 
    4. DELETE для удаления строк
*/

SET search_path TO library;

-- Поиск книг по названию SELECT

CREATE OR REPLACE PROCEDURE find_books_by_title(
    IN p_title TEXT,
    INOUT ref refcursor
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    OPEN ref FOR
    SELECT * FROM books
    WHERE title ILIKE '%' || p_title || '%';
END;
$$;

-- Поиск читателей по email SELECT

CREATE OR REPLACE PROCEDURE find_reader_by_email(
    IN p_email TEXT,
    INOUT ref refcursor
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    OPEN ref FOR
    SELECT * FROM readers
    WHERE email = p_email;
END;
$$;

-- Добавление книги INSERT

CREATE OR REPLACE PROCEDURE insert_book(
    IN p_title TEXT,
    IN p_author_id INT,
    IN p_year INT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO books(title, author_id, year)
    VALUES (p_title, p_author_id, p_year);
END;
$$;

-- Добавление читателя INSERT

CREATE OR REPLACE PROCEDURE insert_reader(
    IN p_name TEXT,
    IN p_email TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO readers(name, email)
    VALUES (p_name, p_email);
END;
$$;

-- Добавление автора INSERT

CREATE OR REPLACE PROCEDURE insert_author(p_name TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO authors(name) VALUES (p_name);
END;
$$;

-- Добавление жанра INSERT

CREATE OR REPLACE PROCEDURE insert_genre(p_name TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO genres(name) VALUES (p_name);
END;
$$;

-- Добавление связи книги и жанра INSERT

CREATE OR REPLACE PROCEDURE insert_book_genre(p_book_id INT, p_genre_id INT)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO book_genres(book_id, genre_id)
    VALUES (p_book_id, p_genre_id);
END;
$$;

-- Выдача книги INSERT

CREATE OR REPLACE PROCEDURE insert_loan(
    p_book_id INT,
    p_reader_id INT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Проверка существования книги
    IF NOT EXISTS (
        SELECT 1 FROM books WHERE book_id = p_book_id
    ) THEN
        RAISE EXCEPTION 'Книга с ID % не существует', p_book_id;
    END IF;

    -- Проверка существования читателя
    IF NOT EXISTS (
        SELECT 1 FROM readers WHERE reader_id = p_reader_id
    ) THEN
        RAISE EXCEPTION 'Читатель с ID % не существует', p_reader_id;
    END IF;

    -- Проверка: книга уже выдана?
    IF EXISTS (
        SELECT 1 FROM loans 
        WHERE book_id = p_book_id AND return_date IS NULL
    ) THEN
        RAISE EXCEPTION 'Книга уже выдана и не возвращена';
    END IF;

    -- Если всё ок → выдаём
    INSERT INTO loans(book_id, reader_id, loan_date)
    VALUES (p_book_id, p_reader_id, CURRENT_DATE);
END;
$$;

-- Обновление книги UPDATE

CREATE OR REPLACE PROCEDURE update_book(
    IN p_book_id INT,
    IN p_title TEXT,
    IN p_year INT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE books
    SET title = p_title,
        year = p_year
    WHERE book_id = p_book_id;
END;
$$;

-- Обновление email читателя UPDATE

CREATE OR REPLACE PROCEDURE update_reader_email(
    IN p_reader_id INT,
    IN p_email TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE readers
    SET email = p_email
    WHERE reader_id = p_reader_id;
END;
$$;

-- Удаление книги DELETE

CREATE OR REPLACE PROCEDURE delete_book(p_book_id INT)
SECURITY DEFINER
AS $$
BEGIN
    -- сначала удаляем связи
    DELETE FROM book_genres
    WHERE book_id = p_book_id;
    -- потом все выданные книги
    DELETE FROM loans
    WHERE book_id = p_book_id;
    -- потом саму книгу
    DELETE FROM books
    WHERE book_id = p_book_id;
END;
$$ LANGUAGE plpgsql;

-- Удаление читателя DELETE

CREATE OR REPLACE PROCEDURE delete_reader(p_reader_id INT)
SECURITY DEFINER
AS $$
BEGIN
    DELETE FROM loans WHERE reader_id = p_reader_id;
    DELETE FROM readers WHERE reader_id = p_reader_id;
END;
$$ LANGUAGE plpgsql;

-- Тестирование

-- SELECT
BEGIN;
CALL find_books_by_title('война', 'mycursor');
FETCH ALL FROM mycursor;
COMMIT;

-- INSERT
CALL insert_book('Братья Карамазовы', 2, 1880);

-- UPDATE
CALL update_book(1, 'Война и мир (ред.)', 1870);

-- DELETE
CALL delete_book(2);

-- Добавление авторов

CALL insert_author('Лев Толстой');
CALL insert_author('Фёдор Достоевский');
CALL insert_author('Александр Пушкин');
CALL insert_author('Антон Чехов');
CALL insert_author('Иван Тургенев');
CALL insert_author('Михаил Булгаков');
CALL insert_author('Николай Гоголь');
CALL insert_author('Максим Горький');
CALL insert_author('Иван Бунин');
CALL insert_author('Владимир Набоков');
CALL insert_author('Александр Солженицын');
CALL insert_author('Михаил Шолохов');
CALL insert_author('Борис Пастернак');
CALL insert_author('Анна Ахматова');
CALL insert_author('Марина Цветаева');
CALL insert_author('Сергей Есенин');
CALL insert_author('Владимир Маяковский');
CALL insert_author('Николай Некрасов');
CALL insert_author('Иван Крылов');
CALL insert_author('Михаил Лермонтов');
CALL insert_author('Александр Грибоедов');
CALL insert_author('Николай Лесков');
CALL insert_author('Алексей Толстой');
CALL insert_author('Михаил Салтыков-Щедрин');
CALL insert_author('Гавриил Державин');
CALL insert_author('Константин Батюшков');
CALL insert_author('Евгений Баратынский');
CALL insert_author('Фёдор Тютчев');
CALL insert_author('Афанасий Фет');
CALL insert_author('Николай Чернышевский');
CALL insert_author('Иван Гончаров');
CALL insert_author('Дмитрий Мамин-Сибиряк');
CALL insert_author('Павел Бажов');
CALL insert_author('Аркадий Гайдар');
CALL insert_author('Константин Паустовский');
CALL insert_author('Михаил Пришвин');
CALL insert_author('Виталий Бианки');
CALL insert_author('Евгений Шварц');
CALL insert_author('Самуил Маршак');
CALL insert_author('Корней Чуковский');
CALL insert_author('Агния Барто');
CALL insert_author('Сергей Михалков');
CALL insert_author('Николай Носов');
CALL insert_author('Виктор Драгунский');
CALL insert_author('Эдуард Успенский');
CALL insert_author('Григорий Остер');
CALL insert_author('Борис Заходер');
CALL insert_author('Юрий Коваль');
CALL insert_author('Владислав Крапивин');
CALL insert_author('Кир Булычёв');

-- Добавление жанров

CALL insert_genre('Роман');
CALL insert_genre('Драма');
CALL insert_genre('Поэзия');
CALL insert_genre('Фантастика');
CALL insert_genre('Детектив');
CALL insert_genre('Классика');
CALL insert_genre('Философия');
CALL insert_genre('Приключения');
CALL insert_genre('Трагедия');
CALL insert_genre('Комедия');
CALL insert_genre('Повесть');
CALL insert_genre('Рассказ');
CALL insert_genre('Новелла');
CALL insert_genre('Очерк');
CALL insert_genre('Эссе');
CALL insert_genre('Мемуары');
CALL insert_genre('Биография');
CALL insert_genre('Автобиография');
CALL insert_genre('Публицистика');
CALL insert_genre('Сказка');
CALL insert_genre('Басня');
CALL insert_genre('Легенда');
CALL insert_genre('Миф');
CALL insert_genre('Эпос');
CALL insert_genre('Лирика');
CALL insert_genre('Сонет');
CALL insert_genre('Баллада');
CALL insert_genre('Романс');
CALL insert_genre('Ода');
CALL insert_genre('Элегия');
CALL insert_genre('Фэнтези');
CALL insert_genre('Научная фантастика');
CALL insert_genre('Киберпанк');
CALL insert_genre('Ужасы');
CALL insert_genre('Мистика');
CALL insert_genre('Триллер');
CALL insert_genre('Боевик');
CALL insert_genre('Шпионский роман');
CALL insert_genre('Исторический роман');
CALL insert_genre('Любовный роман');
CALL insert_genre('Психологическая драма');
CALL insert_genre('Сатира');
CALL insert_genre('Юмор');
CALL insert_genre('Пародия');
CALL insert_genre('Путевые заметки');
CALL insert_genre('Эпистолярный жанр');
CALL insert_genre('Документалистика');
CALL insert_genre('Нон-фикшн');
CALL insert_genre('Детская литература');
CALL insert_genre('Постапокалипсис');
CALL insert_genre('ЛитРПГ');
CALL insert_genre('Городское фэнтези');
CALL insert_genre('Тёмное фэнтези');
CALL insert_genre('Дарк-роман');
CALL insert_genre('Роман-эпопея');

-- Добавление книг

CALL insert_book('Война и мир', 1, 1869);
CALL insert_book('Анна Каренина', 1, 1877);
CALL insert_book('Преступление и наказание', 2, 1866);
CALL insert_book('Идиот', 2, 1869);
CALL insert_book('Евгений Онегин', 3, 1833);
CALL insert_book('Капитанская дочка', 3, 1836);
CALL insert_book('Вишневый сад', 4, 1904);
CALL insert_book('Отцы и дети', 5, 1862);
CALL insert_book('Мастер и Маргарита', 6, 1967);
CALL insert_book('Ревизор', 7, 1836);
CALL insert_book('Мертвые души', 7, 1842);
CALL insert_book('На дне', 8, 1902);
CALL insert_book('Темные аллеи', 9, 1943);
CALL insert_book('Лолита', 10, 1955);
CALL insert_book('Дар', 10, 1938);
CALL insert_book('Записки из Мертвого дома', 2, 1862);
CALL insert_book('Бесы', 2, 1872);
CALL insert_book('Руслан и Людмила', 3, 1820);
CALL insert_book('Полтава', 3, 1829);
CALL insert_book('Чайка', 4, 1896);
CALL insert_book('Три сестры', 4, 1901);
CALL insert_book('Дворянское гнездо', 5, 1859);
CALL insert_book('Рудин', 5, 1856);
CALL insert_book('Собачье сердце', 6, 1925);
CALL insert_book('Белая гвардия', 6, 1925);
CALL insert_book('Тарас Бульба', 7, 1835);
CALL insert_book('Вий', 7, 1835);
CALL insert_book('Старуха Изергиль', 8, 1895);
CALL insert_book('Детство', 8, 1913);
CALL insert_book('Господин из Сан-Франциско', 9, 1916);
CALL insert_book('Жизнь Арсеньева', 9, 1930);
CALL insert_book('Защита Лужина', 10, 1930);
CALL insert_book('Приглашение на казнь', 10, 1936);
CALL insert_book('Один день Ивана Денисовича', 11, 1962);
CALL insert_book('Матрёнин двор', 11, 1963);
CALL insert_book('Тихий Дон', 12, 1940);
CALL insert_book('Поднятая целина', 12, 1960);
CALL insert_book('Доктор Живаго', 13, 1957);
CALL insert_book('Реквием', 14, 1963);
CALL insert_book('Поэма без героя', 14, 1960);
CALL insert_book('Стихи о Москве', 15, 1916);
CALL insert_book('Чёрный человек', 16, 1926);
CALL insert_book('Облако в штанах', 17, 1915);
CALL insert_book('Кому на Руси жить хорошо', 18, 1877);
CALL insert_book('Волк на псарне', 19, 1812);
CALL insert_book('Горе от ума', 20, 1825);
CALL insert_book('Левша', 21, 1881);
CALL insert_book('Петр Первый', 22, 1945);
CALL insert_book('История одного города', 23, 1870);
CALL insert_book('Фелица', 24, 1782);

-- Добавление связи книги и жанра

CALL insert_book_genre(3, 1);
CALL insert_book_genre(4, 7);
CALL insert_book_genre(5, 3);
CALL insert_book_genre(6, 8);
CALL insert_book_genre(7, 2);
CALL insert_book_genre(8, 1);
CALL insert_book_genre(9, 4);
CALL insert_book_genre(10, 2);
CALL insert_book_genre(11, 1);
CALL insert_book_genre(12, 2);
CALL insert_book_genre(13, 6);
CALL insert_book_genre(14, 1);
CALL insert_book_genre(15, 7);
CALL insert_book_genre(7, 1);
CALL insert_book_genre(6, 6);
CALL insert_book_genre(5, 1);
CALL insert_book_genre(16, 2);
CALL insert_book_genre(16, 1);
CALL insert_book_genre(17, 1);
CALL insert_book_genre(18, 3);
CALL insert_book_genre(19, 3);
CALL insert_book_genre(20, 2);
CALL insert_book_genre(21, 2);
CALL insert_book_genre(22, 1);
CALL insert_book_genre(23, 1);
CALL insert_book_genre(24, 4);
CALL insert_book_genre(25, 1);
CALL insert_book_genre(26, 8);
CALL insert_book_genre(27, 4);
CALL insert_book_genre(28, 2);
CALL insert_book_genre(29, 2);
CALL insert_book_genre(30, 1);
CALL insert_book_genre(31, 1);
CALL insert_book_genre(32, 7);
CALL insert_book_genre(33, 7);
CALL insert_book_genre(34, 1);
CALL insert_book_genre(35, 1);
CALL insert_book_genre(36, 3);
CALL insert_book_genre(37, 3);
CALL insert_book_genre(38, 3);
CALL insert_book_genre(39, 3);
CALL insert_book_genre(40, 3);
CALL insert_book_genre(41, 3);
CALL insert_book_genre(42, 3);
CALL insert_book_genre(43, 3);
CALL insert_book_genre(44, 3);
CALL insert_book_genre(45, 19);
CALL insert_book_genre(46, 2);
CALL insert_book_genre(47, 8);
CALL insert_book_genre(48, 1);
CALL insert_book_genre(49, 6);
CALL insert_book_genre(50, 6);

-- Добавление читателей

CALL insert_reader('Иван Иванов', 'ivan1@mail.com');
CALL insert_reader('Петр Петров', 'petr@mail.com');
CALL insert_reader('Анна Смирнова', 'anna@mail.com');
CALL insert_reader('Ольга Сидорова', 'olga@mail.com');
CALL insert_reader('Дмитрий Кузнецов', 'dima@mail.com');
CALL insert_reader('Мария Иванова', 'maria@mail.com');
CALL insert_reader('Сергей Орлов', 'sergey@mail.com');
CALL insert_reader('Елена Волкова', 'elena@mail.com');
CALL insert_reader('Алексей Морозов', 'alex@mail.com');
CALL insert_reader('Наталья Федорова', 'nat@mail.com');
CALL insert_reader('Владимир Соколов', 'vlad@mail.com');
CALL insert_reader('Екатерина Лебедева', 'katya@mail.com');
CALL insert_reader('Юрий Козлов', 'yuri@mail.com');
CALL insert_reader('Татьяна Новикова', 'tatiana@mail.com');
CALL insert_reader('Андрей Павлов', 'andrey@mail.com');
CALL insert_reader('Ирина Васильева', 'irina@mail.com');
CALL insert_reader('Николай Степанов', 'nikolay@mail.com');
CALL insert_reader('Светлана Николаева', 'sveta@mail.com');
CALL insert_reader('Михаил Егоров', 'mikhail@mail.com');
CALL insert_reader('Людмила Полякова', 'ludmila@mail.com');
CALL insert_reader('Валентин Фролов', 'valentin@mail.com');
CALL insert_reader('Галина Захарова', 'galina@mail.com');
CALL insert_reader('Артем Соловьев', 'artem@mail.com');
CALL insert_reader('Евгения Борисова', 'evgenia@mail.com');
CALL insert_reader('Виталий Титов', 'vitaly@mail.com');
CALL insert_reader('Оксана Тарасова', 'oksana@mail.com');
CALL insert_reader('Геннадий Беляев', 'gennady@mail.com');
CALL insert_reader('Алла Мельникова', 'alla@mail.com');
CALL insert_reader('Роман Денисов', 'roman@mail.com');
CALL insert_reader('Валерия Савельева', 'valeria@mail.com');
CALL insert_reader('Константин Гусев', 'konstantin@mail.com');
CALL insert_reader('Алина Киселева', 'alina@mail.com');
CALL insert_reader('Станислав Андреев', 'stanislav@mail.com');
CALL insert_reader('Виктория Макарова', 'viktoria@mail.com');
CALL insert_reader('Леонид Белов', 'leonid@mail.com');
CALL insert_reader('Надежда Абрамова', 'nadezhda@mail.com');
CALL insert_reader('Василий Ефимов', 'vasily@mail.com');
CALL insert_reader('Евгений Орлов', 'evgeny@mail.com');
CALL insert_reader('Зоя Кузьмина', 'zoya@mail.com');
CALL insert_reader('Анатолий Сорокин', 'anatoly@mail.com');
CALL insert_reader('Инна Панфилова', 'inna@mail.com');
CALL insert_reader('Вадим Шестаков', 'vadim@mail.com');
CALL insert_reader('Лилия Данилова', 'lilia@mail.com');
CALL insert_reader('Филипп Субботин', 'philipp@mail.com');
CALL insert_reader('Маргарита Рябова', 'rita@mail.com');
CALL insert_reader('Тимур Медведев', 'timur@mail.com');
CALL insert_reader('Камилла Анисимова', 'kamilla@mail.com');
CALL insert_reader('Ярослав Комаров', 'yaroslav@mail.com');
CALL insert_reader('Алиса Громова', 'alisa@mail.com');
CALL insert_reader('Даниил Мартынов', 'daniel@mail.com');

-- Выдача книг читателям

CALL insert_loan(1, 1);
CALL insert_loan(4, 4);
CALL insert_loan(5, 5);
CALL insert_loan(6, 6);
CALL insert_loan(7, 7);
CALL insert_loan(8, 8);
CALL insert_loan(9, 9);
CALL insert_loan(10, 10);
CALL insert_loan(11, 11);
CALL insert_loan(12, 12);
CALL insert_loan(13, 13);
CALL insert_loan(14, 14);
CALL insert_loan(15, 15);
CALL insert_loan(16, 16);
CALL insert_loan(17, 17);
CALL insert_loan(18, 18);
CALL insert_loan(19, 19);
CALL insert_loan(20, 20);
CALL insert_loan(21, 21);
CALL insert_loan(22, 22);
CALL insert_loan(23, 23);
CALL insert_loan(24, 24);
CALL insert_loan(25, 25);
CALL insert_loan(26, 26);
CALL insert_loan(27, 27);
CALL insert_loan(28, 28);
CALL insert_loan(29, 29);
CALL insert_loan(30, 30);
CALL insert_loan(31, 31);
CALL insert_loan(32, 32);
CALL insert_loan(33, 33);
CALL insert_loan(34, 34);
CALL insert_loan(35, 35);
CALL insert_loan(36, 36);
CALL insert_loan(37, 37);
CALL insert_loan(38, 38);
CALL insert_loan(39, 39);
CALL insert_loan(40, 40);
CALL insert_loan(41, 41);
CALL insert_loan(42, 42);
CALL insert_loan(43, 43);
CALL insert_loan(44, 44);
CALL insert_loan(45, 45);
CALL insert_loan(46, 46);
CALL insert_loan(47, 47);
CALL insert_loan(48, 48);
CALL insert_loan(49, 49);
CALL insert_loan(50, 50);
