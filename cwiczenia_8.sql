create extension postgis;
create extension postgis_raster;

-- Zadanie 2
Select count(*) from uk_250k;

-- Zadanie 5
Select * from national_parks;

-- Zadanie 6
CREATE TABLE uk_lake_district AS
SELECT
    ST_Clip(r.rast, p.geom, true) AS rast
FROM
    uk_250k AS r,
    national_parks AS p
WHERE
    p.id = 1  -- ID:1 to Lake District
    AND ST_Intersects(r.rast, p.geom);

Select * from uk_lake_district

-- Zadanie 10
-- Stworzenie B03 obciętego do obszaru Lake District
CREATE TABLE sentinel_green_clip AS
SELECT
    ST_Clip(r.rast, ST_Transform(p.geom, ST_SRID(r.rast)), true) AS rast
FROM
    sentinel_green r,
    national_parks p;
WHERE
    p.id = 1
    AND ST_Intersects(r.rast, ST_Transform(p.geom, ST_SRID(r.rast)));


SELECT AddRasterConstraints('sentinel_green_clip', 'rast');
CREATE INDEX sentinel_green_clip_idx ON sentinel_green_clip USING GIST (ST_ConvexHull(rast));

-- Stworzenie B08 obciętego do obszaru Lake District
CREATE TABLE sentinel_nir_clip AS
SELECT
    ST_Clip(r.rast, ST_Transform(p.geom, ST_SRID(r.rast)), true) AS rast
FROM
    sentinel_nir r,
    national_parks p;
WHERE
    p.id = 1
    AND ST_Intersects(r.rast, ST_Transform(p.geom, ST_SRID(r.rast)));

SELECT AddRasterConstraints('sentinel_nir_clip', 'rast');
CREATE INDEX sentinel_nir_clip_idx ON sentinel_nir_clip USING GIST (ST_ConvexHull(rast));


Select count(*) From lake_district_ndwi;


DROP TABLE lake_district_ndwi;

-- Obliczanie NDWI
CREATE TABLE lake_district_ndwi_v2 AS
SELECT
    -- Wymuszamy, żeby wynik miał ten sam SRID co dane wejściowe (Sentinel)
    ST_SetSRID(
        ST_MapAlgebra(
            a.rast,
            b.rast,
            '([rast1] - [rast2]) / NULLIF([rast1] + [rast2], 0)::float'
        ),
        ST_SRID(a.rast) -- Pobieramy ID układu z pliku wejściowego
    ) AS rast
FROM
    sentinel_green_clip a,
    sentinel_nir  b
WHERE
    ST_Intersects(a.rast, b.rast);

SELECT AddRasterConstraints('lake_district_ndwi_v2', 'rast');