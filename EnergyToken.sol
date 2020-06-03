pragma solidity 0.5.1;

/* 
This will be Token used to buy and sell renawable energy in the blockchain.
Anyone can acquire these tokens paying with Ethereum.
*/
contract EnergyToken {
    
    string public name;
    mapping(address => uint256) public balances;
    uint256 public exchange_rate;
    address private owner;
    
    // Constructor function of the EnergyToken conctract
    constructor() public {
        name = "EnergyToken";  
        exchange_rate = 10**18; // 1 ether = 1 token
        owner = msg.sender;
    }
    
    // Obtain tokens in exchange for ethereum
    function buyToken () public payable {
        require(msg.value % 1 ether == 0, "Insert a value of ETH greater than 0 to exchange");
        balances[tx.origin] += msg.value/exchange_rate;
    }
    
    // Transfer tokens to other address
    function transfer(address receiver, uint numTokens) public {
          require(numTokens <= balances[tx.origin], "You don't have enough tokens to pay for this energy. Please, buy EnergyToken before.");
          balances[tx.origin] = balances[tx.origin] - numTokens;
          balances[receiver] = balances[receiver] + numTokens;
    }
    
    // Change exchange rate of the token. Only allowed for the owner of the contract.
    function changeExchangeRate(uint256 _exchangeRate) public {
          require(msg.sender == owner, "You don't have permissions to modify the Exchange Rate.");
          exchange_rate = _exchangeRate;
    }
    
}