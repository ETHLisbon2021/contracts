//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import './Merkle.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import "hardhat/console.sol";

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

    /// @notice Initiates a tokensale
    /// @param token        address of the selling token
    /// @param totalCap     total amount of funds
    /// @param distribution total tokens to distribute
    /// @param maxDeposit   max deposit per user
    /// @param endingAt     date of the ending of token sale
    /// @param ipfsHash     IPFS hash of the description file
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

    /// @notice Distributes token through Merkle drop
    /// @param tokenAddress Token address of the token to sale
    /// @param root         The root of the Merkle tree
    /// @param tree         IPFS hash of the Merkle tree file
    function mekrleDistribute(
        address tokenAddress,
        bytes32 root,
        bytes32 tree
    )
        external
        onlyGuardian
    {
        Sale storage sale = sales[tokenAddress];
        require(sale.state == saleState.Active, "sale does not exist");
        // require(sale.endingAt < block.timestamp, "");

        sale.root = root;
        sale.state = saleState.Finished;

        emit TokenDistributed(tokenAddress, tree, root);
    }

    /// @notice Distirbutes tokens
    /// @param tokenAddress the address of the token to distribute
    /// @param receivers    a Array of receivers addresses
    /// @param amounts      a Array of receivers amounts
    function distribute(
        address tokenAddress,
        address[] calldata receivers,
        uint256[] calldata amounts
    )
        external
    {
        Sale storage sale = sales[tokenAddress];
        require(receivers.length == amounts.length, "");
        uint256  sum = 0;

        for(uint256 i = 0; i < receivers.length; i++) {
            IERC20(tokenAddress).transfer(receivers[i], amounts[i]);
            sum += deposits[receivers[i]][tokenAddress];
            delete deposits[receivers[i]][tokenAddress];
        }

        sales[tokenAddress].initiator.transfer(sum);

        sale.state = saleState.Finished;
    }

    /// @notice Deposites funds for the tokensale
    /// @param tokenAddress the address of the token to sale
    /// @param receiver the address which will checked and get the allocation
    function deposit(
        address tokenAddress,
        address receiver
    )
        external
        payable
    {
        Sale storage sale = sales[tokenAddress];

        require(sale.state == saleState.Active, "sale does not exist");
        require(msg.value <= sale.maxDeposit, "Deposit is too high");
        require(block.timestamp < sale.endingAt, "Sale is over");
        require(deposits[receiver][tokenAddress] == 0, "User already has a deposit");

        sale.totalDeposits += msg.value;
        deposits[receiver][tokenAddress] = msg.value;

        emit Deposited(tokenAddress, receiver, msg.value);
    }

    /// @notice Withdraws deposit in case of user is not eligible
    /// @param tokenAddress the address of the token to sale
    /// @param receiver the address which will get refunds
    function withdraw(
        address tokenAddress,
        address receiver
    )
        external
    {
        Sale storage sale = sales[tokenAddress];
        require(sale.state != saleState.Active, "sale does not exist");
        sales[tokenAddress].initiator.transfer(deposits[receiver][tokenAddress]);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param tokenAddress the address of the token to sale
    /// @param amount the amount of the allocated tokens
    /// @param receiver the address of receiver
    function claim(
        address tokenAddress,
        uint256 amount,
        address receiver,
        bytes32[] memory proof
    )
        external
    {
        bytes32 leaf = keccak256(abi.encodePacked(receiver, Strings.toString(amount)));
        require(verifyProof(leaf, sales[tokenAddress].root, proof), "The user is not eligible");
        IERC20(tokenAddress).transfer(receiver, amount);
        sales[tokenAddress].initiator.transfer(deposits[receiver][tokenAddress]);
        delete deposits[receiver][tokenAddress];
    }
}

