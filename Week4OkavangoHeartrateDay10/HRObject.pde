class HRObject {
	int id;
	int seaLevelPressure;
	//String sampleType;
	//int t_utc; 
	int distance;
	
	float speed;
	float hr;
	String person;
	//int verticalSpeed;
	//String contentType;
	//String dateTime;
	Date dateTime;
	float energyConsumption;
	//float time;
	float temperature;
	int altitude;

	float period;

	PVector pos = new PVector();
	PVector tpos;// = new PVector();

	HRObject(float heartRate) {
		hr = heartRate;
		if(hr > 0) period = 1 / hr * 1000;
		else period = -1;
	}

	void update() {
		pos.lerp(tpos, 0.1);
	}

	void render() {
		pushMatrix();
		translate(pos.x, pos.y, pos.z);
		//text(person, 0, 0);
		fill(255);
		stroke(255);
		//ellipse(0, 0, 1, 1);
		point(0, 0, 0);
		//line(0, 0, 0, height - pos.y);
		popMatrix();
	}
}
