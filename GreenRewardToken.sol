pragma solidity 0.5.1;

/*
This token is designed as a reward for sustainable behaviours. Therefore, it cannot be bought 
but only received as a reward from the system. It can later be used to buy stuff included in the circular economy project.
*/
contract GreenRewardToken {

    string public name;
    mapping(address => uint256) public balances;
    mapping(address => bool) private administrators; // Stores if an address has admin permissions
    address private owner;

    //Consttructor of the GreenRewardToken contract
    constructor() public {
        name = "GreenRewardToken";
        owner = msg.sender;
    }

    // Include an administrator for the token so that she/he can issue rewards
    function addAdmin (address _address) public {
        require(msg.sender == owner, "You cannot add administrators because you are not the owner of this contract.");
        administrators[_address] = true;
    }

    // Remove one existing administrator from the contract
    function removeAdmin (address _address) public {
        require(msg.sender == owner, "You cannot add administrators because you are not the owner of this contract.");
        administrators[_address] = false;
    }

    // This function can only be called by administrator to reward a user with tokens.
    function reward (uint256 amount, address user) public {
        require(administrators[msg.sender] == true, "You cannot reward with GreenToken because you are not administrator.");
        balances[user] += amount;
    }

    // Function used to pay with GreenRewardToken
    function pay(address receiver, uint numTokens) public {
        require(numTokens <= balances[tx.origin], "You don't have enough tokens to pay. Please, buy Token before.");
        balances[tx.origin] = balances[tx.origin] - numTokens;
        balances[receiver] = balances[receiver] + numTokens;
    }

}