/*
Article Search API Key: FBE2D451C771722E7C18A8A566DB0A92:5:68364049
*/

import java.util.Map;
import java.util.Comparator;
import java.util.Collections;
import java.util.Date;
import java.text.SimpleDateFormat;

String base = "http://api.nytimes.com/svc/search/v2/articlesearch.json?";
String apiKey = "FBE2D451C771722E7C18A8A566DB0A92:5:68364049";

String globalQuery = "Beijing";
String filterType = "glocations";
String filterQuery = "BEIJING (CHINA)";

int beginYear = 1986;
int endYear = 2013;

int threshold = 1;
int index = 1986;

int mostCount = 0;

PFont yearFont;
PFont labelFont;

boolean useLocalData = true;

PVector mousePos = new PVector();

// HashMap<Integer, ArrayList> map = new HashMap();

// ArrayList<Keyword> wordList = new ArrayList();

HashMap<String, ArrayList<Date>> keywordMap = new HashMap(); 
ArrayList<Keyword> keywordList = new ArrayList();
//ArrayList<Keyword> showList = new ArrayList();

//1986-11-26T00:00:00Z
SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");


void setup() {
	size(1280, 720, P3D);
	noStroke();
	colorMode(HSB, 360, 100, 100);
	yearFont = createFont("Futura Condensed.ttf", 200);
	labelFont = createFont("Futura Condensed.ttf", 14);
	
	

	for (int i = beginYear; i<=endYear; i++){
		Query q = new Query(globalQuery);
		q.filterType = filterType;
		q.filterQuery = filterQuery;
		q.sortType = "oldest";
		q.beginDate = Integer.toString(i) + "0101";
		q.endDate = Integer.toString(i) + "1231";

		getKeywords(q, i);

		// ArrayList<Keyword> l = getKeywords(q, i);
		// sortWordList(l);
		// if(l.get(0).count > mostCount) mostCount = l.get(0).count;
		// map.put(i, l);
	}
	for(Map.Entry me : keywordMap.entrySet()) {
		Keyword k = new Keyword();
		k.keywordString = (String)me.getKey();
		k.dateList = (ArrayList<Date>)me.getValue();
		keywordList.add(k);
	}
	updateKeywordList();

	// changeList(map.get(index));
	smooth(4);
}

void draw() {
	background(0);

	mousePos.set(mouseX, mouseY);

	for (Keyword k : keywordList){
		k.update();
		if(k.tbarSize > threshold) k.render();
	}

	fill(255);
	textFont(yearFont, 200);
	textAlign(RIGHT);
	text(index, width - 10, height - 10);
}

void getKeywords(Query q, int indexYear) {
	//String url = (page == 0) ? q.getEndPoint() : q.getEndPoint() + "&page=" + page;
	int page = 0;
	//HashMap<String, Keyword> wordMap = new HashMap();

	while (page < 100){
		String url;
		if(!useLocalData) url = q.getEndPoint() + "&page=" + page;
		else url = "data/json/" + indexYear + nf(page, 3) + ".json";

		//println("url: "+url);
		JSONObject myJSON = loadJSONObject(url);

		// save json to local
		if(!useLocalData) saveJSONObject(myJSON, "data/json/" + indexYear + nf(page, 3) + ".json");

		JSONObject response = myJSON.getJSONObject("response");

		JSONObject meta = response.getJSONObject("meta");
		// hits = meta.getInt("hits");

		JSONArray docs = response.getJSONArray("docs");

		if (docs.size() < 1){
			println(q.endDate + " page: "+page);
			page = 200;
			break;
		}
		for (int i = 0; i<docs.size(); i++){
			JSONObject doc = docs.getJSONObject(i);
			
			String dateString = doc.getString("pub_date");
			try {
				Date keywordDate = sdf.parse(dateString);

				JSONArray keywords = doc.getJSONArray("keywords");

				IntDict tempDict = new IntDict();

				for (int j = 0; j<keywords.size(); j++){
					JSONObject keywordObject = keywords.getJSONObject(j);
					String keywordType = keywordObject.getString("name");
					String keyword = keywordObject.getString("value").toUpperCase();
					
					if(keywordType.equals("subject")) {
						//println(keywordType, keyword);

						if (!tempDict.hasKey(keyword)){
							tempDict.increment(keyword);
							if (!keywordMap.containsKey(keyword)){
								keywordMap.put(keyword, new ArrayList<Date>());
							}
							keywordMap.get(keyword).add(keywordDate);
						}
					} 
				}

			} catch (Exception e) {
				println("Error parsing date: " + e);
			}

		}
		page++;
		if(!useLocalData) delay(120);
	}
}

String replaceSpace(String str) {
	String[] list = split(str, ' ');
	return join(list, "+");
}

void updateKeywordList() {
	for (Keyword k : keywordList){
		int count = 0;
		for (Date date : k.dateList){
			if (date.getYear()+1900 == index){
				count++;
			}
		}
		k.tbarSize = count==0 ? 0 : count;
	}
	sortKeywords();
}

void sortKeywords() {
	Collections.sort(keywordList);
	positionLine();
}

void positionLine() {
	for (int i = 0; i<keywordList.size(); i++){
		Keyword k = keywordList.get(i);
		float x = 50 + i * 20;
		float y = height / 2;
		k.tpos.set(x, y);
	}
}

void keyPressed() {
	if (key == CODED){
		if (keyCode == UP && index < endYear){
			index++;
			updateKeywordList();
		}
		if (keyCode == DOWN && index > beginYear){
			index--;
			updateKeywordList();
		}
	}
}