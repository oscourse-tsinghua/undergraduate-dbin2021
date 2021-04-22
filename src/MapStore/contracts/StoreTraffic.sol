pragma solidity ^0.5.16;

contract StoreTraffic{
	
	uint max_threshold = 10;
	uint min_threshold = 3;
	
	uint smooth_delta = 10; //平滑时每相差一个时间段减去的权重(%,暂不支持float, double)
	uint aggregate_alpha = 50; //汇总路况的权重
	
	uint max_seq = 1440; //24*60
	uint max_speed = 3333;
	
	//本地路况数量大于threshold时汇总路况并更新。
	struct tmp_traffics{
		mapping(uint => uint) tmp_speed;
		uint counter;
	}
	
	struct traffic{
		uint date;
		uint seq;  // 1分钟一个时间段，只存储最新的路况
		uint speed;   // 道路速度*100，目前solidity不支持float/double
		tmp_traffics local_traffic;
	}
	mapping(uint => traffic) traffics;//道路id->路况

	//event traffic_change(uint road_id);
	
	//本地延迟数量大于threshold时汇总延迟并更新。
	struct tmp_delays{
		mapping(uint => uint) tmp_delaytime;
		uint counter;
	}
	
	struct switching_delay{
		uint date;
		uint seq;  // 1分钟一个时间段，只存储最新的延迟
		uint delay_time;//转向延迟时间，单位s
		tmp_delays local_delaytime;	
		mapping (uint => uint) map;
	}
	switching_delay[2][] delays;
	
	function smooth_delays(uint gid_A,uint gid_B,uint delay_time, uint pre_seq, uint seq, uint pre_date, uint date) public{
		if(delay_time > max_speed){
			return;
		}
		uint diff_seq = 0;
		uint alpha;
		if(pre_date == date){
			diff_seq = (seq - pre_seq)>0 ? seq-pre_seq : pre_seq - seq;
			alpha = smooth_delta + smooth_delta* diff_seq;
		}
		else if(date - pre_date ==1){
			diff_seq = seq + max_seq - pre_seq;
			alpha = smooth_delta + smooth_delta* diff_seq;
		}
		else{
			alpha = 100;
		}
		//更新延迟信息
		delays[gid_A][gid_B].seq = seq;
		delays[gid_A][gid_B].date = date;
		delays[gid_A][gid_B].delay_time = delays[gid_A][gid_B].delay_time * (100- alpha)/ 100 + delay_time * alpha/ 100;
		
	}

	function aggregate_delays(uint gid_A,uint gid_B) public{
		//对所有延迟进行排序并取中位数
		uint counter = delays[gid_A][gid_B].local_delaytime.counter;
		if(counter >= min_threshold){
			uint temp;
			for(int32 i=0; i< int32(counter); i++){
				temp = delays[gid_A][gid_B].local_delaytime.tmp_delaytime[uint(i)];
				int32 j= i-1;
				while(j>-1 && temp < delays[gid_A][gid_B].local_delaytime.tmp_delaytime[uint(j)]){
					delays[gid_A][gid_B].local_delaytime.tmp_delaytime[uint(j+1)] = delays[gid_A][gid_B].local_delaytime.tmp_delaytime[uint(j)];
					j--;
				}
				delays[gid_A][gid_B].local_delaytime.tmp_delaytime[uint(j+1)] = temp;
			}
		}
		delays[gid_A][gid_B].delay_time = delays[gid_A][gid_B].delay_time * (100-aggregate_alpha)/ 100 + 
			delays[gid_A][gid_B].local_delaytime.tmp_delaytime[counter/2] * aggregate_alpha/ 100;
			
		//清空临时延迟
		delays[gid_A][gid_B].local_delaytime.counter = 0;
	}
	
	function add_switching_delay(uint gid_A,uint gid_B, uint delay_time, uint seq, uint date) public{
		//对路口添加转向延迟
		
		uint pre_seq  = delays[gid_A][gid_B].seq;
		uint pre_date = delays[gid_A][gid_B].date;		
		
		uint counter;
		
		//第一次转向延迟
		if(pre_date == 0){
			//添加转向延迟
			delays[gid_A][gid_B].date = date;
			delays[gid_A][gid_B].seq = seq;
			delays[gid_A][gid_B].delay_time = delay_time;
		}
		//转向延迟比当前转向延迟新
		else if(date > pre_date || date == pre_date && seq > pre_seq){
			//对前一个时间段的延迟进行汇总更新
			aggregate_delays(gid_A,gid_B);
			//平滑并更新延迟
			smooth_delays(gid_A,gid_B, delay_time, pre_seq, seq, pre_date, date);
			//添加到本地延迟
			delays[gid_A][gid_B].local_delaytime.tmp_delaytime[0] = delay_time;
			delays[gid_A][gid_B].local_delaytime.counter++;
		}
		//允许早两个时间段的延迟提交
		else if(date == pre_date && pre_seq - seq <= 2){
			//添加到本地延迟
			counter = delays[gid_A][gid_B].local_delaytime.counter;
			delays[gid_A][gid_B].local_delaytime.tmp_delaytime[counter++] = delay_time;
			//本地延迟数量大于阈值，汇总延迟并更新
			if(counter > max_threshold){
				aggregate_delays(gid_A,gid_B);
			}
			//平滑并更新延迟
			else{
				smooth_delays(gid_A,gid_B, delay_time, pre_seq, seq, pre_date, date);
			}
		}
		
	}

	
	function aggregate_traffic(uint road_id) public{
		//对所有速度进行排序并取中位数
		uint counter = traffics[road_id].local_traffic.counter;
		if(counter >= min_threshold){
			uint temp;
			for(int32 i=0; i< int32(counter); i++){
				temp = traffics[road_id].local_traffic.tmp_speed[uint(i)];
				int32 j= i-1;
				while(j>-1 && temp < traffics[road_id].local_traffic.tmp_speed[uint(j)]){
					traffics[road_id].local_traffic.tmp_speed[uint(j+1)] = traffics[road_id].local_traffic.tmp_speed[uint(j)];
					j--;
				}
				traffics[road_id].local_traffic.tmp_speed[uint(j+1)] = temp;
			}
		}
		traffics[road_id].speed = traffics[road_id].speed * (100-aggregate_alpha)/ 100 + 
			traffics[road_id].local_traffic.tmp_speed[counter/2] * aggregate_alpha/ 100;
			
		//清空临时路况	
		traffics[road_id].local_traffic.counter = 0;
	}
	
	function smooth_traffic(uint road_id, uint speed, uint pre_seq, uint seq, uint pre_date, uint date) public{
		if(speed > max_speed){
			return;
		}
		uint diff_seq = 0;
		uint alpha;
		if(pre_date == date){
			diff_seq = (seq - pre_seq)>0 ? seq-pre_seq : pre_seq - seq;
			alpha = smooth_delta + smooth_delta* diff_seq;
		}
		else if(date - pre_date ==1){
			diff_seq = seq + max_seq - pre_seq;
			alpha = smooth_delta + smooth_delta* diff_seq;
		}
		else{
			alpha = 100;
		}
		//更新路况信息
		traffics[road_id].seq = seq;
		traffics[road_id].date = date;
		traffics[road_id].speed = traffics[road_id].speed * (100- alpha)/ 100 + speed * alpha/ 100;
		
	}
	
	function get_traffic(uint road_id) view public returns (uint speed, uint seq) {
		speed = traffics[road_id].speed;
		seq = traffics[road_id].seq;
    }	

	function add_traffic(uint road_id, uint speed, uint seq, uint date) public{
		uint pre_seq  = traffics[road_id].seq;
		uint pre_date = traffics[road_id].date;
		
		uint counter;
		//第一次路况
		if(pre_date == 0){
			//添加到本地路况
			counter = traffics[road_id].local_traffic.counter;
			traffics[road_id].local_traffic.tmp_speed[counter++] = speed;
			traffics[road_id].seq = seq;
			traffics[road_id].date = date;
			traffics[road_id].speed;
		}
		//路况比当前路况新
		else if(date > pre_date || date == pre_date && seq > pre_seq){
			//对前一个时间段的路况进行汇总更新
			aggregate_traffic(road_id);
			//平滑并更新路况
			smooth_traffic(road_id, speed, pre_seq, seq, pre_date, date);
			//添加到本地路况
			traffics[road_id].local_traffic.tmp_speed[0] = speed;
			traffics[road_id].local_traffic.counter++;
		}
		//允许早两个时间段的路况提交
		else if(date == pre_date && pre_seq - seq <= 2){
			//添加到本地路况
			counter = traffics[road_id].local_traffic.counter;
			traffics[road_id].local_traffic.tmp_speed[counter++] = speed;
			//本地路况数量大于阈值，汇总路况并更新
			if(counter > max_threshold){
				aggregate_traffic(road_id);
			}
			//平滑并更新路况
			else{
				smooth_traffic(road_id, speed, pre_seq, seq, pre_date, date);
			}
		}

    }
	
}

