CREATE DATABASE wodociagi


CREATE SCHEMA uzytkownicy;

CREATE TABLE uzytkownicy.adresy (
    id_adresu serial PRIMARY KEY,
    ulica varchar(70),
    numer varchar(10),
    lokal varchar(10),
    miasto varchar(50),
    kod_pocztowy varchar(6)
);

CREATE TABLE uzytkownicy.klienci (
    id_klienta serial PRIMARY KEY,
    nazwa_klienta varchar(100),
    telefon varchar(15),
    adres int REFERENCES uzytkownicy.adresy(id_adresu),
    email varchar(100),
    e_faktura boolean
);


CREATE TABLE uzytkownicy.punkty (
    id_punktu serial PRIMARY KEY,
    wlasciciel int REFERENCES uzytkownicy.klienci(id_klienta),
    adres int UNIQUE REFERENCES uzytkownicy.adresy(id_adresu) 
);

CREATE SCHEMA rozliczenia;

CREATE TABLE rozliczenia.wodomierze (
    id_wodomierza int PRIMARY KEY,
    data_montarzu date,
    data_konca_legalizacji date GENERATED ALWAYS AS (data_montarzu + INTERVAL '5 years') STORED,
    id_punktu int REFERENCES uzytkownicy.punkty(id_punktu)
);

CREATE TABLE rozliczenia.pomiary (
    id_pomiaru serial PRIMARY KEY,
    data_pomiaru date,
    id_punktu int REFERENCES uzytkownicy.punkty(id_punktu),
    wartosc_pomiaru float,
    wartosc_poprzedniego_pomiaru float,
    roznica float GENERATED ALWAYS AS (wartosc_pomiaru - wartosc_poprzedniego_pomiaru) STORED
);

CREATE TABLE rozliczenia.faktury (
    id_faktury serial PRIMARY KEY,
    id_pomiaru int UNIQUE REFERENCES rozliczenia.pomiary(id_pomiaru), 
    kwota float,
    klient int REFERENCES uzytkownicy.klienci(id_klienta),
    data_sprzedazy date,
    data_oplacenia date,
    data_wystawienia date,
    oplacona boolean
);

CREATE ROLE admin;
CREATE ROLE inspektorzy;

GRANT ALL ON SCHEMA rozliczenia TO admin;

GRANT USAGE ON SCHEMA rozliczenia TO inspektorzy;

GRANT SELECT ON ALL TABLES IN SCHEMA rozliczenia TO inspektorzy;

ALTER DEFAULT PRIVILEGES IN SCHEMA rozliczenia
GRANT SELECT ON TABLES TO inspektorzy;