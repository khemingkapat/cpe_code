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
    FOREIGN KEY (hotelNo) REFERENCES hotels (hotelNo) ON DELETE CASCADE,
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
    dateFrom date CHECK (dateFrom > CURRENT_DATE),
    dateTo date CHECK (dateTo > CURRENT_DATE),
    roomNo int NOT NULL,
    PRIMARY KEY (hotelNo, guestNo, dateFrom),
    FOREIGN KEY (hotelNo) REFERENCES hotels (hotelNo) ON DELETE CASCADE,
    FOREIGN KEY (guestNo) REFERENCES guests (guestNo) ON DELETE CASCADE,
    FOREIGN KEY (roomNo, hotelNo) REFERENCES rooms (roomNo, hotelNo) ON DELETE CASCADE,
    CONSTRAINT valid_date CHECK (dateFrom <= dateTo)
);

ALTER TABLE bookings
    ADD CONSTRAINT unique_room_booking UNIQUE (hotelNo, roomNo, dateFrom);

ALTER TABLE bookings
    ADD CONSTRAINT unique_guest_booking UNIQUE (guestno, dateFrom);

INSERT INTO hotels (hotelNo, hotelName, city)
    VALUES (1, 'Grosvenor Hotel', 'London'),
    (2, 'Imperial Hotel', 'London'),
    (3, 'Waterfront Lodge', 'London'),
    (4, 'Riverside Inn', 'Manchester'),
    (5, 'Ocean Breeze Hotel', 'Brighton'),
    (6, 'Royal Plaza', 'London'),
    (7, 'Mountain View Lodge', 'Edinburgh'),
    (8, 'Central Hotel', 'London'),
    (9, 'Seaside Resort', 'Brighton'),
    (10, 'Park Hotel', 'London');

INSERT INTO rooms (roomNo, hotelNo, type, price)
    VALUES (1, 1, 'Single', 35.00),
    (2, 1, 'Double', 38.00),
    (3, 1, 'Family', 85.00),
    (4, 1, 'Single', 32.00),
    (5, 2, 'Double', 39.50),
    (6, 2, 'Family', 75.00),
    (7, 3, 'Single', 30.00),
    (8, 3, 'Double', 42.00),
    (9, 4, 'Family', 95.00),
    (10, 5, 'Double', 55.00);

INSERT INTO guests (guestNo, guestName, guestAddress)
    VALUES (1, 'Alice Smith', '123 Oxford St, London'),
    (2, 'Bob Johnson', '456 Baker St, London'),
    (3, 'Carol Williams', '789 Bond St, London'),
    (4, 'David Brown', '321 King St, Manchester'),
    (5, 'Emma Davis', '654 Queen St, Brighton'),
    (6, 'Frank Wilson', '987 Park Lane, London'),
    (7, 'Grace Taylor', '147 Rose St, Edinburgh'),
    (8, 'Henry Martin', '258 Pine Rd, London'),
    (9, 'Ivy Thompson', '369 Oak Ave, Brighton'),
    (10, 'Jack Anderson', '741 Elm St, London');

INSERT INTO bookings (hotelNo, guestNo, dateFrom, dateTo, roomNo)
    VALUES
    -- (1, 1, '2025-02-08', '2025-02-15', 1),
    -- (1, 2, '2025-02-08', '2025-02-12', 2),
    (1, 3, '2025-08-01', '2025-08-07', 3),
    (2, 4, '2025-08-05', '2025-08-10', 5),
    -- (2, 5, '2025-02-08', '2025-02-11', 6),
    (3, 6, '2025-08-15', '2025-08-20', 7),
    (3, 7, '2025-03-01', '2025-03-05', 8),
    (4, 8, '2025-08-20', '2025-08-25', 9),
    (5, 9, '2025-04-01', NULL, 10),
    (1, 10, '2025-08-10', '2025-08-15', 4);
