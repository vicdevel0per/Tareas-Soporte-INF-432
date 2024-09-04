--- ELIMINACION COMPLETA DEL DATABASE
USE master;
GO
ALTER DATABASE AirlineReservation
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE AirlineReservation;
GO
------------ FIN DE METODOS PARA ELIMINAR

----- CREACION DE LA BASE DE DATOS ---------------
IF NOT EXISTS(SELECT name FROM master.sys.databases WHERE name='AirlineReservation')
BEGIN	
CREATE DATABASE AirlineReservation;
PRINT'Base de datos creada exitosamente';
END
 ELSE
BEGIN
	PRINT 'La base de datos ya existe';
END
GO
--------------
USE AirlineReservation;
GO
--------------
--IF OBJECT_ID('customers','U') IS NOT NULL
--DROP TABLE customers;
--GO

----- CLIENTE
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'customer') AND type = N'U')
BEGIN
    CREATE TABLE customer(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	date_of_birth DATE NOT NULL,
	[name] VARCHAR(255),
	CONSTRAINT CHK_customer_date_of_birth 
	CHECK (date_of_birth < GETDATE())
);
END ELSE
BEGIN
 print 'ya existe la tabla';
END
GO

---------------------
If not Exists(Select * from sys.indexes where object_id=OBJECT_ID(N'dbo.customer')and name='IDX_customer_name_')
Begin
CREATE INDEX IDX_customer_name_ ON customer([name]);
End
 Else
 Begin
  print'El índice ya ha sido creado!!'
 End
GO

------- CATEGORIA DE CLIENTE 
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'customer_category') AND type = N'U')
BEGIN
    CREATE TABLE customer_category (
        id INT PRIMARY KEY IDENTITY(1,1),
	[name] VARCHAR(50) NOT NULL,
	id_customer INT NOT NULL,
	FOREIGN KEY (id_customer) REFERENCES customer(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT UQ_customer_category_name UNIQUE([name])
    );
END ELSE
BEGIN
 print 'ya existe la tabla';
END
GO
-------------------------
If not Exists(select * from sys.indexes where object_id=OBJECT_ID(N'dbo.customer_category')and name='_IDX_customer_category_')
Begin
CREATE INDEX _IDX_customer_category_ ON customer_category([name]);
End
 Else
Begin
 print 'El índice ya ha sido creado'; 
END
GO

-------------
---------TARJETA DE VIAJERO FRECUENTE 
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'frequent_flyer_card') AND type = N'U')
BEGIN
    CREATE TABLE frequent_flyer_card (
	id INT PRIMARY KEY IDENTITY(1,1),
	ffc_number INT NOT NULL,
	miles INT,
	meal_code VARCHAR(10),
	id_customer INT NOT NULL,
	FOREIGN KEY(id_customer) REFERENCES customer(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT UQ_frequent_flyer_card_ffc_number UNIQUE(ffc_number),
	CONSTRAINT CHK_miles CHECK (miles>0)
);
END ELSE
BEGIN
 print 'ya existe la tabla';
END
GO
---------------------
If Not Exists(select * from sys.indexes where object_id=OBJECT_ID (N'dbo.frequent_flyer_card')and name='_IDX_frequent_flyer_card_ffc_number_')
Begin
CREATE INDEX _IDX_frequent_flyer_card_ffc_number_ ON frequent_flyer_card(ffc_number);
 print'índice creado exitosamente!!';
End
 Else
Begin
 print 'El índice ya ah sido creado';
End
GO


------------   TICKET   ----------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ticket') AND type = N'U')
BEGIN
    CREATE TABLE ticket(
	id INT PRIMARY KEY IDENTITY(1,1),
	ticketing_code INT NOT NULL,
	number INT NOT NULL,
	id_customer INT NOT NULL,
	FOREIGN KEY (id_customer) REFERENCES customer(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT UQ_ticket_ticketing_code_number UNIQUE (ticketing_code, number)
);
END ELSE
BEGIN
 print 'ya existe la tabla';
END
GO


-------------------- PAIS ------------------
IF NOT EXISTS( SELECT* FROM sys.objects WHERE object_id=OBJECT_ID (N'country') and type=N'U')
BEGIN
CREATE TABLE country(
	id INT PRIMARY KEY IDENTITY(1,1),
	"name" VARCHAR(100),
	CONSTRAINT UQ_country_name UNIQUE("name")
)
END
 ELSE
BEGIN
print'la tabla ya existe';
END
GO


------------------ 1 AEROLINEA --------------
IF NOT EXISTS(SELECT * FROM sys.objects WHERE object_id=OBJECT_ID(N'airline')AND type=N'U')
BEGIN
CREATE TABLE airline (
    id INT PRIMARY KEY IDENTITY(1,1),
    [name] VARCHAR(255) NOT NULL,
    code VARCHAR(10) NOT NULL,
	Grapchic VARCHAR(255),
    country_of_origin INT NOT NULL,
    FOREIGN KEY(country_of_origin) REFERENCES country(id),
    CONSTRAINT airline_code UNIQUE(code)
)
END
 ELSE
 BEGIN
  print 'La tabla ya existe!!!';
 END
GO
--------------------
IF NOT EXISTS(SELECT * FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.airline')and name=N'IDX_airline_name')
BEGIN
CREATE INDEX IDX_airline_name ON airline([name]);
END 
 ELSE
BEGIN
  print 'El índice ya ah sido creado';
END
GO


--------------------- 2 PILOTO ----------------
IF NOT EXISTS(SELECT * FROM sys.objects WHERE object_id=OBJECT_ID(N'pilot')and type=N'U')
BEGIN
CREATE TABLE pilot (
    id INT PRIMARY KEY IDENTITY(1,1),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    license_number VARCHAR(50) NOT NULL,
    license_expiry_date DATE NOT NULL,
    nationality INT NOT NULL,
    FOREIGN KEY(nationality) REFERENCES country(id),
    CONSTRAINT pilot_license_number UNIQUE(license_number),
    CONSTRAINT pilot_license_expiry_date CHECK (license_expiry_date > GETDATE())
)
END
 ELSE
 BEGIN
 print'La tabla ya existe!!!';
 END
GO
IF NOT EXISTS(SELECT * FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.pilot')and name=N'IDX_pilot_last_name')
BEGIN
CREATE INDEX IDX_pilot_last_name ON pilot(last_name);
END
 ELSE
BEGIN
 print 'El índice ya ah sido creado';
END
GO

-------- DOCUMENTO DE IDENTIFICACION ---------
IF NOT EXISTS(SELECT* FROM sys.objects where object_id=OBJECT_ID(N'identification_document') and type=N'U' )
BEGIN
CREATE TABLE identification_document(
	id INT PRIMARY KEY IDENTITY(1,1),
	document_number VARCHAR(50) NOT NULL,
	document_type VARCHAR(30) NOT NULL,
	issue_date DATE NOT NULL,
	expiration_date DATE NOT NULL,
	issue_country INT NOT NULL,
	id_customer INT NOT NULL,
	FOREIGN KEY (issue_country) REFERENCES country(id),
	FOREIGN KEY (id_customer) REFERENCES customer(id),
	CONSTRAINT UQ_identification_document_document_number UNIQUE(document_number),
	CONSTRAINT CHK_identification_document_issue_date CHECK(issue_date<=GETDATE()),
	CONSTRAINT CHK_identification_document_expiration_date CHECK(expiration_date>GETDATE()),
	CONSTRAINT CHK_identification_document_issue_country CHECK(issue_country>0)
)
END
 ELSE
BEGIN
print 'La tabla ya existe!!!';
END
GO
---------

If Not Exists(select * from sys.indexes where object_id=OBJECT_ID(N'dbo.identification_document')and name='IDX_identification_document_document_number_')
Begin
CREATE INDEX IDX_identification_document_document_number_ ON identification_document(document_number);
 print'Índice creado exitosamente!!!'
End
 Else
Begin
 print'El índice ya ah sido creado';
End
GO

---------------- CIUDAD ------------------
IF NOT EXISTS(SELECT * FROM sys.objects where object_id=OBJECT_ID(N'city') and type=N'U' )
BEGIN
CREATE TABLE city(
	id INT PRIMARY KEY IDENTITY(1,1),
	"name" VARCHAR(100) UNIQUE,
	id_country INT NOT NULL,
	FOREIGN KEY (id_country) REFERENCES country(id)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	CONSTRAINT CHK_city_id_country CHECK(id_country>0)
)
END
 ELSE
BEGIN
print 'La tabla ya existe!!!'
END
GO


----------------- AEROPUERTO -----------------
IF not exists(select * from sys.objects where object_id=OBJECT_ID(N'airport')and type=N'U')
BEGIN
CREATE TABLE airport(
	id INT PRIMARY KEY IDENTITY(1,1),
	"name" VARCHAR(255) NOT NULL,
	id_city INT NOT NULL,
	FOREIGN KEY (id_city) REFERENCES city(id),
	CONSTRAINT CHK_airport_id_city CHECK(id_city>0)
)
END
 ELSE
BEGIN
print'La tabla ya existe!!!'
END
GO
------------------
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.airport') 
    AND name = N'IDX_airport_name_'
)
BEGIN
    CREATE INDEX IDX_airport_name_
    ON dbo.airport("name");
END;
 ELSE
Begin
print 'El índice ya ah sido creado!!!'
End
GO


--------- MODELO DE AVION ---------------
If Not Exists(select * from sys.objects where object_id=OBJECT_ID(N'plane_model')and type=N'U')
Begin
CREATE TABLE plane_model(
	id INT PRIMARY KEY IDENTITY(1,1),
	"description" VARCHAR(255),
	graphic VARCHAR(255),
)
End
 Else
Begin
print'La tabla ya existe!!!';
End
GO


---- NUMERO DE VUELO ------------
If not Exists(Select * from sys.objects where object_id=OBJECT_ID(N'flight_number')and type=N'U')
Begin
CREATE TABLE flight_number(
	id INT PRIMARY KEY IDENTITY(1,1),
	departure_time TIME NOT NULL,
	"description" VARCHAR(255),
	"type" VARCHAR(255) NOT NULL,
	airline VARCHAR(255) NOT NULL,
	id_airport_start INT NOT NULL,
	id_airport_goal INT NOT NULL,
	id_plane_model INT,
	FOREIGN KEY(id_airport_start) REFERENCES airport(id),
	FOREIGN KEY(id_airport_goal) REFERENCES airport(id),
	FOREIGN KEY(id_plane_model) REFERENCES plane_model(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT CHK_fligth_number_id_airport_start CHECK(id_airport_start>0),
	CONSTRAINT CHK_fligth_number_id_airport_goal CHECK(id_airport_goal>0),
	CONSTRAINT CHK_fligth_number_id_airport_plane_model CHECK(id_plane_model>0),
)
End
 Else
Begin
print 'La tabla ya existe!!!'
End
GO


-------------------- VUELO ---------------
If Not Exists(select *from sys.objects where object_id=OBJECT_ID(N'flight')and type=N'U')
Begin
CREATE TABLE flight(
	id INT PRIMARY KEY IDENTITY(1,1),
	boarding_time TIME NOT NULL,
	flight_date DATE NOT NULL,
	gate VARCHAR(10) NOT NULL,
	check_in_counter VARCHAR(10) NOT NULL,
	id_flight_number INT NOT NULL,
	FOREIGN KEY(id_flight_number) REFERENCES flight_number(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT CHK_flight_flight_date CHECK(flight_date>GETDATE())
)
End
 Else
Begin
print'La tabla ya existe!!!'; 
End
GO


---------------- 3 TRIPULACION DE VUELO ------------------
If not exists(select* from sys.objects where object_id=OBJECT_ID(N'flight_crew')and type=N'U')
Begin
CREATE TABLE flight_crew (
    id INT PRIMARY KEY IDENTITY(1,1),
    role VARCHAR(100) NOT NULL,
    id_pilot INT,
    id_flight INT NOT NULL,
    FOREIGN KEY(id_pilot) REFERENCES pilot(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
    FOREIGN KEY(id_flight) REFERENCES flight(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
End
 Else
 Begin
 print'La tabla ya existe!!!'; 
 End
GO


-------------- CUPON -----------------
If not exists(select* from sys.objects where object_id=OBJECT_ID(N'coupon')and type=N'U')
Begin
CREATE TABLE coupon(
	id INT PRIMARY KEY IDENTITY(1,1),
	id_ticket INT NOT NULL,
	date_of_redemption DATE NOT NULL,
	class VARCHAR(255) NOT NULL,
	stand_by VARCHAR(255),
	meal_code VARCHAR(10),
	id_flight INT NOT NULL,
	FOREIGN KEY (id_ticket) REFERENCES ticket(id),
	FOREIGN KEY (id_flight) REFERENCES flight(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT CHK_coupon_date_of_redemption CHECK (date_of_redemption <= GETDATE()),
)
End
 Else
Begin
print 'La tabla ya existe!!!';
End
GO


--------------------- EQUIPAJE ---------------------
If not Exists(select *from sys.objects where object_id=OBJECT_ID(N'pieces_of_luggage')and type=N'U')
Begin
CREATE TABLE pieces_of_luggage(
	id INT PRIMARY KEY IDENTITY(1,1),
	number INT NOT NULL,
	"weight" DECIMAL NOT NULL, 
	id_coupon INT NOT NULL,
	FOREIGN KEY (id_coupon) REFERENCES coupon(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT CHK_pieces_of_luggage_weight CHECK ("weight" > 0),
    CONSTRAINT CHK_pieces_of_luggage_number CHECK (number > 0)
)
End
 Else
Begin
 print'La tabla ya existe!!!';
End
GO


------------------ ASIENTO ----------------
If not Exists(select* from sys.objects where object_id=OBJECT_ID(N'seat')and type=N'U')
Begin
CREATE TABLE seat(
	id INT PRIMARY KEY IDENTITY(1,1),
	size DECIMAL NOT NULL,
	number INT NOT NULL,
	"location" VARCHAR(20),
	id_plane_model INT NOT NULL,
	FOREIGN KEY (id_plane_model) REFERENCES plane_model(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT CHK_seat_size CHECK (size > 0),
    CONSTRAINT CHK_seat_number CHECK (number > 0)
)
End
 Else
Begin
 print'La tabla ya existe!!!';
End
GO


---------------- ASIENTOS DISPONIBLES ---------------------
If not exists(select * from sys.objects where object_id=OBJECT_ID(N'available_seat')and type=N'U')
Begin
CREATE TABLE available_seat(
	id INT PRIMARY KEY IDENTITY(1,1),
	id_coupon INT NOT NULL,
	id_flight INT NOT NULL,
	id_seat INT NOT NULL,
	FOREIGN KEY(id_coupon) REFERENCES coupon(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	FOREIGN KEY(id_flight) REFERENCES flight(id),
	FOREIGN KEY(id_seat) REFERENCES seat(id)
)
End
 Else
 Begin
  print'La tabla ya existe!!!';
 End
GO

--REVISAR(**)
-------------------- 4 PASAJEROS A BORDO  ------------------
If not Exists(Select *from sys.objects where object_id=OBJECT_ID(N'passenger')and type=N'U')
Begin
CREATE TABLE passenger (
    id INT PRIMARY KEY IDENTITY(1,1),
    id_customer INT NOT NULL,
    id_ticket INT NOT NULL,
    id_seat INT NOT NULL,
    FOREIGN KEY(id_customer) REFERENCES customer(id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY(id_ticket) REFERENCES ticket(id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY(id_seat) REFERENCES seat(id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);
End
 Else
Begin
print 'La tabla ya existe'
End
GO


------------------ 5 RESERVAS -------------
If not Exists(Select *from sys.objects where object_id=OBJECT_ID(N'reservation')and type=N'U')
Begin
CREATE TABLE reservation (
    id INT PRIMARY KEY IDENTITY(1,1),
    reservation_code VARCHAR(50) NOT NULL,
    reservation_date DATE NOT NULL,
    id_passenger INT NOT NULL,
    FOREIGN KEY(id_passenger) REFERENCES passenger(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT UQ_reservation_code UNIQUE(reservation_code),
    CONSTRAINT CHK_reservation_date CHECK (reservation_date >= GETDATE())
);
End
 Else
Begin
print 'La tabla ya existe'
End
GO


----------------------- AVION ----------------
If not Exists(Select *from sys.objects where object_id=OBJECT_ID(N'airplane')and type=N'U')
Begin
CREATE TABLE airplane(
	id INT PRIMARY KEY IDENTITY(1,1),
	registration_number VARCHAR(15) NOT NULL,
	begin_of_operation DATE NOT NULL,
	"status" VARCHAR(50),
	id_plane_model INT NOT NULL,
	FOREIGN KEY (id_plane_model) REFERENCES plane_model(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT UQ_airplane_registration_number UNIQUE(registration_number),
	CONSTRAINT CHK_airplane_begin_of_operation CHECK(begin_of_operation<=GETDATE())
);
End
 Else
 Begin
 print 'La tabla ya existe!!!';
 End
GO


--------------- 6 HISTORIAL DE VUELOS --------------
If not Exists(Select *from sys.objects where object_id=OBJECT_ID(N'airplane_flight_history')and type=N'U')
Begin
CREATE TABLE airplane_flight_history (
    id INT PRIMARY KEY IDENTITY(1,1),
    id_airplane INT NOT NULL,
    id_flight INT NOT NULL,
    flight_date DATE NOT NULL,
    FOREIGN KEY(id_airplane) REFERENCES airplane(id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY(id_flight) REFERENCES flight(id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    CONSTRAINT CHK_airplane_flight_history_flight_date CHECK (flight_date <= GETDATE())
);
End
 Else
 Begin
 print 'La tabla ya existe!!!';
 End
GO
----------------------------------------------------------

INSERT INTO customer (date_of_birth, "name") VALUES
('1985-06-15', 'Hector Contreras'),
('1990-09-22', 'Diana Salas'),
('1978-11-30', 'Alicia Montalbán'),
('2001-04-12', 'Victor Cárdenas');

INSERT INTO customer_category ([name], id_customer) VALUES
('Regular', 1),
('VIP', 2),
('Frequent', 3),
('Occasional', 4);

INSERT INTO frequent_flyer_card (ffc_number, miles, meal_code, id_customer) VALUES
(1001, 15000, 'VGML', 1),
(1002, 20000, 'KSML', 2),
(1003, 5000, NULL, 3),
(1004, 12000, 'GFML', 4);

INSERT INTO ticket (ticketing_code, number, id_customer) VALUES
(111, 1, 1),
(112, 2, 2),
(113, 3, 3),
(114, 4, 4);

INSERT INTO country (name) VALUES
('USA'),
('Canada'),
('UK'),
('Germany'),
('France');

INSERT INTO city (name, id_country) VALUES
('New York', 1),
('Toronto', 2),
('London', 3),
('Berlin', 4),
('Paris', 5);

INSERT INTO identification_document (document_number, issue_date, expiration_date, issue_country, id_customer) VALUES
('A1234567', '2010-01-01', '2020-12-31', 1, 1),
('B2345678', '2012-05-15', '2022-05-14', 2, 2),
('C3456789', '2015-09-01', '2025-08-31', 3, 3),
('D4567890', '2018-11-20', '2028-11-19', 4, 4);

INSERT INTO airport (name, id_city) VALUES
('JFK International Airport', 1),
('Toronto Pearson International Airport', 2),
('Heathrow Airport', 3),
('Berlin Brandenburg Airport', 4);

INSERT INTO plane_model (description, graphic) VALUES
('Boeing 737', 'graphic1.png'),
('Airbus A320', 'graphic2.png'),
('Boeing 787', 'graphic3.png'),
('Airbus A380', 'graphic4.png'),
('Boeing 747', 'graphic5.png');

INSERT INTO flight_number (departure_time, "description", "type", airline, id_airport_start, id_airport_goal, id_plane_model) VALUES
('10:00:00', 'Morning Flight to London', 'International', 'British Airways', 1, 4, 4),
('12:30:00', 'Afternoon Flight to Toronto', 'International', 'Air Canada', 1, 2, 2),
('15:45:00', 'Evening Flight to Mexico City', 'International', 'Aerom�xico', 1, 3, 1),
('08:00:00', 'Early Flight to New York', 'Domestic', 'American Airlines', 4, 1, 1);

INSERT INTO flight (boarding_time, flight_date, gate, check_in_counter, id_flight_number) VALUES
('10:00:00', '2024-09-15', 'A1', '1', 1),
('12:30:00', '2024-09-16', 'B2', '2', 2),
('15:45:00', '2024-09-17', 'C3', '3', 3),
('08:00:00', '2024-09-18', 'D4', '4', 4);

INSERT INTO coupon (id_ticket, date_of_redemption, class, stand_by, meal_code, id_flight) VALUES
(1, '2024-08-15', 'Economy', NULL, 'VGML', 1),
(2, '2024-08-16', 'Business', 'Yes', 'KSML', 2),
(3, '2024-08-17', 'First', NULL, 'GFML', 3),
(4, '2024-08-18', 'Economy', 'No', NULL, 4);


INSERT INTO pieces_of_luggage (number, weight, id_coupon) VALUES
(1, 23.50, 1),
(2, 18.75, 2),
(3, 20.00, 3),
(4, 15.00, 4);

INSERT INTO flight (boarding_time, flight_date, gate, check_in_counter, id_flight_number) VALUES
('07:30:00', '2024-08-01', 'A1', '1', 1),
('11:30:00', '2024-08-02', 'B2', '2',2 ),
('16:00:00', '2024-08-03', 'C3', '3', 3),
('20:00:00', '2024-08-04', 'D4', '4', 4),
('23:00:00', '2024-08-05', 'E5', '5', 5);

INSERT INTO seat (size, number, "location", id_plane_model) VALUES
(2.00, 1, 'Window', 1),
(2.00, 2, 'Aisle', 1),
(2.50, 3, 'Window', 2),
(2.50, 4, 'Middle', 2);


INSERT INTO available_seat (id_coupon, id_flight, id_seat) VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 4);

INSERT INTO airplane (registration_number, begin_of_operation, "status", id_plane_model) VALUES
('N12345', '2010-01-01', 'Active', 1),
('C67890', '2015-05-15', 'Active', 2),
('G54321', '2020-10-10', 'Maintenance', 3),
('B09876', '2018-03-25', 'Retired', 4);

--select * from airplane;