//******************************************************************************************
// Centrality Algorthims
//******************************************************************************************

//*********************************************************
//PageRank algorithm -- Rank incoming traffic - unweighted
//*********************************************************
CALL algo.pageRank.stream('airport', 'has_routes', {iterations:20, dampingFactor:0.85})
YIELD nodeId, score
RETURN algo.asNode(nodeId).airport_id  AS airport,score
ORDER BY score DESC

CALL algo.pageRank('airport', 'has_routes',
  {iterations:20, dampingFactor:0.85, write: true,writeProperty:"pagerank"})
YIELD nodes, iterations, loadMillis, computeMillis, writeMillis, dampingFactor, write, writeProperty

//*****************************************************
//PageRank algorithm -- Rank incoming traffic with COST
//*****************************************************
CALL algo.pageRank.stream('airport', 'has_routes', {
  iterations:20, dampingFactor:0.85, weightProperty: "cost"
})
YIELD nodeId, score
RETURN algo.asNode(nodeId).airport_id AS airport,score
ORDER BY score DESC

CALL algo.pageRank('airport', 'has_routes',{
  iterations:20, dampingFactor:0.85, write: true, writeProperty:"pagerank", weightProperty: "cost"
})
YIELD nodes, iterations, loadMillis, computeMillis, writeMillis, dampingFactor, write, writeProperty


//*************************************************************
//PageRank algorithm -- Personalized PageRank from a Departure
//*************************************************************
MATCH (departure:airport {airport_id: "MAA"})
CALL algo.pageRank.stream('airport', 'has_routes', {iterations:20, dampingFactor:0.85, sourceNodes: [departure]})
YIELD nodeId, score
RETURN algo.asNode(nodeId).airport_id AS page,score
ORDER BY score DESC


//*************************************************
//ArticleRank algorithm  -- Most important Airport
//*************************************************
CALL algo.articleRank.stream('airport', 'has_routes', {iterations:20, dampingFactor:0.85})
YIELD nodeId, score
RETURN algo.asNode(nodeId).airport_id AS page,score
ORDER BY score DESC


//***********************************************************************************
// Betweenness Centrality algorithm - pair of airports that go along with each other
//***********************************************************************************
CALL algo.betweenness.stream('airport','has_routes',{direction:'out'})
YIELD nodeId, centrality
MATCH (airport:airport) WHERE id(airport) = nodeId
RETURN airport.airport_id AS airport,centrality
ORDER BY centrality DESC;


//***********************************************************************************
// Closeness Centrality algorithm - the best connected Airport
//***********************************************************************************
CALL algo.closeness.stream('airport', 'has_routes')
YIELD nodeId, centrality
RETURN algo.asNode(nodeId).airport_id AS node, centrality
ORDER BY centrality DESC
LIMIT 50;

//***********************************************************************************
// Eigenvector Centrality algorithm - the most traffic Airport
//***********************************************************************************

CALL algo.eigenvector.stream('airport', 'has_routes', {})
YIELD nodeId, score
RETURN algo.asNode(nodeId).airport_id AS airport,score
ORDER BY score DESC

//***********************************************************************************
// Degree Centrality algorithm  - the most Airport with incoming (unweighted)
//***********************************************************************************
CALL algo.degree.stream("airport", "has_routes", {direction: "incoming"})
YIELD nodeId, score
RETURN algo.asNode(nodeId).airport_id AS name, score AS incoming_traffic
ORDER BY incoming_traffic DESC;


//***********************************************************************************
// Eigenvector Centrality algorithm - the most Airport with outgoing (unweighted)
//***********************************************************************************
CALL algo.degree.stream("airport", "has_routes", {direction: "outgoing"})
YIELD nodeId, score
RETURN algo.asNode(nodeId).airport_id AS name, score AS outgoing_traffic
ORDER BY outgoing_traffic DESC;



//***********************************************************************************
// Eigenvector Centrality algorithm - the most Airport with incoming (weighted)
//***********************************************************************************
CALL algo.degree.stream("airport", "has_routes", {direction: "incoming", weightProperty: "cost"})
YIELD nodeId, score
RETURN algo.asNode(nodeId).airport_id AS name, score AS weighted_cost
ORDER BY weighted_cost DESC

//***********************************************************************************
// Eigenvector Centrality algorithm - the most Airport with outgoing (weighted)
//***********************************************************************************
CALL algo.degree.stream("airport", "has_routes", {direction: "outgoing", weightProperty: "cost"})
YIELD nodeId, score
RETURN algo.asNode(nodeId).airport_id AS name, score AS weighted_cost
ORDER BY weighted_cost DESC

