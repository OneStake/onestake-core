// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./interfaces/IStrategy.sol";

/**
 * @title Controller contract
 * @dev Gatekeeping interface between vaults and strategies, and oversees communication and fund flows.
 * @author OneStake Finance
 **/

contract Controller is Initializable {

    function initialize() external initializer {}

    function balanceOf(address _strategy, address _token) external view returns (uint256) {
        return IStrategy(_strategy).checkBalance(_token);
    }
}
