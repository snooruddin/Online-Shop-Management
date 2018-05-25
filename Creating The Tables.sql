--unComment all of these if you are having issues with creating the tables
--DROP TABLE ORDERDETAILS;
--DROP TABLE ORDERS;
--DROP TABLE CUSTOMERS;
--DROP TABLE EMPLOYEES;
--DROP TABLE PRODUCTS;
--DROP TABLE LOG;

CREATE TABLE Customers
(   id INTEGER
,   name VARCHAR(200) NOT NULL
,   location VARCHAR(1000) NOT NULL
,   contact NUMBER(11) NOT NULL UNIQUE
,   clubPoints NUMBER(9,2) DEFAULT 0
,   totalSpent NUMBER(9,2) DEFAULT 0

,   PRIMARY KEY(id)
);

CREATE TABLE Employees
(   id INTEGER
,   name VARCHAR(200)
,   location VARCHAR(1000)
,   contact NUMBER(11) NOT NULL UNIQUE
,   position VARCHAR(100) NOT NULL
,   salary NUMBER(9,2) DEFAULT 0
,   commission NUMBER(9,2) DEFAULT 0

,   PRIMARY KEY(id)
);

CREATE TABLE Products
(   id INTEGER
,   name VARCHAR(200) NOT NULL
,   manufacturer VARCHAR(200) NOT NULL
,   type VARCHAR(200) NOT NULL
,   subtype VARCHAR(200) NOT NULL
,   price NUMBER(9,2) NOT NULL CHECK(price >= 0)
,   quantityInStock INTEGER CHECK(quantityInStock >= 0)
,   totalQuantitySold INTEGER DEFAULT 0

,   PRIMARY KEY(id)
);

CREATE TABLE Orders
(   id INTEGER
,   cid INTEGER
,   eid INTEGER
,   pid INTEGER
,   quantity INTEGER CHECK(quantity > 0)
,   totalPrice NUMBER(9,2) CHECK(totalPrice > 0)
,   clubPointsUsed NUMBER(9,2) 
    
,   PRIMARY KEY(id)
,   FOREIGN KEY(cid) REFERENCES customers(id)
,   FOREIGN KEY(eid) REFERENCES employees(id)
,   FOREIGN key(pid) REFERENCES products(id)
);

CREATE TABLE OrderDetails
(   id INTEGER
,   orderDate DATE NOT NULL
,   shipmentDate DATE NOT NULL
,   shipmentStatus varchar(100) DEFAULT 'PROCESSING'

,   PRIMARY KEY(id)
,   FOREIGN KEY(id) REFERENCES orders(id)
);

CREATE TABLE Log
(   logDate DATE NOT NULL
,   logFrom VARCHAR(500) NOT NULL
,   logMsg  VARCHAR(1000) NOT NULL
);