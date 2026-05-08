// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title TokenFaucet
 * @notice Distribute tokens - 100 per user per day
 */
contract TokenFaucet {
    
    address public owner;
    address public tokenAddress;
    uint256 public constant DAILY_AMOUNT = 100 * 10**18; // 100 tokens
    
    mapping(address => uint256) public lastClaimTime;
    mapping(address => uint256) public totalClaimed;
    
    event TokensClaimed(address indexed user, uint256 amount, uint256 timestamp);
    
    constructor(address _tokenAddress) {
        owner = msg.sender;
        tokenAddress = _tokenAddress;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    function claimTokens() external {
        uint256 lastClaim = lastClaimTime[msg.sender];
        uint256 oneDay = 1 days;
        
        require(block.timestamp >= lastClaim + oneDay, "Wait 24 hours");
        
        lastClaimTime[msg.sender] = block.timestamp;
        totalClaimed[msg.sender] += DAILY_AMOUNT;
        
        // Transfer tokens (would need token to have mint function or have balance)
        emit TokensClaimed(msg.sender, DAILY_AMOUNT, block.timestamp);
    }
    
    function timeUntilNextClaim(address user) external view returns (uint256) {
        uint256 lastClaim = lastClaimTime[user];
        uint256 nextClaimTime = lastClaim + 1 days;
        
        if (block.timestamp >= nextClaimTime) {
            return 0;
        }
        return nextClaimTime - block.timestamp;
    }
    
    function getUserStats(address user) external view returns (uint256 claimed, uint256 timeLeft) {
        return (totalClaimed[user], this.timeUntilNextClaim(user));
    }
}
