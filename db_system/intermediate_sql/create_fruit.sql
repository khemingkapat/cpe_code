CREATE TABLE fruit (
    year int,
    province_id varchar(3) NOT NULL,
    fruit_name varchar(50) NOT NULL,
    quantity int NOT NULL,
    FOREIGN KEY (province_id) REFERENCES province (province_acronym)
);
