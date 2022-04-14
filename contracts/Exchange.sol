// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
    address public cryptoDevTokenAddress;

    constructor(address _CryptoDevtoken) ERC20("CryptoDev LP Token", "CDLP") {
        require(
            _CryptoDevtoken != address(0),
            "Token address passed is a null address"
        );
        cryptoDevTokenAddress = _CryptoDevtoken;
    }

    // return CD Token held by the contract
    function getReserve() public view returns (uint256) {
        return ERC20(cryptoDevTokenAddress).balanceOf(address(this));
    }

    function addLiquidity(uint256 _amount) external payable returns (uint256) {
        uint256 liquidity;
        uint256 ethBalance = address(this).balance;
        uint256 cryptoDevTokenReserve = getReserve();
        ERC20 cryptoDevToken = ERC20(cryptoDevTokenAddress);
        // if cryptoDevTokenReserve is empyt,intake any user supplied
        if (cryptoDevTokenReserve == 0) {
            // transfer _amount CDtoken to contract
            cryptoDevToken.transferFrom(msg.sender, address(this), _amount);
            // for first time user
            // mint that much token to user
            liquidity = ethBalance;
            _mint(msg.sender, liquidity);
        } else {
            // reserver already exists
            uint256 ethReserve = address(this).balance - msg.value;
            // ratio should be maintained
            // ratio ->(CDtoken user can add/cryptoDevTokenReserve) = (eth sent by user/ethReserve)
            uint256 cryptoDevTokenAmount = (msg.value * cryptoDevTokenReserve) /
                ethReserve;
            require(
                _amount >= cryptoDevTokenAmount,
                "Amount of tokens sent is less than the minimum tokens required"
            );
            cryptoDevToken.transferFrom(
                msg.sender,
                address(this),
                cryptoDevTokenAmount
            );
            //  calculate liquidity
            // ratio => (LP token to be sent(liquidity)/(total LP token (minted previously)) = (eth sent by user/(eth reserve in contract)))
            liquidity = (totalSupply() * msg.value) / ethReserve;
            _mint(msg.sender, liquidity);
        }
        return liquidity;
    }

    function removeLiquidity(uint256 _amount)
        external
        payable
        returns (uint256, uint256)
    {
        require(_amount > 0, "_amount should be greater than zero");
        uint256 ethReserve = address(this).balance;
        uint256 _totalSupply = totalSupply();
        // code to calculate eth to sent back
        uint256 ethAmount = (_amount * ethReserve) / _totalSupply;
        // code to calculate CDT to sent back
        uint256 cryptoDevTokenAmount = (_amount * getReserve()) / _totalSupply;
        // burn _amount LP from user
        _burn(msg.sender, _amount);
        // sent ethAmount to user
        payable(msg.sender).transfer(ethAmount);
        // sent cryptoDevTokenAmount to user
        ERC20(cryptoDevTokenAddress).transfer(msg.sender, cryptoDevTokenAmount);
        return (ethAmount, cryptoDevTokenAmount);
    }

    // start swap functionality
    function getAmountOfTokens(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) public pure returns (uint256) {
        require(inputReserve > 0 && outputReserve > 0, "invalid reserves");
        // we charge 1% fees
        // inputAfterFee = (inputAmount * 99)/100
        // so the final formulae is Δy = (y*Δx)/(x + Δx);
        // Δx = (inputAmount * 99)/100
        // x = inputReserve
        // y = outputReserve
        uint256 inputAfterFee = inputAmount * 99;
        uint256 numerator = inputAfterFee * outputReserve;
        uint256 denominator = (inputReserve * 100) + inputAfterFee;
        return numerator / denominator;
    }

    // ETH -> CryptoDev Tokens
    function ethToCryptoDevToken(uint256 _minTokens) public payable {
        uint256 tokenReserve = getReserve();
        // inputReserve = address(this).balance - msg.value
        uint256 tokensBought = getAmountOfTokens(
            msg.value,
            address(this).balance - msg.value,
            tokenReserve
        );
        require(tokensBought >= _minTokens, "insufficient output amount");
        ERC20(cryptoDevTokenAddress).transfer(msg.sender, tokensBought);
    }

    // CryptoDev Tokens -> ETH
    function cryptoDevTokenToEth(uint256 _tokensSold, uint256 _minEth) public {
        uint256 tokenReserve = getReserve();
        uint256 ethBought = getAmountOfTokens(
            _tokensSold,
            tokenReserve,
            address(this).balance
        );
        require(ethBought >= _minEth, "insufficient output amount");
        // Transfer `Crypto Dev` tokens from the user's address to the contract
        ERC20(cryptoDevTokenAddress).transferFrom(
            msg.sender,
            address(this),
            _tokensSold
        );
        // send the `ethBought` to the user from the contract
        payable(msg.sender).transfer(ethBought);
    }
}
