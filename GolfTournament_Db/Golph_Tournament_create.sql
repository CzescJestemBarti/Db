-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2019-05-31 15:01:59.467

-- tables
-- Table: Dolki
CREATE TABLE Dolki (
    NumerDolka integer  NOT NULL,
    CONSTRAINT Dolki_pk PRIMARY KEY (NumerDolka)
) ;

-- Table: Golfista
CREATE TABLE Golfista (
    IdGolfisty integer  NOT NULL,
    Imie varchar2(30)  NOT NULL,
    Nazwisko varchar2(30)  NOT NULL,
    RokUrodzenia date  NOT NULL,
    IdPomocnika integer  NOT NULL,
    CONSTRAINT Golfista_pk PRIMARY KEY (IdGolfisty)
) ;

-- Table: Kij
CREATE TABLE Kij (
    IdKija integer  NOT NULL,
    NazwaKija varchar2(30)  NOT NULL,
    CONSTRAINT Kij_pk PRIMARY KEY (IdKija)
) ;

-- Table: Nagroda
CREATE TABLE Nagroda (
    Miejsce integer  NOT NULL,
    NagrodaMaterialna varchar2(30)  NOT NULL,
    PunktyDoRankingu integer  NOT NULL,
    IdGolfisty integer  NOT NULL,
    CONSTRAINT Nagroda_pk PRIMARY KEY (Miejsce)
) ;

-- Table: Pomocnik
CREATE TABLE Pomocnik (
    Imie varchar2(30)  NOT NULL,
    Nazwisko varchar2(30)  NOT NULL,
    IdPomocnika integer  NOT NULL,
    CONSTRAINT Pomocnik_pk PRIMARY KEY (IdPomocnika)
) ;

-- Table: Sponsor
CREATE TABLE Sponsor (
    Nazwa varchar2(30)  NOT NULL,
    IdSponsora integer  NOT NULL,
    CONSTRAINT Sponsor_pk PRIMARY KEY (IdSponsora)
) ;

-- Table: Sponsoring
CREATE TABLE Sponsoring (
    IdGolfisty integer  NOT NULL,
    IdSponsora integer  NOT NULL,
    kwota integer  NOT NULL,
    CONSTRAINT Sponsoring_pk PRIMARY KEY (IdGolfisty,IdSponsora)
) ;

-- Table: Uderzenie
CREATE TABLE Uderzenie (
    IdUderzenia integer  NOT NULL,
    IdGolfisty integer  NOT NULL,
    IdKija integer  NOT NULL,
    Wbicie varchar2(30)  NOT NULL,
    NumerDolka integer  NOT NULL,
    CONSTRAINT Uderzenie_pk PRIMARY KEY (IdUderzenia)
) ;

-- foreign keys
-- Reference: Golfista_Pomocnik (table: Golfista)
ALTER TABLE Golfista ADD CONSTRAINT Golfista_Pomocnik
    FOREIGN KEY (IdPomocnika)
    REFERENCES Pomocnik (IdPomocnika);

-- Reference: Nagroda_Golfista (table: Nagroda)
ALTER TABLE Nagroda ADD CONSTRAINT Nagroda_Golfista
    FOREIGN KEY (IdGolfisty)
    REFERENCES Golfista (IdGolfisty);

-- Reference: Sponsoring_Golfista (table: Sponsoring)
ALTER TABLE Sponsoring ADD CONSTRAINT Sponsoring_Golfista
    FOREIGN KEY (IdGolfisty)
    REFERENCES Golfista (IdGolfisty);

-- Reference: Sponsoring_Sponsor (table: Sponsoring)
ALTER TABLE Sponsoring ADD CONSTRAINT Sponsoring_Sponsor
    FOREIGN KEY (IdSponsora)
    REFERENCES Sponsor (IdSponsora);

-- Reference: Uderzenie_Dolki (table: Uderzenie)
ALTER TABLE Uderzenie ADD CONSTRAINT Uderzenie_Dolki
    FOREIGN KEY (NumerDolka)
    REFERENCES Dolki (NumerDolka);

-- Reference: Wbicie_Golfista (table: Uderzenie)
ALTER TABLE Uderzenie ADD CONSTRAINT Wbicie_Golfista
    FOREIGN KEY (IdGolfisty)
    REFERENCES Golfista (IdGolfisty);

-- Reference: Wbicie_Kij (table: Uderzenie)
ALTER TABLE Uderzenie ADD CONSTRAINT Wbicie_Kij
    FOREIGN KEY (IdKija)
    REFERENCES Kij (IdKija);

-- End of file.

