class Edge {
	Vertex target;
	long weight;

	Trip trip;

	String toString() {
		return trip.route_id;
	}
}