pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/StoreTraffic.sol";

contract TestStoreTraffic {

  function testStoreTraffic() {
    StoreTraffic traffic = StoreTraffic(DeployedAddresses.StoreTraffic());
    traffic.set_traffic(1,100,288);

    Assert.equal(traffic.get_traffic(1), 100, "road speed equal");
  }
}
