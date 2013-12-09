class Trail {
	HalfTrail uptown;
	HalfTrail downtown;

	int day;
	long startTime;
	
	PVector pos = new PVector();
	PVector tpos = new PVector();

	Trail(int _day, long _startTime, String startStopId, StringList uptownStopPool, StringList downtownStopPool) {
		day = _day;
		startTime = _startTime;

		//uptown = new HalfTrail(day, startTime, startStopId+"N", uptownStopPool);
		downtown = new HalfTrail(day, startTime, startStopId+"S", downtownStopPool);

		//uptown.computePaths();
		downtown.computePaths();
	}

	void setVertexPos() {
		//uptown.setVertexPos(tpos);
		downtown.setVertexPos(tpos);
	}

	void update() {
		pos.lerp(tpos, 0.1);
	}
	
	void render() {
		// pushMatrix();
		// translate(pos.x, pos.y, pos.z);

		// noStroke();
		// fill(255);
		// rectMode(CENTER);
		// rect(0, 0, 5, 5);

		// popMatrix();
		// for (Map.Entry me : uptown.vertexMap.entrySet()){
		// 	Vertex v = (Vertex)me.getValue();
		// 	v.update();
		// 	v.render();
		// }

		for (Map.Entry me : downtown.vertexMap.entrySet()){
			Vertex v = (Vertex)me.getValue();
			v.update();
			v.render();
		}
	}
}