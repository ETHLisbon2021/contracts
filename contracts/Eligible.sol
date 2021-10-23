//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import './Merkle.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract Eligible is Merkle {

    enum saleState {None, Active, Finished, Declined}

    struct Sale {
        uint256 totalCap;
        uint256 maxDeposit;
        uint256 totalDeposits;
        uint256 date;
        uint256 distribution;
        bytes32 description;
        bytes32 root;
        saleState state;
    }

    mapping(address => Sale) public sales;

    mapping(address => mapping(address => uint256)) deposits;

    event Deposited(address indexed tokenAddress, address indexed user, uint256  amount);

    event SaleInitiated(address indexed tokenAddress, address indexed initiator);

    constructor() {

    }

    function initSale(
        address token,
        uint256 totalCap,
        uint256 distribution,
        uint256 maxDeposit,
        uint256 date,
        bytes32 description

    )
        external
    {
        sales[token] = Sale({
            totalCap      : totalCap,
            maxDeposit    : maxDeposit,
            totalDeposits : 0,
            distribution  : distribution,
            date          : date,
            description   : description,
            root          : bytes32(0),
            state         : saleState.Active
        });

        IERC20(token).transferFrom(msg.sender, address(this), distribution);

        emit SaleInitiated(token, msg.sender);
    }

    function distribute(address tokenAddress, bytes32 root) external {
        Sale storage sale = sales[tokenAddress];
        require(sale.state == saleState.Active, "sale does not exist");

        sale.root = root;
        sale.state = saleState.Finished;

    }

    function deposit(address tokenAddress, address receiver) external payable {
        Sale storage sale = sales[tokenAddress];
        require(sale.state == saleState.Active, "sale does not exist");
        require(msg.value <= sale.maxDeposit, "");
        require(block.timestamp < sale.date, "");
        require(deposits[receiver][tokenAddress] > 0, "");

        sale.totalDeposits += msg.value;
        deposits[receiver][tokenAddress] = msg.value;

        emit Deposited(tokenAddress, receiver, msg.value);
    }

    function withdraw(address tokenAddress) external {
        //
    }

    function claim(uint256 amount, address receiver, address tokenAddress, bytes memory proof) external {
        bytes32 leaf = keccak256(abi.encodePacked(receiver, amount));
        require(verifyProof(leaf, sales[tokenAddress].root, proof), "");

        IERC20(tokenAddress).transfer(receiver, amount);
        // sales[initiator].send(deposit);
    }
}
