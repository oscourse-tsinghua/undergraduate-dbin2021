document.write("<script language='javascript' src='traffic_files/web3.js'></script>");
document.write("<script language='javascript' src='traffic_files/truffle-contract.js'></script>");
document.write("<script language='javascript' src='traffic_files/StoreMap.json'></script>");

var web3 = new Web3();
//web3.setProvider(new web3.providers.HttpProvider("http://localhost:8545"));
var MyContract = TruffleContract(contract_json);
// Step 3: Provision the contract with a web3 provider
MyContract.setProvider(new Web3.providers.HttpProvider("http://localhost:8545"));

var contract_addr = "0xfb374b3004ad93410c405b286813491aaba04937"
var myContractInstance = MyContract.at(contract_addr);


var roads_buffer = new {};//buffer roads in geohash block
var buffer_size = 50;

function get_roads(geo_hash){
	//clear buffer if full
	if(Object.getOwnPropertyNames(roads_buffer).length > buffer_size){
		for(var name in roads_buffer){
			delete roads_buffer.name;
		}
	}

	if(geo_hash in roads_buffer){
		alert("here");
		return roads_buffer.geo_hash;
	}
	//not in buffer, get roads from block chain
	var roads_array = new Array();
	myContractInstance.get_roads(geo_hash).then(function(roads){
  		var road_info = roads[0];
		//alert(road_info);
		var road_name = roads[1];
			
		for(var i=0; i<road_name.length; i++){
			var road = {};
			road.gid = road_info[i*6];
			road.x1  = road_info[i*6 + 1] / 100000;
			road.y1  = road_info[i*6 + 2] / 100000;
			road.x2  = road_info[i*6 + 3] / 100000;
			road.y2  = road_info[i*6 + 4] / 100000;
			road.oneway  = road_info[i*6 + 5];
			road.name = hex2str(road_name[i]);

			printObj(road);
			roads_array.push(road);
		}
	});
	//buffer
	roads_buffer.geo_hash = roads_array;
	return roads_array;
}

function get_map_by_tile(tile_x, tile_y, tile_z){
	tile_x = parseInt(tile_x);
	tile_y = parseInt(tile_y);
	tile_z = parseInt(tile_z);
	var hash_array = get_geohash_by_tile(tile_x, tile_y, tile_z);
	alert(hash_array.length);
	var roads_array = new Array();
	var area_roads;
	var bound = {};
	var x1 = tile2long(tile_x,tile_z);
	var x2 = tile2long(tile_x+1,tile_z);
	var y1 = tile2lat(tile_y,tile_z);
	var y2 = tile2lat(tile_y+1,tile_z);
	
	bound.min_x = Math.min(x1, x2);
	bound.max_x = Math.max(x1, x2);
	bound.min_y = Math.min(y1, y2);
	bound.max_y = Math.max(y1, y2);
		
	var gid_array = new Array();
	for(var hash in hash_array){
		area_roads = get_roads(hash);
		for(var road in area_roads){
			//duplicate road
			if(gid_array.indexOf(road.gid) != -1){
				continue;
			}
			if(has_intersection(road.x1, road.x2, road.y1, road.y2, bound)){
				roads_array.push(road);
			}
		}
	}
	alert(roads_array.length);
	return roads_array;
}

function hex2str(hex){ 
	hex = hex.substr(0,2).toLowerCase() === "0x" ? hex.substr(2) : hex;
	var str = ""; 
	for(var i = 0;i < hex.length;i+=4){ 
		str += String.fromCharCode(parseInt(hex.substr(i,4),16)); 
	} 
	return str; 
} 

function printObj(obj){ 
	var description = ""; 
	for(var i in obj){ 
		var property=obj[i]; 
		description+=i+" = "+property+"\n"; 
	} 
	alert(description); 
} 

