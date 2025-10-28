-- 1. Znajdź budynki, które zostały wybudowane lub wyremontowane na przestrzeni roku (zmiana pomiędzy 2018 a 2019).
SELECT b19.gid, b19.geom FROM t2019_kar_buildings b19
LEFT JOIN t2018_kar_buildings b18
ON st_equals(b19.geom,b18.geom)
WHERE b18.geom IS NULL;


-- 2. Znajdź ile nowych POI pojawiło się w promieniu 500 m od wyremontowanych lub wybudowanych budynków
CREATE TABLE nowe_budynki AS
    SELECT b19.geom FROM t2019_kar_buildings b19
    LEFT JOIN t2018_kar_buildings b18
    ON st_equals(b19.geom,b18.geom)
    WHERE b18.geom IS NULL;

CREATE TABLE nowe_punkty AS
    SELECT p19.gid, p19.type, p19.geom  FROM t2019_kar_poi_table p19
    LEFT JOIN t2018_kar_poi_table p18
    ON St_equals(p19.geom,p18.geom)
    WHERE p18.geom IS NULL;

SELECT p.type, COUNT(DISTINCT p.gid) AS "liczba punktów"  FROM nowe_punkty p
WHERE EXISTS (
      SELECT 1 FROM nowe_budynki b
      WHERE St_DWithin(p.geom::geography,b.geom::geography,500)
      )
GROUP BY p.type
ORDER BY "liczba punktów" DESC


-- 3. Utwórz nową tabelę o nazwie ‘streets_reprojected’, która zawierać będzie dane z tabeli T2019_KAR_STREETS przetransformowane do układu współrzędnych DHDN.Berlin/Cassini.
CREATE TABLE streets_reprojected AS
SELECT gid, link_id, st_name, ref_in_id,
       func_class,speed_cat,fr_speed_l,to_speed_l,dir_travel, ST_Transform(geom, 3068) AS geom
FROM t2019_kar_streets;

SELECT * FROM streets_reprojected


-- 4. Stwórz tabelę o nazwie ‘input_points’ i dodaj do niej dwa rekordy o geometrii punktowej.
CREATE TABLE input_points (
    id SERIAL PRIMARY KEY,
    geom geometry(Point, 4326)
);

INSERT INTO input_points (geom) VALUES
  (ST_SetSRID(ST_MakePoint(8.36093, 49.03174), 4326)),
  (ST_SetSRID(ST_MakePoint(8.39876, 49.00644), 4326))

SELECT * FROM input_points

--5. Zaktualizuj dane w tabeli ‘input_points’ tak, aby punkty te były w układzie współrzędnych DHDN.Berlin/Cassini.
ALTER TABLE input_points
  ALTER COLUMN geom TYPE geometry(Point, 3068)
  USING ST_Transform(geom, 3068);

SELECT id, ST_SRID(geom) AS srid, ST_AsText(geom) AS punkt
FROM input_points;


--6. Znajdź wszystkie skrzyżowania, które znajdują się w odległości 200 m od linii zbudowanej z punktów w tabeli ‘input_points’.
ALTER TABLE t2019_kar_street_node
  ALTER COLUMN geom TYPE geometry(Point, 3068)
  USING ST_Transform(geom, 3068);

WITH reference_line AS (
  SELECT ST_MakeLine(geom ORDER BY id) AS line_geom
  FROM input_points
)
SELECT DISTINCT skrzyzowania.*
FROM
  t2019_kar_street_node AS skrzyzowania,
  reference_line AS line
WHERE ST_DWithin(skrzyzowania.geom, line.line_geom, 200);


--7. Policz jak wiele sklepów sportowych (‘Sporting Goods Store’ - tabela POIs) znajduje się w odległości 300 m od parków (LAND_USE_A).
SELECT Count(*) FROM t2019_kar_poi_table sklepy
WHERE sklepy.type LIKE 'Sporting%'
    AND EXISTS(
        SELECT 1 FROM T2019_KAR_LAND_USE_A parki
        WHERE parki.type LIKE'Park%'
        AND ST_DWithin(sklepy.geom, parki.geom, 300)
);


--8. Znajdź punkty przecięcia torów kolejowych (RAILWAYS) z ciekami (WATER_LINES). Zapisz znalezioną geometrię do osobnej tabeli o nazwie ‘T2019_KAR_BRIDGES’
CREATE TABLE T2019_KAR_BRIDGES AS
SELECT DISTINCT St_Intersection(r.geom, w.geom) AS geom
FROM t2019_kar_railways r
JOIN t2019_kar_water_lines w
ON ST_Intersects(r.geom, w.geom);

SELECT * FROM t2019_kar_bridges