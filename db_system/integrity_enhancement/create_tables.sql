CREATE TABLE hotels (
    hotelNo serial PRIMARY KEY,
    hotelName varchar(50) NOT NULL,
    city varchar(50) NOT NULL
);

CREATE TABLE rooms (
    roomNo serial CHECK (roomNo BETWEEN 1 AND 100),
    hotelNo int NOT NULL,
    type varchar(50) NOT NULL CHECK (type IN ('Single', 'Double', 'Family')),
    price int NOT NULL CHECK (price BETWEEN 10 AND 100),
    FOREIGN KEY (hotelNo) REFERENCES hotels (hotelNo),
    PRIMARY KEY (roomNo, hotelNo)
);

CREATE TABLE guests (
    guestNo serial PRIMARY KEY,
    guestName varchar(50) NOT NULL,
    guestAddress varchar(50) NOT NULL
);

CREATE TABLE bookings (
    hotelNo int NOT NULL,
    guestNo int NOT NULL,
    dateFrom date NOT NULL CHECK (dateFrom > CURRENT_DATE),
    dateTo date NOT NULL CHECK (dateTo > CURRENT_DATE),
    roomNo int NOT NULL,
    PRIMARY KEY (hotelNo, guestNo, dateFrom),
    FOREIGN KEY (hotelNo) REFERENCES hotels (hotelNo),
    FOREIGN KEY (guestNo) REFERENCES guests (guestNo),
    FOREIGN KEY (roomNo, hotelNo) REFERENCES rooms (roomNo, hotelNo),
    CONSTRAINT valid_date CHECK (dateFrom <= dateTo)
);

ALTER TABLE bookings
    ADD CONSTRAINT unique_room_booking UNIQUE (hotelNo, roomNo, dateFrom);

ALTER TABLE bookings
    ADD CONSTRAINT unique_guest_booking UNIQUE (guestno, dateFrom);
