 /*
 ___  ___  ________  ________  ___  ___  ________  ___       ________  ________  _________  ________  ________     
|\  \|\  \|\   __  \|\   ____\|\  \|\  \|\   __  \|\  \     |\   __  \|\   ____\|\___   ___\\_____  \|\   __  \    
\ \  \\\  \ \  \|\  \ \  \___|\ \  \\\  \ \  \|\ /\ \  \    \ \  \|\  \ \  \___|\|___ \  \_\|____|\ /\ \  \|\  \   
 \ \   __  \ \   __  \ \_____  \ \   __  \ \   __  \ \  \    \ \   __  \ \_____  \   \ \  \      \|\  \ \   _  _\  
  \ \  \ \  \ \  \ \  \|____|\  \ \  \ \  \ \  \|\  \ \  \____\ \  \ \  \|____|\  \   \ \  \    __\_\  \ \  \\  \| 
   \ \__\ \__\ \__\ \__\____\_\  \ \__\ \__\ \_______\ \_______\ \__\ \__\____\_\  \   \ \__\  |\_______\ \__\\ _\ 
    \|__|\|__|\|__|\|__|\_________\|__|\|__|\|_______|\|_______|\|__|\|__|\_________\   \|__|  \|_______|\|__|\|__|
                       \|_________|                                      \|_________|                              
 hashblast3r@gmail.com
 */                                                                                                                  
                                                                                                                   
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Venmo {
  // Define the Owner of the smart contract
  address public owner;

  constructor() {
    owner = msg.sender;
  }

  // Create Struct and Mapping for request, transaction & name
  struct Request {
    address requestor;
    uint256 amount;
    string message;
    string name;
  }

  struct Transaction {
    string action;
    uint256 amount;
    string message;
    address otherPartyAddress;
    string otherPartyName;
  }

  struct User {
    string name;
    bool hasName;
  }

  mapping(address => User) users;
  mapping(address => Request[]) requests;
  mapping(address => Transaction[]) history;

  // Add a name to wallet address
  function addUser(string memory _name) public {
    User storage newUser = users[msg.sender];
    newUser.name = _name;
    newUser.hasName = true;
  }

  // Create a request
  function createRequest(address user, uint256 _amount, string memory _message) public {
    Request memory newRequest;
    newRequest.requestor = msg.sender;
    newRequest.amount = _amount;
    newRequest.message = _message;
    if(users[msg.sender].hasName) {
      newRequest.name = users[msg.sender].name;
    }
    requests[user].push(newRequest);
  }

  // Pay a request
  function payRequest(uint256 _request) public payable {
    require(_request < requests[msg.sender].length, "No such request exists");
    Request[] storage myRequests = requests[msg.sender];
    Request storage payableRequest = myRequests[_request];

    uint256 toPay = payableRequest.amount;
    require(msg.value == (toPay), "Pay the correct amount please");

    payable(payableRequest.requestor).transfer(msg.value);

    addHistory(msg.sender, payableRequest.requestor, payableRequest.amount, payableRequest.message);

    myRequests[_request] = myRequests[myRequests.length-1];
    myRequests.pop();
  }

  function addHistory(address sender, address receiver, uint256 _amount, string memory _message) private {
    Transaction memory newSend;
    newSend.action = "Send";
    newSend.amount = _amount;
    newSend.message = _message;
    newSend.otherPartyAddress = receiver;
    if(users[receiver].hasName) {
      newSend.otherPartyName = users[receiver].name;
    }
    history[sender].push(newSend);

    Transaction memory newReceive;
    newReceive.action = "Receive";
    newReceive.amount = _amount;
    newReceive.message = _message;
    newReceive.otherPartyAddress = sender;
    if(users[sender].hasName) {
      newReceive.otherPartyName = users[sender].name;
    }
    history[receiver].push(newReceive);
  }

  // Get all requests sent to a User
  function getMyRequests(address _user) public view returns(
    address[] memory,
    uint256[] memory,
    string[] memory,
    string[] memory
  ){
    address[] memory addrs = new address[](requests[_user].length);
    uint256[] memory amnt = new uint256[](requests[_user].length);
    string[] memory msge = new string[](requests[_user].length);
    string[] memory nme = new string[](requests[_user].length);

    for(uint i = 0; i < requests[_user].length; i++) {
      Request storage myRequests = requests[_user][i];
      addrs[i] = myRequests.requestor;
      amnt[i] = myRequests.amount;
      msge[i] = myRequests.message;
      nme[i] = myRequests.name;
    } 

    return(addrs, amnt, msge, nme);
  }

  // Get all historic transactions user has been involved with
  function getMyHistory(address _user) public view returns(Transaction[] memory) {
    return history[_user];
  }

  function getUser(address _user) public view returns(User memory) {
    return users[_user];
  }

  // Withdraw fees
}
