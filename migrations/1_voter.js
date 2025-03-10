var Voter = artifacts.require("VoterContract.sol");

module.exports = function(deployer) {
    deployer.deploy(Voter);
};