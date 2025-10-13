SET search_path TO ksiegowosc;

CREATE TABLE pracownicy (
    id_pracownika SERIAL PRIMARY KEY,
    imie VARCHAR(50) NOT NULL,
    nazwisko VARCHAR(50) NOT NULL,
    adres VARCHAR(100),
    telefon VARCHAR(15)
);

COMMENT ON TABLE pracownicy IS 'Podstawowe dane o pracownikach firmy';

CREATE TABLE godziny (
    id_godziny SERIAL PRIMARY KEY,
    data DATE NOT NULL,
    liczba_godzin INT NOT NULL,
    id_pracownika INT REFERENCES pracownicy(id_pracownika)
);

COMMENT ON TABLE godziny IS 'Liczba godzin przepracowanych przez pracownika';

CREATE TABLE pensja (
    id_pensji SERIAL PRIMARY KEY,
    stanowisko VARCHAR(100) NOT NULL,
    kwota NUMERIC(10, 2) NOT NULL
);

COMMENT ON TABLE pensja IS 'Słownik stanowisk i przypisanych do nich stawek wynagrodzenia';

CREATE TABLE premia (
    id_premii SERIAL PRIMARY KEY,
    rodzaj VARCHAR(100) NOT NULL,
    kwota NUMERIC(10, 2)
);

COMMENT ON TABLE premia IS 'Informacje o możliwych premiach i ich rodzajach';

CREATE TABLE wynagrodzenie (
    id_wynagrodzenia SERIAL PRIMARY KEY,
    data DATE NOT NULL,
    id_pracownika INT REFERENCES pracownicy(id_pracownika),
    id_godziny INT REFERENCES godziny(id_godziny),
    id_pensji INT REFERENCES pensja(id_pensji),
    id_premii INT REFERENCES premia(id_premii)
);

COMMENT ON TABLE wynagrodzenie IS 'Tabela łącząca informacje o wypłatach, pracownikach, godzinach, pensjach i premiach';

INSERT INTO pracownicy (id_pracownika, imie, nazwisko, adres, telefon) VALUES
(1, 'Jan', 'Kowalski', 'ul. Długa 5, Warszawa', '111222333'),
(2, 'Anna', 'Nowak', 'ul. Krótka 12, Kraków', '222333444'),
(3, 'Piotr', 'Zieliński', 'ul. Szeroka 2, Gdańsk', '333444555'),
(4, 'Katarzyna', 'Wójcik', 'ul. Wąska 8, Poznań', '444555666'),
(5, 'Joanna', 'Kamińska', 'ul. Prosta 1, Wrocław', '555666777'),  
(6, 'Andrzej', 'Lewandowski', 'ul. Krzywa 15, Łódź', '666777888'),
(7, 'Monika', 'Jankowska', 'al. Jerozolimskie 100, Warszawa', '777888999'),
(8, 'Tomasz', 'Mazur', 'ul. Marszałkowska 3, Warszawa', '888999000'),
(9, 'Barbara', 'Wiśniewska', 'ul. Floriańska 22, Kraków', '999000111'),
(10, 'Jacek', 'Szymański', 'ul. Zielona 1, Gdynia', '123123123'); 

INSERT INTO pensja (id_pensji, stanowisko, kwota) VALUES
(1, 'Stażysta', 950.00), 
(2, 'Specjalista', 2800.00),
(3, 'Starszy Specjalista', 4500.00), 
(4, 'Analityk', 4800.00), 
(5, 'Kierownik', 7500.00), 
(6, 'Pracownik biurowy', 2100.00); 

INSERT INTO premia (id_premii, rodzaj, kwota) VALUES
(1, 'Uznaniowa', 500.00),
(2, 'Projektowa', 1200.00),
(3, 'Regulaminowa', 300.00);

INSERT INTO godziny (id_godziny, data, liczba_godzin, id_pracownika) VALUES
(1, '2025-09-30', 168, 1),
(2, '2025-09-30', 160, 2),
(3, '2025-09-30', 180, 3), 
(4, '2025-09-30', 155, 4),
(5, '2025-09-30', 172, 5), 
(6, '2025-09-30', 160, 6),
(7, '2025-09-30', 160, 7),
(8, '2025-09-30', 160, 8),
(9, '2025-09-30', 164, 9), 
(10, '2025-09-30', 160, 10);

INSERT INTO wynagrodzenie (id_wynagrodzenia, data, id_pracownika, id_godziny, id_pensji, id_premii) VALUES
(1, '2025-10-10', 1, 1, 3, 1),
(2, '2025-10-10', 2, 2, 2, 3),
(3, '2025-10-10', 3, 3, 4, NULL),
(4, '2025-10-10', 4, 4, 1, NULL),
(5, '2025-10-10', 5, 5, 5, 2),
(6, '2025-10-10', 6, 6, 5, NULL),
(7, '2025-10-10', 7, 7, 6, NULL),
(8, '2025-10-10', 8, 8, 2, NULL),
(9, '2025-10-10', 9, 9, 3, NULL),
(10, '2025-10-10', 10, 10, 6, 1);