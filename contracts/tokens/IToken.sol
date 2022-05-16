//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/**
 * @title ERC20 IToken contract
 * @dev Implementation of the interest bearing token for the OneStake Finance
 * @author OneStake Finance
 */

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract IToken is Initializable, ERC20Upgradeable {
    /**
    * @dev Initializes the iToken
    * @param _iTokenName The name of the aToken
    * @param _iTokenSymbol The symbol of the aToken
    */
    function initialize(
        string calldata _iTokenName,
        string calldata _iTokenSymbol
    ) external initializer {
        __ERC20_init(_iTokenName, _iTokenSymbol);
    }

    function mint(
        address _user,
        uint256 _amount
    ) external {
        _mint(_user, _amount);
    }

    function burn(
        address _user,
        uint256 _amount
    ) external {
        _burn(_user, _amount);
    }
}
