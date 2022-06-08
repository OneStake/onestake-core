const hre = require("hardhat");
const { ethers } = require("hardhat");
const { parseUnits, formatUnits } = ethers.utils;

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
    parseUnits,
    usdtUnits,
    usdtUnitsFormat,
    usdcUnits,
    usdcUnitsFormat,
    daiUnits,
    daiUnitsFormat,
    advanceTime,
    getBlockTimestamp
};
