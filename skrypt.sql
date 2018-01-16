use master
if exists(select * from sys.databases where name = 'Konferencje')
drop database Konferencje
create database Konferencje

use Konferencje

IF object_id ('dbo.Address', 'U') IS NOT NULL
DROP TABLE Address
CREATE TABLE [Address] (
  [AddressID] [int] NOT NULL PRIMARY KEY IDENTITY (1,1),
  [Street] [nvarchar](50) NULL,
  [City] [nvarchar](50) NULL,
  [ZIP] [nvarchar](10) NULL,
  [Country] [nvarchar](30) NULL,
  );

IF object_id ('dbo.Conferences', 'U') IS NOT NULL
DROP TABLE Conferences
CREATE TABLE [Conferences] (
  [ConferenceID] [int] NOT NULL PRIMARY KEY IDENTITY (1,1),
  [ConferenceName] [nvarchar](50) NOT NULL,
  [StartDate] [datetime] NULL,
  [EndDate] [datetime] NULL,
  [LocationID] [int] NOT NULL FOREIGN KEY REFERENCES Address(AddressID),
  [StudentDiscount] [int] NULL,
);

ALTER TABLE Conferences
ADD CONSTRAINT CK_StudentDiscount CHECK (StudentDiscount >= 0 AND StudentDiscount <= 100);
ALTER TABLE Conferences
ADD CONSTRAINT CK_Days CHECK (StartDate < EndDate);

IF object_id ('dbo.Prices', 'U') IS NOT NULL
DROP TABLE Prices
CREATE TABLE [Prices] (
  [ConferenceID] [int] NOT NULL FOREIGN KEY REFERENCES Conferences(ConferenceID),
  [DaysBeforeStart] [int] NOT NULL,
  [Price] [money] NOT NULL,
);

ALTER TABLE Prices
ADD CONSTRAINT CK_Price CHECK (Price > 0);
ALTER TABLE Prices
ADD CONSTRAINT CK_DaysBeforeStart CHECK (DaysBeforeStart >= 0);

IF object_id ('dbo.Customers', 'U') IS NOT NULL
DROP TABLE Customers
CREATE TABLE [Customers] (
  [CustomerID] [int] NOT NULL PRIMARY KEY IDENTITY (1,1),
  [AddressID] [int] NOT NULL FOREIGN KEY REFERENCES Address(AddressID),
  [Email] [nvarchar](50) NULL,
  [Phone] [nvarchar](20) NULL,
  [IsCompany] [bit] DEFAULT 0 NOT NULL,
);

IF object_id ('dbo.PrivateCustomers', 'U') IS NOT NULL
DROP TABLE PrivateCustomers
CREATE TABLE [PrivateCustomers] (
  [CustomerID] [int] NOT NULL FOREIGN KEY REFERENCES Customers(CustomerID),
  [Firstname] [nvarchar](30) NOT NULL,
  [Lastname] [nvarchar](30) NOT NULL,
);

IF object_id ('dbo.Companies', 'U') IS NOT NULL
DROP TABLE Companies
CREATE TABLE [Companies] (
  [CustomerID] [int] NOT NULL FOREIGN KEY REFERENCES Customers(CustomerID),
  [CompanyName] [nvarchar](50) NOT NULL,
  [ContactName] [nvarchar](30) NOT NULL,
  [NIP] [nchar](10) UNIQUE NOT NULL,
);

IF object_id ('dbo.Attendees', 'U') IS NOT NULL
DROP TABLE Attendees
CREATE TABLE [Attendees] (
  [AttendeeID] [int] NOT NULL PRIMARY KEY IDENTITY (1,1),
  [Firstname] [nvarchar](30) NOT NULL,
  [Lastname] [nvarchar](30) NOT NULL,
  [Email] [nvarchar](50) NULL,
  [Phone] [nvarchar](20) NULL,
  [StudentCard] [nvarchar](20) NULL UNIQUE,
  [WorksForID] [int] NULL FOREIGN KEY REFERENCES Customers(CustomerID),
);

IF object_id ('dbo.ConferenceDays', 'U') IS NOT NULL
DROP TABLE ConferenceDays
CREATE TABLE [ConferenceDays] (
  [ConferenceDayID] [int] NOT NULL PRIMARY KEY IDENTITY (1, 1),
  [ConferenceID] [int] NOT NULL FOREIGN KEY REFERENCES Conferences(ConferenceID),
  [Day] [int] NOT NULL,
  [MaxParticipants] [int] NOT NULL,
);

ALTER TABLE ConferenceDays
ADD CONSTRAINT CK_DayNo CHECK (Day > 0);
ALTER TABLE ConferenceDays
ADD CONSTRAINT CK_MaxParticipants CHECK (MaxParticipants > 0);

IF object_id ('dbo.Workshops', 'U') IS NOT NULL
DROP TABLE Workshops
CREATE TABLE [Workshops] (
  [WorkshopID] [int] NOT NULL PRIMARY KEY IDENTITY (1, 1),
  [Name] [nvarchar](50) NOT NULL,
  [ConferenceDayID] [int] FOREIGN KEY REFERENCES ConferenceDays(ConferenceDayID),
  [StartTime] [datetime] NOT NULL,
  [EndTime] [datetime] NOT NULL,
  [Location] [nvarchar](50) NOT NULL,
  [Price] [money] NOT NULL,
  [ParticipantsLimit] [int] NOT NULL,
);

ALTER TABLE Workshops
ADD CONSTRAINT CK_Times CHECK (StartTime < EndTime);
ALTER TABLE Workshops
ADD CONSTRAINT CK_WPrice CHECK (Price >= 0);
ALTER TABLE Workshops
ADD CONSTRAINT CK_WParticipantsLimit CHECK (ParticipantsLimit > 0);

IF object_id ('dbo.Payments', 'U') IS NOT NULL
DROP TABLE Payments
CREATE TABLE [Payments] (
  [PaymentID] [int] NOT NULL PRIMARY KEY IDENTITY(1, 1),
  [Value] [money] NOT NULL,
  [Date] [datetime] NOT NULL,
);

IF object_id ('dbo.Reservations', 'U') IS NOT NULL
DROP TABLE Reservations
CREATE TABLE [Reservations] (
  [ReservationID] [int] NOT NULL PRIMARY KEY IDENTITY(1, 1),
  [CustomerID] [int] NOT NULL FOREIGN KEY REFERENCES Customers(CustomerID),
  [PaymentID] [int] NULL FOREIGN KEY REFERENCES Payments(PaymentID),
  [IsCancelled] [bit] DEFAULT 0 NOT NULL,
  [Date] [datetime] NOT NULL,
);

IF object_id ('dbo.WorkshopReservations', 'U') IS NOT NULL
DROP TABLE WorkshopReservations
CREATE TABLE [WorkshopReservations] (
  [WorkshopReservationID] [int] NOT NULL PRIMARY KEY IDENTITY(1, 1),
  [ReservationID] [int] NOT NULL FOREIGN KEY REFERENCES Reservations(ReservationID),
  [WorkshopID] [int] NOT NULL FOREIGN KEY REFERENCES Workshops(WorkshopID),
  [NumReservations] [int] NOT NULL,
);

ALTER TABLE WorkshopReservations
ADD CONSTRAINT CK_WNumReservations CHECK (NumReservations > 0);

IF object_id ('dbo.ConferenceReservations', 'U') IS NOT NULL
DROP TABLE ConferenceReservations
CREATE TABLE [ConferenceReservations] (
  [ConferenceReservationID] [int] NOT NULL PRIMARY KEY IDENTITY(1, 1),
  [ReservationID] [int] NOT NULL FOREIGN KEY REFERENCES Reservations(ReservationID),
  [ConferenceID] [int] NOT NULL FOREIGN KEY REFERENCES Conferences(ConferenceID),
  [NumReservations] [int] NOT NULL,
);

ALTER TABLE ConferenceReservations
ADD CONSTRAINT CK_CNumReservations CHECK (NumReservations > 0);

IF object_id ('dbo.WorkshopRegistrations', 'U') IS NOT NULL
DROP TABLE WorkshopRegistrations
CREATE TABLE [WorkshopRegistrations] (
  [ConferenceReservationID] [int] NOT NULL FOREIGN KEY REFERENCES ConferenceReservations(ConferenceReservationID),
  [WorkshopReservationID] [int] NOT NULL FOREIGN KEY REFERENCES WorkshopReservations(WorkshopReservationID),
  [AttendeeID] [int] NOT NULL FOREIGN KEY REFERENCES Attendees(AttendeeID),
);

IF object_id ('dbo.ConferenceRegistrations', 'U') IS NOT NULL
DROP TABLE ConferenceRegistrations
CREATE TABLE [ConferenceRegistrations] (
  [ConferenceReservationID] [int] NOT NULL FOREIGN KEY REFERENCES ConferenceReservations(ConferenceReservationID),
  [AttendeeID] [int] NOT NULL FOREIGN KEY REFERENCES Attendees(AttendeeID),
);







