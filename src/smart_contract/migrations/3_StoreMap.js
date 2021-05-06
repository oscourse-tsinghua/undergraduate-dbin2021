// const Migrations = artifacts.require("Migrations");
const StoreMap = artifacts.require("StoreMap");

module.exports = function (deployer) {
//   deployer.deploy(Migrations);
  deployer.deploy(StoreMap);
};
