# EnergyChain

Blockchain Technologies - Universitat Pompeu Fabra - 2019/20
**Group 7**
Javier Rando Ramírez<br>
Núria Varas Paneque<br>
Sara Estevez Manteiga<br>
Claudia Herron Mulet<br>
Coral Planagumà Colom<br>

---


#### **PROJECT SUMMARY**
This code contains three contracts: EnergyToken, GreenRewardToken and EnergyChain.
The idea of the project is creating a blockchain that allows neighbors to buy/sell their excess of renewable energy. Ideally, all these
behaviours will be automated using IoT to control the input/output of energy. To buy and sell the energy an specific token (EnergyToken) 
is used and also, we have implemented a GreenRewardToken that works as a reward for sustainable behaviours. This last token could be
also integrated within other projects, creating a circular economy trading tool. It cannot be exchanged for regular money but only 
transferred between users. This way, it can only be used within circular economy projects.


#### **DEPLOYMENT STEPS**

You may need to change startTime in EnergyChain to test behaviour. Otherwise, it will be closed

**IMPORTANT**: When compiling, enable optimization or increase gas limit for the contract to work

1. Deploy EnergyToken. It is implements the tokens used to buy and sell renewable energy in the blockchain.
2. Deploy GreenRewardToken. It is a reward token for sustainable behaviours, which can be used in circular economy projects.
3. Deploy EnergyChain using the address of the previously deployed contracts. This is the implementation of our blockchain. 
   It contains all the main behaviours of the network (buy and sell energy between neighbors).
4. The following step is adding the EnergyChain contract as an administrator for the GreenRewardToken. Only authorized users/contracts
   can issue this token. For this, use the addAdmin function within GreenRewardToken and introduce EnergyChain address.

#### **EXECUTION SIMULATION**
Now, we can simulate an interaction with the blockchain. Remember that only the deployer of EnergyChain will be able to perform those operations
with onlyOwner modifier. However, we can also include other addresses as administrators to allow them to create/modify users.

1. Create two users (using two different addresses). One can be both seller and buyer and the other one only buyer.
2. Using the seller account, post a sellOffer for a given amount of energy.
3. Using the buyer account, set a value of Ether for the transaction and buy EnergyToken using buyToken function. 1 Ether = 1 Token.
4. Now that we have EnergyToken in the buyer account, we can buy energy in the EnergyChain. For this, use buyEnergy function.
5. Finally, we can check that the balances in the EnergyToken have been updated and also both addreess have been rewarded for 
   buying/selling energy.
