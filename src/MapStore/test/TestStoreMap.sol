pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/StoreMap.sol";

contract TestStoreMap {

  function testStoreMap() {
    StoreMap maps = StoreMap(DeployedAddresses.StoreMap());
    //maps.set_road(1,116,38,117,39);
    //uint[] road = maps.get_map(1);
    bytes a = maps.encode_geohash(3990599,11638946);
    Assert.equal(a, "111", "road speed equal");
  }
}
