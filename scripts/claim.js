// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
    const proof = [
        "0xb8e7c06d9376f3b890457dfd8b4694570be10e6a938d3404e6d36d72b82cb4d7",
        "0xe75d9c68fc4b984f9c5dc2c9d34f79bd1689e60acb11fac9e65ec716a6c2098a",
        "0x115c6921cd6a99b665b06d0a30b2aa9ae37c7ec73a9c62f7299c99420e3e8dcb",
    ];
    const receiver = "0xcd5f8fa45e0ca0937f86006b9ee8fe1eedee5fc4";
    const amount = 1000;
    const leaf =
        "0x03f09572247dbc0e264efbafa1a91f12eb056b7be1979724ff79fbd6d8c73d30";
    const Eligible = await hre.ethers.getContractAt(
        "Eligible",
        process.env.ELIGIBLE
    );
    const Token = await hre.ethers.getContractAt("Token", process.env.TOKEN);

    await Eligible.claim(Token.address, amount, receiver, proof);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
