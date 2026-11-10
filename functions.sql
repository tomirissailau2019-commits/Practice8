CREATE OR REPLACE FUNCTION search_contacts(search_text VARCHAR)
RETURNS TABLE (
    id INTEGER,
    first_name VARCHAR,
    second_name VARCHAR,
    phone VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT p.id, p.first_name, p.second_name, p.phone
    FROM phonebook p
    WHERE p.first_name ILIKE '%' || search_text || '%'
       OR p.second_name ILIKE '%' || search_text || '%'
       OR p.phone ILIKE '%' || search_text || '%';
END;
$$;


-- 2. Get contacts with pagination
CREATE OR REPLACE FUNCTION get_contacts_paginated(
    page_number INTEGER,
    page_size INTEGER
)
RETURNS TABLE (
    id INTEGER,
    first_name VARCHAR,
    second_name VARCHAR,
    phone VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF page_number < 1 OR page_size < 1 THEN
        RAISE EXCEPTION 'Page number and page size must be positive';
    END IF;

    RETURN QUERY
    SELECT p.id, p.first_name, p.second_name, p.phone
    FROM phonebook p
    ORDER BY p.id
    LIMIT page_size
    OFFSET (page_number - 1) * page_size;
END;
$$;
