class Keyword implements Comparable {
	String keywordString;
	ArrayList<Date> dateList = new ArrayList();
	color c = color(random(360), random(70, 80), random(80, 90));

	PVector pos = new PVector(width + 100, height / 2);
	PVector tpos = new PVector(width + 100, height / 2);

	PVector rot = new PVector(0, 0, PI/2);
	PVector trot = new PVector(0, 0, PI/2);

	float barSize;
	float tbarSize;

	void update() {
		pos.lerp(tpos, 0.1);
		rot.lerp(trot, 0.1);
		barSize = lerp(barSize, tbarSize, 0.1);

		// if (mousePressed && mousePos.dist(pos) < 10){
		// 	println("dateList: "+dateList);
		// }
	}

	void render() {
		textAlign(LEFT);
		textFont(labelFont, 14);

		pushMatrix();
		translate(pos.x, pos.y, pos.z);
		rotateX(rot.x);
		rotateY(rot.y);
		rotateZ(rot.z);

		fill(c);
		rect(0, 0, -barSize, 10);
		fill(255);
		text(keywordString, 5, 10);
		popMatrix();
	}

	int compareTo(Object o) {
		return int(((Keyword)o).tbarSize - tbarSize);
	}
}