# 1 Create new database name `cpe_dblab2`
create it inside pgAdmin

# 2 Create table with information,
using [create_branch.sql](https://github.com/khemingkapat/cpe_code/blob/main/db_system/CRUD_commands/create_branch.sql), [create_staff.sql](https://github.com/khemingkapat/cpe_code/blob/main/db_system/CRUD_commands/create_staff.sql)

after that, insert by [insert_branch.sql](https://github.com/khemingkapat/cpe_code/blob/main/db_system/CRUD_commands/insert_branch.sql), [insert_staff.sql](https://github.com/khemingkapat/cpe_code/blob/main/db_system/CRUD_commands/insert_staff.sql) 

# 3 Basic Query Command
## 3.1 Select every row
to select every row from the table use
```sql
select * from staff;
```

## 3.2 Select staff whose last name is "Johnson"
using `LIKE` to filter it
```sql
select * from staff where lastName = "Johnson";
```

## 3.3 Select staff whose first name starts with "A"
we use string matching with `A%` as anything that start with `A` with `LIKE`
```sql
select * from staff where firstName like 'A%';
```

## 3.4 Select every row from branch table
```sql
select * from branch;
```

# 4 Join table
using inner join since everything is common in both table(as property of primary key and foreign key)
```sql
select s.*, b.branchLocation from staff s,branch b where s.branch_id = b.branch_id;
```

# 5 Update Information in table
using `update`
```sql
update staff set phoneNumber = '044 556 7788'
where firstName = 'Carla' and lastName = 'Nguyen';
```

# 6 Delete specific row
using `delete`
```sql
delete from staff where firstName = 'Allen' and lastName = 'Smith';
```

# 7 Delete table
we could delete all rows in table by
```sql
delete from staff;
```
and drop the whole table with
```sql
drop table staff;
```

