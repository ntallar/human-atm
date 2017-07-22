var HumanATM = artifacts.require("./HumanATM.sol");

module.exports = function(deployer) {
  deployer.deploy(HumanATM);
};
