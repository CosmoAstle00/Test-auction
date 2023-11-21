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

 function placeBid(uint256 _amount) external notAuctionEnded onlyBeforeAuctionEnd {
        require(_amount > highestBid, "Bid must be greater than the current highest bid");
        require(_amount >= reservePrice, "Bid must be greater than or equal to the reserve price");

        if (highestBidder != address(0)) {
            // Refund the previous highest bidder
            require(token.transfer(highestBidder, highestBid), "Token transfer failed");
        }

        // Update highest bidder and bid amount
        highestBidder = msg.sender;
        highestBid = _amount;

        // Transfer the bid amount to the contract
        require(token.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");

        emit BidPlaced(msg.sender, _amount);
    }
function endAuction() external onlyAdmin onlyAfterAuctionEnd notAuctionEnded {
        // Mark the auction as ended
        auctionEnded = true;

        if (highestBidder != address(0)) {
            // Transfer the tokens to the highest bidder
            require(token.transfer(highestBidder, highestBid), "Token transfer failed");
        }

        emit AuctionEnded(highestBidder, highestBid);
    }
}
