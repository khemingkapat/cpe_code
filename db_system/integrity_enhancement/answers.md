# Create Table and Insert
using [this](https://github.com/khemingkapat/cpe_code/blob/main/db_system/integrity_enhancement/create_and_insert.sql) file to insert, run with `psql` by
```bash
psql -U <username> -d <db_name> -a -f create_and_insert.sql
```

with many integrity enhancing function such as
- domain constraint, `type` of room in `rooms` table
- general constraint, `price` of room in `rooms` and `dateFrom` and `dateTo` to check if booking date is valid

> note that if it could use the subquery as a constraint, it would be so much better

# Simple Query
## List full detail of all `hotels`
```sql
select * from hotels;
```

## List only hotel in London
this is easy, just use `where` clause
```sql
select * from hotels where city = `London`;
```
## List the names and addresses of all guests living in London, alphabetically ordered by name.
we use string comparision with `like` to see which addresses end with **London**
```sql
select guestName from guests where guestAddress like '%London' order by guestName;
```
## List all double or family rooms with a price below £40.00 per night, in ascending order of price.
so we list by `in` and check if the `type` of room is in the list we want
```sql
select * from room where type in ('Double','Family')
```

## List the bookings for which no dateTo has been specified.
so there is one row that the `dateTo` in `bookings` table is not specified, so we find by
```sql
select * from bookings where dateTo is NULL;
```
# Aggregate functions
often use with `group by` to perform aggregation, calculating statistics
## How many hotels are there?
```sql
select count(*) from hotels;
```
## What is the average price of a room?
```sql
select avg(price) from rooms;
```
## What is the total revenue per night from all double rooms?
kinda similar to last one but with `where` to filter the double room and use sum instead
```sql
select sum(price) from rooms where type = 'Double';
```
## How many different guests have made bookings for August?
to see how many, we need to use `extract` to get the `month` information from `date` data type
```sql
select count(distinct guestNo) from bookings where
extract(month from dateFrom) = 8 or
extract(month from dateTo) = 8;
```
we use `distinct` to prevent counting the same guest when they do multiple booking in same month

# Subqueries and joins
when we want to do the query with the information of another query

and grouping is to do the aggregate function
## List the price and type of all rooms at the Grosvenor Hotel.
this would use `join` (to be specific `inner join`) of `rooms` and `hotels` to filter by `hotelName` and see the `price`
```sql
select  r.price , r.type from rooms r, hotels s
where h.hotelName = 'Grosvenor Hotel' and
r.hotelNo = h.hotelNo;
```
## List all guests currently staying at the Grosvenor Hotel.
a little more complicated, use `inner join` of `guests`, `bookings` and `hotels` to filter by `hotelName` and to see which guest book hotel in that `hotelName`
```sql
select g.* from guests g, hotels h, bookings b
where h.hotelfname = 'Grosvenor Hotel'
and b.hotelNo = h.hotelNo
and b.guestNo = g.guestNo;
```
## List the details of all rooms at the Grosvenor Hotel, including the name of the guest staying in the room, if the room is occupied.
we use the `outer join` so we could list the room even if it is not occupied, so we `join` of 4 tables, we could use `inner join` of the `rooms` and `hotels`

then we need to use `left outer join` or that join with `bookings` since we want the room that is occupied and unoccupied. then `left outer join` again for `guests` for same purpose
```sql
select r.*,g.guestName from rooms r join hotels h on r.hotelNo = h.hotelNo
left outer join bookings b on r.roomNo = b.roomNo and r.hotelNo = b.hotelNo
left outer join guests on b.guestNo = g.guestNo
where h.hotelName = 'Grosvenor Hotel';
```
## What is the total income from bookings for the Grosvenor Hotel today?
use `sum` aggregation function and filter the hotel by `current_date`
```sql
select sum(price) from rooms r, hotels h, bookings b
where h.hotelName = 'Grosvenor Hotel'
and b.hotelNo = h.hotelNo
and current_date between b.dateFrom and b.dateTo
and r.roomNo = b.roomNo and r.hotelNo = b.hotelNo
```
## List the rooms that are currently unoccupied at the Grosvenor Hotel.
to see unoccupied, we need to make sure that that room no is not in the `bookings` table column `roomNo`
```sql
select r.* from rooms r, hotels h where r.roomNo not in
(select b.roomNo from bookings b, hotels h
where h.hotelName = 'Grosvenor Hotel'
and h.hotelNo = b.hotelNo)
and h.hotelName = 'Grosvenor'
and r.hotelNo = h.hotelNo;
```
## What is the lost income from unoccupied rooms at the Grosvenor Hotel?
so we sum up the total price of unoccupied room
```sql
select sum(r.price) from rooms r, hotels h where r.roomNo not in
(select b.roomNo from bookings b, hotels h
where h.hotelName = 'Grosvenor Hotel'
and h.hotelNo = b.hotelNo)
and h.hotelName = 'Grosvenor'
and r.hotelNo = h.hotelNo;
```
# Grouping
group row by property of some column
## List the number of rooms in each hotel.
again, the aggregation function
```sql
select h.hotelName, count(r.*) as numbers_of_room
from hotels h join rooms r on h.hotelNo = r.hotelNo
group by h.hotelName;
```
## List the number of rooms in each hotel in London.
like the last one but filter with `where`
```sql
select h.hotelName, count(r.*) as numbers_of_room
from hotels h join rooms r on h.hotelNo = r.hotelNo and h.city = 'London'
group by h.hotelName;
```
## What is the average number of bookings for each hotel in August?
we need to `avg` the `count` of each hotel booked room
```sql
select avg(count) from
(select count(*) from bookings where
(extract(month from dateFrom)) = 8 or
(extract(month from dateTo)) = 8 or
((extract(month from dateFrom)) < 8 and (extract(month from dateTo)) > 8)
group by hotelNo);
```
## What is the most commonly booked room type for each hotel in London?
this is tricky, i create the `view` name `tbc` to see `booking_count` first
```sql
create view tbc as select
h.hotelName,
r.type,
count(*) as booking_count
from bookings b join hotels h on b.hotelNo = h.hotelNo
join rooms r on b.hotelNo = r.hotelNo and b.roomNo = r.roomNo
where h.city = 'London'
group by h.hotelName,r.type
order by h.hotelName,booking_count DESC;
```

then I will filter using the `hotelName` and `booking_count` on the max
```sql
select hotelName,type,booking_count from tbc where (hotelName,booking_count) in
(select hotelName,max(booking_count) as booking_count from tbc group by hotelName);
```
## What is the lost income from unoccupied rooms at each hotel today?
so we filter the room that is not in today `bookings` and `sum` up the `price`
```sql
select h.hotelName,sum(r.price) from rooms r join hotels h on r.hotelNo = h.hotelNo
where r.roomNo not in (select roomNo from bookings where current_date between dateFrom and dateTo);
```
# Populating tables
## Insert rows into each of these tables.
```sql
insert into bookings(hotelNo,guestNo,dateFrom,dateTo,roomNo)
values (1,10,'2025-09-10','2025-09-15',4);
```
## Update the price of all rooms by 5%.
```sql
update rooms set price = price*1.05;
```
