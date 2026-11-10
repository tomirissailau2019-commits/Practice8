import psycopg2
import json
from config import load_config


def connect():
    return psycopg2.connect(**load_config())


# 1. Search contacts
def search_contacts(pattern):
    with connect() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT * FROM search_contacts(%s)",
                (pattern,)
            )
            return cur.fetchall()


# 2. Add or update contact
def upsert_contact(first_name, second_name, phone):
    with connect() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "CALL upsert_contact(%s, %s, %s)",
                (first_name, second_name, phone)
            )


# 3. Bulk insert contacts from JSON
def bulk_insert_contacts(contacts):
    with connect() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "CALL bulk_insert_contacts(%s::jsonb, %s::jsonb)",
                (json.dumps(contacts), "[]")
            )
            result = cur.fetchone()
            return result[0] if result else []


# 4. Get contacts with pagination
def get_contacts_paginated(limit, offset):
    with connect() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT * FROM get_contacts_paginated(%s, %s)",
                (limit, offset)
            )
            return cur.fetchall()


# 5. Delete contact
def delete_contact(name=None, phone=None):
    with connect() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "CALL delete_contact(%s, %s)",
                (name, phone)
            )


# Main menu
while True:
    print("\n--- PHONEBOOK ---")
    print("1. Search contact")
    print("2. Add or update contact")
    print("3. Bulk insert")
    print("4. Show contacts (pagination)")
    print("5. Delete contact")
    print("0. Exit")

    choice = input("Choose: ")

    if choice == "1":
        pattern = input("Enter name or phone: ")
        for contact in search_contacts(pattern):
            print(contact)

    elif choice == "2":
        first = input("First name: ")
        second = input("Second name: ")
        phone = input("Phone: ")
        upsert_contact(first, second, phone)
        print("Contact saved!")

    elif choice == "3":
        contacts = [
            {
                "first_name": "Anna",
                "second_name": "Kim",
                "phone": "+77001112233"
            },
            {
                "first_name": "Test",
                "second_name": "User",
                "phone": "123"
            }
        ]
        invalid = bulk_insert_contacts(contacts)
        print("Invalid contacts:", invalid)

    elif choice == "4":
        limit = int(input("How many contacts: "))
        offset = int(input("Start from: "))
        for contact in get_contacts_paginated(limit, offset):
            print(contact)

    elif choice == "5":
        name = input("Name (or press Enter): ") or None
        phone = input("Phone (or press Enter): ") or None
        delete_contact(name, phone)
        print("Contact deleted!")

    elif choice == "0":
        break

    else:
        print("Wrong choice!")
