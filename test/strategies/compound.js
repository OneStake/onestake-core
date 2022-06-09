const { expect } = require("chai");
const { utils } = require("ethers");
const { ethers, upgrades } = require("hardhat");

describe("Compound Strategy", () => {
    let iUSD;
    
    before(async () => {
        const Controller = await ethers.getContractFactory("Controller");
        const controller = await (await upgrades.deployProxy(Controller, [])).deployed();

        const IUSD = await ethers.getContractFactory("IUSD");
        iUSD = await upgrades.deployProxy(IUSD, ["iUSD", "iUSD", controller.address]);
        
        const CompoundStrategy = await ethers.getContractFactory("CompoundStrategy");
        const compoundStrategy = await upgrades.deployProxy(CompoundStrategy, []);
        await compoundStrategy.deployed();
        console.log("compound strategy deployed to: ", compoundStrategy.address);
    });
});
