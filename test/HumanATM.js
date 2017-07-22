var HumanATM = artifacts.require("./HumanATM.sol");

contract('HumanATM', function(accounts) {
    it("should start with the correct total supply", function() {
        return HumanATM.new(1000).then(function(instance) {
            hatm = instance
            return hatm.totalSupply();
        }).then(function(totalSupp){
            assert.equal(totalSupp, 1000, "It started with wrong total supply");
        })
    });

    it("register an user", function() {
        var hatm;
        var user = '0x0000000000000000000000000000000000000000';
        var balance = 100;
        return HumanATM.new(1000).then(function(instance) {
            hatm = instance;
            return instance.registerUser(user, balance);
        }).then(function(){
            return hatm.isRegistered.call(user);
        }).then(function(isReg){
            assert.equal(isReg, true, "The user wasn't registered");
            return hatm.balanceOf.call(user);
        }).then(function(bal){
            assert.equal(bal, balance, "The user has invalid balance");
        })
    });


    it("correctly transfer tokens", function() {
        var hatm;
        var sender = accounts[0];
        var receiver = accounts[1];
        var initialAmount = 1000;
        var amount = 100;
        return HumanATM.new(initialAmount, {from: accounts[0]}).then(function(instance) {
            hatm = instance;
            return instance.registerUser(sender, initialAmount / 2);
        }).then(function(){
            return hatm.registerUser(receiver, 0);
        }).then(function(){
            return hatm.transfer(receiver, amount);
        }).then(function(){
            return hatm.userAwardedTokens(receiver);
        }).then(function(tokens){
            assert.equal(tokens, amount, "The transfer was unsuccessful");
        })
    });

    it("correctly reconciliates accounts", function() {
        var hatm;
        var sender = accounts[0];
        var receiver = accounts[1];
        var initialAmount = 1000;
        var amount = 100;
        return HumanATM.new(initialAmount, {from: accounts[0]}).then(function(instance) {
            hatm = instance;
            return instance.registerUser(sender, initialAmount / 2);
        }).then(function(){
            return hatm.registerUser(receiver, 0);
        }).then(function(){
            return hatm.transfer(receiver, amount);
        }).then(function(){
            return hatm.accountsReconciliation();
        }).then(function(){
            return hatm.balanceOf(receiver);
        }).then(function(tokens){
            assert.equal(tokens, 0, "The reconciliation worked unexpectedly");
        })
    });
});
