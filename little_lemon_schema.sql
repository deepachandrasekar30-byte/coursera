-- Little Lemon Database Schema
-- Drop database if exists and create fresh
DROP DATABASE IF EXISTS LittleLemonDB;
CREATE DATABASE LittleLemonDB;
USE LittleLemonDB;

-- Create Customers table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerName VARCHAR(255) NOT NULL,
    ContactNumber VARCHAR(20),
    Email VARCHAR(255)
);

-- Create Bookings table
CREATE TABLE Bookings (
    BookingID INT PRIMARY KEY AUTO_INCREMENT,
    BookingDate DATE NOT NULL,
    TableNumber INT NOT NULL,
    NumberOfGuests INT NOT NULL,
    CustomerID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE
);

-- Create MenuItems table
CREATE TABLE MenuItems (
    MenuItemID INT PRIMARY KEY AUTO_INCREMENT,
    ItemName VARCHAR(255) NOT NULL,
    Category VARCHAR(100),
    Price DECIMAL(10, 2) NOT NULL
);

-- Create Orders table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    OrderDate DATE NOT NULL,
    TotalCost DECIMAL(10, 2),
    CustomerID INT,
    BookingID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE SET NULL,
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID) ON DELETE SET NULL
);

-- Create OrderDetails table
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    MenuItemID INT,
    Quantity INT NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (MenuItemID) REFERENCES MenuItems(MenuItemID) ON DELETE CASCADE
);

-- Create Staff table
CREATE TABLE Staff (
    StaffID INT PRIMARY KEY AUTO_INCREMENT,
    StaffName VARCHAR(255) NOT NULL,
    Role VARCHAR(100),
    Salary DECIMAL(10, 2)
);

-- Insert Sample Data into Customers
INSERT INTO Customers (CustomerName, ContactNumber, Email) VALUES
('John Doe', '555-0101', 'john.doe@email.com'),
('Jane Smith', '555-0102', 'jane.smith@email.com'),
('Michael Brown', '555-0103', 'michael.brown@email.com'),
('Emily Davis', '555-0104', 'emily.davis@email.com'),
('David Wilson', '555-0105', 'david.wilson@email.com');

-- Insert Sample Data into Bookings
INSERT INTO Bookings (BookingDate, TableNumber, NumberOfGuests, CustomerID) VALUES
('2024-11-10', 1, 4, 1),
('2024-11-10', 2, 2, 2),
('2024-11-11', 3, 6, 3),
('2024-11-11', 4, 3, 4),
('2024-11-12', 5, 5, 5),
('2024-11-12', 1, 2, 1),
('2024-11-13', 2, 4, 2);

-- Insert Sample Data into MenuItems
INSERT INTO MenuItems (ItemName, Category, Price) VALUES
('Greek Salad', 'Appetizer', 8.99),
('Bruschetta', 'Appetizer', 7.50),
('Grilled Salmon', 'Main Course', 22.99),
('Pasta Carbonara', 'Main Course', 16.99),
('Margherita Pizza', 'Main Course', 14.99),
('Tiramisu', 'Dessert', 6.99),
('Chocolate Cake', 'Dessert', 5.99),
('Lemon Sorbet', 'Dessert', 4.99);

-- Insert Sample Data into Orders
INSERT INTO Orders (OrderDate, TotalCost, CustomerID, BookingID) VALUES
('2024-11-10', 45.97, 1, 1),
('2024-11-10', 31.98, 2, 2),
('2024-11-11', 89.94, 3, 3),
('2024-11-11', 39.97, 4, 4),
('2024-11-12', 74.95, 5, 5);

-- Insert Sample Data into OrderDetails
INSERT INTO OrderDetails (OrderID, MenuItemID, Quantity) VALUES
(1, 1, 2),
(1, 3, 1),
(1, 6, 2),
(2, 2, 1),
(2, 5, 1),
(2, 7, 1),
(3, 1, 3),
(3, 4, 3),
(3, 6, 3),
(4, 2, 2),
(4, 3, 1),
(5, 5, 2),
(5, 4, 1),
(5, 8, 3);

-- Insert Sample Data into Staff
INSERT INTO Staff (StaffName, Role, Salary) VALUES
('Mario Rossi', 'Manager', 55000.00),
('Luigi Verde', 'Head Chef', 48000.00),
('Anna Bianchi', 'Waiter', 32000.00),
('Carlo Neri', 'Chef', 42000.00),
('Sofia Giallo', 'Host', 30000.00);

-- Stored Procedures

-- 1. GetMaxQuantity() - Returns the maximum quantity ordered
DELIMITER //
CREATE PROCEDURE GetMaxQuantity()
BEGIN
    SELECT MAX(Quantity) AS MaxQuantity 
    FROM OrderDetails;
END //
DELIMITER ;

-- 2. ManageBooking() - Check if a table is already booked
DELIMITER //
CREATE PROCEDURE ManageBooking(
    IN booking_date DATE,
    IN table_number INT
)
BEGIN
    DECLARE table_status VARCHAR(50);
    
    SELECT COUNT(*) INTO @table_count
    FROM Bookings
    WHERE BookingDate = booking_date AND TableNumber = table_number;
    
    IF @table_count > 0 THEN
        SET table_status = 'Table is already booked';
    ELSE
        SET table_status = 'Table is available';
    END IF;
    
    SELECT table_status AS Status;
END //
DELIMITER ;

-- 3. UpdateBooking() - Update booking details
DELIMITER //
CREATE PROCEDURE UpdateBooking(
    IN booking_id INT,
    IN new_booking_date DATE
)
BEGIN
    UPDATE Bookings
    SET BookingDate = new_booking_date
    WHERE BookingID = booking_id;
    
    SELECT CONCAT('Booking ', booking_id, ' updated successfully') AS Confirmation;
END //
DELIMITER ;

-- 4. AddBooking() - Add a new booking
DELIMITER //
CREATE PROCEDURE AddBooking(
    IN booking_date DATE,
    IN table_number INT,
    IN customer_id INT,
    IN num_guests INT
)
BEGIN
    INSERT INTO Bookings (BookingDate, TableNumber, CustomerID, NumberOfGuests)
    VALUES (booking_date, table_number, customer_id, num_guests);
    
    SELECT 'New booking added successfully' AS Confirmation;
END //
DELIMITER ;

-- 5. CancelBooking() - Cancel a booking
DELIMITER //
CREATE PROCEDURE CancelBooking(
    IN booking_id INT
)
BEGIN
    DELETE FROM Bookings
    WHERE BookingID = booking_id;
    
    SELECT CONCAT('Booking ', booking_id, ' cancelled successfully') AS Confirmation;
END //
DELIMITER ;

-- Additional useful procedures

-- Get booking details
DELIMITER //
CREATE PROCEDURE GetBookingDetails(IN booking_id INT)
BEGIN
    SELECT 
        b.BookingID,
        b.BookingDate,
        b.TableNumber,
        b.NumberOfGuests,
        c.CustomerName,
        c.ContactNumber,
        c.Email
    FROM Bookings b
    JOIN Customers c ON b.CustomerID = c.CustomerID
    WHERE b.BookingID = booking_id;
END //
DELIMITER ;

-- Get all bookings for a specific date
DELIMITER //
CREATE PROCEDURE GetBookingsByDate(IN booking_date DATE)
BEGIN
    SELECT 
        b.BookingID,
        b.TableNumber,
        b.NumberOfGuests,
        c.CustomerName,
        c.ContactNumber
    FROM Bookings b
    JOIN Customers c ON b.CustomerID = c.CustomerID
    WHERE b.BookingDate = booking_date
    ORDER BY b.TableNumber;
END //
DELIMITER ;

-- Views for reporting

-- Create view for order summary
CREATE VIEW OrderSummary AS
SELECT 
    o.OrderID,
    o.OrderDate,
    c.CustomerName,
    o.TotalCost,
    COUNT(od.OrderDetailID) AS TotalItems
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY o.OrderID, o.OrderDate, c.CustomerName, o.TotalCost;

-- Create view for popular menu items
CREATE VIEW PopularMenuItems AS
SELECT 
    mi.ItemName,
    mi.Category,
    mi.Price,
    SUM(od.Quantity) AS TotalOrdered,
    SUM(od.Quantity * mi.Price) AS TotalRevenue
FROM MenuItems mi
JOIN OrderDetails od ON mi.MenuItemID = od.MenuItemID
GROUP BY mi.MenuItemID, mi.ItemName, mi.Category, mi.Price
ORDER BY TotalOrdered DESC;

-- Create view for booking statistics
CREATE VIEW BookingStatistics AS
SELECT 
    BookingDate,
    COUNT(*) AS TotalBookings,
    SUM(NumberOfGuests) AS TotalGuests,
    AVG(NumberOfGuests) AS AvgGuestsPerBooking
FROM Bookings
GROUP BY BookingDate
ORDER BY BookingDate;