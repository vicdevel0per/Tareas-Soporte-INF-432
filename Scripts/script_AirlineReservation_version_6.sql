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

BULK INSERT cancellation
FROM 'D:\Soporte\CANCELACION.csv'
WITH (
    FIRSTROW = 1,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
)------------**********

---- SELECT -------
select * from city
 select * from country
 select * from airport
 select * from flight_number
 select * from airline
 select * from airport
 select * from checkin
 select * from cancellation




----- CREACION DE LA BASE DE DATOS ---------------
IF NOT EXISTS(SELECT name FROM master.sys.databases WHERE name='AirlineReservation_ex')
BEGIN	
CREATE DATABASE AirlineReservation_ex;
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


------- persona------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'person') AND type = N'U')
BEGIN
    CREATE TABLE person (
        id INT PRIMARY KEY IDENTITY(1,1),
	[name] VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	CONSTRAINT UQ_person_name UNIQUE([name])
    );
END ELSE
BEGIN
 print 'ya existe la tabla';
END
GO

----- CLIENTE---------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'customer') AND type = N'U')
BEGIN
    CREATE TABLE customer(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	date_of_birth DATE NOT NULL,
	[name] VARCHAR(255),
	id_person INT NOT NULL,
	FOREIGN KEY(id_person) REFERENCES person(id),
	CONSTRAINT CHK_customer_date_of_birth 
	CHECK (date_of_birth < GETDATE())
);
END ELSE
BEGIN
 print 'ya existe la tabla';
END
GO

If not Exists(Select * from sys.indexes where object_id=OBJECT_ID(N'dbo.customer')and name='IDX_customer_name_')
Begin
CREATE INDEX IDX_customer_name_ ON customer([name]);
End
 Else
 Begin
  print'El índice ya ha sido creado!!'
 End
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

------------------ 1 AEROLINEA --------------
IF NOT EXISTS(SELECT * FROM sys.objects WHERE object_id=OBJECT_ID(N'airline')AND type=N'U')
BEGIN
CREATE TABLE airline (
    id INT PRIMARY KEY IDENTITY(1,1),
    [name] VARCHAR(255) NOT NULL,
    code VARCHAR(10) NOT NULL,
	Grapchic VARCHAR(255),
    CONSTRAINT airline_code UNIQUE(code)
)
END
 ELSE
 BEGIN
  print 'La tabla ya existe!!!';
 END
GO

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.airline')and name=N'IDX_airline_name')
BEGIN
CREATE INDEX IDX_airline_name ON airline([name]);
END 
 ELSE
BEGIN
  print 'El índice ya ah sido creado';
END
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
	id_airline INT NOT NULL,
	FOREIGN KEY(id_airline) REFERENCES airline(id),
	FOREIGN KEY(id_airport_start) REFERENCES airport(id),
	FOREIGN KEY(id_airport_goal) REFERENCES airport(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
)
End
 Else
Begin
print 'La tabla ya existe!!!'
End
GO



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

-------------------- TIPO DE DOCUMENTO ------------------
IF NOT EXISTS( SELECT* FROM sys.objects WHERE object_id=OBJECT_ID (N'document_type(') and type=N'U')
BEGIN
CREATE TABLE document_type(
	id INT PRIMARY KEY IDENTITY(1,1),
	"name" VARCHAR(100),
	CONSTRAINT UQ_document_type_name UNIQUE("name")
)
END
 ELSE
BEGIN
print'la tabla ya existe';
END
GO

-------- DOCUMENTO DE IDENTIFICACION ---------
IF NOT EXISTS(SELECT* FROM sys.objects where object_id=OBJECT_ID(N'identification_document') and type=N'U' )
BEGIN
CREATE TABLE identification_document(
	id INT PRIMARY KEY IDENTITY(1,1),
	document_number VARCHAR(50) NOT NULL,
	document_type_id INT NOT NULL,
	issue_date DATE NOT NULL,
	expiration_date DATE NOT NULL,
	issue_country INT NOT NULL,
	FOREIGN KEY (issue_country) REFERENCES country(id),
	FOREIGN KEY (document_type_id) REFERENCES document_type(id),
	CONSTRAINT UQ_identification_document_document_number UNIQUE(document_number),
	CONSTRAINT CHK_identification_document_issue_date CHECK(issue_date<=GETDATE()),
	CONSTRAINT CHK_identification_document_expiration_date CHECK(expiration_date>GETDATE()),
)
END
 ELSE
BEGIN
print 'La tabla ya existe!!!';
END
GO

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

------------------ METODO DE PAGO  -------------
If not Exists(Select *from sys.objects where object_id=OBJECT_ID(N'payment_method')and type=N'U')
Begin
CREATE TABLE payment_method (
    id INT PRIMARY KEY IDENTITY(1,1),
	number_card VARCHAR(255),
    CONSTRAINT UQ_number_card UNIQUE(number_card)
);
End
 Else
Begin
print 'La tabla ya existe'
End
GO

------------------ PAGO  -------------
If not Exists(Select *from sys.objects where object_id=OBJECT_ID(N'payment')and type=N'U')
Begin
CREATE TABLE payment (
    id INT PRIMARY KEY IDENTITY(1,1),
	amount FLOAT NOT NULL,
	date_of_pay DATE NOT NULL,
	id_payment_method INT NOT NULL,
    CONSTRAINT CHK_date_of_pay CHECK(date_of_pay>getDate()),
	CONSTRAINT CHK_amount CHECK(amount>=0)
);
End
 Else
Begin
print 'La tabla ya existe'
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
	id_airplane INT NOT NULL,
	FOREIGN KEY(id_flight_number) REFERENCES flight_number(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	FOREIGN KEY(id_airplane) REFERENCES airplane(id),
	CONSTRAINT CHK_flight_flight_date CHECK(flight_date>GETDATE())
)
End
 Else
Begin
print'La tabla ya existe!!!'; 
End
GO

------------------ RESERVAS -------------
If not Exists(Select *from sys.objects where object_id=OBJECT_ID(N'reservation')and type=N'U')
Begin
CREATE TABLE reservation (
    id INT PRIMARY KEY IDENTITY(1,1),
    reservation_code VARCHAR(50) NOT NULL,
    reservation_date DATE NOT NULL,
    id_customer INT NOT NULL,
	id_payment INT NOT NULL,
    FOREIGN KEY(id_customer) REFERENCES customer(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
	FOREIGN KEY(id_payment) REFERENCES payment(id),
    CONSTRAINT UQ_reservation_code UNIQUE(reservation_code),
    CONSTRAINT CHK_reservation_date CHECK (reservation_date >= GETDATE())
);
End
 Else
Begin
print 'La tabla ya existe'
End
GO

------------   TICKET   ----------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ticket') AND type = N'U')
BEGIN
    CREATE TABLE ticket(
	id INT PRIMARY KEY IDENTITY(1,1),
	ticketing_code INT NOT NULL,
	number INT NOT NULL,
	id_reservation INT NOT NULL,
	id_person INT NOT NULL,
	id_identification_document INT NOT NULL,
	FOREIGN KEY(id_identification_document) REFERENCES identification_document(id),
	FOREIGN KEY (id_person) REFERENCES person(id),
	FOREIGN KEY (id_reservation) REFERENCES reservation(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT UQ_ticket_ticketing_code_number UNIQUE (ticketing_code, number)
);
END ELSE
BEGIN
 print 'ya existe la tabla';
END
GO

------------  CHECKIN-----------------
If not Exists(Select *from sys.objects where object_id=OBJECT_ID(N'checkin')and type=N'U')
Begin
CREATE TABLE checkin (
    id INT PRIMARY KEY IDENTITY(1,1),
	[date] DATE NOT NULL,
	[time] TIME NOT NULL,
	id_ticket INT NOT NULL,
	FOREIGN KEY(id_ticket) REFERENCES ticket(id),
    CONSTRAINT CHK_date_checkin CHECK([date]>getDate())
);
End
 Else
Begin
print 'La tabla ya existe'
End
GO

------------  CANCELACION-----------------
If not Exists(Select *from sys.objects where object_id=OBJECT_ID(N'cancellation')and type=N'U')
Begin
CREATE TABLE cancellation (
    id INT PRIMARY KEY IDENTITY(1,1),
	[date] DATE NOT NULL,
	[time] TIME NOT NULL,
	id_ticket INT NOT NULL,
	FOREIGN KEY(id_ticket) REFERENCES ticket(id),
    CONSTRAINT CHK_date_cancellation CHECK([date]>getDate())
);
End
 Else
Begin
print 'La tabla ya existe'
End
GO



------- CLASEv-----------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'coupon_class') AND type = N'U')
BEGIN
    CREATE TABLE coupon_class (
        id INT PRIMARY KEY IDENTITY(1,1),
	[name] VARCHAR(50) NOT NULL,
	CONSTRAINT UQ_coupon_class_name UNIQUE([name])
    );
END ELSE
BEGIN
 print 'ya existe la tabla';
END
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
	id_class INT NOT NULL,
	FOREIGN KEY (id_ticket) REFERENCES ticket(id),
	FOREIGN KEY (id_flight) REFERENCES flight(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	FOREIGN KEY (id_class) REFERENCES coupon_class(id),
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




----------------PERIODO DE USO----------------
If not Exists(Select *from sys.objects where object_id=OBJECT_ID(N'aircraft_assignment')and type=N'U')
Begin
CREATE TABLE aircraft_assignment(
	id INT PRIMARY KEY IDENTITY(1,1),
	start_of_operation DATE NOT NULL,
	end_of_operation DATE,
	id_airplane INT NOT NULL,
	id_airline INT NOT NULL,
	FOREIGN KEY (id_airplane) REFERENCES airplane(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	FOREIGN KEY (id_airline) REFERENCES airline(id),
	CONSTRAINT CHK_airplane_start_of_operation CHECK(start_of_operation<=GETDATE()),
	CONSTRAINT CHK_airplane_end_of_operation CHECK(end_of_operation > start_of_operation)
);
End
 Else
 Begin
 print 'La tabla ya existe!!!';
 End
GO


------- rol ----------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'role_flight') AND type = N'U')
BEGIN
    CREATE TABLE role_flight (
        id INT PRIMARY KEY IDENTITY(1,1),
	[name] VARCHAR(50) NOT NULL,
	CONSTRAINT UQ_role_name UNIQUE([name])
    );
END ELSE
BEGIN
 print 'ya existe la tabla';
END
GO



---------------- 3 TRIPULACION DE VUELO ------------------
If not exists(select* from sys.objects where object_id=OBJECT_ID(N'flight_crew')and type=N'U')
Begin
CREATE TABLE flight_crew (
    id INT PRIMARY KEY IDENTITY(1,1),
    role VARCHAR(100) NOT NULL,
    id_person INT NOT NULL,
    FOREIGN KEY(id_person) REFERENCES person(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
End
 Else
 Begin
 print'La tabla ya existe!!!'; 
 End
GO

---------------- 3 TRIPULACION DE VUELO-rol ------------------
If not exists(select* from sys.objects where object_id=OBJECT_ID(N'flight_crew_role')and type=N'U')
Begin
CREATE TABLE flight_crew_role (
    id INT PRIMARY KEY IDENTITY(1,1),
    role VARCHAR(100) NOT NULL,
    id_role INT NOT NULL,
    id_flight INT NOT NULL,
    id_flight_crew INT NOT NULL,
    FOREIGN KEY(id_role) REFERENCES role_flight(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
	FOREIGN KEY(id_flight) REFERENCES flight(id),
	FOREIGN KEY(id_flight_crew) REFERENCES flight_crew(id)
)
End
 Else
 Begin
 print'La tabla ya existe!!!'; 
 End
GO

/*
BULK INSERT
	customer
FROM 
	'D:\Carlos\Semestre2-2024Apuntes\Sistmas para el soporte\prueba.csv'
WITH(
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	FIRSTROW = 1
)
*/