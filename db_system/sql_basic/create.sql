CREATE TABLE student_info( 
    student_number SERIAL PRIMARY KEY, 
    student_id VARCHAR(12) NOT NULL, 
    student_firstname VARCHAR(50) NOT NULL, 
    student_lastname VARCHAR(50) NOT NULL 
);
