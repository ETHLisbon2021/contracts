//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Eligible {

    enum saleState {None, Active, Finished, Declined}

    struct Sale {
        uint256 totalCap;
        uint256 maxDeposit;
        uint256 totalDeposits;
        uint256 date;
        bytes32 description;
        bytes32 root;
        saleState state;
    }

    struct Deposit {
        uint256 amount;
    }

    mapping(address => Sale) public sales;

    event Deposited(address indexed tokenAddress, address indexed user);

    event SaleInitiated(address indexed tokenAddress);

    constructor() {

    }

    function initSale(
        address token,
        uint256 totalCap,
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
            date          : date,
            description   : description,
            root          : bytes32(0),
            state         : saleState.Active
        });
        // emit sale inited
    }

    function distribute(address tokenAddress, bytes32 root) external {
        Sale storage sale = sales[tokenAddress];
        require(sale.state == saleState.Active, "sale does not exist");

        sale.root = root;
        sale.state = saleState.Finished;

    }

    function deposit(address tokenAddress) external payable {
        Sale storage sale = sales[tokenAddress];
        require(sale.state == saleState.Active, "sale does not exist");
        require(msg.value <= sale.maxDeposit, "");
        require(block.timestamp < sale.date, "");

        sale.totalDeposits += msg.value;

        emit Deposited(tokenAddress, msg.sender);
    }

    function withdraw(address tokenAddress) external {
        //
    }

    function claim(address tokenAddress, bytes32 proof) external {
        //
    }
}
