--number 13 on design
--Customer can't order products that are unavailable in stock
--number 15 in design
--Customer gets 5% of actual payment as club points
--number 16 on design
--Customer can use club points to buy products
--number 18 on design
--Operators get 2% commission on the total price of the order
--number 19 on design
--Total price of a order is automatically calculated
--number 20 on design
--Only operators can permit a product 
--number 21 on design
--Customer's actual payment is automatically calculated
--numebr 22 on design
--Quantity of products in stock after each order automatically decreases
--number 23 on design
--Total quantity sold of a product increases after every order
--number 24 on design
--Customer's total spent money increases after every order

CREATE OR REPLACE TRIGGER processingOnOrder
    BEFORE
        INSERT
    ON orders
    FOR EACH ROW
DECLARE
    empType EMPLOYEES.POSITION%TYPE;
    
    prodQuant PRODUCTS.QUANTITYINSTOCK%TYPE;
    
    totalOrderPrice ORDERS.TOTALPRICE%TYPE;
    pricePerPiece PRODUCTS.PRICE%TYPE;
    
    currClub CUSTOMERS.CLUBPOINTS%TYPE;
    
    currComm EMPLOYEES.COMMISSION%TYPE;
    
    actualPayment ORDERS.CUSTOMERPAID%TYPE;
    
    currSpent CUSTOMERS.TOTALSPENT%TYPE;
    
    totSold PRODUCTS.TOTALQUANTITYSOLD%TYPE;
BEGIN
    --get position of corresponding employee to empType
    SELECT position INTO empType FROM employees WHERE id = :NEW.eid;
    
    --get the current quantity of corresponding product into prodQuant
    SELECT quantityInStock INTO prodQuant FROM products WHERE id = :NEW.pid;
    
    --get current club points of corresponding customer into currClub
    SELECT clubPoints INTO currClub FROM customers WHERE id = :NEW.cid;

    --if there is not enough product in stock, you will get an ORA-20001 ERROR
    IF prodQuant = 0 OR :NEW.quantity > prodQuant THEN
        RAISE_APPLICATION_ERROR(-20001, 'QUANTITY NOT AVAILABLE');
    END IF;
    
    
    --if employee is not an operator, you will get an ORA-20002 ERROR
    IF empType != 'operator' THEN
        RAISE_APPLICATION_ERROR(-20002, 'EMPLOYEE NOT AN OPERATOR');
    END IF;
    
    
    --customer can use club points
    --if not enough club points, you will get ORA-20003 ERROR;
    IF :NEW.clubPointsUsed > currClub THEN
        RAISE_APPLICATION_ERROR(-20003, 'NOT ENOUGH CLUB POINTS');
    END IF;
    --calculate new total club points
    currClub := currClub - :NEW.clubPointsUsed;
    --update new club points 
    UPDATE customers SET clubPoints = currClub WHERE id = :NEW.cid;
    DBMS_OUTPUT.PUT_LINE('REMAINING CLUB POINTS OF CUSTOMER: ' || currClub);
    
    
    --calculate total price of order
    --get per piece price of corresponding order into pricePerPiece
    SELECT price INTO pricePerPiece FROM products WHERE id = :NEW.pid;
    --calculate total order price
    totalOrderPrice := :NEW.quantity * pricePerPiece;
    --set total order price
    :NEW.totalPrice := totalOrderPrice;
    DBMS_OUTPUT.PUT_LINE('TOTALPRICE: ' || totalOrderPrice);
    
    
    --operator gets 2% commission
    --get corresponding operator's current commission into currComm
    SELECT commission INTO currComm FROM employees WHERE id = :NEW.eid;
    --calculate new total commission
    currComm := currComm + totalOrderPrice * .02;
    --update total commission
    UPDATE employees SET commission = currComm WHERE id = :NEW.eid;
    DBMS_OUTPUT.PUT_LINE('UPDATED COMMISSION OF EMPLOYEE ' || currComm);
    
    
    --calculating actual payment of customer
    actualPayment := totalOrderPrice - :NEW.clubPointsUsed;
    --set actual payment
    :NEW.customerPaid := actualPayment;
    DBMS_OUTPUT.PUT_LINE('CUSTOMERPAID: '||actualPayment);
    
    
    --customer gets 5% of actual payment as club points
    --currClub IS THE LATEST UPDATED CLUB POINT OF CUSTOMER
    currClub := currClub + actualPayment * .05;
    --update customer's club points
    UPDATE customers SET clubPoints = currClub WHERE id = :NEW.cid;
    DBMS_OUTPUT.PUT_LINE('UPDATED CLUBPOINTS OF CUSTOMER ' || currClub);
    
    
    --adding to customers totalspent
    --get corresponding customer's total money spent till now into currSpent
    SELECT totalSpent INTO currSpent FROM customers WHERE id = :NEW.cid;
    --add the money spent in this odrder to currSpent
    currSpent := currSpent + actualPayment;
    --update customers total spent
    UPDATE customers SET totalSpent = currSpent WHERE id = :NEW.cid;
    DBMS_OUTPUT.PUT_LINE('CUSTOMER TOTAL SPENT ' || currSpent);
    
    
    --quantity in stock decreases after each order
    --prodQuant is the current quantity of corresponding product in stock
    --subtract quantity of this order from prodQuant;
    prodQuant := prodQuant - :NEW.QUANTITY;
    --update products table
    UPDATE products SET quantityInStock = prodQuant WHERE id = :NEW.pid;
    DBMS_OUTPUT.PUT_LINE('CURRENT PRODUCT QUANTITY ' || prodQuant);
    
    
    --total number sold increases after each successfull order
    --get total number of products sold into totSold
    SELECT totalQuantitySold INTO totSold FROM products WHERE id = :NEW.pid;
    --add this order's sold quantity with totSold
    totSold := totSold + :NEW.QUANTITY;
    --update products total sold
    UPDATE products SET totalQuantitySold = totSold WHERE id = :NEW.pid;
    DBMS_OUTPUT.PUT_LINE('TOTAL QUANTITY SOLD : ' || totSold);
    
    
    --log the trigger
    INSERT INTO log(logDate, logFrom, logMsg)
        VALUES(TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy'), 'TRIGGER: processingOnOrder', 'SUCCESSFULL');
        
        
    DBMS_OUTPUT.PUT_LINE('processingOnOrder : Order Successfully Inserted');
    
END;
SHOW ERRORS;

--number 25 on design
--Order details will be automatically filled out.
CREATE OR REPLACE TRIGGER fillOrderDetails
    AFTER
        INSERT
    ON orders
    FOR EACH ROW
BEGIN
    --TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy') gets only the current date
    --TO_DATE(TO_CHAR(SYSDATE + 3, 'dd/mm/yyyy'),'dd/mm/yyyy') gets only the date from 3 days from today
    INSERT INTO orderDetails(id, orderDate, shipmentDate, shipmentStatus)
        VALUES(:NEW.id, TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy'), TO_DATE(TO_CHAR(SYSDATE + 3, 'dd/mm/yyyy'),'dd/mm/yyyy'), 'Processing');
        
    
    --log the trigger
    INSERT INTO log(logDate, logFrom, logMsg)
        VALUES(TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy'), 'TRIGGER: fillOrderDetails', 'SUCCESSFULL');
        
    
    DBMS_OUTPUT.PUT_LINE('fillOrderDetails : ORDER DETAILS FILLED');
    
END;
SHOW ERRORS;

--number 14 on design
--Customer can delete an order
CREATE OR REPLACE TRIGGER processingAfterOrderDelete
    BEFORE
        DELETE
    ON orders
    FOR EACH ROW
DECLARE
    
    prodQuant PRODUCTS.QUANTITYINSTOCK%TYPE;
    
    
    currClub CUSTOMERS.CLUBPOINTS%TYPE;
    
    currComm EMPLOYEES.COMMISSION%TYPE;
        
    currSpent CUSTOMERS.TOTALSPENT%TYPE;
    
    totSold PRODUCTS.TOTALQUANTITYSOLD%TYPE;
BEGIN

    --delete the corresponding order details from orderDetails table
    DELETE FROM orderDetails WHERE id = :OLD.id;
    
    --get current quantity of corresponding product into prodQuant
    SELECT quantityInStock INTO prodQuant FROM PRODUCTS WHERE id = :OLD.pid;
    
    
    --increase product quantity to previous quantity
    prodQuant := prodQuant + :OLD.quantity;
    --UPDATE PRODUCTS TABLE
    UPDATE products SET quantityInStock = prodQuant WHERE id = :OLD.id;
    DBMS_OUTPUT.PUT_LINE('CURRENT PRODUCT QUANTITY ' || prodQuant);
    
    
    --return customer's their club points
    --get current club points of customer into currClub
    SELECT clubPoints INTO currClub FROM customers WHERE id = :OLD.cid;
    --calculate new total club points
    currClub := currClub + :OLD.clubPointsUsed;
    --update new club points
    UPDATE customers SET clubPoints = currClub WHERE id = :OLD.cid;
    DBMS_OUTPUT.PUT_LINE('REMAINING CLUB POINTS OF CUSTOMER: ' || currClub);
    
    
    --take back club points awarded for this order
    --customer gets 5% of actual payment as club points
    --currClub is the latest updated club point of customer
    currClub := currClub - :OLD.customerPaid * .05;
    --update customer's club points
    UPDATE customers SET clubPoints = currClub WHERE id = :OLD.cid;
    DBMS_OUTPUT.PUT_LINE('UPDATED CLUBPOINTS OF CUSTOMER ' || currClub);
    
    
    --take back commission from operator
    --get current commission of corrsponding employee into currComm
    SELECT commission INTO currComm FROM employees WHERE id = :OLD.eid;
    --calculate new total commission
    currComm := currComm - :OLD.totalPrice * .02;
    --update total commission
    UPDATE employees SET commission = currComm WHERE iD = :OLD.eid;
    DBMS_OUTPUT.PUT_LINE('UPDATED COMMISSION OF EMPLOYEE ' || currComm);
    
    
    --take back customer's totalspent
    --get current total spent money of corresponding customer into currSpent
    SELECT totalSpent INTO currSpent FROM customers WHERE id = :OLD.cid;
    --add actualpayment to totalspent
    currSpent := currSpent - :OLD.customerPaid;
    --update customers total spent
    UPDATE customers SET totalSpent = currSpent WHERE id = :OLD.cid;
    DBMS_OUTPUT.PUT_LINE('CUSTOMER TOTAL SPENT ' || currSpent);
    
    
    
    --take back total numebr sold
    --get current total number of products sold into totSold
    SELECT totalQuantitySold INTO totSold FROM products WHERE id = :OLD.pid;
    --subtract the order's quantity from totSold
    totSold := totSold - :OLD.quantity;
    --update products total sold
    UPDATE products SET totalQuantitySold = totSold WHERE id = :OLD.pid;
    DBMS_OUTPUT.PUT_LINE('TOTAL QUANTITY SOLD : ' || totSold);
    
    
    --log the trigger
    INSERT INTO log(logDate, logFrom, logMsg)
        VALUES(TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy'), 'TRIGGER: processingAfterOrderDelete', 'SUCCESSFULL');
    
    DBMS_OUTPUT.PUT_LINE('processingAfterOrderDelete: ORDER SUCCESSFULLY DELETED');
    
    
END;
SHOW ERRORS;