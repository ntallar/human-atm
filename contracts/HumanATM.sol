pragma solidity ^0.4.11;

import "zeppelin-solidity/contracts/token/ERC20Basic.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

contract HumanATM is ERC20Basic, Ownable {
    using SafeMath for uint256;

    //Contract events
    event NewUser(address user, uint256 initialCredit);
    event UserCreditIncrease(address user, uint256 creditExtension);
    event ReconciledAccounts(uint256 totalAmountReconciled);

    address[] users;
    mapping(address => uint256) creditTokenBalances;
    mapping(address => uint256) prizeTokenBalances;

    //Used for limiting the total amount of tokens distributed
    uint256 public distributedSupply;
    uint256 public totalSupply;

    /**
      * Contract initialization function
      *
      * @param initialTotalSupply The starting total supply
      */
    function HumanATM(uint256 initialTotalSupply) {
        totalSupply = initialTotalSupply;
        distributedSupply = 0;
    }

    /**
      * Returns whether an user is registered or not
      *
      * @return whether the user parameter is registered or not
      */
    function isRegistered(address user) constant returns (bool) {
        for(uint i = 0;i < users.length; i++) {
            if(users[i] == user){
                return true;
            }
        }
        return false;
    }

    /**
      * Registers a new user, setting initial credit tokens for it
      *
      * @param user The new user to register
      * @param initialCredit The initial amount of tokens the user will have
      */
    function registerUser(address user, uint256 initialCredit) onlyOwner() {
        require(!isRegistered(user)); //User not registered
        require(totalSupply >= distributedSupply.add(initialCredit)); //Enough supply for new user

        users.push(user);
        creditTokenBalances[user] = initialCredit;
        distributedSupply += initialCredit;

        NewUser(user, initialCredit);
    }

    /**
      * Adds credit tokens to a user
      *
      * @param user The user whose amount of credit tokens will be increased
      * @param creditExtension The amount of credit tokens that will be given to the user
      */
    function addCredit(address user, uint256 creditExtension) onlyOwner() {
        require(isRegistered(user)); //User registered
        require(totalSupply >= distributedSupply.add(creditExtension)); //Enough supply for user

        creditTokenBalances[user] += creditExtension;
        distributedSupply += creditExtension;

        UserCreditIncrease(user, creditExtension);
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
      * Returns total number of tokens (includit credit and prize tokens) of a user
      *
      * @param user The user to query the balance
      * @return total number of tokens the user has
      */
    function balanceOf(address user) constant returns (uint256) {
        return userCredit(user) + userAwardedTokens(user);
    }

    /**
      * Returns number of credit tokens of a user
      *
      * @param user The user to query the number of credit tokens
      * @return total number of credit tokens the user has
      */
    function userCredit(address user) constant returns (uint256) {
        return creditTokenBalances[user];
    }

    /**
      * Returns number of prize tokens of a user
      *
      * @param user The user to query the number of prize tokens
      * @return total number of prize tokens the user has
      */
    function userAwardedTokens(address user) constant returns (uint256) {
        return prizeTokenBalances[user];
    }

    /**
      * Transfers credit tokens (as prize tokens) from msg.sender to 'to'
      *
      * @param to The user that will receive the tokens
      * @param value The amount of tokens to be transfered
      * @return whether the transfer was successful or not
      */
    function transfer(address to, uint256 value) returns (bool) {
        require(isRegistered(msg.sender));
        require(isRegistered(to));

        creditTokenBalances[msg.sender] = creditTokenBalances[msg.sender].sub(value);
        prizeTokenBalances[to] = prizeTokenBalances[to].add(value);

        Transfer(msg.sender, to, value);
        return true;
    }

    /**
      * Deletes all the prize tokens and returns the prize tokens previously owned by each user
      *
      * @return the address of the users with the prize tokens previously owned by each
      */
    function accountsReconciliation() onlyOwner() returns (address[], uint256[]) {
        address[] memory reconciledUsers = new address[](users.length);
        uint256[] memory reconciledAmounts = new uint256[](users.length);
        uint256 totalAmountReconciled = 0;

        for(uint i = 0;i < users.length; i++) {
            address user = users[i];
            uint256 userPrizeTokens = prizeTokenBalances[user];

            reconciledUsers[i] = user;
            reconciledAmounts[i] = userPrizeTokens;

            totalAmountReconciled += userPrizeTokens;
            prizeTokenBalances[user] = 0;
        }
        distributedSupply -= totalAmountReconciled;

        ReconciledAccounts(totalAmountReconciled);

        return (reconciledUsers, reconciledAmounts);
    }

}