const { expect } = require("chai");
const { utils } = require("ethers");
const { ethers, upgrades } = require("hardhat");

const {
    iUSD,
    controller,
    user1,
    user2,
    user3
} = require("../helpers");

describe("Aave Strategy", () => {
    before(async () => {
        const platformAddress = "0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5";

        const AaveStrategy = await ethers.getContractFactory("AaveStrategy");
        const aaveStrategy = await upgrades.deployProxy(AaveStrategy, [
            platformAddress, // LendingPoolAddressesProvider
            iUSD.address,
            ["0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9"] // Aave Token address
        ]);
        await aaveStrategy.deployed();
    });
});
