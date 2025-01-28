CREATE TABLE staff (
    branch_id int,
    staff_id serial PRIMARY KEY,
    firstName varchar(50) NOT NULL,
    lastName varchar(50) NOT NULL,
    phoneNumber varchar(50) NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES branch (branch_id)
);

ALTER SEQUENCE staff_staff_id_seq
    RESTART WITH 100;
