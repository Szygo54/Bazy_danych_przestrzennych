CREATE EXTENSION postgis;

CREATE TABLE buildings (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    geometry GEOMETRY(POLYGON)
);


CREATE TABLE roads (
  id SERIAL PRIMARY KEY,
  name VARCHAR(10),
  geometry GEOMETRY(LINESTRING)
);



CREATE TABLE poi (
    id SERIAL PRIMARY KEY,
    name VARCHAR(10),
    geometry GEOMETRY(POINT)
);

INSERT INTO buildings (name, geometry) VALUES
('BuildingA', ST_GeomFromText('POLYGON((8 1.5,10.5 1.5,10.5 4,8 4,8 1.5))')),
('BuildingB', ST_GeomFromText('POLYGON((4 5,6 5,6 7,4 7,4 5))')),
('BuildingC', ST_GeomFromText('POLYGON((3 6,5 6,5 8,3 8,3 6))')),
('BuildingD', ST_GeomFromText('POLYGON((9 8,10 8,10 9,9 9,9 8))')),
('BuildingF', ST_GeomFromText('POLYGON((1 1,2 1,2 2,1 2,1 1))'));


INSERT INTO roads (name,geometry) VALUES
('RoadX', ST_GeomFromText('LINESTRING(0 4.5,12 4.5)')),
('RoadY', ST_GeomFromText('LINESTRING(7.5 0,7.5 10.5)'));

INSERT INTO poi (name, geometry) VALUES
('H',ST_GeomFromText('POINT(5.5 1.5)')),
('G',ST_GeomFromText('POINT(1 3.5)')),
('I',ST_GeomFromText('POINT(9.5 6)')),
('J',ST_GeomFromText('POINT(6.5 6)')),
('K',ST_GeomFromText('POINT(6 9.5)'));


--a. Wyznacz długość wszystkich dróg w mieście

SELECT sum(ST_Length(geometry)) AS "Długość wszystkich dróg" FROM roads

--b. Wypisz geometrię (WKT), pole powierzchni oraz obwód poligonu reprezentującego budynek o nazwie BuildingA.

SELECT ST_Area(geometry) AS "Pole powierzchni", ST_Perimeter(geometry) AS "Obwod" FROM buildings
WHERE name = 'BuildingA'

--c. Wypisz nazwy i pola powierzchni wszystkich poligonów w warstwie budynki. Wyniki posortuj alfabetycznie.
SELECT name, ST_Area(geometry) FROM buildings
ORDER BY name

--d Wypisz nazwy i obwody 2 budynków o największej powierzchni.

SELECT name, ST_Perimeter(geometry) AS "Obwod", ST_Area(geometry) AS "Pole" FROM buildings
ORDER BY ST_Area(geometry) DESC
LIMIT 2;

--e. Wyznacz najkrótszą odległość między budynkiem BuildingC a punktem K

SELECT ST_Distance(b.geometry, p.geometry) AS najkrotsza_odleglosc
FROM buildings b, poi p
WHERE b.name = 'BuildingC' AND p.name = 'K';

--f. Wypisz pole powierzchni tej części budynku BuildingC, która znajduje się w odległości większej niż 0.5 od budynku BuildingB.

SELECT ST_Area(
    ST_Difference(
        (SELECT geometry FROM buildings WHERE name = 'BuildingC'),
        (SELECT ST_Buffer(geometry, 0.5) FROM buildings WHERE name = 'BuildingB')
    )
) AS "Pole_powierzchni_wynik";

--g. Wybierz te budynki, których centroid (ST_Centroid) znajduje się powyżej drogi  o nazwie RoadX.

SELECT name FROM buildings
WHERE ST_Y(ST_Centroid(geometry)) > 4.5;

--h. Oblicz pole powierzchni tych części budynku BuildingC i poligonu o współrzędnych  (4 7, 6 7, 6 8, 4 8, 4 7), które nie są wspólne dla tych dwóch obiektów.

SELECT ST_Area(
    ST_SymDifference(
        (SELECT geometry FROM buildings WHERE name = 'BuildingC'),
        ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))')
    )
) AS "Pole powierzchni"