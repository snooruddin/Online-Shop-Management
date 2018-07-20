--NUMBER 1 ON DESIGN
/*
 *  Procedure Name : setDiscountOnAllProducts
 *  Parameters : Amnt [IN] NUMBER
 *  
 *  Description : This procedure updates the price of all the products to their discounted price.
 *               The percetage of discount is passed through the 'Amnt' parameter
 * 
 */
CREATE OR REPLACE PROCEDURE setDiscountOnAllProducts(AMNT IN NUMBER)
    AS
        CURSOR prod_info
            IS
                SELECT 
                    id
                ,   price
                FROM products;
        prodId PRODUCTS.ID%TYPE;
        crntPrice PRODUCTS.PRICE%TYPE;
        updPrice PRODUCTS.PRICE%TYPE;
        
        F UTL_FILE.FILE_TYPE;
        
    BEGIN
        OPEN prod_info;
        F := UTL_FILE.FOPEN('DNAME','ActualPrice.csv','W');
        IF UTL_FILE.IS_OPEN(F) THEN
            DBMS_OUTPUT.PUT_LINE('ActualPrice.csv OPENED FOR WRITING');
            UTL_FILE.PUT(F, 'id' || ',' || 'price' );
            UTL_FILE.NEW_LINE(F);
            LOOP
                FETCH prod_info INTO prodId, crntPrice;
                    EXIT WHEN prod_info%NOTFOUND;
                UTL_FILE.PUT(F, prodId || ',' || crntPrice);
                UTL_FILE.NEW_LINE(F);
                
                updPrice := (crntPrice * 11) / 100;
                
                UPDATE products
                    SET price = updPrice
                WHERE id = prodId;
                
            END LOOP;
        END IF;
        
        --log the procedure
        INSERT INTO log(logDate, logFrom, logMsg)
            VALUES(TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy'), 'Procedure: setDiscountOnAllProducts', 'Successful ' );

        COMMIT;
        
        UTL_FILE.FCLOSE(F); 
        
        CLOSE prod_info;        
        
    END;
SHOW ERRORS;

--NUMBER 5 ON DESIGN
/*
 *  Procedure Name : payAllCommission
 *  
 *  Description : This procedure sets the commission of all the employees to 0
 *
 */
CREATE OR REPLACE PROCEDURE payAllCommission
    IS
        CURSOR employee_id 
            IS
                SELECT id FROM employees;
        empId EMPLOYEES.ID%TYPE;
    BEGIN
        OPEN employee_id;
        LOOP
            FETCH employee_id INTO empId;
                EXIT WHEN employee_id%NOTFOUND; 
        
            UPDATE employees 
                SET commission = 0
            WHERE id = empId;
        END LOOP;
        
        --log the procedure
        INSERT INTO log(logDate, logFrom, logMsg)
            VALUES(TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy'), 'Procedure: payAllCommission', 'Successful ' );

        COMMIT;
        
        CLOSE employee_id;
    END;
SHOW ERRORS;

--NUMBER 6 ON DESIGN
/*
 *  Procedure Name : getSingleEmployeeInfo
 *  Parameters : EMPID [IN] INTEGER
 *
 *  Description : Prints All Available Information of Employee given the employee
 *                id is passed in the parameter.  
 */
CREATE OR REPLACE PROCEDURE getSingleEmployeeInfo(EMPID IN INTEGER)
    AS
        CURSOR employee_info
            IS 
                SELECT * FROM employees WHERE id = empId;
        emplId EMPLOYEES.ID%TYPE;
        empName EMPLOYEES.NAME%TYPE;
        empLocation EMPLOYEES.LOCATION%TYPE;
        empContact EMPLOYEES.CONTACT%TYPE;
        empPosition EMPLOYEES.POSITION%TYPE;
        empSalary EMPLOYEES.SALARY%TYPE;
        empCommission EMPLOYEES.COMMISSION%TYPE;
    BEGIN
        OPEN employee_info;
        LOOP
            FETCH employee_info 
                INTO emplId 
                ,   empName
                ,   empLocation
                ,   empContact
                ,   empPosition
                ,   empSalary
                ,   empCommission;
                EXIT WHEN employee_info%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('EMPLOYEE NAME: ' || empName || 'LOCATION: ' || empLocation || 'CONTACT: ' || empContact || 'SALARY: ' || empSalary || 'COMMISSION: ' || empCommission);                                    
        END LOOP;
        CLOSE employee_info;
        
        --log the procedure
        INSERT INTO log(logDate, logFrom, logMsg)
            VALUES(TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy'), 'Procedure: getSingleEmployeeInfo', 'Successful ' );

        COMMIT;
    END;
SHOW ERRORS;

--number 7 on design
/*
 *  Procedure Name : getMostSoldProducts
 *
 *  Description : Return list of 10 most sold products in inventory
 *
 */
 CREATE OR REPLACE PROCEDURE getMostSoldProducts
    AS
        CURSOR prod_info IS
            SELECT name
            ,   manufacturer
            ,   type
            ,   totalQuantitySold
            FROM products
            ORDER BY totalQuantitySold;
            
        prodName PRODUCTS.NAME%TYPE;
        prodMan PRODUCTS.MANUFACTURER%TYPE;
        prodType PRODUCTS.TYPE%TYPE;
        prodQuant PRODUCTS.TOTALQUANTITYSOLD%TYPE;
        counter INTEGER;
    BEGIN
        OPEN prod_info;
        FOR counter IN 0..9
            LOOP 
                FETCH prod_info INTO prodName, prodMan, prodType, prodQuant;
                DBMS_OUTPUT.PUT_LINE('PRODUCT NAME: ' || prodName || ' MANUFACTURER: ' || prodMan || ' TYPE: ' || prodType || ' TOTAL QUANTITY: ' || prodQuant );
            END LOOP;
        CLOSE prod_info;
        
        --log the procedure
        INSERT INTO log(logDate, logFrom, logMsg)
            VALUES(TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy'), 'Procedure: getMostSoldProducts', 'Successful ' );

        COMMIT;
    END;
SHOW ERRORS;

--NUMBER 8 ON DESIGN
/*
 *  Procedure Name : mostPayingCustomers
 *
 *  Description : Prints all available information of the 10 most paying customers
 *
 */
CREATE OR REPLACE PROCEDURE mostPayingCustomers
    AS
        CURSOR cust_info
            IS
                SELECT 
                    name
                ,   location
                ,   contact
                ,   totalSpent
                FROM customers
                ORDER BY totalSpent;
        custId CUSTOMERS.ID%TYPE;
        custName CUSTOMERS.NAME%TYPE;
        custLoc CUSTOMERS.LOCATION%TYPE;
        custCont CUSTOMERS.CONTACT%TYPE;
        custSpent CUSTOMERS.CONTACT%TYPE;
        counter INTEGER;
    BEGIN
        OPEN cust_info;
        FOR counter IN 0..9
            LOOP 
                FETCH cust_info INTO custName, custLoc, custCont, custSpent;
                DBMS_OUTPUT.PUT_LINE('CUSTOMER NAME: ' || custName || ' LOCATION: ' || custLoc || ' CONTACT: ' || custCont || ' TOTAL SPENT: ' || custSpent );
            END LOOP;
        CLOSE cust_info;
        
        --log the procedure
        INSERT INTO log(logDate, logFrom, logMsg)
            VALUES(TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy'), 'Procedure: mostPayingCustomers', 'Successful ' );

        COMMIT;
    END;
SHOW ERRORS;



--NUMBER 10(a) ON DESIGN
/*
 *  Procedure Name : awardClubPointsToAllCustomers
 *  Parameters : Award [IN] NUMBER
 *               TotalAwardedTo [OUT] INTEGER
 *
 *  Description : Adds club points to all customers, club points are supplied through 'Award',
 *                The number of customers that are awarded the club points are stored in 'TotalAwardedTo'.
 *  
 */
CREATE OR REPLACE PROCEDURE awardClubPointsToAllCustomers(AWARD IN NUMBER, TTLAWARDEDTO OUT INTEGER)
    AS
        CURSOR cust_info
            IS  
                SELECT 
                    id
                ,   clubPoints 
                FROM customers;
        custId CUSTOMERS.ID%TYPE;
        crntpts CUSTOMERS.CLUBPOINTS%TYPE;
        updpts  CUSTOMERS.CLUBPOINTS%TYPE;
       
    BEGIN
        TTLAWARDEDTO := 0;
        OPEN cust_info;
        LOOP
            FETCH cust_info INTO custId, crntpts;
                EXIT WHEN cust_info%NOTFOUND;
            
            updpts := crntpts + AWARD;
            
            UPDATE customers 
                SET clubPoints = updpts
            WHERE id = custId;   
            
            TTLAWARDEDTO := TTLAWARDEDTO + 1;
        END LOOP;
        
        --log the procedure
        INSERT INTO log(logDate, logFrom, logMsg)
            VALUES(TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy'), 'Procedure: awardClubPointsToAllCustomers', 'Successful ' );

        COMMIT;
        CLOSE cust_info;
    END;
SHOW ERRORS;

--NUMBER 10(b) ON DESIGN
/*
 *  Procedure Name : awardClubPointsToOneCustomer
 *  Parameters : Cid [IN] INTEGER
 *               Amnt [IN] INTEGER
 *
 *  Description : Club points is added to one customer. Customer id is supplied through 'Cid'
 *                and the amount of club points to be added are supplied through 'Amnt'.
 *
 */
CREATE OR REPLACE PROCEDURE awardClubPointsToOneCustomer(CID IN INTEGER, AMNT IN INTEGER)
    AS
        crntpts CUSTOMERS.CLUBPOINTS%TYPE;
        updpts CUSTOMERS.CLUBPOINTS%TYPE; 
    BEGIN
        SELECT clubPoints INTO crntpts
        FROM customers
        WHERE id = CID;
        
        updpts := crntpts + AMNT;
        
        UPDATE customers
            SET clubPoints = updpts
        WHERE id = CID;
        
        --log the procedure
        INSERT INTO log(logDate, logFrom, logMsg)
            VALUES(TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy'), 'Procedure: awardClubPointsToOneCustomer', 'Successful ' );
        
        COMMIT;
    END;
SHOW ERRORS;

--number 11 on design
/*
 *  Procedure Name : updateShipmentStatus
 *   
 *  Description : Updates shipment status of orders in the order details table.
 *  By default, the possible shipment date is set to three days from the order date and shipment status is set to 'processing'. 
 *  This function will compare the shipment date with SYSDATE and if it has already been three days from order date, will update the shipment status to 'shipped'.
 *
 */
 CREATE OR REPLACE PROCEDURE updateShipmentStatus
    AS
        CURSOR orderDet IS
            SELECT id
            ,   shipmentDate
            FROM orderDetAILS;
        
        currDate orderDetAILS.SHIPMENTDATE%TYPE;
        
        oid orderDetAILS.ID%TYPE;
        shipDate orderDetAILS.SHIPMENTDATE%TYPE;
    BEGIN
        currDate := TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy');
        
        OPEN orderDet;
        LOOP
            FETCH orderDet INTO oid, shipDate;
                EXIT WHEN orderDet%NOTFOUND;
            IF currDate = shipDate THEN
                UPDATE orderDetAILS SET SHIPMENTSTATUS = 'SHIPPED' WHERE ID = oid;
            END IF;
        END LOOP;
        
        --log the procedure
        INSERT INTO log(logDate, logFrom, logMsg)
            VALUES(TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy'), 'Procedure: updateShipmentStatus', 'Successful ' );

        COMMIT;
    END;
    SHOW ERRORS;

--NUMBER 12 ON DESIGN
/*
 *  Procedure Name : restockAllProducts
 *  Parameters : Amnt [IN] INTEGER
 *               Updtd [OUT] INTEGER
 *               
 *  Description : Adds the amount supplied via 'Amnt' to QunatityInStock of all products
 *                Stores the number of products updated via this procedure to 'Updtd'.
 *
 */
CREATE OR REPLACE PROCEDURE restockAllProducts(AMNT IN INTEGER, UPDTD OUT INTEGER)
    AS
        CURSOR prod_info
            IS
                SELECT
                    id
                ,   quantityInStock
                FROM products;
        prodId PRODUCTS.ID%TYPE;
        crntQuant PRODUCTS.QUANTITYINSTOCK%TYPE;
        updQuant PRODUCTS.QUANTITYINSTOCK%TYPE;
    BEGIN
        UPDTD := 0;
        
        OPEN prod_info;
        LOOP
            FETCH prod_info INTO prodId, crntQuant;
                EXIT WHEN prod_info%NOTFOUND;
                
            updQuant := crntQuant + AMNT;
            
            UPDATE products
                SET quantityInStock = updQuant
            WHERE id = prodId;
            
            UPDTD := UPDTD + 1;
        END LOOP;
        
        --log the procedure
        INSERT INTO log(logDate, logFrom, logMsg)
            VALUES(TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy'), 'Procedure: restockAllProducts', 'Successful ' );

        COMMIT;
    END;
SHOW ERRORS;

--NUMBER 12(B) ON DESIGN
/*
 *  Procedure Name : restockSingleProduct
 *  Parameters : Pid [IN] Integer
 *               Amnt [IN] Integer
 *
 *  Description : Adds the amount supplied via 'Amnt' to QuantityInStock of product
 *                Product Id is supplied via the 'Pid'.
 */
CREATE OR REPLACE PROCEDURE restockSingleProduct(PID IN INTEGER, AMNT IN INTEGER)
    AS
        crntQuant PRODUCTS.QUANTITYINSTOCK%TYPE;
        updQuant PRODUCTS.QUANTITYINSTOCK%TYPE;
    BEGIN
        SELECT 
            quantityInStock INTO crntQuant
        FROM products
        WHERE id = PID;
        
        updQuant := crntQuant + AMNT;
        
        UPDATE products
            SET quantityInStock = updQuant
        WHERE id = PID;
        
        --log the procedure
        INSERT INTO log(logDate, logFrom, logMsg)
            VALUES(TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy'), 'Procedure: restockSingleProduct', 'Successful ' );
        
        COMMIT;
    END;
SHOW ERRORS;