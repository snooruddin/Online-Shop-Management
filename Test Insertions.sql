--insert into the employees table

--serveroutput shows the DBMS_OUTPUT in the output screen
SET SERVEROUTPUT ON;
DECLARE
    --this block is used to declare variables
    --f represents the file that we are going to read from
    --line will hold the records read from the file
    f UTL_FILE.FILE_TYPE;
    line VARCHAR(10000);
    
    --the following variables represent the attributes and types of data we are going to read from the file
    id employees.id%TYPE;
    name employees.name%TYPE;
    location employees.location%TYPE;
    contact employees.contact%TYPE;
    position employees.position%TYPE;
    salary employees.salary%TYPE;
BEGIN
    --we are going to open the file into READ mode
    --UTL_FILE.FOPEN('DIRECTORY NAME', 'FILE NAME', 'FILE MODE')
    f := UTL_FILE.FOPEN('DNAME','Employees.csv','R');
    IF UTL_FILE.IS_OPEN(f) THEN
        --delete all previous data from the employees table
        DELETE FROM employees;
    
        --if the file is successfully open, we now log the success
        DBMS_OUTPUT.PUT_LINE('Employee file opened for reading');
        INSERT INTO log(logDate, logFrom, logMsg) VALUES(TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy'), 'FOPEN', 'Employee file opened for reading');
        
        --this statement is for getting the first row in the file
        --the first row in the file contains the name of the attributes of the table
        --UTL_FILE.GET_LINE('from variable', 'to variable', maximum limit);
        UTL_FILE.GET_LINE(f, line, 10000);
        LOOP
            BEGIN
                UTL_FILE.GET_LINE(f, line, 10000);
                
                --REGEXP_SUBSTR('data container variable', 'RegExp', line_number, col_number)
                --the RegExp [^,]+ breaks the string in 'line' whenever a comma is found
                --we now store the data of each column(sttribute) to their respective variables
                id := REGEXP_SUBSTR(line, '[^,]+', 1, 1);
                name := REGEXP_SUBSTR(line, '[^,]+', 1, 2);
                location := REGEXP_SUBSTR(line, '[^,]+', 1, 3);
                contact := REGEXP_SUBSTR(line, '[^,]+', 1, 4);
                position := REGEXP_SUBSTR(line, '[^,]+', 1, 5);
                salary := REGEXP_SUBSTR(line, '[^,]+', 1, 6);
                
                --we now have all the data from a row of the data file
                --we now insert the data into the EmployeeS table
                INSERT INTO employees(id, name, location, contact, position, salary) VALUES(id, name, location, contact, position, salary);
                --commit the changes into the database
                COMMIT;
            EXCEPTION
                --when no_data_found meaning the end of file then exit the procedure
                WHEN NO_DATA_FOUND THEN EXIT;
            END;
        END LOOP;
    END IF;
    UTL_FILE.FCLOSE(f);    
END;
--show errors is used to show errors produced by procedures and such in toad
SHOW ERRORS;
/    

--insert into the customers table

DECLARE
    f UTL_FILE.FILE_TYPE;
    line VARCHAR(10000);
    
    id customers.id%TYPE;
    name customers.name%TYPE;
    location customers.location%TYPE;
    contact customers.contact%TYPE;
BEGIN
    f := UTL_FILE.FOPEN('DNAME','Customers.csv','R');
    IF UTL_FILE.IS_OPEN(f) THEN
        DELETE FROM customers;
        DBMS_OUTPUT.PUT_LINE('Customers file opened for reading');
        INSERT INTO log(logDate, logFrom, logMsg) VALUES(TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy'), 'FOPEN', 'Customers file opened for reading');
        UTL_FILE.GET_LINE(f, line, 10000);
        LOOP
            BEGIN
                UTL_FILE.GET_LINE(f, line, 10000);

                id := REGEXP_SUBSTR(line, '[^,]+', 1, 1);
                name := REGEXP_SUBSTR(line, '[^,]+', 1, 2);
                location := REGEXP_SUBSTR(line, '[^,]+', 1, 3);
                contact := REGEXP_SUBSTR(line, '[^,]+', 1, 4);
                
                INSERT INTO customers(id, name, location, contact) VALUES(id, name, location, contact);
                
                COMMIT;
            EXCEPTION
                
                WHEN NO_DATA_FOUND THEN EXIT;
            END;
        END LOOP;
    END IF;
    UTL_FILE.FCLOSE(f);    
END;
SHOW ERRORS;
/    

--insert data into products
DECLARE
    f UTL_FILE.FILE_TYPE;
    line VARCHAR(10000);
    
    id customers.id%TYPE;
    name customers.name%TYPE;
    manufacturer PRODUCTS.MANUFACTURER%TYPE;
    prodtype products.type%TYPE;
    prodsubtype PRODUCTS.SUBTYPE%TYPE;
    price PRODUCTS.PRICE%TYPE;
    quant PRODUCTS.QUANTITYINSTOCK%TYPE;
    
BEGIN
    f := UTL_FILE.FOPEN('DNAME','Products.csv','R');
    IF UTL_FILE.IS_OPEN(f) THEN
        DELETE FROM products;
        DBMS_OUTPUT.PUT_LINE('Products file opened for reading');
        INSERT INTO log(logDate, logFrom, logMsg) VALUES(TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy'), 'FOPEN', 'Products file opened for reading');
        UTL_FILE.GET_LINE(f, line, 10000);
        LOOP
            BEGIN
                UTL_FILE.GET_LINE(f, line, 10000);

                id := REGEXP_SUBSTR(line, '[^,]+', 1, 1);
                name := REGEXP_SUBSTR(line, '[^,]+', 1, 2);
                manufacturer := REGEXP_SUBSTR(line, '[^,]+', 1, 3);
                prodtype := REGEXP_SUBSTR(line, '[^,]+', 1, 4);
                prodsubtype := REGEXP_SUBSTR(line, '[^,]+', 1, 5);
                price := REGEXP_SUBSTR(line, '[^,]+', 1, 6);
                quant := REGEXP_SUBSTR(line, '[^,]+', 1, 7);
                
                INSERT INTO products(id, name, manufacturer, type, subtype, price, quantityInStock) VALUES(id, name, manufacturer, prodtype, prodsubtype, price, quant);
                
                COMMIT;
            EXCEPTION
                
                WHEN NO_DATA_FOUND THEN EXIT;
            END;
        END LOOP;
    END IF;
    UTL_FILE.FCLOSE(f);    
END;
SHOW ERRORS;
/    