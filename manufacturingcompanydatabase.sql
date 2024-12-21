CREATE DATABASE ManufacturingERP;
GO
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(50),
    UnitPrice DECIMAL(10, 2) NOT NULL,
    StockLevel INT NOT NULL
);

CREATE TABLE Components (
    ComponentID INT IDENTITY(1,1) PRIMARY KEY,
    ComponentName VARCHAR(100) NOT NULL,
    UnitCost DECIMAL(10, 2) NOT NULL,
    StockLevel INT NOT NULL
);

CREATE TABLE Warehouses (
    WarehouseID INT IDENTITY(1,1) PRIMARY KEY,
    Location VARCHAR(100) NOT NULL,
    Capacity INT NOT NULL
);

CREATE TABLE Inventory (
    InventoryID INT IDENTITY(1,1) PRIMARY KEY,
    WarehouseID INT NOT NULL FOREIGN KEY REFERENCES Warehouses(WarehouseID),
    ItemID INT NOT NULL, -- Links to either Products or Components
    ItemType VARCHAR(10) NOT NULL CHECK (ItemType IN ('Product', 'Component')), -- To differentiate between Products and Components
    Quantity INT NOT NULL
);

CREATE TABLE ProductionOrders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL FOREIGN KEY REFERENCES Products(ProductID),
    Quantity INT NOT NULL,
    ScheduledDate DATETIME NOT NULL,
    Status VARCHAR(20) NOT NULL -- Example values: 'Planned', 'In Progress', 'Completed'
);

CREATE TABLE Suppliers (
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierName VARCHAR(100) NOT NULL,
    ContactInfo VARCHAR(200)
);

CREATE TABLE PurchaseOrders (
    PurchaseOrderID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID INT NOT NULL FOREIGN KEY REFERENCES Suppliers(SupplierID),
    ComponentID INT NOT NULL FOREIGN KEY REFERENCES Components(ComponentID),
    Quantity INT NOT NULL,
    OrderDate DATETIME NOT NULL,
    ExpectedDeliveryDate DATETIME
);

CREATE TABLE CustomerOrders (
    CustomerOrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    ProductID INT NOT NULL FOREIGN KEY REFERENCES Products(ProductID),
    Quantity INT NOT NULL,
    OrderDate DATETIME NOT NULL,
    ShippingDate DATETIME,
    Status VARCHAR(20) NOT NULL -- Example values: 'Pending', 'Shipped', 'Delivered'
);

CREATE TABLE Shipments (
    ShipmentID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerOrderID INT NOT NULL FOREIGN KEY REFERENCES CustomerOrders(CustomerOrderID),
    WarehouseID INT NOT NULL FOREIGN KEY REFERENCES Warehouses(WarehouseID),
    ShippedDate DATETIME NOT NULL
);

CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeName VARCHAR(100) NOT NULL,
    Role VARCHAR(50) NOT NULL,
    ContactInfo VARCHAR(200)
);

INSERT INTO Products (ProductName, Category, UnitPrice, StockLevel) VALUES
('Digging Machine', 'Machinery', 5000.00, 10),
('Drill', 'Machinery', 2500.00, 20),
('Fixing Machine', 'Machinery', 15000.00, 5),
('Generator', 'Machinery', 8000.00, 8),
('Hammer', 'Equipment', 2000.00, 15);

INSERT INTO Components (ComponentName, UnitCost, StockLevel) VALUES
('Steel Rod', 100.00, 500),
('Oil', 50.00, 200),
('Motor', 150.00, 50),
('Paint', 300.00, 30),
('Wire', 20.00, 1000);

INSERT INTO Warehouses (Location, Capacity) VALUES
('Karachi', 1000),
('Islamabad', 1500),
('Lahore', 1200),
('Kashmir', 800),
('Khairpur', 900);

INSERT INTO Inventory (WarehouseID, ItemID, ItemType, Quantity) VALUES
(1, 1, 'Product', 10),
(2, 2, 'Product', 20),
(3, 1, 'Component', 500),
(4, 3, 'Component', 50),
(5, 2, 'Component', 200);

INSERT INTO ProductionOrders (ProductID, Quantity, ScheduledDate, Status) VALUES
(1, 5, '2024-12-22', 'Planned'),
(2, 10, '2024-12-23', 'In Progress'),
(3, 2, '2024-12-24', 'Planned'),
(4, 3, '2024-12-25', 'Completed'),
(5, 7, '2024-12-26', 'Planned');

INSERT INTO Suppliers (SupplierName, ContactInfo) VALUES
('SteelCorp', 'steelcorp@gmail.com'),
('Hydraulic World', 'hydraulic@gmail.com'),
('MotorTech', 'motortech@gmail.com'),
('Panel Pros', 'panelpros@gmail.com'),
('Bearing Supplies', 'bearings@gmail.com');

INSERT INTO PurchaseOrders (SupplierID, ComponentID, Quantity, OrderDate, ExpectedDeliveryDate) VALUES
(1, 1, 200, '2024-12-01', '2024-12-05'),
(2, 2, 50, '2024-12-02', '2024-12-06'),
(3, 3, 20, '2024-12-03', '2024-12-07'),
(4, 4, 10, '2024-12-04', '2024-12-08'),
(5, 5, 100, '2024-12-05', '2024-12-09');

INSERT INTO CustomerOrders (CustomerName, ProductID, Quantity, OrderDate, ShippingDate, Status) VALUES
('Haris', 1, 2, '2024-12-10', '2024-12-12', 'Shipped'),
('Maryam', 2, 1, '2024-12-11', '2024-12-13', 'Shipped'),
('Sadia', 3, 3, '2024-12-12', '2024-12-14', 'Delivered'),
('Sadaf', 4, 1, '2024-12-13', '2024-12-15', 'Pending');

INSERT INTO Shipments (CustomerOrderID, WarehouseID, ShippedDate) VALUES
(2, 2, '2024-12-13'),
(3, 3, '2024-12-14'),
(4, 4, '2024-12-15');

INSERT INTO Employees (EmployeeName, Role, ContactInfo) VALUES
('Arooba', 'Manager', 'arooba@gmail.com'),
('Dolly', 'Technician', 'dolly@gmail.com'),
('Millie Brown', 'Supervisor', 'millie@gmail.com'),
('Taylor Swift', 'Logistics', 'taylor@gmail.com'),
('Harry Styles', 'Accountant', 'harry@gmail.com');

select * from Products;
select * from Components;
select * from Inventory;
select * from Warehouses;
select * from Shipments;
select * from Suppliers;
select * from PurchaseOrders;
select * from ProductionOrders;
select * from Employees;
select * from CustomerOrders;


CREATE PROCEDURE UpdateInventoryOnShipment
    @CustomerOrderID INT
AS
BEGIN
    DECLARE @ProductID INT, @Quantity INT;
    SELECT @ProductID = ProductID, @Quantity = Quantity
    FROM CustomerOrders
    WHERE CustomerOrderID = @CustomerOrderID;
    UPDATE Inventory
    SET Quantity = Quantity - @Quantity
    WHERE ItemID = @ProductID AND ItemType = 'Product';
END;


EXEC UpdateInventoryOnShipment @CustomerOrderID = 1;

CREATE TRIGGER UpdateInventoryAfterShipment
ON Shipments
FOR INSERT
AS
BEGIN
    DECLARE @CustomerOrderID INT, @WarehouseID INT, @ProductID INT, @Quantity INT;
    SELECT @CustomerOrderID = CustomerOrderID, @WarehouseID = WarehouseID
    FROM INSERTED;
    SELECT @ProductID = ProductID, @Quantity = Quantity
    FROM CustomerOrders
    WHERE CustomerOrderID = @CustomerOrderID;
    UPDATE Inventory
    SET Quantity = Quantity - @Quantity
    WHERE ItemID = @ProductID AND ItemType = 'Product' AND WarehouseID = @WarehouseID;
END;

INSERT INTO Shipments (CustomerOrderID, WarehouseID, ShippedDate)
VALUES (1, 1, '2024-12-12');

CREATE TRIGGER UpdateProductionOrderStatus
ON ProductionOrders
FOR UPDATE
AS
BEGIN
    DECLARE @OrderID INT, @QuantityProduced INT, @RequiredQuantity INT;
    SELECT @OrderID = OrderID, @QuantityProduced = Quantity
    FROM INSERTED;
    SELECT @RequiredQuantity = Quantity
    FROM ProductionOrders
    WHERE OrderID = @OrderID;
    IF @QuantityProduced >= @RequiredQuantity
    BEGIN
        UPDATE ProductionOrders
        SET Status = 'Completed'
        WHERE OrderID = @OrderID;
    END
END;

UPDATE ProductionOrders
SET Quantity = 10
WHERE OrderID = 1;

SELECT co.CustomerName, co.Quantity, p.ProductName, p.UnitPrice, s.ShippedDate, co.Status
FROM CustomerOrders co
JOIN Products p ON co.ProductID = p.ProductID
JOIN Shipments s ON co.CustomerOrderID = s.CustomerOrderID
WHERE co.Status = 'Shipped';

SELECT co.CustomerOrderID, co.CustomerName, p.ProductName, p.UnitPrice, co.Quantity, co.OrderDate
FROM CustomerOrders co
INNER JOIN Products p ON co.ProductID = p.ProductID;

SELECT w.WarehouseID, w.Location, p.ProductID, p.ProductName
FROM Warehouses w
CROSS JOIN Products p;

SELECT p.ProductName, SUM(i.Quantity) AS TotalQuantity
FROM Products p
JOIN Inventory i ON p.ProductID = i.ItemID AND i.ItemType = 'Product'
GROUP BY p.ProductName;

SELECT s.ShipmentID, co.CustomerName, p.ProductName, w.Location, s.ShippedDate
FROM Shipments s
INNER JOIN CustomerOrders co ON s.CustomerOrderID = co.CustomerOrderID
INNER JOIN Products p ON co.ProductID = p.ProductID
INNER JOIN Warehouses w ON s.WarehouseID = w.WarehouseID;


CREATE PROCEDURE CreateProductionOrder
    @ProductID INT,
    @RequiredQuantity INT
AS
BEGIN
    DECLARE @CurrentStock INT;
    SELECT @CurrentStock = Quantity
    FROM Inventory
    WHERE ItemID = @ProductID AND ItemType = 'Product';
    IF @CurrentStock < @RequiredQuantity
    BEGIN
        INSERT INTO ProductionOrders (ProductID, Quantity, ScheduledDate, Status)
        VALUES (@ProductID, @RequiredQuantity - @CurrentStock, GETDATE(), 'Planned');
    END
END;

EXEC CreateProductionOrder @ProductID = 1, @RequiredQuantity = 15;


