pragma solidity^0.5.0;

import './DaiToken.sol';
import './DappToken.sol';

contract TokenFarm {
  string public name = "DApp Token Farm";
  DappToken public dappToken;
  DaiToken public daiToken;
  address public owner;

  address[] public stakers;
  mapping(address => uint) public stakingBalance;
  mapping(address => bool) public hasStaked;
  mapping(address => bool) public isStaking;


  constructor(DappToken _dappToken, DaiToken _daiToken) public {
    dappToken = _dappToken;
    daiToken = _daiToken;
    owner = msg.sender;
  }

  // Stake Tokens (Deposit)
  function stakeTokens(uint _amount) public {
    // Require amount greatere than 0
    require(_amount > 0, "amount cannot be 0");

    // Transfer Mock Dai tokens to this contract for staking
    daiToken.transferFrom(msg.sender, address(this), _amount);

    // Update staking balance
    stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

    // Add user to stakers array *only* if they haven't stakes already
    if (!hasStaked[msg.sender]) {
      stakers.push(msg.sender);
    }

    // Update staking status
    isStaking[msg.sender] = true;
    hasStaked[msg.sender] = true;
  }

  // Issuing Tokens (Earn Interest)
  function issueTokens() public {
    // Reassure the owner is the sender. Only owner can call this function
    require(msg.sender == owner, "caller must be the owner");

    for (uint i = 0; i < stakers.length; i++) {
      address recipient = stakers[i];
      uint balance = stakingBalance[recipient];
      if (balance > 0) {
        dappToken.transfer(recipient, balance);
      }
    }
  }


  // Unstaking Tokens (Withdraw)
  function unstakeTokens() public {
    // Fetch the staking balance
    uint balance = stakingBalance[msg.sender];

    // Require amount greater than 0
    require(balance > 0, "staking balance cannot be 0");

    // Transfer Mock DAI tokens from this contract
    daiToken.transfer(msg.sender, balance);

    // Reset staking balance
    stakingBalance[msg.sender] = 0;

    // Update staking status
    isStaking[msg.sender] = false;
  }

}