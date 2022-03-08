// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// inherit ERC721 storage class
contract NFT is ERC721URIStorage{
  using Counters for Counters.Counter;

 // Set variables for this contract
  // using counters.counter util func to increment the token ids (when a NFT is minted, we will need to assign a token Id with increment )
  Counters.Counter private _tokenIds;
  // need to fetch the address 
  address contractAddress;

  constructor (address _marketplaceAddress)ERC721("Metaverse Token", "METT"){
    constractAddress = _marketplaceAddress;
  }

  function createToken(string memory _tokenURI) public returns(unit){
    _tokenIds.increment();
    uint256 newItemId = _tokenIds.current();

    _mint(msg.sender, newItemId);
    _setTokenURI(newItemId, _tokenURI);
    setApprovalForAll(contractAdress, true);

    // return new item id for frontend (What about the emit event)
    return newItemId;
  }
}