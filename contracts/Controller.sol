// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "./interfaces/IIUSD.sol";

/**
 * @title Controller contract
 * @dev Gatekeeping interface between vaults and strategies, and oversees communication and fund flows.
 * @author OneStake Finance
 **/

contract Controller is Initializable, ReentrancyGuardUpgradeable {
    IIUSD public iUSDVault;

    modifier onlyUSDVault() {
        require(msg.sender == address(iUSDVault), "Not iUSD vault");
        _;
    }

    function initialize() external initializer {
        __ReentrancyGuard_init();
    }

    function depositUSD(
        address _user,
        address _asset,
        uint256 _amount
    ) external nonReentrant onlyUSDVault {
        IERC20Upgradeable(_asset).transferFrom(_user, address(this), _amount);
    }

    function setUSDVault(address _iUSDVault) external {
        require(_iUSDVault != address(0), "Must specify iUSD vault address");
        iUSDVault = IIUSD(_iUSDVault);
    }
}
