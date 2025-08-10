// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title HAIP Presale Contract
/// @notice Accepts USDT, sends HAIP, and forwards funds to the owner's wallet

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 value) external returns (bool);
}

contract HaipPresale {
    address public owner = 0xD82D9eB1C0D36fBEA8e48898B5e4B88Ae82011De;
    IERC20 public usdt;
    IERC20 public haip;

    // 0.0036 USDT per HAIP, expressed in fractions of 10,000 for precision
    uint256 public pricePerToken = 36;
    uint256 public constant PRICE_DENOMINATOR = 10000;
    // Adjusts USDT's 6 decimals to HAIP's 18 decimals (10^(18-6))
    uint256 public constant DECIMALS_ADJUSTMENT = 1e12;

    uint256 public tokensSold;

    constructor(address _usdt, address _haip) {
        usdt = IERC20(_usdt);
        haip = IERC20(_haip);
    }

    function buy(uint256 usdtAmount) external {
        // usdtAmount is expected in 6 decimals
        require(usdtAmount >= 9720000 && usdtAmount <= 194400000,
            "Must be between 9.72 and 194.4 USDT (in 6 decimals)");

        uint256 tokensToReceive = usdtAmount * PRICE_DENOMINATOR * DECIMALS_ADJUSTMENT / pricePerToken;

        require(haip.transfer(msg.sender, tokensToReceive), "HAIP transfer failed");
        require(usdt.transferFrom(msg.sender, owner, usdtAmount), "USDT transfer failed");

        tokensSold += tokensToReceive;
    }

    function setPrice(uint256 newPrice) external {
        require(msg.sender == owner, "Only owner can set price");
        require(newPrice > 0, "Price must be positive");
        pricePerToken = newPrice;
    }

    function withdrawTokens(address token, uint256 amount) external {
        require(msg.sender == owner, "Only owner can withdraw");
        IERC20(token).transfer(owner, amount);
    }
}
