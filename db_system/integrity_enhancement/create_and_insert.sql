CREATE TABLE hotels (
    hotelNo serial PRIMARY KEY, -- serial for it to automatically icrease if needed
    hotelName varchar(50) NOT NULL, -- hotelName is needed
    city varchar(50) NOT NULL -- city is needed also
);

CREATE TABLE rooms (
    roomNo serial CHECK (roomNo BETWEEN 1 AND 100), -- again, use serial, but check between 1-100 since it is constraint
    hotelNo int NOT NULL, -- hotelNo as a foreign key to hotels table, needed
    type varchar(50) NOT NULL CHECK (type IN ('Single', 'Double', 'Family')), -- specifiy the domain of room type
    price int NOT NULL CHECK (price BETWEEN 10 AND 100), -- price as int and within range
    FOREIGN KEY (hotelNo) REFERENCES hotels (hotelNo) ON DELETE CASCADE, -- use delete on cascade since if hotel if delte, we would delete the row with that hotel
    PRIMARY KEY (roomNo, hotelNo) -- create composite primary key since we hotelNo wouldn't be unique
);

CREATE TABLE guests (
    guestNo serial PRIMARY KEY, -- again, serial
    guestName varchar(50) NOT NULL,
    guestAddress varchar(50) NOT NULL
);

CREATE TABLE bookings (
    hotelNo int NOT NULL, -- hotelNo as foreign key
    guestNo int NOT NULL, -- geustNo as foriegn key also
    dateFrom date CHECK (dateFrom > CURRENT_DATE), -- dateFrom as type of date, and need to be more
    dateTo date CHECK (dateTo > CURRENT_DATE), -- same as dateFrom
    roomNo int NOT NULL, -- as foriegn key
    PRIMARY KEY (hotelNo, guestNo, dateFrom), -- composite pk since one alone is not unique
    -- these three are to specify the foriegn key
    FOREIGN KEY (hotelNo) REFERENCES hotels (hotelNo) ON DELETE CASCADE,
    FOREIGN KEY (guestNo) REFERENCES guests (guestNo) ON DELETE CASCADE,
    FOREIGN KEY (roomNo, hotelNo) REFERENCES rooms (roomNo, hotelNo) ON DELETE CASCADE,
    -- check the common sense of the date
    CONSTRAINT valid_date CHECK (dateFrom <= dateTo)
);

-- this use to make sure no room is book the same date, I think for better we need subquery as constraint, but we couldn't use it
ALTER TABLE bookings
    ADD CONSTRAINT unique_room_booking UNIQUE (hotelNo, roomNo, dateFrom);

-- again, this is for no guest could book 2 room at the same time, idk why, doesn't make so much sence for rich people
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
