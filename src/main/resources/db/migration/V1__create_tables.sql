CREATE TYPE enum_staff_position7 AS ENUM ('SALE', 'WAREHOUSE', 'MANAGEMENT', 'TECHNICAL');

CREATE TYPE enum_appointment_status7 AS ENUM ('PENDING', 'CONFIRMED', 'CANCELLED', 'DONE');

CREATE TABLE tbl_member7 (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username text NOT NULL UNIQUE,
    password_hashed text NOT NULL,

    CONSTRAINT tbl_member7_username_not_blank CHECK (btrim(username) <> ''),
    CONSTRAINT tbl_member7_password_hashed_not_blank CHECK (btrim(password_hashed) <> '')
);

CREATE TABLE tbl_customer7 (
    fullname text NOT NULL,
    phone_number text NOT NULL UNIQUE,
    member7_id bigint PRIMARY KEY REFERENCES tbl_member7 (id) ON DELETE CASCADE,

    CONSTRAINT tbl_customer7_fullname_not_blank CHECK (btrim(fullname) <> ''),
    CONSTRAINT tbl_customer7_phone_number_not_blank CHECK (btrim(phone_number) <> '')
);

CREATE TABLE tbl_staff7 (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fullname text NOT NULL,
    phone_number text NOT NULL UNIQUE,
    email text NOT NULL UNIQUE,
    birth_date date NOT NULL,
    position enum_staff_position7 NOT NULL,
    member7_id bigint UNIQUE REFERENCES tbl_member7 (id) ON DELETE RESTRICT,

    CONSTRAINT tbl_staff7_fullname_not_blank CHECK (btrim(fullname) <> ''),
    CONSTRAINT tbl_staff7_phone_number_not_blank CHECK (btrim(phone_number) <> ''),
    CONSTRAINT tbl_staff7_email_not_blank CHECK (btrim(email) <> '')
);

CREATE TABLE tbl_technical_staff7 (
    level text NOT NULL,
    specialty text NOT NULL,
    staff7_id bigint PRIMARY KEY REFERENCES tbl_staff7 (id) ON DELETE CASCADE,

    CONSTRAINT tbl_technical_staff7_level_not_blank CHECK (btrim(level) <> ''),
    CONSTRAINT tbl_technical_staff7_specialty_not_blank CHECK (btrim(specialty) <> '')
);

CREATE TABLE tbl_service7 (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL,
    price numeric(15, 2) NOT NULL,
    duration_minutes integer,
    description text,
    available boolean NOT NULL DEFAULT true,

    CONSTRAINT tbl_service7_name_not_blank CHECK (btrim(name) <> ''),
    CONSTRAINT tbl_service7_description_not_blank CHECK (btrim(description) <> ''),
    CONSTRAINT tbl_service7_price_non_negative CHECK (price >= 0),
    CONSTRAINT tbl_service7_duration_minutes_positive CHECK (duration_minutes > 0)
);

CREATE TABLE tbl_spare_part7 (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    barcode text UNIQUE,
    name text NOT NULL,
    unit text NOT NULL,
    producer text,
    unit_price numeric(15, 2) NOT NULL,
    stock_quantity integer NOT NULL,
    description text,

    CONSTRAINT tbl_spare_part7_barcode_not_blank CHECK (btrim(barcode) <> ''),
    CONSTRAINT tbl_spare_part7_name_not_blank CHECK (btrim(name) <> ''),
    CONSTRAINT tbl_spare_part7_unit_not_blank CHECK (btrim(unit) <> ''),
    CONSTRAINT tbl_spare_part7_producer_not_blank CHECK (btrim(producer) <> ''),
    CONSTRAINT tbl_spare_part7_description_not_blank CHECK (btrim(description) <> ''),
    CONSTRAINT tbl_spare_part7_unit_price_non_negative CHECK (unit_price >= 0),
    CONSTRAINT tbl_spare_part7_stock_quantity_non_negative CHECK (stock_quantity >= 0)
);

CREATE TABLE tbl_spare_part_image7 (
    ordinal integer NOT NULL,
    content_type text NOT NULL,
    data bytea NOT NULL,
    spare_part7_id bigint NOT NULL REFERENCES tbl_spare_part7 (id) ON DELETE CASCADE,

    PRIMARY KEY (spare_part7_id, ordinal),
    CONSTRAINT tbl_spare_part_image7_content_type_image CHECK (content_type LIKE 'image/%'),
    CONSTRAINT tbl_spare_part_image7_data_not_empty CHECK (octet_length(data) > 0),
    CONSTRAINT tbl_spare_part_image7_ordinal_not_negative CHECK (ordinal >= 0)
);

CREATE TABLE tbl_supplier7 (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL,
    address text NOT NULL,
    phone_number text NOT NULL UNIQUE,
    email text,
    description text,

    CONSTRAINT tbl_supplier7_name_not_blank CHECK (btrim(name) <> ''),
    CONSTRAINT tbl_supplier7_address_not_blank CHECK (btrim(address) <> ''),
    CONSTRAINT tbl_supplier7_phone_number_not_blank CHECK (btrim(phone_number) <> ''),
    CONSTRAINT tbl_supplier7_email_not_blank CHECK (btrim(email) <> ''),
    CONSTRAINT tbl_supplier7_description_not_blank CHECK (btrim(description) <> '')
);

CREATE TABLE tbl_appointment7 (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    booking_at timestamp NOT NULL,
    problem_description text,
    status enum_appointment_status7 NOT NULL,
    customer7_id bigint NOT NULL REFERENCES tbl_customer7 (member7_id) ON DELETE RESTRICT,

    CONSTRAINT tbl_appointment7_problem_description_not_blank CHECK (btrim(problem_description) <> '')
);

CREATE TABLE tbl_sale_order7 (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    received_at timestamptz NOT NULL,
    vehicle_license_plate text NOT NULL,
    vehicle_model text NOT NULL,
    notes text,
    customer7_id bigint NOT NULL REFERENCES tbl_customer7 (member7_id) ON DELETE RESTRICT,

    CONSTRAINT tbl_sale_order7_vehicle_license_plate_not_blank CHECK (btrim(vehicle_license_plate) <> ''),
    CONSTRAINT tbl_sale_order7_vehicle_model_not_blank CHECK (btrim(vehicle_model) <> ''),
    CONSTRAINT tbl_sale_order7_notes_not_blank CHECK (btrim(notes) <> '')
);

CREATE TABLE tbl_sale_service_detail7 (
    sold_price numeric(15, 2) NOT NULL,
    begin_at timestamp,
    end_at timestamp,
    notes text,
    technical_staff7_id bigint NOT NULL REFERENCES tbl_technical_staff7 (staff7_id) ON DELETE RESTRICT,
    sale_order7_id bigint NOT NULL REFERENCES tbl_sale_order7 (id) ON DELETE CASCADE,
    service7_id bigint NOT NULL REFERENCES tbl_service7 (id) ON DELETE RESTRICT,

    PRIMARY KEY (sale_order7_id, service7_id),
    CONSTRAINT tbl_sale_service_detail7_notes_not_blank CHECK (btrim(notes) <> ''),
    CONSTRAINT tbl_sale_service_detail7_sold_price_non_negative CHECK (sold_price >= 0),
    CONSTRAINT tbl_sale_service_detail7_end_at_after_begin_at CHECK (end_at >= begin_at)
);

CREATE TABLE tbl_sale_part_detail7 (
    quantity integer NOT NULL,
    sold_unit_price numeric(15, 2) NOT NULL,
    notes text,
    sale_order7_id bigint NOT NULL REFERENCES tbl_sale_order7 (id) ON DELETE CASCADE,
    spare_part7_id bigint NOT NULL REFERENCES tbl_spare_part7 (id) ON DELETE RESTRICT,

    PRIMARY KEY (sale_order7_id, spare_part7_id),
    CONSTRAINT tbl_sale_part_detail7_notes_not_blank CHECK (btrim(notes) <> ''),
    CONSTRAINT tbl_sale_part_detail7_quantity_positive CHECK (quantity > 0),
    CONSTRAINT tbl_sale_part_detail7_sold_unit_price_non_negative CHECK (sold_unit_price >= 0)
);

CREATE TABLE tbl_sale_invoice7 (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    paid_at timestamptz NOT NULL,
    notes text,
    sale_order7_id bigint NOT NULL UNIQUE REFERENCES tbl_sale_order7 (id) ON DELETE RESTRICT,
    sale_staff7_id bigint NOT NULL REFERENCES tbl_staff7 (id) ON DELETE RESTRICT,

    CONSTRAINT tbl_sale_invoice7_notes_not_blank CHECK (btrim(notes) <> '')
);

CREATE TABLE tbl_import_invoice7 (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    imported_at timestamptz NOT NULL,
    notes text,
    supplier7_id bigint NOT NULL REFERENCES tbl_supplier7 (id) ON DELETE RESTRICT,
    warehouse_staff7_id bigint NOT NULL REFERENCES tbl_staff7 (id) ON DELETE RESTRICT,

    CONSTRAINT tbl_import_invoice7_notes_not_blank CHECK (btrim(notes) <> '')
);

CREATE TABLE tbl_import_part_detail7 (
    quantity integer NOT NULL,
    imported_unit_price numeric(15, 2) NOT NULL,
    notes text,
    import_invoice7_id bigint NOT NULL REFERENCES tbl_import_invoice7 (id) ON DELETE CASCADE,
    spare_part7_id bigint NOT NULL REFERENCES tbl_spare_part7 (id) ON DELETE RESTRICT,

    PRIMARY KEY (import_invoice7_id, spare_part7_id),
    CONSTRAINT tbl_import_part_detail7_notes_not_blank CHECK (btrim(notes) <> ''),
    CONSTRAINT tbl_import_part_detail7_quantity_positive CHECK (quantity > 0),
    CONSTRAINT tbl_import_part_detail7_imported_unit_price_non_negative CHECK (imported_unit_price >= 0)
);

CREATE INDEX ON tbl_appointment7 (customer7_id);
CREATE INDEX ON tbl_sale_order7 (customer7_id);
CREATE INDEX ON tbl_sale_service_detail7 (technical_staff7_id);
CREATE INDEX ON tbl_sale_service_detail7 (service7_id);
CREATE INDEX ON tbl_sale_part_detail7 (spare_part7_id);
CREATE INDEX ON tbl_sale_invoice7 (sale_staff7_id);
CREATE INDEX ON tbl_import_invoice7 (supplier7_id);
CREATE INDEX ON tbl_import_invoice7 (warehouse_staff7_id);
CREATE INDEX ON tbl_import_part_detail7 (spare_part7_id);
