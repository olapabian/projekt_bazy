-- Tworzenie schematu
CREATE SCHEMA billing;
-- OUTPUT:
-- CREATE SCHEMA

-- Tabela: adresy
CREATE TABLE billing.adresy (
    id_adresu SERIAL PRIMARY KEY,
    ulica VARCHAR(70),
    numer VARCHAR(10),
    lokal VARCHAR(10),
    miasto VARCHAR(50),
    kod_pocztowy VARCHAR(6)
);
-- OUTPUT:
-- CREATE TABLE

-- Tabela: klienci
CREATE TABLE billing.klienci (
    id_klienta SERIAL PRIMARY KEY,
    nazwa_klienta VARCHAR(100),
    telefon VARCHAR(15),
    adres INT REFERENCES billing.adresy(id_adresu),
    email VARCHAR(100),
    e_faktura BOOLEAN
);
-- OUTPUT:
-- CREATE TABLE

-- Tabela: punkty
CREATE TABLE billing.punkty (
    id_punktu SERIAL PRIMARY KEY,
    wlasciciel INT REFERENCES billing.klienci(id_klienta),
    adres INT UNIQUE REFERENCES billing.adresy(id_adresu)
);
-- OUTPUT:
-- CREATE TABLE

-- Tabela: wodomierze
CREATE TABLE billing.wodomierze (
    id_wodomierza INT PRIMARY KEY,
    data_montarzu DATE,
    data_konca_legalizacji DATE GENERATED ALWAYS AS (data_montarzu + INTERVAL '5 years') STORED,
    id_punktu INT REFERENCES billing.punkty(id_punktu)
);
-- OUTPUT:
-- CREATE TABLE

-- Tabela: pomiary
CREATE TABLE billing.pomiary (
    id_pomiaru SERIAL PRIMARY KEY,
    data_pomiaru DATE,
    id_punktu INT REFERENCES billing.punkty(id_punktu),
    wartosc_pomiaru FLOAT,
    wartosc_poprzedniego_pomiaru FLOAT,
    roznica FLOAT GENERATED ALWAYS AS (wartosc_pomiaru - wartosc_poprzedniego_pomiaru) STORED
);
-- OUTPUT:
-- CREATE TABLE

-- Tabela: faktury
CREATE TABLE billing.faktury (
    id_faktury SERIAL PRIMARY KEY,
    id_pomiaru BIGINT UNIQUE REFERENCES billing.pomiary(id_pomiaru),
    kwota FLOAT,
    klient INT REFERENCES billing.klienci(id_klienta),
    data_sprzedazy DATE GENERATED ALWAYS AS (
        (SELECT p.data_pomiaru FROM billing.pomiary p WHERE p.id_pomiaru = faktury.id_pomiaru)
    ) STORED,
    data_oplacenia DATE,
    data_wystawienia DATE,
    oplacona BOOLEAN
);
-- OUTPUT:
-- CREATE TABLE

-- Dodanie danych testowych

-- Adres
INSERT INTO billing.adresy (ulica, numer, lokal, miasto, kod_pocztowy)
VALUES ('Polna', '12', '5', 'Poznań', '60-123');
-- OUTPUT:
-- INSERT 0 1

-- Klient
INSERT INTO billing.klienci (nazwa_klienta, telefon, adres, email, e_faktura)
VALUES ('Jan Kowalski', '601234567', 1, 'jan@example.com', TRUE);
-- OUTPUT:
-- INSERT 0 1

-- Punkt poboru
INSERT INTO billing.punkty (wlasciciel, adres)
VALUES (1, 1);
-- OUTPUT:
-- INSERT 0 1

-- Wodomierz
INSERT INTO billing.wodomierze (id_wodomierza, data_montarzu, id_punktu)
VALUES (1001, '2020-06-01', 1);
-- OUTPUT:
-- INSERT 0 1

-- Pomiar
INSERT INTO billing.pomiary (data_pomiaru, id_punktu, wartosc_pomiaru, wartosc_poprzedniego_pomiaru)
VALUES ('2025-06-01', 1, 120.5, 100.0);
-- OUTPUT:
-- INSERT 0 1

-- Faktura (CENA_M3 = 9.85 zł)
INSERT INTO billing.faktury (id_pomiaru, kwota, klient, data_oplacenia, data_wystawienia, oplacona)
VALUES (1, 20.5 * 9.85, 1, NULL, '2025-06-01', FALSE);
-- OUTPUT:
-- INSERT 0 1

-- Sprawdzenie poprawności danych
SELECT f.id_faktury, k.nazwa_klienta, p.roznica, f.kwota, f.oplacona
FROM billing.faktury f
JOIN billing.klienci k ON f.klient = k.id_klienta
JOIN billing.pomiary p ON f.id_pomiaru = p.id_pomiaru;
-- OUTPUT:
-- id_faktury | nazwa_klienta | roznica | kwota   | oplacona
--     1      | Jan Kowalski  | 20.5    | 201.925 | f
