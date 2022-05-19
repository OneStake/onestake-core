//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

import "../libraries/Helpers.sol";
import "../libraries/StableMath.sol";

import "hardhat/console.sol";
/**
 * @title IUSD vault contract
 * @dev consolidates stable coins in one pool.
 * @author OneStake Finance
 */

contract IUSD is Initializable, ERC20Upgradeable, ReentrancyGuardUpgradeable {
    using StableMath for uint256;
    using SafeMathUpgradeable for uint256;

    /// @notice Stablecoins supported by the IUSD Vault
    mapping(address => bool) internal isSupportedAsset;
    address[] internal allAssets;
    
    event AssetSupported(address indexed _asset);
    event Deposit(address indexed _user, address indexed _asset, uint256 _amount, uint256 _shares);
    
    function initialize(
        string calldata _iTokenName,
        string calldata _iTokenSymbol
    ) external initializer {
        __ERC20_init(_iTokenName, _iTokenSymbol);
        __ReentrancyGuard_init();
    }

    function deposit(
        address _asset,
        uint256 _amount
    ) external nonReentrant returns (uint256 shares) {
        require(isSupportedAsset[_asset], "Asset is not supported");
        require(_amount > 0, "Amount must be greater than 0");

        uint256 assetDecimals = Helpers.getDecimals(_asset);
        require((shares = previewDeposit(_amount.scaleBy(18, assetDecimals))) != 0, "ZERO_SHARES");

        if(IERC20Upgradeable(_asset).balanceOf(address(this)) == 0) allAssets.push(_asset);

        IERC20Upgradeable(_asset).transferFrom(msg.sender, address(this), _amount);

        _mint(msg.sender, shares);

        emit Deposit(msg.sender, _asset, _amount, shares);
    }

    function convertToShares(uint256 _amount) internal view returns (uint256) {
        uint256 supply = totalSupply();
        return supply == 0 ? _amount : _amount.mul(supply).div(totalAssets());
    }

    function totalAssets() internal view returns (uint256 totalBalance) {
        for (uint256 i = 0; i < allAssets.length; i++) {
            uint256 assetDecimals = Helpers.getDecimals(allAssets[i]);
            uint256 balance = IERC20Upgradeable(allAssets[i]).balanceOf(address(this));
            totalBalance = totalBalance.add(
                balance.scaleBy(18, assetDecimals)
            );
        }
    }

    function previewDeposit(uint256 _amount) internal view returns (uint256) {
        return convertToShares(_amount);
    }

    /**
     * @dev Add a supported asset to the contract, i.e. one that can be to mint iUSD.
     * @param _asset Address of asset
     */
    function supportAsset(address _asset) external {
        require(!isSupportedAsset[_asset], "Asset already supported");

        isSupportedAsset[_asset] = true;

        emit AssetSupported(_asset);
    }

    /**
     * @dev Return the number of assets supported by the Vault.
     */
    function getAssetCount() public view returns (uint256) {
        return allAssets.length;
    }

    /**
     * @dev Return all asset addresses in order
     */
    function getAllAssets() external view returns (address[] memory) {
        return allAssets;
    }
}
