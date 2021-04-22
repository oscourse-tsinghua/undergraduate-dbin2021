pragma solidity ^0.5.16;

contract StoreMap{
	//	这一行声明了一个可以被公开访问的
	/*
	//	address 类型是一个160位的值，且不允许任何算数操作
	//	这种类型适合存储合约地址或外部人员的密钥对
	*/
	address public owner;

	// 这个合约只定义一个修饰器，但并未使用： 它将会在派生合约中用到
	// 修饰器所修饰的函数体会被插入到特殊符号 _; 的位置
	// 这意味着如果是 owner 调用这个函数，则函数会被执行，否则会抛出异常
	// 修改器可以修改参数
	modifier restricted(){
    	if (msg.sender == owner) _;
  	}

	// 存储道路信息
	struct road_info
	{	
		int32 x1;
		int32 x2;
		int32 y1;
		int32 y2;
		int32 source;
		int32 target;
		bool  oneway;  //单向或双向
		bytes32 name;   //道路名称 
		uint path_num;	
		mapping(uint => int32) path; // 道路数组
	}

	//gid->road_info,store real ways
	mapping(uint => road_info) ways;

	// 区域道路结构体,用于存储区域内的道路信息
	struct area_ways{
		uint num;
		// num->gid,store gids of roads in the area
		mapping(uint => uint) ways_list;
	}

	// 对称
	mapping(bytes32 => area_ways) public geo_maps;

	// 存储地图函数，将owner存储为当前发送者
	constructor() public{
		owner = msg.sender;
	}

	// 读取道路信息，返回至前端，通过gid寻找
	function get_road(uint gid) view public returns (int32[] memory road, bytes32 names, int32[] memory path) {
		road = new int32[](7);
		road_info storage single_road = ways[gid];
		path = new int32[](single_road.path_num);
		road[0] = single_road.x1;
		road[1] = single_road.y1;
		road[2] = single_road.x2;
		road[3] = single_road.y2;
		road[4] = single_road.source;
		road[5] = single_road.target;
		if(single_road.oneway){
			road[6] = 1;
		}
		else{
			road[6] = 0;
		}
		names = single_road.name;
		for(uint i=0; i< single_road.path_num; i++){
			path[i] = single_road.path[i];
		}
		
	}

	// 获取对应geohash区域内所有道路信息
	function get_roads(bytes32 hash) view public returns (int32[] memory road, bytes32[] memory names, int32[] memory path) {
		uint num = geo_maps[hash].num;
		uint path_num = 0;
		//different parm in different domain may cause duplicate declare error when compile, maybe a bug
		uint i;

		if(num > 0){
			road = new int32[](8 * num);
			names = new bytes32[]( num );
			uint gid;
			for(i=0; i< num; i++){
				gid = geo_maps[hash].ways_list[i]; 
				road_info storage single_road = ways[gid];
				uint base = i * 8;
				road[base] = int32(gid);
				road[base + 1] = single_road.x1;
				road[base + 2] = single_road.y1;
				road[base + 3] = single_road.x2;
				road[base + 4] = single_road.y2;
				road[base + 5] = single_road.source;
				road[base + 6] = single_road.target;
				path_num = path_num + 1 + single_road.path_num;
				if(single_road.oneway){
					road[base + 7] = 1;
				}
				else{
					road[base + 7] = 0;
				}
				names[i] = single_road.name;
			}	
			path = new int32[](path_num);
			uint pos = 0;
			for(i=0; i< num; i++){
				gid = geo_maps[hash].ways_list[i];
				//may cause duplicate declare, don't know why
				road_info storage single_road2 = ways[gid];
				path[pos++] = int32(single_road2.path_num);
				for(uint j=0; j< single_road2.path_num; j++){
					path[pos++] = single_road2.path[j];
				}
			}
		}
    }

	// 添加一条道路
	function add_road(uint gid, int32 x1, int32 y1, int32 x2, int32 y2, int32 source, int32 target, bool oneway, bytes32 name, int32[] memory path) public restricted {
        ways[gid].x1 = x1;
	    ways[gid].x2 = x2;	
		ways[gid].y1 = y1;
		ways[gid].y2 = y2;
		ways[gid].source = source;
		ways[gid].target = target;
		ways[gid].oneway = oneway;
		ways[gid].name = name;
		uint num = ways[gid].path_num;
		for(uint i=0; i< path.length; i++){
			ways[gid].path[num++] = path[i];
		}
		ways[gid].path_num = num;
    }

	//bind a road to an area 
	function add_area_road(bytes32 hash, uint gid) public restricted {
		//if(ways[gid].x1 > 0){//road exists
			uint num = geo_maps[hash].num++;
			geo_maps[hash].ways_list[num] = gid;
		//}
	}
	
    
}

