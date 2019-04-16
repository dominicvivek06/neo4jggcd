//From MAA to DEL
MATCH path = (maa:airport{airport_id:'MAA'})-[:has_route*0..2]->(del:airport{airport_id:'DEL'}) RETURN path;

//********************************************************************
//Graph - Visual - adjust the "NEXT" line thickness. Background WHITE
//********************************************************************
//1 hop
MATCH (start:airport{airport_id:'MAA'}), (end:airport{airport_id:'DEL'})
CALL algo.kShortestPaths.stream(start, end, 3, 'cost', {path: true})
YIELD path
RETURN path
LIMIT 1
//5 hop
MATCH (start:airport{airport_id:'MAA'}), (end:airport{airport_id:'DEL'})
CALL algo.kShortestPaths.stream(start, end, 3, 'cost', {path: true})
YIELD path
RETURN path
LIMIT 5


//*************************************************************************************
//Graph - Visual - adjust the "PATH" line thickness. Background WHITE - Different PATH
//*************************************************************************************
MATCH (start:airport{airport_id:'MAA'}), (end:airport{airport_id:'DEL'})
CALL algo.kShortestPaths(start, end, 3, 'cost' ,{})
YIELD resultCount
RETURN resultCount;
//2nd query
MATCH p=()-[r:PATH_0|:PATH_1|:PATH_2]->() RETURN p LIMIT 25



//*********************************************************
//Yen’s K-shortest paths -- all path costs from MAA to DEL
//*********************************************************
MATCH (start:airport{airport_id:'MAA'}), (end:airport{airport_id:'DEL'})
CALL algo.kShortestPaths.stream(start, end, 3, 'cost' ,{})
YIELD index, nodeIds, costs
RETURN [node in algo.getNodesById(nodeIds) | node.airport_id] AS airports,
       costs,
       reduce(acc = 0.0, cost in costs | acc + cost) AS totalCost;



//*************************************************
//Shortest Path between MAA and DEL - cummulative
//*************************************************
MATCH (start:airport{airport_id:'MAA'}), (end:airport{airport_id:'DEL'})
CALL algo.shortestPath.stream(start, end, 'cost')
YIELD nodeId, cost
RETURN algo.asNode(nodeId).airport_id AS airport_id, cost


//*********************************************************
//Delta stepping algorithm - cost of going to each airport
//*********************************************************
MATCH (n:airport {airport_id:'MAA'})
CALL algo.shortestPath.deltaStepping.stream(n, 'cost', 3.0)
YIELD nodeId, distance
RETURN algo.asNode(nodeId).airport_id AS destination, distance
order by distance



//*********************************************************
//All Pairs Shortest Path algorithm - furthes airport pair
//*********************************************************
CALL algo.allShortestPaths.stream('cost',{nodeQuery:'airport',defaultValue:1.0})
YIELD sourceNodeId, targetNodeId, distance
WITH sourceNodeId, targetNodeId, distance
WHERE algo.isFinite(distance) = true
MATCH (source:airport) WHERE id(source) = sourceNodeId
MATCH (target:airport) WHERE id(target) = targetNodeId
WITH source, target, distance WHERE source <> target
RETURN source.airport_id AS source_airport_id, source.airport_name as source_airport, source.city as source_city, target.airport_id AS target_airport_id, target.airport_name as target_airport, target.city as target_city, distance
ORDER BY distance DESC
LIMIT 10


//*********************************************************
//All Pairs Shortest Path algorithm - from MAA
//*********************************************************
CALL algo.allShortestPaths.stream('cost',{nodeQuery:'airport',defaultValue:1.0})
YIELD sourceNodeId, targetNodeId, distance
WITH sourceNodeId, targetNodeId, distance
WHERE algo.isFinite(distance) = true
MATCH (source:airport{airport_id:'MAA'}) WHERE id(source) = sourceNodeId
MATCH (target:airport) WHERE id(target) = targetNodeId
WITH source, target, distance WHERE source <> target
RETURN source.airport_id AS source_airport_id, source.airport_name as source_airport, source.city as source_city, target.airport_id AS target_airport_id, target.airport_name as target_airport, target.city as target_city, distance
ORDER BY distance DESC
LIMIT 10

//*********************************************************
//The A* algorithm  - with GPS Locations
//*********************************************************
MATCH (start:airport{airport_id:"MAA"}),(end:airport{airport_id:"DEL"})
CALL algo.shortestPath.astar.stream(start, end, 'cost', 'lat', 'long', {defaultValue:1.0})
YIELD nodeId, cost
RETURN algo.asNode(nodeId).airport_id as airport,cost






//**********************************************
//Minimum Weight Spanning Tree
//**********************************************
//Minimum weight spanning tree visits all airport that are in the same connected component as the 
//starting airport, and returns a spanning tree of all airport in the component where the 
//total weight of the relationships is minimized.
//**********************************************
MATCH (n:airport {airport_id:"MAA"})
CALL algo.spanningTree.minimum('airport', 'has_routes', 'cost', id(n),
  {write:true, writeProperty:"MINST"})
YIELD loadMillis, computeMillis, writeMillis, effectiveNodeCount
RETURN loadMillis, computeMillis, writeMillis, effectiveNodeCount;

MATCH path = (n:airport {airport_id:"MAA"})-[:MINST*]-()
WITH relationships(path) AS rels
UNWIND rels AS rel
WITH DISTINCT rel AS rel
RETURN startNode(rel).airport_id AS source, endNode(rel).airport_id AS destination, rel.cost AS cost

//**********************************************
//Maximum weighted tree spanning algorithm is similar to the minimum one, 
//except that it returns a spanning tree of all nodes in the component where 
//the total weight of the relationships is maximized.
//**********************************************

MATCH (n:airport {airport_id:"MAA"})
CALL algo.spanningTree.minimum('airport', 'has_routes', 'cost', id(n),
  {write:true, writeProperty:"MAXST"})
YIELD loadMillis, computeMillis, writeMillis, effectiveNodeCount
RETURN loadMillis, computeMillis, writeMillis, effectiveNodeCount;

MATCH path = (n:airport {airport_id:"MAA"})-[:MAXST*]-()
WITH relationships(path) AS rels
UNWIND rels AS rel
WITH DISTINCT rel AS rel
RETURN startNode(rel).airport_id AS source, endNode(rel).airport_id AS destination, rel.cost AS cost




//*************************************************************************************
//Random Route from Source Airport - MAA
//*************************************************************************************
MATCH (airport:airport {airport_id: "MAA"})
CALL algo.randomWalk.stream(id(airport), 3, 1)
YIELD nodeIds
UNWIND nodeIds AS nodeId
RETURN algo.asNode(nodeId).airport_id AS airport