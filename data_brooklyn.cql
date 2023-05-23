LOAD CSV WITH HEADERS FROM 'file:///google_transit_brooklyn/agency.txt' AS csv
MERGE (a:Agency {id: csv.agency_id, name: csv.agency_name, url: csv.agency_url, timezone: csv.agency_timezone});


LOAD CSV WITH HEADERS FROM 'file:///google_transit_brooklyn/routes.txt' AS csv
MATCH (a:Agency {id: csv.agency_id})
MERGE (r:Route {id: csv.route_id, short_name: csv.route_short_name, long_name: csv.route_long_name, type: toInteger(csv.route_type)})
MERGE (a)-[:OPERATES]->(r);


LOAD CSV WITH HEADERS FROM 'file:///google_transit_brooklyn/trips.txt' AS csv  
MATCH (r:Route {id: csv.route_id})
MERGE (t:Trip {id: csv.trip_id, service_id: csv.service_id, headsign: csv.trip_headsign, direction_id: csv.direction_id, block_id: csv.block_id, shape_id: csv.shape_id})  
MERGE (r)<-[:USES]-(t);


LOAD CSV WITH HEADERS FROM 'file:///google_transit_brooklyn/stops.txt' AS csv  
CREATE (s:Stop {id: csv.stop_id, name: csv.stop_name, lat: toFloat(csv.stop_lat), lon: toFloat(csv.stop_lon), platform_code: csv.platform_code, parent_station: csv.parent_station, location_type: csv.location_type, timezone: csv.stop_timezone, code: csv.stop_code});


LOAD CSV WITH HEADERS FROM 'file:///google_transit_brooklyn/stops.txt' AS csv  
WITH csv
WHERE NOT (csv.parent_station IS NULL)
MATCH (ps:Stop {id: csv.parent_station}), (s:Stop {id: csv.stop_id})
MERGE (ps)<-[:PART_OF]-(s);


:auto
LOAD CSV WITH HEADERS FROM 'file:///google_transit_brooklyn/stop_times.txt' AS csv
CALL {
    WITH csv
    MATCH (t:Trip {id: csv.trip_id}), (s:Stop {id: csv.stop_id})
    CREATE (t)<-[:PART_OF_TRIP]-(st:StopTime {arrival_time: csv.arrival_time, departure_time: csv.departure_time, stop_sequence: toInteger(csv.stop_sequence)})-[:LOCATED_AT]->(s)
} IN TRANSACTIONS


:auto
CAll {
    MATCH (s1:StopTime)-[:PART_OF_TRIP]->(t:Trip), (s2:StopTime)-[:PART_OF_TRIP]->(t)  
    WHERE s2.stop_sequence=s1.stop_sequence+1  
    MERGE (s1)-[:PRECEDES]->(s2) 
} IN TRANSACTIONS