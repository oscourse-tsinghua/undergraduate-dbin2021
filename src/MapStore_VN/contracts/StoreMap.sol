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

	// 存储地图信息
	struct one_type
	{	
		int32 minzoom;
		bool  oneway;  
        bool  building; 
        bytes32 highway;
        bytes32 name;   //名称 
        bytes32 gtype;
		uint path_num;	
		mapping(uint => bytes32) path;
	}

	//gid->one_type,store real types
	mapping(uint => one_type) types;

	// 区域道路结构体,用于存储区域内的道路信息
	struct  area_types{
		uint num;
		// num->gid,store gids of roads in the area
		mapping(uint => uint) types_list;
	}

	// 对称
	mapping(bytes32 =>  area_types) public geo_maps;

	// 存储地图函数，将owner存储为当前发送者
	constructor() public{
		owner = msg.sender;
	}

	// 读取道路信息，返回至前端，通过gid寻找
	function get_onetype(uint gid) view public returns (int32[] memory feature, bytes32 names, bytes32 highway, bytes32 gtype, bytes32[] memory path) {
		feature = new int32[](3);
		one_type storage single_type = types[gid];
		path = new bytes32[](single_type.path_num);
		feature[0] = single_type.minzoom;
		if(single_type.oneway){
			feature[1] = 1;
		}
		else{
			feature[1] = 0;
		}
        if(single_type.building){
			feature[2] = 1;
		}
		else{
			feature[2] = 0;
		}
		names = single_type.name;
		highway = single_type.highway;
		gtype = single_type.gtype;
		for(uint i=0; i< single_type.path_num; i++){
			path[i] = single_type.path[i];
		}
		
	}

	// 获取对应geohash区域内所有道路信息
	function get_types(bytes32 hash) view public returns (int32[] memory feature, bytes32[] memory names, bytes32[] memory highways, bytes32[] memory gtypes, bytes32[] memory path) {
		uint num = geo_maps[hash].num;
		uint path_num = 0;
		//different parm in different domain may cause duplicate declare error when compile, maybe a bug
		uint i;

		if(num > 0){
			feature = new int32[](4 * num);
			names = new bytes32[]( num );
			highways = new bytes32[]( num );
			gtypes = new bytes32[]( num );
			uint gid;
			for(i=0; i < num; i++){
				gid = geo_maps[hash].types_list[i]; 
				one_type storage single_type = types[gid];
				uint base = i * 4;
				feature[base] = int32(gid);
				feature[base + 1] = single_type.minzoom;
				if(single_type.oneway){
					feature[base + 2] = 1;
				}
				else{
					feature[base + 2] = 0;
				}
				if(single_type.building){
					feature[base + 3] = 1;
				}
				else{
					feature[base + 3] = 0;
				}
				path_num = path_num + 1 + single_type.path_num;
				names[i] = single_type.name;
				highways[i] = single_type.highway;
				gtypes[i] = single_type.gtype;
			}
			path = new bytes32[](path_num);
			uint pos = 0;
			for(i=0; i< num; i++){
				gid = geo_maps[hash].types_list[i];
				//may cause duplicate declare, don't know why
				one_type storage single_type2 = types[gid];
				path[pos++] = bytes32(single_type2.path_num);
				for(uint j=0; j< single_type2.path_num; j++){
					path[pos++] = single_type2.path[j];
				}
			}
		}
    }

	// 添加一条
	function add_onetype(uint gid, int32 minzoom, bool oneway, bool building, bytes32 highway, bytes32 name, bytes32 gtype, bytes32[] memory path) public restricted {
		types[gid].minzoom = minzoom;
	    types[gid].oneway = oneway;	
		types[gid].building = building;
		types[gid].highway = highway;
		types[gid].name = name;
		types[gid].gtype = gtype;

		uint num = types[gid].path_num;
		for(uint i=0; i< path.length; i++){
			types[gid].path[num++] = path[i];
		}
		types[gid].path_num = num;
    }

	//bind a line to an area 
	function add_area_line(bytes32 hash, uint gid) public restricted {
			uint num = geo_maps[hash].num++;
			geo_maps[hash].types_list[num] = gid;
	} 
}

