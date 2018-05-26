--number : 19 on Design
--Operators get 2% commission on the total price of the order

CREATE OR REPLACE TRIGGER addCommissionToEmployee
    BEFORE 
        INSERT
    ON orders
    FOR EACH ROW
DECLARE
    empId EMPLOYEES.ID%TYPE;
    totPrice ORDERS.TOTALPRICE%TYPE;
    addComm EMPLOYEES.COMMISSION%TYPE;
    currComm EMPLOYEES.COMMISSION%TYPE;
    updatedComm EMPLOYEES.COMMISSION%TYPE;
BEGIN
    --get employee id from orders table
    empId := :NEW.eid;
    --get total order price
    totPrice := :NEW.totalPrice;
    --calculate commission
    addComm := totPrice * .02;
    --get current commission of employee from employees table
    SELECT commission INTO currComm FROM employees WHERE id = empId;
    --add new commission to current commission
    updatedComm := currComm + addComm;
    --update employee on employees table
    UPDATE employees SET commission = updatedComm WHERE id = empId;
    
    --log the trigger for easy debugging
    INSERT INTO log(logDate, logFrom, logMsg) VALUES(TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy'), 'TRIGGER : addCommissionToEmployee', 'empid : ' || empId || ' PrevComm : ' || currComm || 'NewComm : ' || updatedComm);
END;

--number 20 on Design
--Total price of a order is automatically calculated

CREATE OR REPLACE TRIGGER calculateTotalPriceOfOrder
    BEFORE
        INSERT
    ON orders
    FOR EACH ROW
DECLARE
    prodId ORDERS.ID%TYPE;
    quantity ORDERS.QUANTITY%TYPE;
    pricePerPiece PRODUCTS.PRICE%TYPE;
    totalOrderPrice ORDERS.TOTALPRICE%TYPE;
BEGIN
    --get product id from order
    prodId := :NEW.pid;
    --get quantity of order
    quantity := :NEW.quantity;
    --get per piece price of product
    SELECT price INTO pricePerPiece FROM products WHERE id = prodId;
    --calculate total order price
    totalOrderPrice := quantity * pricePerPiece;
    --set total order price
    :NEW.totalPrice := totalOrderPrice;
    
    --log
    INSERT INTO log(logDate, logFrom, logMsg) VALUES(TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy'), 'TRIGGER : calculateTotalPriceOfOrder', 'orderId : ' || :NEW.oid || ' price : ' || totalOrderPrice);
    
END;