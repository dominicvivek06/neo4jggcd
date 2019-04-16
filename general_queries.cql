//Delete All
match (n) detach delete(n);

//Limit first 15
match (n) return (n) limit 25;


//Number of Routes from each airport
MATCH (departure:airport)-[:has_route]->(destination:airport) 
WITH departure,count(destination.airport_id) as rels, collect(destination.airport_id) as airports
WHERE rels > 1
RETURN departure.airport_id as departure_Airport,airports as Destination_Airport, rels as No_of_Routes
order by departure_Airport

