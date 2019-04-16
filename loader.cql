//Load all Master Airport Info
CREATE CONSTRAINT ON (a:airport) ASSERT a.airport_id IS UNIQUE;
USING PERIODIC COMMIT 10 LOAD CSV WITH HEADERS FROM "file:///airports.csv" AS line FIELDTERMINATOR ';'
MERGE (a:airport{airport_id:line.airport_id,icao:line.icao,airport_name:line.airport,city:line.city,lat:toFloat(line.lat),long:toFloat(line.long),altitude:line.altitude,timezone:line.timezone})
return a;

//Load Air India Routes
USING PERIODIC COMMIT 10 LOAD CSV WITH HEADERS FROM "file:///ai_route.csv" AS row FIELDTERMINATOR ';'
MATCH (s:airport {airport_id:row.sair})
MATCH (d:airport {airport_id:row.dair})
MERGE (s)-[r:has_route]->(d)
ON CREATE SET r.cost = toInteger(row.cost)
ON CREATE SET r.equipment = row.equipment
return s,r,d;

//First Loader - IGNORE
CREATE CONSTRAINT ON (a:airport) ASSERT a.airport_id IS UNIQUE;
USING PERIODIC COMMIT 10 LOAD CSV WITH HEADERS FROM "file:///aircode.csv" AS line FIELDTERMINATOR ';'
MERGE (a:airport {airport_id:line.airport_id})
return a;

