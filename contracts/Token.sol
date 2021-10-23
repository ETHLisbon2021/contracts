//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import './Merkle.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract Token is ERC20 {

    constructor() ERC20("Eligible", "ELI") {
        _mint(msg.sender, 1000000 ether);
    }

}
