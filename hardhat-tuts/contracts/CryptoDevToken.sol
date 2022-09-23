// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable {
    // CryptoDevsNft contract Instance
    //type keeps track of our variable
    ICryptoDevs CryptoDevsNft;
    uint256 public constant tokenPrice = 0.001 ether;
    uint256 public constant tokensPerNFT = 10 * 10**18;
    uint256 public constant maxTotalSupply = 10000 * 10**18;

    // Keeping track of how many tokens have been claimed
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _cryptoDevsContract) ERC20("Crypto Dev Token", "CD") {
        //we need to specify which cryptodev address we want to keep track of
        //because they can be multiple same kind of contract address
        CryptoDevsNft = ICryptoDevs(_cryptoDevsContract);
    }

    /**
     Mints `amount` number of CryptoDevTokens
       * Requirements:
       * - `msg.value` should be equal or greater than the tokenPrice * amount
       */
    function mint(uint256 amount) public payable {
        // the value of ether that should be equal or greter than tokenPrice * amount;
        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value >= _requiredAmount, "Ether sent is incorrect");

        // total tokens + amount <= 1000, otherwise revert the transaction
        uint256 amountWithDecimals = amount * 10**18;
        require(
            (totalSupply() + amountWithDecimals) <= maxTotalSupply,
            "Exceeds the max total supply availble."
        );
        // call the internal function from Openzeppelin's ERC20 contract
        _mint(msg.sender, amountWithDecimals);
    }

    //the number of token i can claim based on the number of NFTs
    //Requirements: * balance of Crypto Dev NFT's owned by the sender should be greater than 0
    // * Tokens should have not been claimed for all the NFTs owned by the sender
    function claim() public {
        address sender = msg.sender;

        // Get the number of CryptoDev NFT's held by a given sender address
        uint256 balance = CryptoDevsNft.balanceOf(sender);

        // If the balance is zero, revert the transaction
        require(balance > 0, "You don't own any Crypto Dev NFT's");

        // amount keeps track of number of unclaimed tokenIds
        uint256 amount = 0;

        // Loop over the balance and get the token ID owned by 'Sender' at a given
        // 'index' of its token list.
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = CryptoDevsNft.tokenOfOwnerByIndex(sender, i);
            if (!tokenIdsClaimed[tokenId]) {
                amount += 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }

        // If all the token Ids have been claimed, revert the transaction;
        //checking if the amount is greater than 0.
        require(amount > 0, "You have already claimed all the tokens");

        // call the internal function from oppenzeppelin's ERC20 contract
        // Mint (amount * 10) tokens for each NFT
        _mint(msg.sender, amount * tokensPerNFT);
    }

    /**
        withdraws all ETH and tokens sent to the contract
        * Requirements:
        * wallet connected must be owner's address
        */
    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
