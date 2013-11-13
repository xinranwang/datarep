/*
http://api.nytimes.com/svc/search/v2/articlesearch.json?q=new+york&fq=organizations:(%22New+York+University%22)&api-key=FBE2D451C771722E7C18A8A566DB0A92:5:68364049
*/

class Query {
	String query;

	String filterType;
	String filterQuery;

	String beginDate;
	String endDate;

	String sortType;

	int page = 0;

	Query(String q) {
		query = replaceSpace(q);
	}

	String getEndPoint() {
		String endPoint = base + "q=" + query + "&api-key=" + apiKey;
		if(filterType != null && filterQuery != null) endPoint += "&fq=" + filterType + ":(\"" + replaceSpace(filterQuery) + "\")";
		if(beginDate != null) endPoint += "&begin_date=" + beginDate;
		if(endDate != null) endPoint += "&end_date=" + endDate;
		if(sortType != null) endPoint += "&sort=" + sortType;
		return endPoint;
	}

}