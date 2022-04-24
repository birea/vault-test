//SPDX-License-Identifier: UNLICENSED

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

pragma solidity ^0.8.0;

contract Vault {
    address auth;
    address owner;
    address tknContract;
    uint256 totalBalance;
    uint256 unlockedBalance;
    uint256 withdrawAmount;

    constructor() {
        setAuth(msg.sender);
    }

    error OwnerNotSet();
    error OwnerAlreadySet();
    error UnlockedBalanceLessThanZero();
    error TknContractAlreadySet();
    error OwnerCanN();

    function withdraw(address _toAddress, uint256 amount) public onlyOwner {
        require(getAuth() != msg.sender, "Caller should not be autherized");
        if (unlockedBalance <= 0) {
            revert UnlockedBalanceLessThanZero();
        }
        IERC20 sdextoken = IERC20(tknContract);
        if (amount <= unlockedBalance) {
            sdextoken.transfer(_toAddress, amount);
            withdrawAmount += amount;
        } else {
            sdextoken.transfer(_toAddress, unlockedBalance);
            withdrawAmount += unlockedBalance;
        }
    }
    function setOwner(address _ownerAddress) public onlyAuth {
        if (getOwner() != address(0)) {
            revert OwnerAlreadySet();
        }
        owner = _ownerAddress;
    }
    function getOwner() public view returns (address) {
        return owner;
    }
    function setTkn(address _tknAddress) public onlyAuth {
        if (tknContract!=address(0)) {
            revert TknContractAlreadySet();
        }
        if (getOwner() == address(0)) {
            revert OwnerNotSet();
        }
        if (getOwner() == msg.sender) {
            revert TknContractAlreadySet();
        }
        tknContract = _tknAddress;
    }
    function setAuth(address _authAddress) public {
        auth = _authAddress;
    }
    function getAuth() public view returns (address) {
        return auth;
    }
    /*
    unlocked balance comes from the vesting formula.
    that formula could not be calculated in smart contract.
    because of the poor data types of the solidity language.
    the calculation also come from front or backend.
    but already withdraw amount should be removed.
    */
    function updateUnlockedAmount(uint256 yieldBalance) public {
        unlockedBalance = yieldBalance - withdrawAmount;
    }

    modifier onlyAuth() {
        require(getAuth() == msg.sender, "Caller is not autherized");
        _;
    }
    modifier onlyOwner() {
        if (getOwner() == address(0)) {
            revert OwnerNotSet();
        }
        require(getOwner() == msg.sender, "Ownable: caller is not an owner");
        _;
    }
}