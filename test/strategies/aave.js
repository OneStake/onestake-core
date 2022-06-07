const { expect } = require("chai");
const { utils } = require("ethers");
const { ethers, upgrades } = require("hardhat");

const {
    iUSD,
    user1,
    user2,
    user3
} = require("../helpers");

describe("Aave Strategy", () => {
    before(async () => {
        const AaveStrategy = await ethers.getContractFactory("AaveStrategy");
        const aaveStrategy = await upgrades.deployProxy(AaveStrategy, [""]);
        await aaveStrategy.deployed();
    });
});
