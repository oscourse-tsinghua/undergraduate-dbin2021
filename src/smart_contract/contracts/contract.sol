pragma solidity ^0.5.16;

contract Contract{
    // 用户结构体
    struct user{
        string uuid; //用户id,唯一标识码
        uint num;   //相当于下面数据列表的长度
        bool isUsed; //判断id是否在用
        uint status;
        mapping(uint => uint) latOri;  //原始纬度
        mapping(uint => uint) lonOri;  //原始经度
        mapping(uint => uint) latFix;  //修正纬度
        mapping(uint => uint) lonFix;  //修正经度
        mapping(uint => uint) time;   //时间
        int quality;           //用户信誉值
    }
    
    user tempuser; //user的一个实例，一个临时的记录
    
    //定义一个映射表，将uuid字符串与user结构体联系起来
    mapping(string => user) users;
    
    /***
    计算信誉值
    ***/
    function revalue(string memory uuid) public { // memory暂存内存，使用开销相对较小
        int quality = users[uuid].quality;
        uint num = users[uuid].num;
        uint dx; //经度差
        uint dy; //纬度差
        //计算差，且保证结果为正
        if (users[uuid].latOri[num] >= users[uuid].latFix[num]) {
            dy = users[uuid].latOri[num] - users[uuid].latFix[num];
        } else {
            dy = users[uuid].latFix[num] - users[uuid].latOri[num];
        }

        if (users[uuid].lonOri[num] >= users[uuid].lonFix[num]) {
            dx = users[uuid].lonOri[num] - users[uuid].lonFix[num];
        } else {
            dx = users[uuid].lonFix[num] - users[uuid].lonOri[num];
        }
        if (4 * dx * dx + dy * dy <= 8) {
            quality = quality + 1;
        }
        if (num % 10 == 9) {
            quality = quality + 1;
        }
        //本次距上次提交数据时间间隔1min、10min、20min信誉值进行减1、20、100
        if ((num > 1) && (users[uuid].time[num] - users[uuid].time[num - 1] > 60)) {
            quality = quality - 1;
        }
        if ((num > 1) && (users[uuid].time[num] - users[uuid].time[num - 1] > 600)) {
            quality = quality - 20;
        }
        if ((num > 1) && (users[uuid].time[num] - users[uuid].time[num - 1] > 1200)) {
            quality = quality - 100;
        }
        
        /*if (num > 1) {
            if (users[uuid].latFix[num] >= users[uuid].latFix[num-1]) {
                dy = users[uuid].latFix[num] - users[uuid].latFix[num-1];
            } else {
                dy = users[uuid].latFix[num-1] - users[uuid].latFix[num];
            }
            if (users[uuid].lonFix[num] >= users[uuid].lonFix[num-1]) {
                dx = users[uuid].lonFix[num] - users[uuid].lonFix[num-1];
            } else {
                dx = users[uuid].lonFix[num-1] - users[uuid].lonFix[num];
            }
            if ((((users[uuid].time[num] - users[uuid].time[num - 1]) * 40) ** 2) < 
                ((dx * 30) ** 2 + (dy * 20) ** 2)) {
                quality = quality - 100;
            }
        }*/
        
        
        if (quality > 100) {
            quality = 100;
        }
        if (quality < 0) {
            quality = 0;
        }
        users[uuid].quality = quality;
        
        /*
        uint quality = tempuser.quality;
        if (tempuser.num == 1) {
            
        }
        
        tempuser.quality = quality + 1;
        */
    }
    
    function getQuality(string memory uuid) view public  returns (int) {
        if (!users[uuid].isUsed) {
            return 0;
        }
        return users[uuid].quality;
        
        
        //if (!tempuser.isUsed) {
        //    return 0;
        //}
        //return tempuser.quality;
    }
    //返回位置和时间数据
    function getSinglePos(string memory uuid) public view returns (uint, uint, uint, uint, uint) {
        uint num = users[uuid].num;
        return (users[uuid].latOri[num], users[uuid].lonOri[num], users[uuid].latFix[num], users[uuid].lonFix[num], users[uuid].time[num]);
        
        //num = tempuser.num;
        //return (tempuser.latOri[num], tempuser.lonOri[num], tempuser.latFix[num], tempuser.lonFix[num], tempuser.time[num]);
        
    }
     
    function setSinglePos(string memory uuid, uint time, uint _latOri, uint _lonOri,  uint _latFix, uint _lonFix) public {
       //初始化
       if (!users[uuid].isUsed) {
           users[uuid].isUsed = true;
           users[uuid].num = 0;
           users[uuid].status = 1;
           users[uuid].quality = 0;
       }
       //设置users里面每个num对应的各项属性
       uint num = users[uuid].num + 1;
       users[uuid].num = num;
       users[uuid].time[num] = time;
       users[uuid].latOri[num] = _latOri;
       users[uuid].lonOri[num] = _lonOri;
       users[uuid].latFix[num] = _latFix;
       users[uuid].lonFix[num] = _lonFix;
       revalue(uuid);
   }   
}