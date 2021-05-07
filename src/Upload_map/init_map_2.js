var Web3 = require('web3');
var json = require("./build/contracts/StoreMap.json");
var contract = require("truffle-contract");
var MyContract = contract(json);

// Step 3: Provision the contract with a web3 provider
MyContract.setProvider(new Web3.providers.HttpProvider("http://localhost:8545"));

// contract address 
var myContractInstance = MyContract.at("0x8DBDC37b4a484d2C30e53E26197f92c046621385");

// read map in json format
var fs=require('fs');
var map_file="./data/ways.json";
var maps = fs.readFileSync(map_file);
var lineReader = require('line-reader');
var counter = 0;
// read map each line, and get counter
lineReader.eachLine(map_file, function(line, last, cb) {
  	add_map(line);
  	sleep(2000);
  	cb();
	console.log(++counter);
});

// user account
var account = "0xcE55488ca40e4548bF3a56225e0d082D863829b4";

var hash_array;

function add_map(road){
  	var road_json=JSON.parse(road);
	var path_string = road_json.path.substring(1,road_json.path.length-1);
	var point_arr = path_string.split(",");
	
	//add road path
	var path = [];
	var gas = 300000;
	// console.log(point_arr);
	for(var i=0; i< point_arr.length; i++){
		var point = point_arr[i].split(" ");

        var point_x = parseFloat(point[0]);
        var point_y = parseFloat(point[1]);
		
        var point_geohash = encode_geohash(point_x,point_y,11);
		// console.log(point_x,point_y,point_geohash);
        path.push(point_geohash);
		gas += 110000;
	}
	// console.log(path);
  	add_road(road_json.gid,road_json.x1*100000,road_json.y1*100000,road_json.x2*100000,road_json.y2*100000,
		road_json.source,road_json.target,road_json.oneway=1?true:false,road_json.name, path, gas, 0);
	
	// console.log("添加道路");

	// 道路绑定
	hash_array = new Array();
	var x1,y1,x2,y2;
	for(var i=0; i< point_arr.length-1; i++){
		var point1 = point_arr[i].split(" ");
		x1 = parseFloat(point1[0]);
		y1 = parseFloat(point1[1]);
		var point2 = point_arr[i+1].split(" ");
		x2 = parseFloat(point2[0]);
		y2 = parseFloat(point2[1]);
		// console.log(x1 + " " + y1 + " " +x2+" " + y2);
		bind_road_geohash(road_json.gid, x1, x2, y1, y2, path);
	}
}

// 将道路信息绑定在geohash块上
function bind_road_geohash(gid, x1, x2, y1, y2, path){
	var area_geohash;
	var min_x = Math.min(x1, x2);
	var max_x = Math.max(x1, x2);
	var min_y = Math.min(y1, y2);
	var max_y = Math.max(y1, y2);

	var step_x = x1 > x2 ? -1:1;
	var step_y = y1 > y2 ? -1:1;

	//get areas which has intersection with the road. for lon, 0.01 degree is equal to about 1000m and 1113m for lat
	for(var x = x1; x < max_x + 0.01 && x > min_x - 0.01; x+=0.01 * step_x){
		for(var y = y1; y < max_y + 0.01 && y > min_y - 0.01; y+=0.01 * step_y){
			area_geohash = encode_geohash(x,y,5);
			// console.log("area_geohash",area_geohash);

			//duplicate geohash
			if(hash_array.indexOf(area_geohash) != -1){
				continue;
			}
			hash_array.push(area_geohash);
			if(has_intersection(path,area_geohash)){
				add_area_road(area_geohash, gid, 150000, 0);
				console.log("area_geohash",area_geohash);
			}
		}
	}
}

// judge whether a road has intersection with an area described by a geohash value
function has_intersection(path,geohash){
	var i = 0;
	for(i = 0 ; i < path.length ; i++){
		// console.log("path[0-5]:",path[i].substring(0,5));
		// console.log("area_geohash",geohash);
		if(path[i].substring(0,5) == geohash){
			return true;
		}
	}
	return false;
}
function add_area_road(geohash, gid, gas, retry_times){
	console.log(retry_times);
	if(retry_times > 10){
		console.log("bind road failed. geohash: " + geohash + " ,gid: " + gid);
		return;
	}
	myContractInstance.add_area_road(geohash, gid,{from: account,gas: gas}).then(function(result) {
  		//console.log(result);
	},
	function(err){
		add_area_road(geohash, gid, gas, retry_times + 1);
	});
}

//call corresponding api of smart contract, retry if reject because of timeout
function add_road(gid, x1, y1, x2, y2, source, target, oneway, name, path, gas, retry_times){
	if(retry_times > 10){
		console.log("add road failed. gid: " + gid);
		return;
	}
	myContractInstance.add_road(gid, x1, y1, x2, y2, source, target, oneway, name, path, {from: account,gas: gas}).then(function(result) {
		//console.log(result);
	},
	function(err){
		//retry
		add_road(gid, x1, y1, x2, y2, source, target, oneway, name, path, gas, retry_times+1);
	});
}

function sleep(delay) {
    var start = new Date().getTime();
    while (new Date().getTime() < start + delay);
}

// var precision = 6;
var Bits = [16, 8, 4, 2, 1];
var Base32 = "0123456789bcdefghjkmnpqrstuvwxyz".split("");

function encode_geohash(longitude, latitude,precision){
	var geohash = "";
	var even = true;
	var bit = 0;
	var ch = 0;
	var pos = 0;
    var lat = [-90,90];
	var lon = [-180,180];
	while(geohash.length < precision){
		var mid;

        if (even)
        {
            mid = (lon[0] + lon[1])/2;
            if (longitude > mid)
            {
                ch |= Bits[bit];
                lon[0] = mid;
             }
            else
                lon[1] = mid;
        }
		else
        {
            mid = (lat[0] + lat[1])/2;
            if (latitude > mid)
            {
                ch |= Bits[bit];
                lat[0] = mid;
            }
            else
                lat[1] = mid;
		}
        even = !even;
        if (bit < 4)
            bit++;
        else
        {
            geohash += Base32[ch];
            bit = 0;
            ch = 0;
        }
	}
	return geohash;
}

function decode_geohash(geohash)
{
	var even = true;
    var lat = [-90,90];
	var lon = [-180,180];

	for(var i=0; i< geohash.length; i++)
	{
		var c= geohash[i];
		var cd = Base32.indexOf(c);
		for (var j = 0; j < 5; j++)
		{
			var mask = Bits[j];
			if (even)
			{
				RefineInterval(lon, cd, mask);
			}
			else
			{
				RefineInterval(lat, cd, mask);
			}
			even = !even;
		}
	}

	return new Array(lon[0], lon[1], lat[0], lat[1]);
}

var Neighbors = [[ "p0r21436x8zb9dcf5h7kjnmqesgutwvy", // Top
	"bc01fg45238967deuvhjyznpkmstqrwx", // Right
	"14365h7k9dcfesgujnmqp0r2twvyx8zb", // Bottom
	"238967debc01fg45kmstqrwxuvhjyznp", // Left
	], ["bc01fg45238967deuvhjyznpkmstqrwx", // Top
	"p0r21436x8zb9dcf5h7kjnmqesgutwvy", // Right
	"238967debc01fg45kmstqrwxuvhjyznp", // Bottom
	"14365h7k9dcfesgujnmqp0r2twvyx8zb", // Left
	]];

var Borders = [["prxz", "bcfguvyz", "028b", "0145hjnp"],
	["bcfguvyz", "prxz", "0145hjnp", "028b"]];


function getNeighbour(hash)
{
	var hash_neighbour = new Array();
	var hash_top = CalculateAdjacent(hash,0);
	hash_neighbour.push(hash_top);
	var hash_right = CalculateAdjacent(hash,1);
	hash_neighbour.push(hash_right);
	var hash_bottom = CalculateAdjacent(hash,2);
	hash_neighbour.push(hash_bottom);
	var hash_left = CalculateAdjacent(hash,3);
	hash_neighbour.push(hash_left);

	var hash_top_left = CalculateAdjacent(hash_top, 3);
	hash_neighbour.push(hash_top_left);
	var hash_top_right = CalculateAdjacent(hash_top, 1);
	hash_neighbour.push(hash_top_right);
	var hash_bottom_left = CalculateAdjacent(hash_bottom, 3);
	hash_neighbour.push(hash_bottom_left);
	var hash_bottom_right = CalculateAdjacent(hash_bottom, 1);
	hash_neighbour.push(hash_bottom_right);

	return hash_neighbour;
}


function CalculateAdjacent(hash, dir)
{
	var lastChr = hash[hash.length - 1];
	var type = hash.length % 2;
	var nHash = hash.substring(0, hash.length - 1);

	if (Borders[type][dir].indexOf(lastChr) != -1)
	{
		nHash = CalculateAdjacent(nHash, dir);
	}
	return nHash + Base32[Neighbors[type][dir].indexOf(lastChr)];
}

function RefineInterval(interval, cd, mask)
{
	if ((cd & mask) != 0)
	{
		interval[0] = (interval[0] + interval[1])/2;
	}
	else
	{
		interval[1] = (interval[0] + interval[1])/2;
	}
}

