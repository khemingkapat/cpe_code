CREATE TABLE staff (
    staff_id serial PRIMARY KEY,
    firstName varchar(50) NOT NULL,
    lastName varchar(50) NOT NULL,
    DOB varchar(11) NOT NULL,
    position varchar(50) NOT NULL,
    salary varchar(7) NOT NULL
);

ALTER SEQUENCE staff_staff_id_seq
    RESTART WITH 101;
