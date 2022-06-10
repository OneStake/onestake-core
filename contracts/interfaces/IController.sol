//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IController {
    function depositUSD(
        address _user,
        address _asset,
        uint256 _amount
    ) external;

    function balanceOf(
        address _strategy, 
        address _token
    ) external view returns (uint256);
}
