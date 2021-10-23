// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
    const root =
        "0x2b7398568aa25bc9585e004649b390a2304865c016f9d51e988f163dfa2c357e";
    const tree =
        "0x2b7398568aa25bc9585e004649b390a2304865c016f9d51e988f163dfa2c357e";
    const Eligible = await hre.ethers.getContractAt(
        "Eligible",
        process.env.ELIGIBLE
    );
    const Token = await hre.ethers.getContractAt("Token", process.env.TOKEN);

    await Eligible.distribute(Token.address, root, tree);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
