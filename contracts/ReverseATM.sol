pragma solidity ^0.4.11;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

contract ReverseATM is Ownable {
    using SafeMath for uint256;

    //Contract events
    event GivedTokens(address indexed to, uint256 value);
    event ReconciledAccounts(uint256 totalAmountReconciled);

    address[] usersWithTokens;
    mapping(address => uint256) balances;
    address owner;

    uint256 public distributedSupply;
    uint256 public totalSupply;

    /**
      * Contract initialization function
      *
      * @param initialTotalSupply The starting total supply
      */
    function ReverseATM(uint256 initialTotalSupply) {
        distributedSupply = 0;
        totalSupply = initialTotalSupply;
    }

    /**
      * Adds tokens to the total supply
      *
      * @param supplyExtension The amount of tokens added to the total supply
      */
    function increaseSupply(uint256 supplyExtension) onlyOwner() {
        totalSupply = totalSupply.add(supplyExtension);
    }

    /**
      * Returns total number of tokens of a user
      *
      * @param user The user to query the balance
      * @return total number of tokens the user has
      */
    function balanceOf(address user) constant returns (uint256) {
        return balances[user];
    }

    /**
      * Gives tokens to 'to' user
      *
      * @param to The user that will be given the tokens
      * @param value The amount of tokens to be transfered
      */
    function rewardWithTokens(address to, uint256 value) onlyOwner() {
        require(totalSupply >= distributedSupply.add(value));

        balances[to] = balances[to].add(value);
        distributedSupply += value;

        GivedTokens(to, value);
    }

    /**
      * Burns all the tokens and returns the tokens previously owned by each user
      *
      * @return the address of the users with the tokens previously owned by each
      */
    function accountsReconciliation() onlyOwner() returns (address[], uint256[]) {
        address[] memory reconciledUsers = new address[](usersWithTokens.length);
        uint256[] memory reconciledAmounts = new uint256[](usersWithTokens.length);
        uint256 totalAmountReconciled = 0;

        for(uint i=0; i<usersWithTokens.length; i++) {
            address user = usersWithTokens[i];

            reconciledUsers[i] = user;
            reconciledAmounts[i] = balances[user];

            totalAmountReconciled += balances[user];
        }

        distributedSupply = 0;
        usersWithTokens = new address[](0);
        ReconciledAccounts(totalAmountReconciled);
        return (reconciledUsers, reconciledAmounts);
    }

}