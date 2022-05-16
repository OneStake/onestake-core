const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

const { parseEther, parseUnits } = ethers.utils;

describe("OST Token contract", function () {
    let ost;

    before(async () => {
        const [deployer, tokenOwner] = await ethers.getSigners();
        const OST = await ethers.getContractFactory("OST");
        ost = await upgrades.deployProxy(OST, [tokenOwner.address]);
        await ost.deployed();
    });

    it("Should return correct token name", async () => {
        expect(await ost.name()).to.equal("OST Token");
    });

    it("Should return correct token symbol", async () => {
        expect(await ost.symbol()).to.equal("OST");
    });

    it("Should return correct token decimals", async () => {
        expect(await ost.decimals()).to.equal(18);
    });

    it("Should return correct total supply", async () => {
        const totalSupply = "24000000";
        const decimals = await ost.decimals();
        expect(await ost.totalSupply()).to.equal(parseUnits(totalSupply, decimals));
    });
});
