// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
    const signers = await ethers.getSigners();
    const Eligible = await hre.ethers.getContractAt(
        "Eligible",
        process.env.ELIGIBLE
    );
    const Token = await hre.ethers.getContractAt("Token", process.env.TOKEN);

    await Eligible.deposit(Token.address, signers[0].address, {
        value: hre.ethers.utils.parseUnits("1"),
    });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
