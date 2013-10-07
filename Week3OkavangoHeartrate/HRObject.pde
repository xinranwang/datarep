class HRObject {
	int id;
	int seaLevelPressure;
	//String sampleType;
	//int t_utc; 
	int distance;
	
	float speed;
	Float hr;
	String person;
	//int verticalSpeed;
	//String contentType;
	//String dateTime;
	Date dateTime;
	float energyConsumption;
	//float time;
	float temperature;
	int altitude;

	PVector pos = new PVector();
	PVector tpos = new PVector();

	void update() {
		pos.lerp(tpos, 0.1);
	}

	void render() {
		pushMatrix();
		translate(pos.x, pos.y);
		//text(person, 0, 0);
		ellipse(0, 0, 1, 1);
		//line(0, 0, 0, height - pos.y);
		popMatrix();
	}
}
