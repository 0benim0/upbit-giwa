// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title TokenFaucet
 * @notice Distribute ERC20 tokens - 100 per user per day
 */

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenFaucet {
    
    address public owner;
    IERC20 public token;
    uint256 public constant DAILY_AMOUNT = 100 * 10**18; // 100 tokens
    
    mapping(address => uint256) public lastClaimTime;
    mapping(address => uint256) public totalClaimed;
    
    event TokensClaimed(address indexed user, uint256 amount, uint256 timestamp);
    
    constructor(address _tokenAddress) {
        owner = msg.sender;
        token = IERC20(_tokenAddress);
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    /**
     * @notice Claim 100 tokens once per 24 hours
     */
    function claimTokens() external {
        uint256 lastClaim = lastClaimTime[msg.sender];
        uint256 oneDay = 1 days;
        
        require(block.timestamp >= lastClaim + oneDay, "Wait 24 hours");
        require(token.balanceOf(address(this)) >= DAILY_AMOUNT, "Insufficient faucet balance");
        
        lastClaimTime[msg.sender] = block.timestamp;
        totalClaimed[msg.sender] += DAILY_AMOUNT;
        
        // Transfer tokens to user
        require(token.transfer(msg.sender, DAILY_AMOUNT), "Transfer failed");
        
        emit TokensClaimed(msg.sender, DAILY_AMOUNT, block.timestamp);
    }
    
    /**
     * @notice Check time until next claim
     */
    function timeUntilNextClaim(address user) external view returns (uint256) {
        uint256 lastClaim = lastClaimTime[user];
        uint256 nextClaimTime = lastClaim + 1 days;
        
        if (block.timestamp >= nextClaimTime) {
            return 0;
        }
        return nextClaimTime - block.timestamp;
    }
    
    /**
     * @notice Get user stats
     */
    function getUserStats(address user) external view returns (uint256 claimed, uint256 timeLeft) {
        return (totalClaimed[user], this.timeUntilNextClaim(user));
    }
    
    /**
     * @notice Owner deposit tokens
     */
    function depositTokens(uint256 amount) external onlyOwner {
        require(token.transferFrom(msg.sender, address(this), amount), "Deposit failed");
    }
    
    /**
     * @notice Owner withdraw tokens
     */
    function withdrawTokens(uint256 amount) external onlyOwner {
        require(token.transfer(msg.sender, amount), "Withdraw failed");
    }
    
    /**
     * @notice Get faucet balance
     */
    function getBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }
}
