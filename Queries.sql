conn chinook/p4ssw0rd

--2.1 SELECT

SELECT * FROM Employee;
SELECT * FROM Employee WHERE LastName = 'King';
select * from Employee where FirstName = 'Andrew' and ReportsTo = NULL;



--2.2 ORDER BY

select * from Album order by title desc;
select FirstName from Customer order by City asc;



--2.3 INSERT INTO

INSERT INTO Genre (GenreId, Name) VALUES (26, 'A Cappella');
INSERT INTO Genre (GenreId, Name) VALUES (27, 'Chiptune');

INSERT INTO Employee (EmployeeId, LastName, FirstName, Title, ReportsTo, BirthDate, HireDate, Address, City, State, Country, PostalCode, Phone, Fax, Email) VALUES (9, 'Williams', 'Megan', 'IT Staff', 6, TO_DATE('1954-5-1 00:00:00','yyyy-mm-dd hh24:mi:ss'), TO_DATE('2003-5-3 00:00:00','yyyy-mm-dd hh24:mi:ss'), '683 10 Street SW', 'Calgary', 'AB', 'Canada', 'T2P 5G3', '+1 (403) 263-3074', '+1 (403) 263-4289', 'megan@chinookcorp.com');
INSERT INTO Employee (EmployeeId, LastName, FirstName, Title, ReportsTo, BirthDate, HireDate, Address, City, State, Country, PostalCode, Phone, Fax, Email) VALUES (10, 'Branwen', 'Aidan', 'IT Staff', 6, TO_DATE('1968-8-12 00:00:00','yyyy-mm-dd hh24:mi:ss'), TO_DATE('2005-2-26 00:00:00','yyyy-mm-dd hh24:mi:ss'), '412 7 Street NE', 'Calgary', 'AB', 'Canada', 'T2P 5G3', '+1 (403) 102-8850', '+1 (403) 363-8877', 'aidan@chinookcorp.com');

INSERT INTO Customer (CustomerId, FirstName, LastName, Address, City, Country, PostalCode, Phone, Email, SupportRepId) VALUES (60, 'Misato', 'Katsuragi', '2000,Nagano Expressway', 'Matsumoto', 'Japan', '20202', '+91 26 73520563', 'katsuragi@nerv.int', 3);
INSERT INTO Customer (CustomerId, FirstName, LastName, Address, City, Country, PostalCode, Phone, Email, SupportRepId) VALUES (61, 'Wenjie', 'Ye', '1970,Baoshi West Road', 'Shenzhen', 'China', '518020', '+81 755 81036394', 'ye__wenjie__1948@baidu.com', 5);


--2.4 UPDATE

UPDATE Customer SET FirstName = 'Robert', LastName = 'Walker' WHERE FirstName = 'Aaron' AND LastName = 'Mitchell';
UPDATE Artist SET Name = 'CCR' WHERE Name = 'Creedence Clearwater Revival';


--2.5 LIKE

SELECT * FROM Invoice WHERE BillingAddress LIKE 'T%';


--2.6 BETWEEN

SELECT * FROM Invoice WHERE Total BETWEEN 15 AND 50;
SELECT * FROM Employee WHERE HireDate BETWEEN TO_DATE('2003-6-1 00:00:00','yyyy-mm-dd hh24:mi:ss') AND TO_DATE('2004-3-1 00:00:00','yyyy-mm-dd hh24:mi:ss');


--2.7 DELETE


ALTER TABLE InvoiceLine
DROP CONSTRAINT FK_InvoiceLineInvoiceId;

ALTER TABLE InvoiceLine
ADD CONSTRAINT FK_InvoiceLineInvoiceId
    FOREIGN KEY (InvoiceId)
    REFERENCES Invoice (InvoiceId)
    ON DELETE CASCADE;

ALTER TABLE Invoice
DROP CONSTRAINT FK_InvoiceCustomerId;

ALTER TABLE Invoice
ADD CONSTRAINT FK_InvoiceCustomerId
    FOREIGN KEY (CustomerId)
    REFERENCES Customer (CustomerId)
    ON DELETE CASCADE;
    
ALTER TABLE Customer
DROP CONSTRAINT FK_CustomerSupportRepId;

ALTER TABLE Customer
ADD CONSTRAINT FK_CustomerSupportRepId
    FOREIGN KEY (SupportRepId)
    REFERENCES Employee (EmployeeId)
    ON DELETE CASCADE;
    
DELETE FROM Customer WHERE FirstName = 'Robert' AND LastName = 'Walker';


--3.1 SYSTEM DEFINED FUNCTIONS


create or replace function GET_CURRENT_TIME return timestamp as t timestamp;
begin
    return LOCALTIMESTAMP;
end;
/

set serveroutput on
declare t timestamp;
begin
    t := GET_CURRENT_TIME;
    dbms_output.put_line(t);
end;
/



create or replace function GET_MEDIATYPE_LENGTH (input_id number)
return number
is
mediatypelength number;
begin
    select length(MediaType.name)
    into
    mediatypelength
    from MediaType
    where MediaType.MediaTypeId = input_id;
    return mediatypelength;
end;
/

select GET_MEDIATYPE_LENGTH(3) from dual;


--3.2 SYSTEM DEFINED AGGREGATE FUNCTIONS


create or replace function AVERAGE_INVOICE_TOTAL
return number
is
invoices_total_average number;
begin
    select avg(Invoice.Total)
    into
    invoices_total_average
    from Invoice;
    return invoices_total_average;
end;
/

select AVERAGE_INVOICE_TOTAL from dual;



create or replace function MOST_EXPENSIVE_TRACK
return varchar2
is
most_expensive_track_name varchar2(200);
max_unit_price number;
begin
    select MAX(UnitPrice) into max_unit_price from Track;
    select Track.Name
    into
    most_expensive_track_name
    from Track
    where Track.UnitPrice = max_unit_price
    and rownum = 1;
    return most_expensive_track_name;
end;
/

select MOST_EXPENSIVE_TRACK from dual;


--3.3 USER DEFINED FUNCTIONS


create or replace function AVERAGE_INVOICELINE_PRICE
return number
is
invoiceline_price_average number;
begin
    select avg(InvoiceLine.UnitPrice)
    into
    invoiceline_price_average
    from InvoiceLine;
    return invoiceline_price_average;
end;
/

select AVERAGE_INVOICELINE_PRICE from dual;


--4.1 BASIC STORED PROCEDURE


create or replace procedure GET_ALL_EMPLOYEE_NAMES(s out sys_refcursor) as
begin
    open s for select FirstName, LastName from Employee;
end;


--6.1 AFTER INSERT


create or replace trigger employee_after_insert
after insert
   on Employee
   for each row
begin
    dbms_output.put_line('An entry has been inserted into the Employee table.');
end;
/


--6.1 AFTER UPDATE


create or replace trigger employee_after_update
after update
   on Employee
   for each row
begin
    dbms_output.put_line('A row has been updated in the Employee table.');
end;
/


--6.1 AFTER DELETE


create or replace trigger employee_after_delete
after delete
   on Employee
   for each row
begin
    dbms_output.put_line('A row has been deleted from the Employee table.');
end;
/


--7.1 INNER JOIN


SELECT Customer.FirstName, Customer.LastName, Invoice.InvoiceId
FROM Customer 
INNER JOIN Invoice
ON Customer.CustomerId = Invoice.CustomerId;


--7.2 OUTER JOIN


SELECT Customer.CustomerId, Customer.FirstName, Customer.LastName, Invoice.InvoiceId, Invoice.Total
FROM Customer 
LEFT OUTER JOIN Invoice
ON Customer.CustomerId = Invoice.CustomerId;


--7.3 RIGHT JOIN


SELECT Artist.Name, Album.Title
FROM Artist 
RIGHT OUTER JOIN Album
ON Artist.ArtistId = Album.ArtistId;


--7.4 CROSS JOIN


SELECT *
FROM Album 
CROSS JOIN Artist
ORDER BY Artist.Name;


--7.5 SELF JOIN


SELECT a.FirstName, a.LastName, b.FirstName, b.LastName
FROM Employee a JOIN Employee b 
ON (a.ReportsTo = b.EmployeeId);
