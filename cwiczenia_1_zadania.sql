SET search_path TO ksiegowosc;

Select id_pracownika, nazwisko FROM pracownicy

SELECT p.id_pracownika from pracownicy p
JOIN wynagrodzenie w ON p.id_pracownika = w.id_pracownika
JOIN pensja pe ON w.id_pensji = pe.id_pensji
WHERE pe.kwota > 1000;

SELECT p.id_pracownika FROM pracownicy p
JOIN wynagrodzenie w ON p.id_pracownika = w.id_pracownika
JOIN pensja pe ON w.id_pensji = pe.id_pensji
WHERE pe.kwota > 2000 AND w.id_premii IS NULL;

SELECT * FROM pracownicy 
WHERE imie like 'J%'

SELECT * FROM pracownicy
WHERE nazwisko like '%n%' AND imie LIKE '%a'

SELECT p.imie, p.nazwisko, g.liczba_godzin FROM pracownicy p
JOIN godziny g ON p.id_pracownika = g.id_pracownika
WHERE g.liczba_godzin > 160

SELECT p.imie, p.nazwisko, pe.kwota FROM pracownicy p
JOIN wynagrodzenie w ON p.id_pracownika = w.id_pracownika
JOIN pensja pe ON pe.id_pensji = w.id_pensji
WHERE pe.kwota BETWEEN 1500 AND 3000

SELECT p.imie, p.nazwisko FROM pracownicy p
JOIN wynagrodzenie w ON p.id_pracownika = w.id_pracownika
JOIN godziny g ON w.id_godziny = g.id_godziny
WHERE g.liczba_godzin > 160 AND w.id_premii IS NULL;

SELECT p.imie, p.nazwisko,pe.kwota FROM pracownicy p
JOIN wynagrodzenie w ON p.id_pracownika = w.id_pracownika
JOIN pensja pe ON w.id_pensji = pe.id_pensji
ORDER BY pe.kwota;

SELECT p.imie, p.nazwisko, pe.kwota, pr.kwota FROM pracownicy p
JOIN wynagrodzenie w ON p.id_pracownika = w.id_pracownika
JOIN pensja pe ON w.id_pensji = pe.id_pensji
LEFT JOIN premia pr ON w.id_premii = pr.id_premii
ORDER BY pe.kwota DESC, pr.kwota DESC;

SELECT pe.stanowisko, COUNT(p.id_pracownika) AS liczba_pracownikow FROM pracownicy p
JOIN wynagrodzenie w ON p.id_pracownika = w.id_pracownika
JOIN pensja pe ON w.id_pensji = pe.id_pensji
GROUP BY pe.stanowisko;

SELECT AVG(pe.kwota) AS srednia_placa, MIN(pe.kwota) AS minimalna_placa, MAX(pe.kwota) AS maksymalna_placa
FROM pensja pe
JOIN wynagrodzenie w ON pe.id_pensji = w.id_pensji
WHERE pe.stanowisko = 'Kierownik'

SELECT SUM(pe.kwota) AS suma_wszystkich_wynagrodzen
FROM wynagrodzenie w
JOIN pensja pe ON w.id_pensji = pe.id_pensji;


SELECT pe.stanowisko, SUM(pe.kwota) AS suma_wynagrodzen_na_stanowisku
FROM wynagrodzenie w
JOIN pensja pe ON w.id_pensji = pe.id_pensji
GROUP BY pe.stanowisko;


SELECT pe.stanowisko, COUNT(w.id_premii) AS liczba_przyznanych_premii
FROM wynagrodzenie w
JOIN pensja pe ON w.id_pensji = pe.id_pensji
GROUP BY pe.stanowisko;

DELETE FROM pracownicy
WHERE id_pracownika IN (
        SELECT w.id_pracownika FROM wynagrodzenie w
        JOIN pensja pe ON w.id_pensji = pe.id_pensji
        WHERE pe.kwota < 1200
    );