var matching_window = new Array();
var window_bound = 20;
var candidate_range = 100;//meters

function match(queue){
	for(var point in queue){
		var candidates = get_candidates(point);
	}
}

function get_candidates(point){
	//get 9 geohash blocks
	var geohash = encode_geohash(point.lon, point.lat);
	var neighbours = getNeighbour(geohash);

	//get all roads in blocks and filter
	var candidates = new Array();




	candidates = candidates.concat(filter(get_roads(geohash)));
	for(var hash in neighbours){
		candidates = candidates.concat(filter(get_roads(hash)));
	}

	return candidates;
}

//filter roads in the range
function filter(roads){
	for(var road in roads){
	}
}
