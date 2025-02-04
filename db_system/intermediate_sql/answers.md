# 1 Create new database name `cpe_dblab3`
via pgAdmin

# 2 Create table and insert information
create by [create_province.sql](https://github.com/khemingkapat/cpe_code/blob/main/db_system/intermediate_sql/create_province.sql), [create_fruit.sql](https://github.com/khemingkapat/cpe_code/blob/main/db_system/intermediate_sql/create_fruit.sql)

and insert information with [insert_province.sql](https://github.com/khemingkapat/cpe_code/blob/main/db_system/intermediate_sql/insert_province.sql), [insert_fruit.sql](https://github.com/khemingkapat/cpe_code/blob/main/db_system/intermediate_sql/insert_fruit.sql)

# 3 Group by `year`
group `fruit` table by year and the sum up `quantity` by
```sql
select sum(quantity) as yearly_quantity from fruit group by year;
```

# 4 Group by `province_id`
group `fruit` table with `province_id` and find the `avg` of `quantity`
```sql
select avg(quantity) as province_avg_quantity from fruit group by province_id;
```

# 5 Show quantity more than 4000 with ascending order
we filter using `where` and `order by` quantity
```sql
select * from fruit where quantity > 4000 order by quantity;
```

# 6 Join table
using inner `join` 
```sql
select year, province_id,p.province_name,fruit_name,quantity 
from fruit f,province p 
where p.province_acronym = f.province_id;
```
