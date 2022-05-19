const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

const { parseEther, parseUnits } = ethers.utils;

describe("iUSD Vault contract", function () {
    let iusd;

    before(async () => {
        const [deployer, tokenOwner, user1, user2] = await ethers.getSigners();
        const IUSD = await ethers.getContractFactory("IUSD");
        iusd = await upgrades.deployProxy(IUSD, ["iUSD Token", "iUSD"]);
        await iusd.deployed();

        const MockDAI = await ethers.getContractFactory("MockDAI");
        const mockDAI = await MockDAI.deploy();
        await mockDAI.deployed();

        const MockUSDT = await ethers.getContractFactory("MockUSDT");
        const mockUSDT = await MockUSDT.deploy();
        await mockUSDT.deployed();

        await mockDAI.connect(user1).mint(parseUnits("1000", 18));
        await mockDAI.connect(user2).mint(parseUnits("1000", 6));
    });

    describe("Initialize", () => {
        it("Should return correct token name", async () => {
            expect(await iusd.name()).to.equal("iUSD Token");
        });
    
        it("Should return correct token symbol", async () => {
            expect(await iusd.symbol()).to.equal("iUSD");
        });
    
        it("Should return correct token decimals", async () => {
            expect(await iusd.decimals()).to.equal(18);
        });
    });
});
