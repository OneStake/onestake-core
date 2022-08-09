const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

const {
    parseUnits,
    daiUnits,
    usdtUnits,
    usdcUnits
} = require("../helpers");

describe("iUSD Vault contract", function () {
    let controller, iusd;
    let mockDAI, mockUSDT, mockUSDC;
    let deployer, tokenOwner, user1, user2, user3;

    const approvalAmount = parseUnits("100000000", 18);

    before(async () => {
        [deployer, tokenOwner, user1, user2, user3] = await ethers.getSigners();

        const Controller = await ethers.getContractFactory("Controller");
        controller = await (await upgrades.deployProxy(Controller, [])).deployed();

        const IUSD = await ethers.getContractFactory("IUSD");
        iusd = await upgrades.deployProxy(IUSD, ["iUSD Token", "iUSD", controller.address]);

        await controller.setUSDVault(iusd.address);
        
        const MockDAI = await ethers.getContractFactory("MockDAI");
        mockDAI = await MockDAI.deploy();
        await mockDAI.deployed();

        const MockUSDT = await ethers.getContractFactory("MockUSDT");
        mockUSDT = await MockUSDT.deploy();
        await mockUSDT.deployed();

        const MockUSDC = await ethers.getContractFactory("MockUSDT");
        mockUSDC = await MockUSDC.deploy();
        await mockUSDC.deployed();

        await mockDAI.connect(user1).mint(daiUnits("1000"));
        await mockUSDT.connect(user2).mint(usdtUnits("1000"));
        await mockUSDC.connect(user3).mint(usdcUnits("1000"));
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

    describe("Deposit", () => {
        it("Reverts if asset is not supported", async () => {
            await expect(
                iusd.deposit(mockDAI.address, parseUnits("100", 18))
            ).to.be.revertedWith("Asset is not supported");
        });

        it("Reverts if amount is not greater than 0", async () => {
            await iusd.supportAsset(mockDAI.address);
            await expect(
                iusd.deposit(mockDAI.address, parseUnits("0", 18))
            ).to.be.revertedWith("Amount must be greater than 0");
        });

        it("User1 deposits successfully", async () => {
            await mockDAI
                .connect(user1)
                .approve(controller.address, approvalAmount);

            await iusd
                .connect(user1)
                .deposit(mockDAI.address, parseUnits("100", 18));

            expect(await iusd.getAssetCount()).to.be.equal("1");
            expect(await mockDAI.balanceOf(iusd.address)).to.be.equal(parseUnits("100", 18));
        });

        it("User2 deposits successfully", async () => {
            await iusd.supportAsset(mockUSDT.address);
            await mockUSDT
                .connect(user2)
                .approve(controller.address, approvalAmount);

            await iusd
                .connect(user2)
                .deposit(mockUSDT.address, parseUnits("200", 6));

            expect(await iusd.getAssetCount()).to.be.equal("2");
            expect(await mockUSDT.balanceOf(iusd.address)).to.be.equal(parseUnits("200", 6));
        });

        it("User3 deposits successfully", async () => {
            await iusd.supportAsset(mockUSDC.address);
            await mockUSDC
                .connect(user3)
                .approve(controller.address, approvalAmount);

            await iusd
                .connect(user3)
                .deposit(mockUSDC.address, parseUnits("150", 6));

            expect(await iusd.getAssetCount()).to.be.equal("3");
            expect(await mockUSDC.balanceOf(iusd.address)).to.be.equal(parseUnits("150", 6));
        });
    });
});
