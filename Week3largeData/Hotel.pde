class Hotel {
	String name;
	int stars;

	PVector pos;
	PVector tpos;

	void update() {
		pos.lerp(tpos, 0.1);
	}

	void render() {
		pushMatrix();
		translate(pos.x, pos.y, pos.z);
		text(name, 0, 0);
		popMatrix();
	}
}