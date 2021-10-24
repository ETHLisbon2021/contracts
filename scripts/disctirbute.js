// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
    const receivers = [
        "0x1db3439a222c519ab44bb1144fc28167b4fa6ee6",
        "0x3ddfa8ec3052539b6c9549f12cea2c295cff5296",
        "0xdd709cae362972cb3b92dcead77127f7b8d58202",
        "0x06fed18718975d9e178e0c0fea35c18eac794c3f",
    ];
    const amounts = [100, 500, 300, 400];
    const Eligible = await hre.ethers.getContractAt(
        "Eligible",
        process.env.ELIGIBLE
    );
    const Token = await hre.ethers.getContractAt("Token", process.env.TOKEN);

    await Eligible.distibute(Token.address, receivers, amounts);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
