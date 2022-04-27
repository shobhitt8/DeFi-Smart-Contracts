pragma solidity ^0.5.0;

import './RWD.sol';
import './Tether.sol';

contract DecentralBank{
    string public name='Decentral Bank';
    address public owner;
    Tether public tether;
    RWD public rwd;

    address[] public stakers;

    mapping(address => uint) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    constructor(RWD _rwd, Tether _tether) public{
        rwd=_rwd;
        tether=_tether;
        owner = msg.sender;
    }

    //staking function
    function depositTokens(uint _amount) public {

        //require staking amount to be greater than zero
         require(_amount > 0,'amount cannot be 0');

        //Transfer tether tokens to this contract address for staking
        tether.transferFrom(msg.sender, address(this), _amount);

        //Update Staking Balance
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        if(!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        // Update Staking Balance afer process is completed
          isStaking[msg.sender] = true;
          hasStaked[msg.sender] = true;
    }

    //unstake tokens
    function unstakeTokens() public{
        uint balance = stakingBalance[msg.sender];
        //Amount should be greater than 0 else it can't be staked 
        require(balance > 0,'staking balance cannot be less than 0');

        //transfer the tokens to specified contract from bank
        tether.transfer(msg.sender, balance);

        //reset staking balance after the process is done
        stakingBalance[msg.sender] = 0;

        //update Staking status
        isStaking[msg.sender] = false;
    }

    //issue tokens
    function issueTokens() public {
        //only owner could issue reward tokens
        require(msg.sender == owner, 'caller must be the owner');

          for(uint i=0; i<stakers.length; i++){
              address receip = stakers[i];
              uint balance = stakingBalance[receip] / 9; 
              if(balance > 0){
                  rwd.transfer(receip, balance);
              }
          }
    }

}