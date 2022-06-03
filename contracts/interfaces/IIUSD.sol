//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IIUSD {
    function deposit(address _asset, uint256 _amount) external returns (uint256 shares);

    function withdraw(uint256 _shares) external returns (uint256 amount);
}
