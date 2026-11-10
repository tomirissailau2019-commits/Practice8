CREATE OR REPLACE PROCEDURE upsert_contact(
    p_first_name VARCHAR,
    p_second_name VARCHAR,
    p_phone VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM phonebook WHERE phone = p_phone) THEN
        UPDATE phonebook
        SET first_name = p_first_name,
            second_name = p_second_name
        WHERE phone = p_phone;
    ELSE
        INSERT INTO phonebook(first_name, second_name, phone)
        VALUES (p_first_name, p_second_name, p_phone);
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE bulk_insert_contacts(
    IN p_contacts JSONB,
    INOUT p_invalid_data JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    contact JSONB;
    v_first_name VARCHAR;
    v_second_name VARCHAR;
    v_phone VARCHAR;
BEGIN
    p_invalid_data := COALESCE(p_invalid_data, '[]'::JSONB);

    FOR contact IN SELECT * FROM jsonb_array_elements(p_contacts)
    LOOP
        v_first_name := contact->>'first_name';
        v_second_name := contact->>'second_name';
        v_phone := contact->>'phone';

        IF v_first_name IS NULL OR v_second_name IS NULL
           OR v_phone IS NULL
           OR v_phone !~ '^\+?[0-9]{10,15}$' THEN

            p_invalid_data := p_invalid_data || jsonb_build_array(contact);

        ELSE
            INSERT INTO phonebook(first_name, second_name, phone)
            VALUES (v_first_name, v_second_name, v_phone);
        END IF;
    END LOOP;
END;
$$;

CREATE OR REPLACE PROCEDURE delete_contact(
    p_name VARCHAR DEFAULT NULL,
    p_phone VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_name IS NULL AND p_phone IS NULL THEN
        RAISE EXCEPTION 'Enter a name or phone number';
    END IF;

    DELETE FROM phonebook
    WHERE (p_name IS NOT NULL AND
          (first_name = p_name OR second_name = p_name))
       OR (p_phone IS NOT NULL AND phone = p_phone);
END;
$$;
