const { expect } = require("chai");
const { utils } = require("ethers");
const { ethers, upgrades } = require("hardhat");

describe("Aave Strategy", () => {
    let iusd;
    before(async () => {
        const Controller = await ethers.getContractFactory("Controller");
        const controller = await (await upgrades.deployProxy(Controller, [])).deployed();

        const IUSD = await ethers.getContractFactory("IUSD");
        iusd = await upgrades.deployProxy(IUSD, ["iUSD", "iUSD", controller.address]);

        // Aave LendingPoolAddressesProvider
        const platformAddress = "0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5";
        // reward token address
        const rewardTokenAddresses = ["0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9"];
        // initial supported assets
        const underlyingAssets = [
            "0xdAC17F958D2ee523a2206206994597C13D831ec7",
            "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
        ];
        // platform token corresponding addresses
        const pTokens = [
            "0x3Ed3B47Dd13EC9a98b44e6204A523E766B225811",
            "0xBcca60bB61934080951369a648Fb03DF4F96263C"
        ];
        const AaveStrategy = await ethers.getContractFactory("AaveStrategy");
        const aaveStrategy = await upgrades.deployProxy(AaveStrategy, [
            platformAddress, // LendingPoolAddressesProvider
            iusd.address,
            rewardTokenAddresses, // Aave Token address
            underlyingAssets,
            pTokens
        ]);
        await aaveStrategy.deployed();
        console.log("aave strategy deployed to: ", aaveStrategy.address);
    });
});
