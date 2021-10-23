// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
    const distribution = hre.ethers.utils.parseUnits("100000");
    const fullCap = hre.ethers.utils.parseUnits("20");
    const maxDeposit = hre.ethers.utils.parseUnits("1");
    const endDate = 1637663818;
    const description =
        "0xe0a39fef8aa5887c76606e7a14a5db8dc6676191e4866b2a609a3aa003b18329";
    // We get the contract to deploy
    const Eligible = await hre.ethers.getContractAt(
        "Eligible",
        process.env.ELIGIBLE
    );
    const Token = await hre.ethers.getContractAt("Token", process.env.TOKEN);

    Token.approve(Eligible.address, distribution);

    Eligible.initSale(
        Token.address,
        fullCap,
        distribution,
        maxDeposit,
        endDate,
        description
    );

    console.log("sale inited");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
