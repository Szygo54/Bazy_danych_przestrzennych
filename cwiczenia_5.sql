create extension postgis;

create table obiekty(
    nazwa VARCHAR(50) PRIMARY KEY,
    geometria GEOMETRY,
    SRID INTEGER -- System Referencji Przestrzennej SRID = 0
);


--Obiekt 1
INSERT INTO obiekty (nazwa, geometria, SRID)
VALUES(
       'obiekt1',
       ST_GeomFromText('COMPOUNDCURVE((0 1, 1 1), CIRCULARSTRING(1 1, 2 0, 3 1),CIRCULARSTRING(3 1, 4 2, 5 1),(5 1, 6 1))',0),
       0
      );

--Obiekt 2

INSERT INTO obiekty (nazwa, geometria, SRID)
VALUES (
    'obiekt2',
    ST_GeomFromText('CURVEPOLYGON(
            COMPOUNDCURVE((10 6, 14 6), CIRCULARSTRING(14 6, 16 4, 14 2), CIRCULARSTRING(14 2, 12 0, 10 2), (10 2, 10 6)),
            COMPOUNDCURVE(CIRCULARSTRING(13 2, 12 1, 11 2),CIRCULARSTRING(11 2, 12 3, 13 2))
        )',
        0
    ),
    0
);

--Obiekt 3

INSERT INTO obiekty(nazwa, geometria, SRID)
VALUES(
       'obiekt3',
       ST_GeomFromText('POLYGON((7 15, 10 17, 12 13, 7 15))', 0),
       0
);


--Obiekt 4
INSERT INTO obiekty (nazwa, geometria, SRID)
VALUES (
    'obiekt4',
    ST_GeomFromText(
        'LINESTRING(20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5)',0),
    0
);


--Obiekt 5
INSERT INTO obiekty (nazwa, geometria, SRID)
VALUES (
    'obiekt5',
    ST_GeomFromText('MULTIPOINT Z (30 30 59, 38 32 234)',0),
    0
);


--Obiekt 6
INSERT INTO obiekty (nazwa, geometria, SRID)
VALUES (
    'obiekt6',
    ST_GeomFromText('GEOMETRYCOLLECTION(LINESTRING(1 1, 3 2), POINT(4 2))',0),
    0
);

--2. Wyznacz pole powierzchni bufora o wielkości 5 jednostek, który został utworzony wokół najkrótszej linii łączącej obiekt 3 i 4.
SELECT
    ST_Area(ST_Buffer(ST_ShortestLine(
                (SELECT geometria FROM obiekty WHERE nazwa = 'obiekt3'),
                (SELECT geometria FROM obiekty WHERE nazwa = 'obiekt4')
                 ), 5.0)) AS pole_powierzchni;

--3. Zamień obiekt4 na poligon. Jaki warunek musi być spełniony, aby można było wykonać to zadanie? Zapewnij te warunki.
--Aby można było zmienić linestringa na na poligon, linia ta musi być zamknięta

UPDATE obiekty
SET geometria = ST_MakePolygon(
    ST_AddPoint(
        (SELECT geometria FROM obiekty WHERE nazwa = 'obiekt4'),
        ST_StartPoint( (SELECT geometria FROM obiekty WHERE nazwa = 'obiekt4') ) -- Dodanie punktu początkowego na koniec
    )
)
WHERE nazwa = 'obiekt4';


--4. W tabeli obiekty, jako obiekt7 zapisz obiekt złożony z obiektu 3 i obiektu 4.
INSERT INTO obiekty (nazwa, geometria, SRID)
VALUES (
    'obiekt7',
    ST_Union(
        (SELECT geometria FROM obiekty WHERE nazwa = 'obiekt3'),
        (SELECT geometria FROM obiekty WHERE nazwa = 'obiekt4')
    ),
    0
);


--5. Wyznacz pole powierzchni wszystkich buforów o wielkości 5 jednostek, które zostały utworzone wokół obiektów nie zawierających łuków.
SELECT
    SUM(ST_Area(
        ST_Buffer(geometria, 5.0)
    )) AS pole_buforow_bez_lukow
FROM obiekty
WHERE NOT ST_HasArc(geometria);




Drop table obiekty
Select * from obiekty