//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/**
 * @title ERC20 OST Token Contract
 * @dev OneStake Finance's governance token
 * @author OneStake Finance
 */

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract OST is Initializable, ERC20Upgradeable, OwnableUpgradeable {

    /// @notice token name
    string public constant NAME = "OST Token";

    /// @notice token symbol
    string public constant SYMBOL = "OST";

    /// @notice token decimals
    uint8 public constant DECIMALS = 18;

    /// @notice Total number of tokens in circulation, 24,000,000 OST
    uint256 public constant TOTAL_SUPPLY = 24000000e18;

    /**
    * @dev initializes OST ERC20 upgradeable contract
    * @param _tokenOwner the owner address with the total supply, can be distributed according to token allocation
    */

    function initialize(
        address _tokenOwner
    ) external initializer {
        __ERC20_init(NAME, SYMBOL);
        __Ownable_init();
        _mint(_tokenOwner, TOTAL_SUPPLY);
    }
}
