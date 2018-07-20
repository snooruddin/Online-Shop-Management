--NUMBER 2 ON DESIGN
/*
 *  Function Name : resetDiscountsOnAllProducts
 *  Return Type : NUMBER
 *
 *  Description : Resets discount on all the products and return their price to original value before discount
 *                Return the number of products updated.
 */
CREATE OR REPLACE FUNCTION resetDiscountsOnAllProducts
    RETURN NUMBER
    AS
        F UTL_FILE.FILE_TYPE;
        LINE VARCHAR(10000);
        
        prodId PRODUCTS.ID%TYPE;
        actualPrice PRODUCTS.PRICE%TYPE;
        updated NUMBER;
    BEGIN
        updated := 0;
        F := UTL_FILE.FOPEN('DNAME','ActualPrice.csv', 'R');
        IF UTL_FILE.IS_OPEN(F) THEN
            DBMS_OUTPUT.PUT_LINE('ActualPrice.csv OPENED FOR READING');
            UTL_FILE.GET_LINE(F, LINE, 10000);
            LOOP
                UTL_FILE.GET_LINE(F, LINE, 10000);
                
                prodId := REGEXP_SUBSTR(LINE, '[^,]+', 1, 1);
                actualPrice := REGEXP_SUBSTR(LINE, '[^,]+', 1, 2);
                
                --update all the products whose id were in the file
                UPDATE products
                    SET price = actualPrice
                WHERE id = prodId;
                
                updated := updated + 1;
            END LOOP;
        END IF;
        UTL_FILE.FCLOSE(F);
        
        --log the function
        INSERT INTO log(logDate, logFrom, logMsg)
            VALUES(TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy'), 'Function: resetDiscountsOnAllProducts', 'Updated : ' || updated);
            
        COMMIT;
        
        RETURN updated;
    END;
SHOW ERRORS;

--number 3 on design
/*
 *  Function Name : grossSale
 *  Return Type : NUMBER
 *
 *  Description : Return total sale of all products in record
 *
 */
CREATE OR REPLACE FUNCTION grossSale
    RETURN NUMBER
    AS
        totalSales ORDERS.CUSTOMERPAID%TYPE := 0;
    BEGIN
        SELECT SUM(customerPaid) INTO totalSales FROM orders ;
        RETURN totalSales;
        
        --log the function
        INSERT INTO log(logDate, logFrom, logMsg)
            VALUES(TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy'), 'Function: grossSale', 'Total Sold : ' || totalSales);
        
        COMMIT;

    END;
SHOW ERRORS;
    
--NUMBER 4 ON DESIGN
/*
 *  Function Name : totalPaidToEmployees
 *  Return Type : NUMBER
 *
 *  Description : Return total amount of commission and salary to be paid to employees
 *
 */
CREATE OR REPLACE FUNCTION totalPaidToEmployees
    RETURN NUMBER
    --REMEMBER TO CHECK IF NEW MONTH
    AS
        CURSOR employee_pay 
            IS
                SELECT commission, salary FROM employees;
        singleCommission EMPLOYEES.COMMISSION%TYPE;
        singleSalary EMPLOYEES.SALARY%TYPE;
        totalCommission EMPLOYEES.COMMISSION%TYPE := 0;
        totalSalary EMPLOYEES.SALARY%TYPE := 0;
        totalReturn NUMBER(9,2);
    BEGIN
        OPEN employee_pay;
        LOOP
            FETCH employee_pay INTO singleCommission, singleSalary;
                EXIT WHEN employee_pay%NOTFOUND; 
            totalCommission := totalCommission + singleCommission;
            totalSalary := totalSalary + singleSalary;
        END LOOP;
        totalReturn := totalCommission + totalSalary;
        CLOSE employee_pay;
        
        --log the function
        INSERT INTO log(logDate, logFrom, logMsg)
            VALUES(TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy'), 'Function: totalPaidToEmployees', 'Total Paid : ' || totalReturn);
        
        COMMIT;
        
        RETURN totalReturn;
    END;
SHOW ERRORS;


    
--NUMBER 9 ON DESIGN
/*
 *  Function Name : getUnderstockedProducts
 *  Return Type : NUMBER
 *
 *  Description : Prints the information of products that are less than 10 available
 *                in stock. Return the number of such products.
 */
CREATE OR REPLACE FUNCTION getUnderstockedProducts
    RETURN NUMBER
    AS
        CURSOR prod_info
            IS
                SELECT 
                    id
                ,   name
                ,   manufacturer
                ,   quantityInStock
                ,   totalQuantitySold
                FROM PRODUCTS
                WHERE quantityInStock < 10;
        prodId PRODUCTS.ID%TYPE;
        prodName PRODUCTS.NAME%TYPE;
        prodMan PRODUCTS.MANUFACTURER%TYPE;
        prodQuant PRODUCTS.QUANTITYINSTOCK%TYPE;
        prodTotSold PRODUCTS.TOTALQUANTITYSOLD%TYPE;
        numOfProd NUMBER(9,2) := 0;
    BEGIN
        OPEN prod_info;
        LOOP
            FETCH prod_info INTO prodId, prodName, prodMan, prodQuant, prodTotSold;
                EXIT WHEN prod_info%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('PRODUCT ID: ' || prodId || 'NAME: ' || prodName || 'manufacturer' || prodMan || 'QUANTITY IN STOCK: ' || prodQuant || 'TOTAL SOLD: ' || prodTotSold );
            numOfProd := numOfProd + 1;
        END LOOP;
        CLOSE prod_info;
        
        IF numOfProd = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No Understocked Products');
        END IF;
        
        --log the function
        INSERT INTO log(logDate, logFrom, logMsg)
            VALUES(TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy'), 'Function: getUnderstockedProducts', 'Total Products : ' || numOfProd);

        COMMIT;
        
        RETURN numOfProd;
    END;
SHOW ERRORS;
    