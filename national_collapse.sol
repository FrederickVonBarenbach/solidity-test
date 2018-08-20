pragma solidity ^0.4.24;

import "./safemath.sol";

contract NationCreation {

  using SafeMath for uint256;

  event NewNation(uint id, string name);

  address owner;

  uint coolDownTime = 1 days;
  //Unsure if this works or not
  string[] private governmentTypes = ["Republic", "Monarchy"];

  struct Nation {
    string name;
    uint id;
    uint8 govTypeVal;
    uint32 population; //In K (thousands)
    uint8 populationGrowth; //Per day
    uint16 lastUpdate;
  }

  Nation[] nations;

  mapping (address => Nation) ownerToNation;

  constructor {
    owner = msg.sender;
  }

  function createNation (string _name, uint8 govTypeVal;) {
    //ID can never be 0
    require(ownerToNation[msg.sender].id == 0);
    //This is where the new nation object is instantiated
    ownerToNation[msg.sender] = Nation(_name, nations.length + 1, _govTypeVal)
    nations.push(ownerToNation[msg.sender]);
    NewNation(nations.length, _name)
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

  //This only checks sender's population
  //If attacking nation that hasn't updated population in long time the contract will need to check the defender's population for the owner
  function updatePopulation () {
    require(ownerToNation[msg.sender].lastUpdate == now.sub(coolDownTime))
    ownerToNation[msg.sender].lastUpdate = now;
    ownerToNation[msg.sender].population = ownerToNation[msg.sender].population
    .add(ownerToNation[msg.sender].populationGrowth.mul(now.sub(ownerToNation[msg.sender].lastUpdate))
    .div(1 days));
  }

  //Perhaps instead of population we can use manpower so that it doesn't need to be updated when the nation is being attacked?
  //
  //Updating costs gas therefore it would make more sense if instead of a physical population, it used a base population and
  //a casualities and the total population is calculated using a pure function which doesn't cost gas.
}
