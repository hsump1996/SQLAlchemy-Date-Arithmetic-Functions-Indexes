DROP TABLE IF EXISTS eatery;

CREATE TABLE eatery (
    eatery_id serial primary key,
    name text,
    location text,
    park_id text,
    start_date date,
    end_date date,
    description text,
    permit_number text,
    phone text,
    website text,
    type_name text
);

