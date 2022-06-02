const hre = require("hardhat");
const { ethers, upgrades } = require("hardhat");
const { parseUnits, formatUnits } = ethers.utils;

// iUSD Vault
const IUSD = await ethers.getContractFactory("IUSD");
const iUSD = await upgrades.deployProxy(IUSD, ["iUSD", "iUSD"]);
await iUSD.deployed();

const MockDAI = await ethers.getContractFactory("MockDAI");
const mockDAI = await MockDAI.deploy();

const MockUSDC = await ethers.getContractFactory("MockUSDC");
const mockUSDC = await MockUSDC.deploy();

const MockUSDT = await ethers.getContractFactory("MockUSDT");
const mockUSDT = await MockUSDT.deploy();

const signers = await ethers.getSigners();

const user1 = signers[1];
const user2 = signers[2];
const user3 = signers[3];

for (const user of [user1, user2, user3]) {
    await mockDAI.connect(user).approve(iUSD.address, parseUnits("100", 18));
    await iUSD.connect(user).mint(mockDAI.address, parseUnits("100", 18));
}

function usdtUnits(amount) {
    return parseUnits(amount, 6);
}

function usdtUnitsFormat(amount) {
    return formatUnits(amount, 6);
}

function usdcUnits(amount) {
    return parseUnits(amount, 6);
}

function usdcUnitsFormat(amount) {
    return formatUnits(amount, 6);
}

function daiUnits(amount) {
    return parseUnits(amount, 18);
}

function daiUnitsFormat(amount) {
    return formatUnits(amount, 18);
}

const advanceTime = async (seconds) => {
    await hre.ethers.provider.send("evm_increaseTime", [seconds]);
    await hre.ethers.provider.send("evm_mine");
};

const getBlockTimestamp = async () => {
    return (await hre.ethers.provider.getBlock("latest")).timestamp;
};

module.exports = {
    mockDAI,
    mockUSDC,
    mockUSDT,
    user1,
    user2,
    user3,
    usdtUnits,
    usdtUnitsFormat,
    usdcUnits,
    usdcUnitsFormat,
    daiUnits,
    daiUnitsFormat,
    advanceTime,
    getBlockTimestamp,
    iUSD
};
