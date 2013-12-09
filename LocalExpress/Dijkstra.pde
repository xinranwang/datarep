class Dijkstra {
	void computePaths(Vertex source, int day, long startTime, HashMap<String, Vertex> vertexMap) {
		// if (veryStart){ // added by me
		// 	source.minDistance = 0;
		// }
		PriorityQueue<Vertex> vertexQueue = new PriorityQueue<Vertex>();
		vertexQueue.add(source);

		while (!vertexQueue.isEmpty ()) {
			Vertex u = vertexQueue.poll();

			u.getEdges(day, startTime+u.minDistance, vertexMap); // added by me

			// Visit each edge exiting u
			for (Edge e : u.adjacencies) {
				Vertex v = e.target;
				long weight = e.weight;
				long distanceThroughU = u.minDistance + weight;
				if (distanceThroughU < v.minDistance) {
					vertexQueue.remove(v);

					v.minDistance = distanceThroughU ;
					v.previous = u;
					v.previousEdge = e; // added by me
					vertexQueue.add(v);
				}
			}
		}
	}

	ArrayList<Vertex> getShortestPathTo(Vertex target) {
		ArrayList<Vertex> path = new ArrayList<Vertex>();
		for (Vertex vertex = target; vertex != null; vertex = vertex.previous)
			path.add(vertex);
		Collections.reverse(path);
		return path;
	}


	// added by me
	ArrayList<Edge> getShortestPathEdgesTo(Vertex target) {
		ArrayList<Edge> edges = new ArrayList<Edge>();
		for (Vertex vertex = target; vertex.previousEdge != null; vertex = vertex.previous)
			edges.add(vertex.previousEdge);
		Collections.reverse(edges);
		return edges;
	}
}