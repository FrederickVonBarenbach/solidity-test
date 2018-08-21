var nationalCollapse;
var userAccount;

function startApp() {
  var nationalCollapseAddress = "YOUR_CONTRACT_ADDRESS";
  nationalCollapse = new web3js.eth.Contract(nationalCollapseABI, nationalCollapseAddress);

  var accountInterval = setInterval(function() {
    // Check if account has changed
    if (web3.eth.accounts[0] !== userAccount) {
      userAccount = web3.eth.accounts[0];
      // Call some function to update the UI with the new account
      //updateInterface();
    }
  }, 100);
}

function createNation(name, govTypeVal) {
  // This is going to take a while, so update the UI to let the user know
  // the transaction has been sent
  console.log("Creating new nation on the blockchain.");
  // Send the tx to our contract:
  return nationalCollapse.methods.createNation(name, govTypeVal)
  .send({ from: userAccount })
  .on("receipt", function(receipt) {
    console.log("Successfully created " govTypeVal + "of " + name + ".");
    // Transaction was accepted into the blockchain, let's redraw the UI
  })
  .on("error", function(error) {
    // Do something to alert the user their transaction has failed
    console.log(error);
  });
}

function updatePopulation() {
  return nationalCollapse.methods.getPopulation(userAccount).call()
}

function updateManpower() {
  return nationalCollapse.methods.getManpower(userAccount).call()
}

function getNationDetails() {
  return nationalCollapse.methods.ownerToNation(userAccount).call()
}

window.addEventListener('load', function() {

  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    // Use Mist/MetaMask's provider
    web3js = new Web3(web3.currentProvider);
  } else {
    // Handle the case where the user doesn't have web3. Probably
    // show them a message telling them to install Metamask in
    // order to use our app.
  }

  // Now you can start your app & access web3js freely:
  startApp()

})
