pragma solidity ^0.4.24;

import "./safemath.sol";

contract NationCreation {

  using SafeMath for uint256;

  event NewNation(uint id, string name);

  address owner;

  uint cooldownTime = 1 days;
  //Unsure if this works or not
  string[] private governmentTypes = ["Republic", "Monarchy"];

  struct Nation {
    string name;
    uint id;
    uint8 govTypeVal;

    uint32 basePopulation; //K (thousands)
    uint32 baseManpower; //K

    uint8 percentConscription; //percent
    uint8 percentPopulationGrowth; //percent per day

    uint32 lastUpdate;
  }

  Nation[] nations;

  mapping (address => Nation) getNation;

  constructor {
    owner = msg.sender;
  }

  function createNation(string _name, uint8 govTypeVal;) {
    //ID can never be 0
    require(getNation[msg.sender].id == 0);
    //This is where the new nation object is instantiated
    getNation[msg.sender] = Nation(_name, nations.length + 1, _govTypeVal, 1000, 50, 5, 1, now);
    nations.push(getNation[msg.sender]);
    NewNation(nations.length, _name);
  }

  modifier onlyOwner {
      require(msg.sender == owner);
      _;
  }

  function destroy() onlyOwner {
      selfdestruct(owner);
  }

  function () payable {}
}

contract NationAdministration is NationCreation {

  function totalPopulation(address _address) internal view returns (uint256) {
    return (uint256(getNation[_address].basePopulation)
           .mul((100 + uint256(getNation[_address].percentPopulationGrowth)) ** (now.sub(uint256(getNation[_address].lastUpdate))).div(1 days)))
           .div(100 ** (now.sub(uint256(getNation[_address].lastUpdate))).div(1 days))
           .add(uint256((getNation[_address].baseManpower)));
  }

  function getPopulation(address _address) view returns (uint256) {
    return (totalPopulation(_address).sub(getManpower(_address)));
  }

  function getManpower(address _address) view returns (uint256) {
    return (uint256(getNation[_address].baseManpower)
            .add((totalPopulation(_address).sub(uint256(getNation[_address].basePopulation).add(uint256((getNation[_address].baseManpower)))))
            .mul(uint256(getNation[_address].percentConscription)).div(100)));
  }

  function updateBases(_address) internal {
    require(now >= getNation[_address].lastUpdate + 1 days);
    getNation[_address].baseManpower = uint32(getManpower(_address));
    getNation[_address].basePopulation = uint32(getPopulation(_address));
    getNation[_address].lastUpdate = now;
  }

  function changeConscriptionLaw(uint _percent) {
    require(now >= getNation[msg.sender].lastUpdate + 1 days);
    require (_percent <= 40 && _percent >= 1);
    getNation[msg.sender].percentConscription = uint8(_percent);
    getNation[msg.sender].baseManpower = uint32((uint256(getNation[_address].baseManpower).add(uint256(getNation[msg.sender].basePopulation)))
    .mul(uint256(getNation[_address].percentConscription)).div(100));
    updateBases(msg.sender);
    //Update the baseManpower to include the new percentage
  }
}
