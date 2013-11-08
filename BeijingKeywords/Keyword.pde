class Keyword {
	String keyword;
	int count;
	color c = color(random(360), random(70, 80), random(80, 90));

	PVector pos = new PVector(width*2, height / 2);
	PVector tpos = new PVector();

	float size = 0;
	float tsize = 0;

	void update() {
		pos.lerp(tpos, 0.1);
		size = lerp(size, tsize, 0.1);
	}

	void render() {
		textAlign(LEFT);
		textFont(labelFont, 14);

		pushMatrix();
		translate(pos.x, pos.y, pos.z);
		fill(c);
		//ellipse(0, 0, size, size);
		rect(-5, 0, 20, -size);
		fill(255);
		text(count, 0, -size-5);
		rotateZ(PI / 2);
		text(keyword, 5, 0);
		popMatrix();
	}
}