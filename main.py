# 5.	**Написать консольное приложение, использующее хранимые процедуры для работы с данными из базы данных. В зависимости от переданных логин-пароля от базы данных приложение должно корректно отрабатывать результаты хранимых процедур. Использовать ORM запрещено.

import psycopg2
import getpass

DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "library" # ваша БД, созданная вручную

def connect():
    print("=== Подключение к БД ===")
    user = input("Логин: ")
    password = getpass.getpass("Пароль: ")

    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            dbname=DB_NAME,
            user=user,
            password=password
        )
        conn.autocommit = True
        print("✔ Подключение успешно\n")
        return conn
    except Exception as e:
        print("Ошибка подключения:", e)
        return None


# ---- SELECT через REFCURSOR ----
def find_books(conn):
    title = input("Введите название: ")
    try:
        with conn.cursor() as cur:
            cur.execute("BEGIN;")
            cur.execute("CALL find_books_by_title(%s, %s);", (title, "my_cursor"))
            cur.execute("FETCH ALL FROM my_cursor;")
            rows = cur.fetchall()
            cur.execute("CLOSE my_cursor;")
            cur.execute("COMMIT;")

            if not rows:
                print("Ничего не найдено")
                return
            print("\nРезультаты:")
            for row in rows:
                print(row)

    except Exception as e:
        print("Ошибка:", e)


def find_reader(conn):
    email = input("Введите email: ")
    try:
        with conn.cursor() as cur:
            cur.execute("BEGIN;")
            cur.execute("CALL find_reader_by_email(%s, %s);", (email, "m_cursor"))
            cur.execute("FETCH ALL FROM m_cursor;")
            rows = cur.fetchall()
            cur.execute("CLOSE m_cursor;")
            cur.execute("COMMIT;")

            if not rows:
                print("Читатель не найден")
                return
            print("\nРезультаты:")
            for row in rows:
                print(row)
    except Exception as e:
        print("Ошибка:", e)


# ---- INSERT процедуры ----
def insert_book(conn):
    title = input("Название: ")
    author_id = input("ID автора: ")
    year = input("Год: ")
    try:
        with conn.cursor() as cur:
            cur.execute("CALL insert_book(%s, %s, %s)", (title, int(author_id), int(year)))
            print("✔ Книга добавлена")
    except Exception as e:
        print("Ошибка:", e)


def insert_reader(conn):
    name = input("Имя читателя: ")
    email = input("Email: ")
    try:
        with conn.cursor() as cur:
            cur.execute("CALL insert_reader(%s, %s)", (name, email))
            print("✔ Читатель добавлен")
    except Exception as e:
        print("Ошибка:", e)


def insert_author(conn):
    name = input("Имя автора: ")
    try:
        with conn.cursor() as cur:
            cur.execute("CALL insert_author(%s)", (name,))
            print("✔ Автор добавлен")
    except Exception as e:
        print("Ошибка:", e)


def insert_genre(conn):
    name = input("Название жанра: ")
    try:
        with conn.cursor() as cur:
            cur.execute("CALL insert_genre(%s)", (name,))
            print("✔ Жанр добавлен")
    except Exception as e:
        print("Ошибка:", e)


def insert_book_genre(conn):
    book_id = input("ID книги: ")
    genre_id = input("ID жанра: ")
    try:
        with conn.cursor() as cur:
            cur.execute("CALL insert_book_genre(%s,%s)", (int(book_id), int(genre_id)))
            print("✔ Жанр привязан к книге")
    except Exception as e:
        print("Ошибка:", e)


def insert_loan(conn):
    book_id = input("ID книги: ")
    reader_id = input("ID читателя: ")
    try:
        with conn.cursor() as cur:
            cur.execute("CALL insert_loan(%s,%s)", (int(book_id), int(reader_id)))
            print("✔ Книга выдана")
    except Exception as e:
        print("Ошибка:", e)


# ---- UPDATE процедуры ----
def update_book(conn):
    book_id = input("ID книги: ")
    title = input("Новое название: ")
    year = input("Новый год: ")
    try:
        with conn.cursor() as cur:
            cur.execute("CALL update_book(%s,%s,%s)", (int(book_id), title, int(year)))
            print("✔ Книга обновлена")
    except Exception as e:
        print("Ошибка:", e)


def update_reader_email(conn):
    reader_id = input("ID читателя: ")
    email = input("Новый email: ")
    try:
        with conn.cursor() as cur:
            cur.execute("CALL update_reader_email(%s,%s)", (int(reader_id), email))
            print("✔ Email обновлён")
    except Exception as e:
        print("Ошибка:", e)

def return_book(conn):
    loan_id = input("ID выдачи (loan_id): ")
    try:
        with conn.cursor() as cur:
            cur.execute("CALL return_book(%s)", (int(loan_id),))
            print("✔ Книга возвращена (дата возврата обновлена)")
    except Exception as e:
        print("Ошибка:", e)

def delete_book(conn):
    book_id = input("ID книги для удаления: ")
    try:
        with conn.cursor() as cur:
            cur.execute("CALL delete_book(%s)", (int(book_id),))
            print("✔ Книга и все связанные данные удалены")
    except Exception as e:
        print("Ошибка:", e)

def delete_reader(conn):
    reader_id = input("ID читателя для удаления: ")
    try:
        with conn.cursor() as cur:
            cur.execute("CALL delete_reader(%s)", (int(reader_id),))
            print("✔ Читатель и все его выдачи удалены")
    except Exception as e:
        print("Ошибка:", e)

# ---- Главное меню ----
def menu(conn):
    while True:
        print("\n--- МЕНЮ ---")
        print("1. Найти книги")
        print("2. Найти читателя по email")
        print("3. Добавить книгу")
        print("4. Добавить читателя")
        print("5. Добавить автора")
        print("6. Добавить жанр")
        print("7. Привязать жанр к книге")
        print("8. Выдать книгу")
        print("9. Обновить книгу")
        print("10. Обновить email читателя")
        print("11. Вернуть книгу")
        print("12. Удалить книгу")
        print("13. Удалить читателя")
        print("0. Выход")

        choice = input("Выбор: ")

        if choice == "1":
            find_books(conn)
        elif choice == "2":
            find_reader(conn)
        elif choice == "3":
            insert_book(conn)
        elif choice == "4":
            insert_reader(conn)
        elif choice == "5":
            insert_author(conn)
        elif choice == "6":
            insert_genre(conn)
        elif choice == "7":
            insert_book_genre(conn)
        elif choice == "8":
            insert_loan(conn)
        elif choice == "9":
            update_book(conn)
        elif choice == "10":
            update_reader_email(conn)
        elif choice == "11":
            return_book(conn)
        elif choice == "12":
            delete_book(conn)
        elif choice == "13":
            delete_reader(conn)
        elif choice == "0":
            print("Выход...")
            break
        else:
            print("Неверный выбор")


def main():
    conn = connect()
    if conn:
        with conn.cursor() as cur:
            cur.execute("SET search_path TO library;")
        menu(conn)
        conn.close()


if __name__ == "__main__":
    main()