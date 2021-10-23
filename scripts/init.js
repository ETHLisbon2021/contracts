// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
    const distribution = hre.ethers.parseUint(100000);
    const fullCap = hre.ethers.parseUint(20);

    // We get the contract to deploy
    const Eligible = await hre.ethers.getContractFactory("Eligible");
    const eligible = await Eligible.at(process.env.ELIGIBLE);
    const Token = await hre.ethers.getContractFactory("Token");
    const token = await Token.at(process.env.TOKEN);

    token.approve(eligible.address, distribution);

    eligible.initSale(
        token.address,
        fullCap,
        distribution,
        maxDeposit,
        endDate,
        description
    );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
