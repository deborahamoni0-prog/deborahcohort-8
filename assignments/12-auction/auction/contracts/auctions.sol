// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract auctions {
    address payable public owner;

    uint256 public startingPrice;
    uint256 public auctionEndTime;
    address public highestBidder;
    uint256 public highestBid;
    bool public auctionEnded;
    uint256 public amount;
    uint256 public durationInSeconds;

    mapping(address => uint256) public pendingRefunds;

    event AuctionStarted(uint256 startingPrice, uint256 duration);
    event BidPlaced(address indexed bidder, uint256 amount);
    event AuctionEnded(address indexed winner, uint256 amount);
    event RefundClaimed(address indexed bidder, uint256 amount);

    error OnlyOwner();
    error AuctionAlreadyEnded();
    error BidTooLow();
    error AuctionNotEnded();
    error AuctionAlreadyEndedError();
    error RefundFailed();
    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }
    modifier auctionActive() {
        if (block.timestamp >= auctionEndTime) revert AuctionAlreadyEnded();
        _;
    }

    constructor(
        uint256 _startingPrice,
        uint256 _durationInSeconds,
        uint256 _auctionEndTime,
        address payable _owner
    ) {
        require(_startingPrice > 0, "Starting price must be greater than 0");
        require(_durationInSeconds > 0, "Duration must be greater than 0");

        owner = _owner;
        startingPrice = _startingPrice;
        auctionEndTime = block.timestamp + _durationInSeconds;
        auctionEnded = false;

        emit AuctionStarted(_startingPrice, _durationInSeconds);
    }

    function startbid() external payable auctionActive {
        if (msg.value < startingPrice) revert BidTooLow();
        if (msg.value <= highestBid) revert BidTooLow();
        if (block.timestamp >= auctionEndTime) revert AuctionAlreadyEnded();

        if (highestBidder != address(0)) {
            pendingRefunds[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit BidPlaced(msg.sender, msg.value);
    }

    function withdrawRefund() external {
        uint256 refundAmount = pendingRefunds[msg.sender];
        if (refundAmount == 0) revert RefundFailed();

        pendingRefunds[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: refundAmount}("");
        if (!success) {
            pendingRefunds[msg.sender] = refundAmount;
            revert RefundFailed();
        }

        emit RefundClaimed(msg.sender, refundAmount);
    }

    function auctionEnd() external onlyOwner {
        if (auctionEnded) revert AuctionAlreadyEndedError();
        auctionEnded = true;

        if (block.timestamp < auctionEndTime) revert AuctionNotEnded();
        if (highestBid == 0) {
            emit AuctionEnded(address(0), 0);
            return;
        }
        emit AuctionEnded(highestBidder, highestBid);
    }
}
