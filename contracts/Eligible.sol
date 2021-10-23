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
        uint256 endingAt;
        uint256 distribution;
        bytes32 ipfsHash;
        bytes32 root;
        address payable initiator;
        saleState state;
    }

    mapping(address => Sale) public sales;

    mapping(address => mapping(address => uint256)) deposits;

    event Deposited(address indexed tokenAddress, address indexed user, uint256  amount);

    event SaleInitiated(address indexed tokenAddress, address indexed initiator);

    event TokenDistributed(address indexed tokenAddress, bytes32 tree, bytes32 root);

    modifier onlyGuardian() {
        //  require(msg.sender == guardianDAO, "")
        _;
    }

    constructor() {

    }

    function initSale(
        address token,
        uint256 totalCap,
        uint256 distribution,
        uint256 maxDeposit,
        uint256 endingAt,
        bytes32 ipfsHash

    )
        external
    {
        sales[token] = Sale({
            totalCap      : totalCap,
            maxDeposit    : maxDeposit,
            totalDeposits : uint256(0),
            distribution  : distribution,
            endingAt      : endingAt,
            ipfsHash      : ipfsHash,
            root          : bytes32(0),
            initiator     : payable(msg.sender),
            state         : saleState.Active
        });

        IERC20(token).transferFrom(msg.sender, address(this), distribution);

        emit SaleInitiated(token, msg.sender);
    }

    function distribute(
        address tokenAddress,
        bytes32 root,
        bytes32 tree
    )
        external
        onlyGuardian
    {
        Sale storage sale = sales[tokenAddress];
        require(sale.state == saleState.Active, "sale does not exist");
        require(sale.endingAt < block.timestamp, "");

        sale.root = root;
        sale.state = saleState.Finished;

        emit TokenDistributed(tokenAddress, tree, root);
    }

    function deposit(
        address tokenAddress,
        address receiver
    )
        external
        payable
    {
        Sale storage sale = sales[tokenAddress];

        require(sale.state == saleState.Active, "sale does not exist");
        require(msg.value <= sale.maxDeposit, "");
        require(block.timestamp < sale.endingAt, "");
        require(deposits[receiver][tokenAddress] > 0, "");

        sale.totalDeposits += msg.value;
        deposits[receiver][tokenAddress] = msg.value;

        emit Deposited(tokenAddress, receiver, msg.value);
    }

    function withdraw(
        address tokenAddress,
        address receiver
    )
        external
    {
        sales[tokenAddress].initiator.transfer(deposits[receiver][tokenAddress]);
    }

    function claim(
        uint256 amount,
        address receiver,
        address tokenAddress,
        bytes memory proof
    )
        external
    {
        bytes32 leaf = keccak256(abi.encodePacked(receiver, amount));
        require(verifyProof(leaf, sales[tokenAddress].root, proof), "The user is not eligible");

        IERC20(tokenAddress).transfer(receiver, amount);
        sales[tokenAddress].initiator.transfer(deposits[receiver][tokenAddress]);
    }
}

