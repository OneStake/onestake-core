//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

import "../interfaces/IController.sol";
import "../interfaces/IPriceOracle.sol";
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
    // mapping(address => bool) internal isSupportedAsset;
    address[] internal allAssets;
    address[] internal allStrategies;

    IController public controller;
    IPriceOracle public priceOracle;

    event AssetSupported(address indexed _asset);
    event Deposit(address indexed _user, address indexed _asset, uint256 _amount, uint256 _shares);
    event Withdraw(address indexed _user, uint256 _share, uint256 _amount);

    function initialize(
        string calldata _iTokenName,
        string calldata _iTokenSymbol,
        address _controller,
        address _priceOracle
    ) external initializer {
        __ERC20_init(_iTokenName, _iTokenSymbol);
        __ReentrancyGuard_init();
        controller = IController(_controller);
        priceOracle = IPriceOracle(_priceOracle);
    }

    function deposit(
        address _asset,
        uint256 _amount
    ) external nonReentrant {
        require(_amount > 0, "Amount must be greater than 0");
        
        uint256 assetDecimals = Helpers.getDecimals(_asset);

        uint256 shares = previewDeposit(_amount.scaleBy(18, assetDecimals));
        require(shares != 0, "ZERO_SHARES");
        
        if(_checkBalance(_asset) == 0) allAssets.push(_asset);

        IERC20Upgradeable(_asset).transferFrom(msg.sender, address(this), _amount);

        _mint(msg.sender, shares);

        emit Deposit(msg.sender, _asset, _amount, shares);
    }

    function withdraw(
        uint256 _shares
    ) external nonReentrant returns (uint256 amount) {
        require(_shares > 0, "shares must be greater than 0");

        require((amount = previewWithdraw(_shares)) != 0, "ZERO_AMOUNT");

        // Calculate redemption outputs
        (
            uint256[] memory outputs,
        ) = _calculateRedeemOutputs(amount);

        _burn(msg.sender, _shares);

        // Send outputs
        for (uint256 i = 0; i < allAssets.length; i++) {
            if (outputs[i] == 0) continue;

            IERC20Upgradeable asset = IERC20Upgradeable(allAssets[i]);

            if (asset.balanceOf(address(this)) >= outputs[i]) {
                // Use Vault funds first if sufficient
                asset.transfer(msg.sender, outputs[i]);
            } else {
                // todo: related to Strategies
                /* address strategyAddr = assetDefaultStrategies[allAssets[i]];
                if (strategyAddr != address(0)) {
                    // Nothing in Vault, but something in Strategy, send from there
                    IStrategy strategy = IStrategy(strategyAddr);
                    strategy.withdraw(msg.sender, allAssets[i], outputs[i]);
                } else {
                    // Cant find funds anywhere
                    revert("Liquidity error");
                } */
                revert("Liquidity error");
            }
        }

        emit Withdraw(msg.sender, _shares, amount);
    }

    function _calculateRedeemOutputs(uint256 _amount)
        internal
        view
        returns (uint256[] memory outputs, uint256 totalBalance)
    {
        uint256 assetCount = getAssetCount();
        uint256[] memory assetBalances = new uint256[](assetCount);
        uint256[] memory assetDecimals = new uint256[](assetCount);
        uint256 totalOutputRatio = 0;
        outputs = new uint256[](assetCount);

        // Calculate assets balances and decimals once,
        for (uint256 i = 0; i < allAssets.length; i++) {
            uint256 balance = _checkBalance(allAssets[i]);
            uint256 decimals = Helpers.getDecimals(allAssets[i]);
            assetBalances[i] = balance;
            assetDecimals[i] = decimals;
            totalBalance = totalBalance.add(balance.scaleBy(18, decimals));
        }

        // Calculate totalOutputRatio
        for (uint256 i = 0; i < allAssets.length; i++) {
            uint256 ratio = assetBalances[i]
                .scaleBy(18, assetDecimals[i])
                .mul(1e18)
                .div(totalBalance);
            totalOutputRatio = totalOutputRatio.add(ratio);
        }
        // Calculate final outputs
        uint256 factor = _amount.divPrecisely(totalOutputRatio);
        for (uint256 i = 0; i < allAssets.length; i++) {
            outputs[i] = assetBalances[i].mul(factor).div(totalBalance);
        }
    }

    /**
     * @notice Get the balance of an asset held in Vault and all strategies.
     * @param _asset Address of asset
     * @return balance Balance of asset in decimals of asset
     */
    function _checkBalance(address _asset)
        internal
        view
        virtual
        returns (uint256 balance)
    {
        IERC20Upgradeable asset = IERC20Upgradeable(_asset);
        balance = asset.balanceOf(address(this));

        for (uint256 i = 0; i < allStrategies.length; i++) {
            balance = balance.add(controller.balanceOf(allStrategies[i], _asset));
        }
    }

    function convertToShares(uint256 _amount) internal view returns (uint256) {
        uint256 supply = totalSupply();
        return supply == 0 ? _amount : _amount.mul(supply).div(totalAssets());
    }

    function convertToAssets(uint256 _shares) internal view returns (uint256) {
        uint256 supply = totalSupply(); // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? _shares : _shares.mul(totalAssets()).div(supply);
    }

    function totalAssets() internal view returns (uint256 totalBalance) {
        for (uint256 i = 0; i < allAssets.length; i++) {
            (uint256 price, uint256 priceDecimal) = IPriceOracle(priceOracle).getPrice(allAssets[i]);
            uint256 balance = _checkBalance(allAssets[i]);
            uint256 priceAdjustedBalance = balance.mulTruncateScale(
                price.scaleBy(18, priceDecimal), // Oracles have 8 decimal precision
                10**Helpers.getDecimals(allAssets[i])
            );
            totalBalance = totalBalance.add(priceAdjustedBalance);
        }
    }

    function previewDeposit(uint256 _amount) public view returns (uint256) {
        return convertToShares(_amount);
    }

    function previewWithdraw(uint256 _shares) public view returns (uint256) {
        return convertToAssets(_shares);
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
