pragma solidity 0.5.1;

/*
Contract used to implement our EnergyChain blockchain. It will contain all the main behaviours of our network.
It will allow users to sell and buy energy from neighbors.
*/
contract EnergyChain {
    
    struct Client {
        string firstName;
        string surname;
        string streetAddress;
        string ID;
        bool isSeller;
        bool isBuyer;
        address payable btAddress;
        uint256 numberOffers; /* Number of energyOffers created by a client*/
        uint256 energySold;
        uint256 energyBought;
        bool exists;
        mapping(uint256 => uint256) energySellingOffers; /*Store the id of a client energyoffers*/
    }
    
    struct EnergyOffer {
        address payable seller;
        uint256 initialEnergy; // This allows us to store the amount of energy of our transactions 
        uint256 energyAvailable;
        bool isActive;
    }
    
    mapping (address => Client) private clients;
    mapping(uint256 => EnergyOffer) public energyOffers;
    mapping(address => bool) private administrators; // Stores if an address has admin permissions
    
    uint256 public clientsCount;
    uint256 public offersCount;
    uint256 public firstAvailableOffer;
    address private owner;
    uint256 startTime;
    address public _EnergyToken;
    address public _GreenRewardToken;
    uint256 public priceKW;
    bytes private greenRewardPassword;
    
    // Construct our EnergyChain given the tokens that will be used and the price of electricity
    constructor(address _energytoken, address _greenrewardtoken, uint256 _priceKW) public {
        //startTime = 1596265200; // 1 of august of 2020 (PoC launch)
        
        // To test complete behaviour choose this StartTime that is previous to current time
        startTime = 1569880800;
        
        _EnergyToken = _energytoken;
        _GreenRewardToken = _greenrewardtoken;
        owner = msg.sender;
        administrators[msg.sender] = true;
        priceKW = _priceKW;
        clientsCount = 0;
    }
    
    // Modifier that determine a starting date for a function
    modifier onlyWhileOpen() {
        require(block.timestamp >= startTime);
        _;
    }
    
    // Modifier for only administrator execution
    modifier onlyAdmin() {
        require(administrators[msg.sender] == true, "You cannot execution this function. Access restricted to administrator.");
        _;
    }
    
    // Modifier for only owner execution
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner of the contract can execute this function.");
        _;
    }

    
    // Only administrator can include new clients in the blockchain after verifying information to avoid
    // malicious behaviour and duplicate accounts
    function addClient(address payable _address, string memory _firstName, string memory _surname, string memory _streetAddress,
    string memory _ID, bool _isSeller, bool _isBuyer) public onlyAdmin {
        require (clients[_address].exists != true, "This user already exists");
        clients[_address] = Client(_firstName, _surname, _streetAddress, _ID, _isSeller, _isBuyer, _address, 0, 0, 0, true);
        clientsCount += 1;
        
    }

    
    // Function used to modify an existing client. Only can be executed by administrator.
    function modifyClient(address payable _address, string memory _firstName, string memory _surname, string memory _streetAddress,
    string memory _ID, bool _isSeller, bool _isBuyer) public onlyAdmin {
        
        clients[_address].btAddress = _address;
        clients[_address].firstName = _firstName;
        clients[_address].surname = _surname;
        clients[_address].streetAddress = _streetAddress;
        clients[_address].ID = _ID;
        clients[_address].isSeller = _isSeller;
        clients[_address].isBuyer = _isBuyer;
        
    }
    
    // The implementation of this function is far beyond the scope of this project. It must be in charge of executing the
    // necessary instructions to physically transport energy from seller to buyer.
    // Warnings showing up when compiling are because the function is not implemented.
    function sendEnergy (address _from, address _to, uint256 amount) private returns (string memory) {
        return ("Energy successfully sent to the buyer");
    }
    
    // Function to buy energy. We use first in first out approach. We will buy from the oldest to the newest offer.
    // It is important to take into account that one single offer may not cover the full energy requirements and that we 
    // may just buy part of an offer
    function buyEnergy(uint256 amount) public payable returns(string memory) {
        
        require(firstAvailableOffer < offersCount, "There is no available energy in this moment. Please, try again later.");
        uint256 need = amount;
        uint256 i = firstAvailableOffer;
        
        EnergyToken energytoken = EnergyToken(address(_EnergyToken));
        GreenRewardToken rewardToken = GreenRewardToken(address(_GreenRewardToken));
        
        while (i<offersCount) {
            
            if (energyOffers[i].isActive) {
                
                // The offer has more energy than we need
                if (energyOffers[i].energyAvailable > need) {
                    energytoken.transfer(energyOffers[i].seller, need*priceKW);
                    sendEnergy(energyOffers[i].seller, tx.origin, need);
                    rewardToken.reward(need, energyOffers[i].seller); // Reward seller
                    clients[energyOffers[i].seller].energySold += need; // Update seller sold energy
                    energyOffers[i].energyAvailable -= need;
                    firstAvailableOffer = i;
                    need = 0;
                    break;
                    
                // The offer has less than the enery than we need
                } else if  (energyOffers[i].energyAvailable < need) {
                    energytoken.transfer(energyOffers[i].seller, energyOffers[i].energyAvailable*priceKW);
                    sendEnergy(energyOffers[i].seller, tx.origin, energyOffers[i].energyAvailable);
                    rewardToken.reward(energyOffers[i].energyAvailable, energyOffers[i].seller); // Reward seller
                    clients[energyOffers[i].seller].energySold += energyOffers[i].energyAvailable; // Update seller sold energy
                    need = need-energyOffers[i].energyAvailable;
                    energyOffers[i].energyAvailable = 0;
                    energyOffers[i].isActive = false;
                    firstAvailableOffer = i+1;
                
                // The offer has exactly the energy we need
                } else {
                    energytoken.transfer(energyOffers[i].seller, need*priceKW);
                    sendEnergy(energyOffers[i].seller, tx.origin, need);
                    rewardToken.reward(need, energyOffers[i].seller); // Reward seller
                    clients[energyOffers[i].seller].energySold += need; // Update seller sold energy
                    need = 0; // We don't need more energy since we acquired all we needed
                    energyOffers[i].energyAvailable = 0; // There is no more energy available
                    energyOffers[i].isActive = false; // This offer is empty so it is not active anymore
                    firstAvailableOffer = i+1; // Since this offer is empty, move available pointer to the next one
                    break;
                }
            }
            
            i++;
        }
        
        clients[tx.origin].energyBought += amount-need; // Update our bought energy
        rewardToken.reward(amount-need, tx.origin); // Reward buyer
        
        if (need > 0) {
            return("There was not enough energy available to fulfill your entire request. Please, try again later.");
        } else {
            return("Energy successfully acquired");
        }
    }
    
   // Function to post a selling offer. There is a limit for each offer to avoid someone coping the market.
    function postSellOffer(uint256 amount) public {
        require(clients[msg.sender].isSeller, "You are not allowed to sell energy");
        energyOffers[offersCount] = EnergyOffer(msg.sender, amount, amount, true);
        offersCount++;
    }
    
    // The owner of an offer should be able to delete it at any moment. It will remain in the mapping to keep track of
    // every operation but it will set to not active.
    function deletetSellOffer(uint256 offerId) public {
        require(energyOffers[offerId].seller == msg.sender, "This offer is not yours. You cannot delete it");
        require(energyOffers[offerId].isActive == true, "The offer is not active. You cannot delete it.");
        energyOffers[offerId].isActive = false;
    }
    
    // Return the number of offers that the message sender has performed
    function getEnergySold() public view returns(uint256) {
        return clients[msg.sender].energySold;
    }
    
    // Return the number of offers that the message sender has performed
    function getEnergyBought() public view returns(uint256) {
        return clients[msg.sender].energyBought;
    }
    
    // Return the number of offers that the message sender has performed
    function modifyEnergyPrice(uint256 _priceKW) public onlyOwner {
        priceKW = _priceKW;
    }
    
    // Include an administrator for the token so that she/he can issue rewards
    function addAdmin (address _address) public onlyOwner {
        administrators[_address] = true;
    }
    
    
}