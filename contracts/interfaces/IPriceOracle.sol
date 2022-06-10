// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPriceOracle {
    function registerOracle(address _token, address _oracle) external;

    function updateOracle(address _token, address _oracle) external;

    function getPrice(address _token) external view returns (int256, uint8);
}
