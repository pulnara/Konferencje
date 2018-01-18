USE master
IF exists(select * from sys.databases where name = 'Konferencje')
DROP DATABASE Konferencje
CREATE DATABASE Konferencje

USE Konferencje

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
  [ParticipantsLimit] [int] NOT NULL,
);

ALTER TABLE ConferenceDays
ADD CONSTRAINT CK_DayNo CHECK (Day > 0);
ALTER TABLE ConferenceDays
ADD CONSTRAINT CK_ParticipantsLimit CHECK (ParticipantsLimit > 0);

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
  [Date] [datetime] NOT NULL,
  [IsCancelled] [BIT] NOT NULL DEFAULT 0,
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

IF object_id ('dbo.ConferenceDayReservations', 'U') IS NOT NULL
DROP TABLE ConferenceDayReservations
CREATE TABLE [ConferenceDayReservations] (
  [ConferenceDayReservationID] [int] NOT NULL PRIMARY KEY IDENTITY(1, 1),
  [ReservationID] [int] NOT NULL FOREIGN KEY REFERENCES Reservations(ReservationID),
  [ConferenceDayID] [int] NOT NULL FOREIGN KEY REFERENCES ConferenceDays(ConferenceDayID),
  [NumReservations] [int] NOT NULL,
);

ALTER TABLE ConferenceDayReservations
ADD CONSTRAINT CK_CNumReservations CHECK (NumReservations > 0);

IF object_id ('dbo.WorkshopRegistrations', 'U') IS NOT NULL
DROP TABLE WorkshopRegistrations
CREATE TABLE [WorkshopRegistrations] (
  [ConferenceReservationID] [int] NOT NULL FOREIGN KEY REFERENCES ConferenceDayReservations(ConferenceDayReservationID),
  [WorkshopReservationID] [int] NOT NULL FOREIGN KEY REFERENCES WorkshopReservations(WorkshopReservationID),
  [AttendeeID] [int] NOT NULL FOREIGN KEY REFERENCES Attendees(AttendeeID),
);

IF object_id ('dbo.ConferenceRegistrations', 'U') IS NOT NULL
DROP TABLE ConferenceRegistrations
CREATE TABLE [ConferenceRegistrations] (
  [ConferenceReservationID] [int] NOT NULL FOREIGN KEY REFERENCES ConferenceDayReservations(ConferenceDayReservationID),
  [AttendeeID] [int] NOT NULL FOREIGN KEY REFERENCES Attendees(AttendeeID),
);

GO
CREATE VIEW v_ReservationsToCancel
AS
SELECT r.ReservationID, r.CustomerID FROM Reservations r
LEFT JOIN Payments p
ON p.PaymentID = r.PaymentID
WHERE r.PaymentID IS NULL OR DATEDIFF(DAY, r.Date, p.Date) > 7
GROUP BY r.CustomerID, r.ReservationID

GO
CREATE VIEW v_UpcomingConferences
AS
SELECT c.ConferenceName, c.StartDate, c.EndDate, a.City, SUM(cd.ParticipantsLimit) AS 'Participants Limit', SUM(cdr.NumReservations) AS 'Participants No' FROM dbo.Conferences c
INNER JOIN dbo.Address a
ON a.AddressID = c.LocationID
INNER JOIN dbo.ConferenceDays cd
ON cd.ConferenceID = c.ConferenceID
INNER JOIN dbo.ConferenceDayReservations cdr
ON cdr.ConferenceDayID = cd.ConferenceDayID
WHERE c.EndDate >= GETDATE()
GROUP BY c.ConferenceName, c.StartDate, c.EndDate, a.City

GO
CREATE VIEW v_UpcomingConferencesParticipants
AS
SELECT a.Firstname, a.Lastname, (SELECT CompanyName FROM dbo.Companies WHERE CustomerID = a.WorksForID) AS CompanyName, c.ConferenceName FROM dbo.Attendees a
INNER JOIN dbo.ConferenceRegistrations cr
ON cr.AttendeeID = a.AttendeeID
INNER JOIN dbo.ConferenceDayReservations cdr
ON cdr.ConferenceDayReservationID = cr.ConferenceReservationID
INNER JOIN dbo.ConferenceDays cd
ON cd.ConferenceDayID = cdr.ConferenceDayID
INNER JOIN dbo.Conferences c
ON c.ConferenceID = cd.ConferenceID

GO
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 69','Bexley',989326,'Turkmenistan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 94','Rio Grande',230771,'Cambodia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 69','Wyano',882352,'Kenya');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Old 20','Crescent Beach',486717,'Laos');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Cowley 12','Ladonia',380775,'Ghana');
INSERT Address (Street, City, ZIP, Country) VALUES ('Old 97','Meade',517884,'Nauru');
INSERT Address (Street, City, ZIP, Country) VALUES ('Old 48','Olar',582514,'South Sudan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 64','Hitschmann',688933,'Rwanda');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Hague 10','Junior',107865,'Papua New Guinea');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Clarendon 56','Ferney',979933,'China');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 90','East Wilson',345888,'Algeria');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 59','Komatke',994767,'Cape Verde');
INSERT Address (Street, City, ZIP, Country) VALUES ('West New 3','Federal',144762,'Samoa');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 74','Shandon',347993,'Latvia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 78','Burgaw',938661,'China');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Old 74','Firestone',998606,'Mali');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 40','Lyncourt',492305,'China');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 12','Hamler',624992,'Estonia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 85','Lockland',593465,'Japan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Second 85','La Dolores',529670,'Iceland');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 36','Shell Lake',761832,'New Zealand');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 32','Upper Crossroads',559956,'Lebanon');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 22','Micco',433512,'Israel');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 52','Keltys',299808,'Djibouti');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 56','Cave Springs',570879,'South Sudan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 26','Rices Landing',922399,'Ghana');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Hague 26','Larned',842853,'Cuba');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 43','Centerfield',612085,'Botswana');
INSERT Address (Street, City, ZIP, Country) VALUES ('West White Old 12','Markleeville',408456,'Brunei');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Blue Clarendon 2','Stewartsville',434298,'Oman');
INSERT Address (Street, City, ZIP, Country) VALUES ('Old 44','Spread Eagle',372879,'Maldives');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Nobel 56','Melfa',932466,'Belize');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Green Nobel 44','Hazel Crest',626374,'Uzbekistan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Milton 12','Rocky Mount',260091,'Angola');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Nobel 25','Calverton Park',509643,'Oman');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 85','Dillingham',992016,'Sierra Leone');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Green Clarendon 96','Cuyahoga Falls',225437,'Luxembourg');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Old 49','North Auburn',784497,'Costa Rica');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Blue Cowley 86','Ville Platte',273643,'Mexico');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Clarendon 75','Malvern',252222,'Thailand');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Clarendon 75','Grapeland',616700,'Cambodia');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 46','Congress',258761,'Japan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 44','Pollock Pines',859236,'Malta');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 38','Port Bolivar',849928,'Georgia');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Red First 7','Carlstadt',406207,'United States');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 88','Chase City',689083,'Iraq');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Old 50','Cotuit',918190,'Cameroon');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 71','Pittsburgh',205852,'Ethiopia');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Hague 86','Ace',746257,'Honduras');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 5','Mayview',295351,'Andorra');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 41','Seven Mile',926288,'Kuwait');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Fabien 92','Lockett',725890,'New Zealand');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Red Cowley 70','Auburndale',810654,'Namibia');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Red Milton 65','Pinecliffe',802085,'Namibia');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Milton 23','Boring',877026,'Ecuador');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 85','Parkerton',567524,'Morocco');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green First 85','El Porvenir',331593,'Latvia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 14','Bodcaw',310282,'South Africa');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 52','Clemons',255118,'Japan');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Nobel 91','Colville',313047,'Panama');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Fabien 69','North Epworth',858882,'Ireland');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Hague 62','Donald',909889,'East Timor');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Milton 25','Cherry Valley',344601,'United Arab Emirates');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Clarendon 23','Moriarty',539398,'Mongolia');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 48','Annandale',194455,'United States');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Green Milton 29','Edgeworth',748017,'Portugal');
INSERT Address (Street, City, ZIP, Country) VALUES ('West First 5','Blennerhassett',682217,'Vatican City');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Fabien 47','Chesapeake',767112,'Georgia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Hague 80','New Amsterdam',723392,'Moldova');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 30','Lake Linden',157482,'Argentina');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 1','Eagle Village',835883,'Andorra');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Fabien 37','Red Lake',548830,'Liechtenstein');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 97','Amawalk',459775,'Palau');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Hague 74','Ferrelview',417409,'Cambodia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 85','Sanatoga',373540,'Mauritius');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 21','Dan',621871,'Eritrea');
INSERT Address (Street, City, ZIP, Country) VALUES ('West First 56','Mount Storm',332485,'Burundi');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 87','Tiptonville',699732,'Tajikistan');
INSERT Address (Street, City, ZIP, Country) VALUES ('South First 9','Monument Beach',864177,'Cameroon');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Green First 30','Ramapo',542267,'Eritrea');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Milton 15','Chuluota',240410,'Finland');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Old 68','White Center',512263,'Croatia');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Old 16','Richford',478125,'Nauru');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Oak 96','Locke',136773,'Belize');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Oak 72','Orwigsburg',609239,'Dominica');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Second 29','South Miami',127645,'Japan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 71','Marshalltown',501070,'Togo');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Green First 15','Butler Junction',484344,'Georgia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 36','Towaoc',226395,'Niger');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Second 67','Hedville',662332,'Cuba');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green New 21','Kentland',895633,'Norway');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Blue New 93','South Fallsburg',652227,'Laos');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Nobel 92','Wauchula',902166,'Australia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 28','Breslau',705610,'Yemen');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Oak 99','Bejou',720935,'Tanzania');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 44','Dallesport',928195,'Canada');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 67','Satsuma',112241,'Gabon');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 28','Baskett',872570,'Equatorial Guinea');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Second 74','Homestead Park',668761,'Kenya');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 27','Chuichu',428050,'Portugal');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Clarendon 41','Higbee',681922,'Estonia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 87','Willow City',125500,'Cyprus');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Clarendon 98','Lake Bird',274328,'Slovakia');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Red Nobel 90','Gridley',126547,'Japan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Oak 56','Goshute',757838,'Italy');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Second 98','Piketon',575529,'Chile');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Fabien 13','Hopkins',690958,'Papua New Guinea');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 26','Martins Mill',989937,'Mongolia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Oak 49','Aldine',796485,'Iraq');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 67','Lindale',755972,'Niger');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 62','Akiak',694472,'Malaysia');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Clarendon 50','Cross Roads',919956,'Seychelles');
INSERT Address (Street, City, ZIP, Country) VALUES ('South New 63','Blythewood',443493,'Spain');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Clarendon 53','Linfield',491571,'Romania');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Cowley 72','Dowelltown',754000,'Brunei');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green First 84','Bovina',330434,'Ghana');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Fabien 67','Elkhorn',724841,'Belgium');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 48','Sidon',383969,'Colombia');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Nobel 82','Nethers',227518,'Rwanda');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Old 75','Pohick',646566,'Eritrea');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 39','Orange Beach',454169,'Nauru');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 17','Max Meadows',575642,'India');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 1','Meadowdale',360774,'Zambia');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Old 93','Surf City',705118,'Mauritius');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Clarendon 73','Lovewell',243424,'Sudan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 64','Pinetop',793656,'Cambodia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 66','Neffs',222306,'East Timor');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 36','Coatesville',442871,'Switzerland');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 46','South Junction',680807,'Sweden');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Blue New 24','Farmerville',585379,'Thailand');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red New 34','Dunlay',713608,'Mongolia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Oak 51','Bay Village',527763,'Maldives');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Hague 71','Washington Court House',339008,'Seychelles');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Nobel 83','East Olympia',322034,'Congo');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 74','Mermentau',339032,'Taiwan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Oak 33','Ivanhoe',168835,'Nauru');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Hague 35','Gays Mills',488227,'Zimbabwe');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Green Nobel 36','Pyatts',381314,'India');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 24','Terra Linda',548401,'Central African Rep');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 81','Anchorage',878901,'Korea South');
INSERT Address (Street, City, ZIP, Country) VALUES ('White New 41','Amado',234361,'Gabon');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Hague 64','Leoti',283898,'Azerbaijan');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Green New 63','Mayaguez',439513,'Taiwan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue New 94','Haugen',198903,'Iran');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 81','Cedar Point',597683,'Romania');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Second 25','Crookston',220684,'Mongolia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Old 35','Brusett',636879,'Haiti');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 57','Jarrell',508158,'Belize');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 63','Cropper',495554,'Vanuatu');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Old 35','Cedar River',688426,'Saudi Arabia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Clarendon 19','Oriskany',263145,'Moldova');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 1','Follansbee',752249,'Australia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 40','Cutler Ridge',854283,'Kenya');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 7','Slovan',572611,'Russian Federation');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 47','Kezar Falls',230487,'Gambia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 86','Summerfield',208528,'Mexico');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 31','Spiritwood',613098,'Swaziland');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Nobel 50','Lake Mills',624566,'Togo');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 12','Southampton',503927,'Ethiopia');
INSERT Address (Street, City, ZIP, Country) VALUES ('South First 24','Notus',952076,'Nigeria');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 32','Honomu',269269,'Afghanistan');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Clarendon 8','East Rutherford',503180,'Slovenia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 71','David City',789411,'Italy');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 85','Croton-on-Hudson',340966,'Central African Rep');
INSERT Address (Street, City, ZIP, Country) VALUES ('South First 98','Brusly',901132,'France');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Clarendon 77','Dunedin',873414,'Paraguay');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Old 89','Catano',215938,'Canada');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 76','Corry',600096,'Andorra');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Clarendon 78','Texola',516984,'Kenya');
INSERT Address (Street, City, ZIP, Country) VALUES ('North First 1','Mendham',448171,'Singapore');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 55','Powells Crossroads',276617,'Senegal');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Red New 94','San Ramon',784563,'Rwanda');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Oak 69','Independence',207090,'Ukraine');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 47','Red Bay',842757,'Tunisia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 63','Klamath',411982,'Antigua & Deps');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 46','Dishman',689205,'St Kitts & Nevis');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Hague 96','Plaquemine',555303,'Bosnia Herzegovina');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 70','Fruita',174482,'Bolivia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Milton 48','Snell',392766,'Macedonia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 9','Laurence Harbor',539685,'Burkina');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 54','Hematite',676018,'Costa Rica');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Milton 79','Lenola',895362,'Sri Lanka');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Clarendon 7','Newnan',860141,'Hungary');
INSERT Address (Street, City, ZIP, Country) VALUES ('St First 63','Tocito',160007,'Morocco');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Milton 62','Turnersville',967356,'Indonesia');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Old 23','McCracken',339529,'Turkey');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Old 97','South Cle Elum',167478,'Djibouti');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Old 45','Slippery Rock',445500,'Russian Federation');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Nobel 11','Tiptonville',460221,'Swaziland');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 56','Parksville',774668,'Iran');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Clarendon 44','Pine Log',331591,'Zambia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Nobel 27','Glen Ellen',172846,'Zimbabwe');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 86','Beebe',785832,'Panama');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Red New 44','Onarga',610933,'Bangladesh');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 2','Laurence Harbor',708598,'Gambia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green First 1','Calavo Gardens',914692,'India');
INSERT Address (Street, City, ZIP, Country) VALUES ('Old 89','Wool Market',619197,'Taiwan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red New 59','Hatchbend',261591,'Nauru');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 69','Shark River Hills',163456,'Saudi Arabia');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 73','Blaine Hill',331072,'El Salvador');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 44','Mayer',869890,'St Lucia');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 96','Hendley',597005,'Niger');
INSERT Address (Street, City, ZIP, Country) VALUES ('White First 98','Tomah',259800,'Switzerland');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Blue Hague 36','Hendrum',530595,'Vatican City');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 61','Frenchburg',472380,'Sierra Leone');
INSERT Address (Street, City, ZIP, Country) VALUES ('South First 74','Achilles',196292,'Nauru');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 56','Purdin',861271,'Albania');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Fabien 73','Cowan Heights',877887,'Vietnam');
INSERT Address (Street, City, ZIP, Country) VALUES ('South New 98','Dresbach',116794,'Kuwait');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 34','Olmsted Falls',277212,'Tunisia');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Nobel 26','Dunmore',672077,'Sierra Leone');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 4','Mattituck',860102,'Mexico');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 58','Conasauga',568437,'Honduras');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 78','Marianna',782444,'Burundi');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 51','Gore',299382,'Romania');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Second 9','Millvale',641002,'Kiribati');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 82','Cookeville',335030,'Romania');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Nobel 32','Lake Darby',672854,'Slovenia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 29','La Habra',166348,'Uzbekistan');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Nobel 82','Caddo Valley',335471,'Solomon Islands');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Old 7','Afton',617911,'Tunisia');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Milton 97','Prairie Point',323424,'Venezuela');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Cowley 29','Loman',125033,'Turkmenistan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 28','Mount Lebanon',331126,'Grenada');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 37','Quintette',732042,'Nicaragua');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Second 96','Manhasset Hills',425207,'Algeria');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Blue New 92','San Carlos Park',315975,'Norway');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Nobel 65','Slayton',848675,'Syria');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 1','Gobles',802844,'Zimbabwe');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Fabien 93','Calcium',184463,'Kiribati');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Nobel 42','Vetal',206236,'Togo');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Hague 8','Fortine',422841,'Turkey');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Cowley 40','Peoria',321892,'Sao Tome & Principe');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 89','Kooskia',655574,'Azerbaijan');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Fabien 14','Teterville',494180,'Djibouti');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Fabien 15','Culver',467724,'Argentina');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 49','Waskish',841583,'Togo');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 74','Claycomo',543071,'Sri Lanka');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 63','Eagle Nest',265379,'Egypt');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Red Old 89','Tustin',232186,'Honduras');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Cowley 82','Haven',357907,'Greece');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Nobel 98','Margie',787356,'Micronesia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 91','Shaktoolik',371492,'Tanzania');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Clarendon 60','Mountain Iron',490790,'Armenia');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Oak 31','Oologah',539148,'Dominican Republic');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Blue Oak 91','Rockdale',484951,'Argentina');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Fabien 76','Elmwood Park',645698,'Croatia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 26','Redgranite',967265,'Liechtenstein');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Oak 5','Forney',288519,'Nigeria');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Oak 47','Umbarger',231786,'Afghanistan');
INSERT Address (Street, City, ZIP, Country) VALUES ('St White Nobel 48','Azalia',166824,'Greece');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Green First 98','Lydia',894424,'Tunisia');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Hague 73','Connorville',544757,'Nepal');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 93','Dawesville',544660,'Macedonia');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Green Hague 15','Westvaco',948633,'Ireland');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Oak 64','Lanyon',138150,'Cambodia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green First 42','Wisner',213244,'Tonga');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 71','Sugarmill Woods',334035,'Slovenia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Fabien 11','Placentia',124602,'Turkmenistan');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 75','Saint Augustine Beach',860956,'Angola');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 59','Wyncote',252550,'Nicaragua');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 74','Humacao',606439,'Grenada');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Cowley 37','Snowball',715100,'Dominican Republic');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Second 99','Harbor Beach',650052,'Liberia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Milton 72','Vanderpool',937487,'Sweden');
INSERT Address (Street, City, ZIP, Country) VALUES ('Old 91','Paden',637022,'Vanuatu');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Fabien 56','Cheraw',557799,'Liechtenstein');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 94','Lockett',184847,'Gabon');
INSERT Address (Street, City, ZIP, Country) VALUES ('West First 97','North Ogden',316575,'Cameroon');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Milton 36','Bergen',215759,'Austria');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red First 80','Hogatza',162611,'Mali');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 6','Pridgen',368108,'Iceland');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Hague 56','Los Altos Hills',183076,'Peru');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Red Milton 31','Itta Bena',811517,'Cambodia');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Clarendon 92','Cottage Hill',153703,'Ukraine');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Old 30','Old Monroe',535736,'Kazakhstan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 13','Hamiltons Fort',774866,'Saint Vincent & the Grenadines');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Green Cowley 96','Onalaska',866096,'Kazakhstan');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Milton 20','West Wenatchee',487279,'Sri Lanka');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 8','Wyalusing',451821,'Lebanon');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 59','G. L. Garcia',729514,'Nauru');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Blue First 38','Hazel Hurst',916481,'Fiji');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 68','Kenova',615912,'Saint Vincent & the Grenadines');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Milton 18','North East Carry',262326,'Vietnam');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Cowley 11','Mountain Lake Park',364694,'Kazakhstan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 66','Hanson',320326,'Tuvalu');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 29','Catano',324093,'Panama');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Green Cowley 76','Happy Jack',585422,'San Marino');
INSERT Address (Street, City, ZIP, Country) VALUES ('South New 58','Fruit Hill',580698,'Romania');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 5','Swan Lake',250949,'Belgium');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Old 18','Piney',799517,'Latvia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 23','The Colony',195637,'United Arab Emirates');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 47','Mandan',503677,'South Sudan');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Red Clarendon 99','Keizer',471197,'Malawi');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Clarendon 15','Carpenterville',739790,'United Kingdom');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 24','Dent',288705,'Comoros');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Fabien 14','Cave Creek',363629,'Kuwait');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Hague 54','Lime Creek',394120,'Saudi Arabia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 7','George',404796,'Liechtenstein');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Nobel 53','Coburg',719255,'Lithuania');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Clarendon 28','San Simon',785551,'Andorra');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Cowley 32','Eleanor',767212,'Zimbabwe');
INSERT Address (Street, City, ZIP, Country) VALUES ('North White First 47','Staunton',592357,'Jordan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Old 41','McWillie',550589,'Tunisia');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Old 41','Saint Johns',594003,'Belarus');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Red First 70','Sherburn',164176,'Paraguay');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue First 32','Spotted Horse',943979,'Tuvalu');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue New 78','North Seekonk',491014,'Zimbabwe');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 52','Poindexter',977345,'Colombia');
INSERT Address (Street, City, ZIP, Country) VALUES ('White First 43','Castor',351720,'Lebanon');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 54','Jet',739008,'Afghanistan');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Old 99','Petros',215380,'El Salvador');
INSERT Address (Street, City, ZIP, Country) VALUES ('Old 51','Beemer',377464,'Malta');
INSERT Address (Street, City, ZIP, Country) VALUES ('Old 41','Easterly',550286,'Guinea-Bissau');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 46','Kissimmee',910275,'Burkina');
INSERT Address (Street, City, ZIP, Country) VALUES ('West New 94','State Line City',759547,'Senegal');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red First 92','Gramercy',654546,'Bahamas');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 57','Clendenin',377905,'Ecuador');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 49','Kingstree',286592,'Cape Verde');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Red Oak 94','Topeka',302435,'Antigua & Deps');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 16','Majestic',653927,'South Sudan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 40','Madison Lake',664723,'Myanmar');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Fabien 53','Lovilia',963818,'Armenia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red First 85','Neshaminy',811583,'Qatar');
INSERT Address (Street, City, ZIP, Country) VALUES ('White New 68','Galatia',864593,'Turkey');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 12','Mauriceville',123039,'Malta');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 89','Beallsville',852331,'Armenia');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Milton 92','Parkdale',160920,'Uruguay');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Fabien 17','Crescent City',389969,'East Timor');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Old 2','Baytown',208978,'Indonesia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 4','Waurika',373758,'Ukraine');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Milton 25','Fern Crest Village',918411,'Samoa');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Fabien 91','Richton Park',667887,'Liechtenstein');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red New 72','Beaver Creek',276057,'Equatorial Guinea');
INSERT Address (Street, City, ZIP, Country) VALUES ('North New 56','South Fallsburg',381713,'Libya');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 70','Lafayette Hill',748801,'Slovenia');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 21','Bardolph',137666,'Honduras');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Nobel 37','Kildeer',395565,'Tanzania');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Red First 15','Sonora',527713,'Bosnia Herzegovina');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Old 68','Cullman',834264,'Denmark');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 89','Mooers',629670,'Maldives');
INSERT Address (Street, City, ZIP, Country) VALUES ('North White First 59','Mont Clare',419506,'Norway');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 52','Sanbornville',747034,'Finland');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 14','Saltdale',871923,'Niger');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 14','Kiwalik',592328,'Moldova');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 54','Evendale',373543,'Suriname');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 12','Hazel',388125,'Serbia');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Cowley 20','Valier',185766,'Fiji');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Old 34','Divide',358688,'Malta');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Milton 9','Splendora',458042,'Fiji');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Clarendon 94','Silver',154296,'Trinidad & Tobago');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 93','Grasonville',845835,'Italy');
INSERT Address (Street, City, ZIP, Country) VALUES ('South New 6','Boomer',881506,'Ireland');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Oak 60','Ortonville',330034,'Saint Vincent & the Grenadines');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 24','East Hills',893193,'New Zealand');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 90','Venus',706289,'Belize');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Red Cowley 59','Lissie',725171,'United States');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Hague 22','Armagh',878095,'Uganda');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Clarendon 76','Mer Rouge',160701,'Myanmar');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Hague 19','Aspers',846106,'San Marino');
INSERT Address (Street, City, ZIP, Country) VALUES ('West White Clarendon 75','Yarnell',547038,'Azerbaijan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Milton 50','Gaines',217977,'Ghana');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Oak 53','East Douglas',512360,'Japan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 58','Spanish Fort',671772,'Mongolia');
INSERT Address (Street, City, ZIP, Country) VALUES ('West New 8','Bowesmont',613814,'Guatemala');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Green Old 49','Walthill',308804,'Tuvalu');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 47','Okeana',391399,'Japan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue First 77','White Apple',309673,'Singapore');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 56','Colmar Manor',442607,'Brazil');
INSERT Address (Street, City, ZIP, Country) VALUES ('North White Clarendon 72','Paragon',881341,'Seychelles');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Second 74','Springlee',902512,'Sao Tome & Principe');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Red Fabien 2','Charter Oak',800319,'Greece');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Blue Second 30','Cove',699923,'Congo');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Clarendon 1','Fort Thomas',648389,'Equatorial Guinea');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 40','Rougemont',641811,'Barbados');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 19','Ossian',374207,'Slovenia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 66','Blennerhassett',152253,'Eritrea');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Old 19','Wilberforce',573249,'Vatican City');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Milton 62','Frankford',283069,'Malaysia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Cowley 2','Kewanna',862933,'Malaysia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 19','Bandana',453592,'Estonia');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Old 70','Matoaka',673857,'Lebanon');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Red Hague 1','Stringer',835466,'Antigua & Deps');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 58','Lime',420423,'Mali');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 1','Orwigsburg',191141,'Gambia');
INSERT Address (Street, City, ZIP, Country) VALUES ('St White Oak 70','Council Bluffs',825478,'Niger');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 87','Murray City',733181,'United Arab Emirates');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 78','Schoharie',364191,'South Africa');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Fabien 2','Saint Robert',814296,'Portugal');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Second 67','Belcher',962830,'Micronesia');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Second 59','Basic',293440,'Brunei');
INSERT Address (Street, City, ZIP, Country) VALUES ('Old 92','Wattenberg',975731,'Japan');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 75','Meta',315253,'Fiji');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Nobel 35','Custer City',735024,'Mongolia');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Green Fabien 95','West Siloam Springs',988621,'Russian Federation');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Blue Nobel 49','Saltville',351287,'South Sudan');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 92','Groesbeck',586371,'Tunisia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 15','Halesite',636507,'Tajikistan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Oak 96','Millinocket',923110,'Saudi Arabia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Nobel 54','Audubon',991031,'Slovenia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 3','Vanderpool',594764,'Belize');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 68','Olivette',969260,'Guatemala');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 88','Comal',314067,'East Timor');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 11','Lonsdale',710520,'Comoros');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 3','Rafael Gonzalez',313190,'Togo');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Fabien 31','Friend',907025,'Mali');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Old 61','Varina',187866,'Bhutan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 93','Webb City',930542,'Germany');
INSERT Address (Street, City, ZIP, Country) VALUES ('North White First 44','Friendship',226585,'Jordan');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Nobel 75','Vigus',290414,'Finland');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Milton 92','Gambrills',445992,'Ethiopia');
INSERT Address (Street, City, ZIP, Country) VALUES ('St White Clarendon 31','North Plains',462735,'Singapore');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Oak 42','Emerald Isle',621739,'Oman');
INSERT Address (Street, City, ZIP, Country) VALUES ('South White Cowley 6','Golden Glades',836127,'Tajikistan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 55','Brashear',300421,'Lebanon');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 76','Estero',111211,'Moldova');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 64','Helen',788400,'East Timor');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Milton 85','Benge',139005,'Bahamas');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 41','Blackstone',241244,'Guatemala');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Old 90','Askewville',881342,'Saudi Arabia');
INSERT Address (Street, City, ZIP, Country) VALUES ('St White Fabien 10','North Merrick',404380,'Taiwan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 28','Latrobe',795824,'Dominica');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Hague 68','Carle Place',384525,'St Kitts & Nevis');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Green Cowley 31','Sunset Hills',553342,'Venezuela');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 70','Moultrie',373212,'Bulgaria');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Oak 66','Bass Harbor',125654,'St Kitts & Nevis');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Clarendon 61','Calhoun',578488,'Seychelles');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Blue Oak 41','Sinclair',117533,'Micronesia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 70','Zaleski',707587,'Kuwait');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Clarendon 80','Westend',889399,'Niger');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue New 17','Robert',185426,'Vietnam');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 45','Coupeville',534696,'Romania');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue New 34','Oshkosh',239356,'Madagascar');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Cowley 68','Gakona',923873,'Turkey');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red First 52','San de Fuca',445169,'Yemen');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 68','Roberta Mill',298570,'Micronesia');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Clarendon 7','Chidester',154462,'South Africa');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red New 69','Palomar Park',199120,'Cape Verde');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 13','Meadow Vale',930318,'Finland');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Nobel 22','Inman Mills',178432,'Mauritania');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Oak 65','Difficult',637267,'United States');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Fabien 89','Orange City',123970,'Serbia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Oak 75','Hoosick Falls',658658,'Norway');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Oak 10','Madisonville',821850,'Sudan');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 55','Ellendale',825455,'Angola');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 77','Derby Line',786326,'Russian Federation');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 69','Mulvane',165497,'Singapore');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Clarendon 95','Ricketts',330665,'Uganda');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Second 92','Chackbay',514042,'Tajikistan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 82','Tarzan',459630,'Cuba');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 54','Paradis',471693,'Moldova');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 50','Grant City',553718,'Cambodia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 13','Lake Itasca',986144,'Central African Rep');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Red Fabien 57','Goodsprings',700142,'Indonesia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Clarendon 6','Sierra Madre',391206,'Kyrgyzstan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 7','Lanagan',567799,'Serbia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 33','Eastover',123512,'Serbia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Second 59','Kempner',297094,'Philippines');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Oak 69','Nanticoke',275324,'Belgium');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Red Fabien 31','Carpinteria',102696,'Dominican Republic');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 48','Casnovia',636239,'Vietnam');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 92','Velva',287259,'Malta');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Second 36','Gastonville',100795,'Italy');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 91','Loring',123467,'Cambodia');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 84','East Duke',133964,'Bahamas');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 43','Rib Lake',225243,'Guinea-Bissau');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 20','Bayshore',186828,'Thailand');
INSERT Address (Street, City, ZIP, Country) VALUES ('West First 53','Ireton',594088,'Burkina');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Old 79','Hawk Inlet',631790,'Macedonia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 69','Darbyville',694274,'United Arab Emirates');
INSERT Address (Street, City, ZIP, Country) VALUES ('West First 9','Hurricane',658714,'Samoa');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 31','Pajaros',516439,'Canada');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Second 94','Idleyld Park',852355,'Sri Lanka');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Cowley 20','Honeyville',520353,'Yemen');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 24','Bristow',501335,'Liberia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Hague 23','Cedar City',387062,'Korea South');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 5','Schultz',487484,'Korea North');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Old 82','Oak View',468614,'Canada');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Nobel 69','Waxhaw',151621,'Hungary');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Clarendon 46','La Cueva',239186,'St Lucia');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Red Clarendon 57','Union Gap',635506,'Serbia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 65','Bentley',587320,'Vietnam');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Oak 47','Boundary',595778,'St Kitts & Nevis');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Hague 80','Monero',997474,'Zambia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 13','Belfry',864608,'Finland');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 74','Haileyville',639464,'Chad');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Fabien 60','Wickenburg',367060,'Spain');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 89','Bondad',189580,'Luxembourg');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 27','Gladys',162761,'Burkina');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue First 60','Arctic Village',131084,'Madagascar');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 46','Orme',130551,'Canada');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 28','Crary',568300,'Mali');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Oak 86','Rye Brook',628955,'Malta');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 36','Bullittsville',333634,'Eritrea');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 41','Edina',835090,'Antigua & Deps');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Green New 4','Rocklin',786708,'Libya');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 50','Sauk Centre',316783,'Bhutan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 7','Granite Quarry',315986,'Kuwait');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Red Nobel 52','Tolono',836708,'Saint Vincent & the Grenadines');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 78','Lost River',254831,'Saudi Arabia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Nobel 21','Lim Rock',722775,'Colombia');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Blue Old 2','Rosebush',669851,'Kiribati');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Nobel 34','Humeston',436847,'Bulgaria');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Cowley 86','Jersey',863858,'Estonia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Old 42','Hyrum',459387,'Haiti');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Nobel 29','Mossy Head',558210,'Dominica');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Second 90','Manahawkin',707477,'Tuvalu');
INSERT Address (Street, City, ZIP, Country) VALUES ('Old 38','Goodwater',901728,'Latvia');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Hague 32','Somerton',372030,'Rwanda');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 54','Cabery',557307,'Pakistan');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Red Fabien 45','Highland Lake',240734,'Cameroon');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 42','Kissimmee',986631,'Russian Federation');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Second 53','Mayflower',997789,'Marshall Islands');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Fabien 95','Southton',491601,'Belize');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Milton 89','Boy River',229055,'Bhutan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 15','Abo',114578,'Denmark');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Clarendon 70','Excelsior Estates',817451,'Serbia');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Milton 89','Needles',328731,'Grenada');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 32','Mooresville',677257,'Sao Tome & Principe');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 62','Kipton',531752,'Fiji');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 99','Asherville',828138,'Mali');
INSERT Address (Street, City, ZIP, Country) VALUES ('St White Fabien 67','Salley',413658,'San Marino');
INSERT Address (Street, City, ZIP, Country) VALUES ('Old 89','Saint Leo',961302,'Rwanda');
INSERT Address (Street, City, ZIP, Country) VALUES ('St White Oak 19','Nampa',547483,'United Arab Emirates');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 47','Brandsville',467303,'Portugal');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 47','Cloudcroft',810607,'France');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Second 5','Grand Haven',302760,'Tunisia');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Green Fabien 74','French',165362,'San Marino');
INSERT Address (Street, City, ZIP, Country) VALUES ('St New 60','Encino',484790,'Iran');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 41','Cleona',667874,'South Africa');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Blue New 44','Bradford Hills',505983,'Philippines');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Green Oak 72','Beechwood',855307,'Lithuania');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 15','River Bluff',948932,'Samoa');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Oak 81','Beal',788798,'Cuba');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 88','Kountze',872756,'Equatorial Guinea');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Milton 70','Fellowsville',201199,'Malawi');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 73','North Houston',124723,'Dominica');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Second 38','Chico',739284,'East Timor');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Old 37','Lazear',161285,'Macedonia');
INSERT Address (Street, City, ZIP, Country) VALUES ('North White Cowley 75','Lono',896351,'Andorra');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 49','McConnellsburg',426812,'Malawi');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Clarendon 9','Fox Run',518988,'Ukraine');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Milton 34','Thomasville',320449,'Belarus');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue First 1','Joyce',413258,'Oman');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Milton 13','Maximo',183029,'Switzerland');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Milton 25','Montezuma',761313,'Guatemala');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Hague 14','Kittery Point',901199,'Ireland');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Fabien 25','Artondale',664942,'Norway');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 35','Gascon',662167,'Jordan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 98','Plummer',203658,'Malawi');
INSERT Address (Street, City, ZIP, Country) VALUES ('Old 64','Shaker Church',651397,'Vatican City');
INSERT Address (Street, City, ZIP, Country) VALUES ('White First 56','Camp Verde',727593,'Costa Rica');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Second 9','Kanab',287039,'Indonesia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 68','Collettsville',476052,'Saint Vincent & the Grenadines');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Nobel 58','Olivia',982465,'Rwanda');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 9','Weaverville',670721,'Belgium');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Milton 56','Meridian',722160,'Singapore');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Second 47','Northwoods Beach',286543,'Nigeria');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Green Hague 60','Helmer',141711,'Belgium');
INSERT Address (Street, City, ZIP, Country) VALUES ('South New 53','Teaticket',762826,'Micronesia');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Old 80','Elk Valley',683573,'Georgia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Old 9','Edge',719739,'Saudi Arabia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Old 17','Sierra City',378220,'Spain');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 10','Vermontville',498648,'Saint Vincent & the Grenadines');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Cowley 2','Dent',488652,'Lesotho');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Fabien 9','Sageville',282060,'Saudi Arabia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Fabien 78','Powellton',337310,'Swaziland');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Milton 21','Vilas',201024,'St Lucia');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Blue Second 57','Redden',782563,'Indonesia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 83','Amherst',551777,'Samoa');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Oak 97','Edmonds',151789,'Armenia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue New 46','Marysville',276932,'Tonga');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Old 33','Bayou Goula',885552,'Peru');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Blue Milton 2','Brooklyn Park',362611,'Greece');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Second 11','Des Arc',388523,'Djibouti');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Clarendon 85','Caspar',432839,'Jordan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Old 47','McVeytown',115153,'Dominican Republic');
INSERT Address (Street, City, ZIP, Country) VALUES ('Old 83','Churchtown',456820,'Mauritania');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 10','Somers Point',781146,'Monaco');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Blue Nobel 46','Palatka',681168,'Philippines');
INSERT Address (Street, City, ZIP, Country) VALUES ('South New 88','Neuse',148150,'Israel');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Fabien 21','Fort Recovery',758971,'Japan');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Second 23','Millheim',267809,'Guatemala');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 56','Gypsum',654931,'Nigeria');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Old 57','Hyattsville',110766,'Samoa');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Red First 62','Esto',951785,'Yemen');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Nobel 52','Talmage',638216,'Barbados');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Clarendon 81','Truesdale',525021,'Djibouti');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue First 75','Abbottstown',847675,'Comoros');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Fabien 46','Puente',594579,'Trinidad & Tobago');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 96','Westwood',523677,'Serbia');
INSERT Address (Street, City, ZIP, Country) VALUES ('West White Nobel 74','Blue River',562810,'Mozambique');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 35','Casselton',704594,'Eritrea');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 34','Kettle River',601749,'Iran');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 46','Tracys Landing',973845,'Ethiopia');
INSERT Address (Street, City, ZIP, Country) VALUES ('North New 50','Atchison',318280,'Fiji');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Blue Fabien 33','Winterstown',303648,'Jordan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 80','Pilot Mound',776787,'Colombia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 95','Visalia',930998,'Finland');
INSERT Address (Street, City, ZIP, Country) VALUES ('White First 14','Bleakwood',252308,'Oman');
INSERT Address (Street, City, ZIP, Country) VALUES ('Old 29','Shelter Island Heights',203462,'Estonia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Second 92','Sierra City',877948,'Chile');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Nobel 1','Dycusburg',234587,'Myanmar');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Red Nobel 37','Bladensburg',328675,'Liechtenstein');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Hague 70','Margate City',345843,'Sudan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Hague 86','Elm Creek',928588,'Armenia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 30','Risco',978271,'Korea North');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Hague 43','West Richfield',608984,'Bahrain');
INSERT Address (Street, City, ZIP, Country) VALUES ('South White New 99','Mims',670466,'Yemen');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Milton 75','Spink',935517,'Italy');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 25','Mule Barn',167243,'Mexico');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Cowley 34','Hurstville',965923,'Congo');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 46','Ratliff',702585,'Croatia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Cowley 97','De Sart',661378,'Mongolia');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 81','Losantville',503260,'Barbados');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Red First 51','Piney Fork',395167,'Bulgaria');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green First 94','War',886643,'St Kitts & Nevis');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Old 8','Minden City',350125,'Estonia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Second 37','Horn',101122,'El Salvador');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Clarendon 90','Port Huron',506899,'Suriname');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Old 86','Cove',239219,'Tonga');
INSERT Address (Street, City, ZIP, Country) VALUES ('West First 80','Mart',341012,'Ethiopia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 99','Caro',595479,'Luxembourg');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 59','Bon',442733,'Norway');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 12','Foster City',255687,'Oman');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 67','Trout Valley',249001,'Burundi');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 29','Rio Pecos',295330,'Algeria');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 16','Maxeys',180736,'Latvia');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 75','Doniphan',148598,'St Kitts & Nevis');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Oak 19','Forbing',173608,'Antigua & Deps');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 44','Kincaid',274293,'Canada');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Second 61','Topeka Junction',809535,'Lebanon');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Old 49','Chilhowee',115873,'Netherlands');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Second 49','Chaniliut',977667,'Egypt');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Blue Fabien 36','Fayette City',429471,'Djibouti');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 10','Mariemont',206439,'Gambia');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 20','Castanea',220072,'Iran');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Fabien 92','Fruithurst',817542,'Liechtenstein');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Red Oak 37','McCutchenville',256830,'Barbados');
INSERT Address (Street, City, ZIP, Country) VALUES ('South White Nobel 79','Ancient Oaks',935133,'Ghana');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Cowley 3','Purcell',414327,'Gambia');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Nobel 66','Providence Forge',791346,'Poland');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 27','Wilseyville',990121,'Togo');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Red Old 69','Unga',930634,'Spain');
INSERT Address (Street, City, ZIP, Country) VALUES ('South First 79','Middleberg',420880,'Mali');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 99','Timmonsville',318225,'Bolivia');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Green New 48','Lugoff',125204,'Liberia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 53','Swink',111815,'Burkina');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Clarendon 88','Rogerson',400806,'India');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Oak 78','Ector',977659,'Pakistan');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 51','Colo',580238,'Ireland');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 77','Beach Glen',474566,'Vatican City');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Red Second 49','Waikii',435373,'Croatia');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Blue Old 37','Barneveld',590733,'Romania');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 27','Grand Mound',670130,'Slovakia');
INSERT Address (Street, City, ZIP, Country) VALUES ('South New 58','Brice',216958,'Mauritania');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 39','Tontitown',506673,'Turkmenistan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 47','Gisela',955231,'Romania');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 79','La Cienega',391471,'Bahamas');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 1','Redondo Beach',103900,'El Salvador');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 68','Bay Center',767454,'Slovakia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Milton 15','Silerton',529935,'Austria');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Oak 25','Gainesville Mills',485567,'Belarus');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Hague 91','Ardara',645179,'Marshall Islands');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Fabien 8','Little Rock',882979,'Netherlands');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Milton 95','Blumenthal',641612,'Dominican Republic');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 6','Needville',495028,'Latvia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Milton 94','Level Park',655601,'Uzbekistan');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Green Oak 51','Immokalee',802287,'Liechtenstein');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 87','Supai',148205,'Hungary');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Clarendon 87','Penfield',638934,'Korea North');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 47','Ravenden',636339,'Czech Republic');
INSERT Address (Street, City, ZIP, Country) VALUES ('South White Old 15','Griffithville',907703,'Morocco');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Oak 5','Youngsville',840118,'Norway');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue New 8','Marbleton',702906,'Nauru');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Blue Milton 40','Sierraville',121144,'Sao Tome & Principe');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 9','Navajo',810375,'Iceland');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Old 15','Belle Glade Camp',230707,'Finland');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Milton 6','Udell',970374,'Finland');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 98','Arial',972596,'Samoa');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Clarendon 16','Plum Grove',943962,'Portugal');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Red Old 90','Croom',559251,'Austria');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Blue Fabien 85','Palo Verde',190016,'Bulgaria');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 66','Sugartown',530803,'Czech Republic');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Hague 45','Saint Augustine Beach',536383,'Poland');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 58','Croft',151595,'Cyprus');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Blue New 69','Bement',262590,'Palau');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 17','Rolling Meadows',353377,'Nicaragua');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Clarendon 3','Constantine',815562,'Mongolia');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Red Milton 23','San Miguel',269867,'Spain');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 74','Nipomo',656254,'Albania');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 36','High Springs',861197,'Bahamas');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Old 29','Center Ossipee',602332,'Jordan');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Hague 67','Ware Shoals',904903,'Thailand');
INSERT Address (Street, City, ZIP, Country) VALUES ('Old 68','West Carson',876985,'Burkina');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Blue Nobel 59','Albertson',187787,'Yemen');
INSERT Address (Street, City, ZIP, Country) VALUES ('Old 36','Normandy',854087,'Congo');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 81','Anchor',889621,'Bosnia Herzegovina');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 61','Walford',226193,'Jamaica');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Blue Second 38','Minor Lane Heights',987639,'Andorra');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Hague 88','Ham Lake',328162,'Pakistan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 89','New Carlisle',137584,'United Arab Emirates');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Milton 55','Stony River',497800,'Dominican Republic');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red First 47','Creedmoor',545849,'Iran');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Old 21','Allenspark',772902,'Dominica');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Green New 49','Hallowell',515534,'Cape Verde');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Red Clarendon 52','Winter',871960,'Mali');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Fabien 73','Navesink',820392,'Belarus');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Clarendon 84','Kenna',389422,'Greece');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 44','Coalton',945729,'Greece');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Nobel 70','Etna Green',960015,'Poland');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 41','Hunterdon',489111,'Australia');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Fabien 46','Villas',849385,'Hungary');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Old 21','Seven Oaks',273967,'Moldova');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Nobel 60','Goodridge',989661,'Guatemala');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Oak 29','Point Pleasant Beach',348627,'Cape Verde');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Oak 6','Alvaton',935056,'Congo');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 57','Dickey',353534,'Japan');
INSERT Address (Street, City, ZIP, Country) VALUES ('North New 43','Del Valle',829272,'India');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Hague 92','Frankfort',760849,'Russian Federation');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Old 50','Lutsen',571537,'Iran');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 98','New Stanton',753179,'Tajikistan');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Second 69','Cogar',694257,'Comoros');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Second 84','Iron Belt',889634,'Namibia');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Hague 54','Trammel',983512,'Angola');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 61','Seaside',970993,'Jamaica');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 18','Marine City',374211,'Ethiopia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 30','Mesita',220388,'Greece');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Oak 5','Alanreed',292110,'Paraguay');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 89','Adams City',852796,'Tuvalu');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Hague 52','Paw Creek',762973,'Chile');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 98','Tierra Amarilla',953975,'Colombia');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Oak 90','Martins Creek',533080,'Tanzania');
INSERT Address (Street, City, ZIP, Country) VALUES ('North New 83','Parnell',941233,'Zimbabwe');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 99','Postville',780922,'Dominica');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Hague 73','Batchtown',114550,'Somalia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 9','Arenzville',230062,'Malta');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Cowley 30','Grosse Pointe',906459,'Chad');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Hague 34','Van Zandt',844208,'Bulgaria');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Nobel 83','Toxey',213208,'Papua New Guinea');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 84','Palmetto Estates',457654,'Turkey');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Fabien 8','Clarkrange',466938,'Saint Vincent & the Grenadines');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Green Fabien 10','Chenoweth',589664,'Serbia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Blue Old 63','Readlyn',881442,'Bulgaria');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green First 1','Spavinaw',479247,'Philippines');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 14','Escobas',578840,'Sweden');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Green Clarendon 48','San Lorenzo',450073,'Papua New Guinea');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Second 37','Springville',509558,'Slovenia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 82','Stone Harbor',318796,'Switzerland');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Old 17','Fulshear',731113,'Nigeria');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Milton 39','San Rafael',147620,'Brunei');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Fabien 19','Carlile',443596,'Panama');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 92','Sublette',822758,'Philippines');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Nobel 24','Utleyville',286232,'Marshall Islands');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 28','Big Springs',115675,'Jordan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 70','Miesville',281101,'Israel');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Nobel 41','Wrightstown',853160,'Bahrain');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 66','Fort Thomas',300085,'Belize');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 92','Beckett',724934,'Jordan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Nobel 58','Haile',631598,'Grenada');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 11','Vanport',340743,'Liberia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Red Oak 18','Richfield Springs',848211,'Georgia');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 40','Fountain Hills',914725,'Zimbabwe');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 71','Brookeville',842826,'Malta');
INSERT Address (Street, City, ZIP, Country) VALUES ('Old 2','Ypsilanti',576177,'Antigua & Deps');
INSERT Address (Street, City, ZIP, Country) VALUES ('First 53','Goshute',888223,'Greece');
INSERT Address (Street, City, ZIP, Country) VALUES ('White First 46','West Milton',317572,'Belgium');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 71','South Santa Rosa',662432,'Suriname');
INSERT Address (Street, City, ZIP, Country) VALUES ('Old 42','Castle Hayne',302755,'Bolivia');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Red Cowley 31','Bayou Sorrel',256571,'Guinea-Bissau');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 28','Moonachie',253757,'United Kingdom');
INSERT Address (Street, City, ZIP, Country) VALUES ('White First 95','Grey Forest',748898,'Honduras');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 21','Marble Falls',967134,'Bahrain');
INSERT Address (Street, City, ZIP, Country) VALUES ('Fabien 55','Temperanceville',401185,'Chile');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green New 42','Rillito',625908,'Mozambique');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Fabien 74','Middleburg Heights',762039,'Albania');
INSERT Address (Street, City, ZIP, Country) VALUES ('Oak 93','Pine Beach',908804,'Rwanda');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 93','Braceville',427673,'Oman');
INSERT Address (Street, City, ZIP, Country) VALUES ('Second 16','Hominy',752858,'Honduras');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green New 80','Mountain Village',835176,'Lebanon');
INSERT Address (Street, City, ZIP, Country) VALUES ('Clarendon 49','Meadow Vista',481252,'Niger');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Cowley 8','Clarkdale',226851,'El Salvador');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Cowley 93','Umpire',534649,'Namibia');
INSERT Address (Street, City, ZIP, Country) VALUES ('White Clarendon 75','Keyes Summit',485611,'Palau');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Blue Fabien 46','Val Verda',185211,'Congo');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Old 67','McKinney',686200,'Lithuania');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Oak 17','Lakehurst',314396,'Vietnam');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Nobel 18','Lamboglia',477219,'Sweden');
INSERT Address (Street, City, ZIP, Country) VALUES ('South Old 26','Sealy',926836,'Thailand');
INSERT Address (Street, City, ZIP, Country) VALUES ('St Old 31','Vineyard',484395,'Uzbekistan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 10','Port Armstrong',436561,'India');
INSERT Address (Street, City, ZIP, Country) VALUES ('West Old 68','Hermiston',142139,'Japan');
INSERT Address (Street, City, ZIP, Country) VALUES ('Green Cowley 54','Luis Llorens Torres',874468,'Papua New Guinea');
INSERT Address (Street, City, ZIP, Country) VALUES ('Hague 20','North Corbin',146334,'Lithuania');
INSERT Address (Street, City, ZIP, Country) VALUES ('North Hague 54','Zillah',231514,'Bulgaria');
INSERT Address (Street, City, ZIP, Country) VALUES ('St First 68','Chesterville',988894,'Nepal');
INSERT Address (Street, City, ZIP, Country) VALUES ('Cowley 24','Oakview',881052,'Libya');
INSERT Address (Street, City, ZIP, Country) VALUES ('New 15','Nicodemus',472065,'Dominican Republic');
INSERT Address (Street, City, ZIP, Country) VALUES ('West White Fabien 22','West Valley City',861790,'Kosovo');
INSERT Address (Street, City, ZIP, Country) VALUES ('Milton 15','Hollymead',402307,'Lesotho');






