# spring2023_exam_neo4j_setup
A graph database setup for neo4j, to find routes between stops on a public transit network.<br>
The model is built from GTFS data, translated into a graph model to efficiently find paths between stops on the network.<br>
This specific setup uses GTFS data from New York Citys public transit network.

Edit the database settings, increase the following by a reasonable amount:<br>
server.memory.heap.initial_size
server.memory.heap.max_size

run the commands in the files in order, starting with constraints, then subways, then the rest in any order.
