// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenAuction {
    address public admin;
    IERC20 public token;
    uint256 public auctionEndTime;
    uint256 public reservePrice;
    address public highestBidder;
    uint256 public highestBid;

    bool public auctionEnded;

    event BidPlaced(address bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can call this function");
        _;
    }

    modifier onlyBeforeAuctionEnd() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }

    modifier onlyAfterAuctionEnd() {
        require(block.timestamp >= auctionEndTime, "Auction has not ended");
        _;
    }

    modifier notAuctionEnded() {
        require(!auctionEnded, "Auction has already ended");
        _;
    }

    constructor(
        address _admin,
        address _token,
        uint256 _auctionDuration,
        uint256 _reservePrice
    ) {
        require(_admin != address(0), "Invalid admin address");
        require(_token != address(0), "Invalid token address");
        require(_auctionDuration > 0, "Auction duration must be greater than 0");

        admin = _admin;
        token = IERC20(_token);
        auctionEndTime = block.timestamp + _auctionDuration;
        reservePrice = _reservePrice;
        auctionEnded = false;
    }

}
