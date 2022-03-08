// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// security control helper to secure the transactions
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarket is ReentrancyGuard{
    using Counters for Counters.Counter;
  
    Counters.Counter private _itemIds;
    // number of items sold
    counters.Coutner private _itemsSold;

    address payable owner;
    uint256 listingPrice = 0.025 ether;

    constructor(){
      owner = payable(msg.sender);
    }

// Define MarketItem Object (struct === object)
    struct MarketItem{
      uint itemId;
      address nftContract;
      uint256 tokenId;
      address payable seller;
      address payable owner;
      uint256 price;
      bool sold;
    }

// Mapping all itemIds ( which is uint256 ) and return MarketItem
  mapping(uint256 => MarketItem) private idToMarketItem;

  // Create an event for each time an item is created
  event MarketItemCreated(
      uint indexed itemId,
      address indexed nftContract,
      uint256 indexed tokenId,
      address  seller,
      address  owner,
      uint256 price,
      bool sold
  );

  // create a function to return a listing price
  function getListingPrice() public view returns(uint256){
    return listingPrice;
  }

  // create a function to create a market item
  function createMarketItem(address _nftContract, uint256 _tokenId, uint256 _price) public payable nonReentrant{
    require(price > 0,  "Price must be at least 1 wei");
    // msg.value refers to the Cryto / Eth that the sender sent
    require(msg.value == listingPrice, "Price must be equal to listing price");
    _itemIds.increment();
    uint256 itemId = _itemIds.current();

    idToMarketItem[itemId] = MarketItem(
      itemId,
      _nftContract,
      _tokenId,
      payable(msg.sender),
      // owner is not yet defined
      payable(address(0)),
      _price,
      false
    );

    // after creating a market item, NFT original owner will transfer the item ownership to the contract
    // address(this) refers to contract
    IERC721(_nftContract).transformFrom(msg.sender, address(this), _tokenId);

    emit MarketItemCreated(
      itemId,
      _nftContract,
      _tokenId,
      msg.sender,
      address(0),
      _price,
      false
    );
  }

  // create a function for sale market item
  function createMarketSale(address _nftContract, uint256 _itemId) public payable nonReentrant{
    uint256 itemPrice = idToMarketItem[_itemId].price;
    uint256 tokenId = idToMarketItem[_itemId].tokenId;

    // msg.value refers to the Cryto / Eth that the sender sent
    require(msg.value == itemPrice, "Please submit the asking price to complete the purchase");

    // transfer the cryto value to the owner of address (send money to the seller)
    idToMarketItem[itemId].seller.transer(msg.value);
    // transfer the ownership of the digital asset from the contract to the buyer (msg.sender)
    IERC721(_nftContract).transferFrom(address(this), msg.sender. tokenId);
    // update the marketItem owner data
    idToMarketItem[itemId].owner = payable(msg.sender);
  idToMarketItem[itemId].sold = true;
  _itemsSold.increment();

// commission for the item sale to the market place
  payable(owner).transfer(listingPrice);
  }

  // create a function for view - market items that are unsold / stil on the market
  function fetchMarketItems() public view returns(MarketItem[] memory){
    // total number of items that we have created
    uint itemCount = _itemIds.current();
    // total number of unsold items
    uint unsoldItemCount = _itemsIds.current() - _itemsSold.current();
    uint currentIndex = 0;

// create an empty array of market items variable name = items
    MarketItem[] memory items = new MarketItem[](unsoldItemCount);
    for (uint i = 0; i <itemCount; i++){
      // when we list an item, owner of the item is saved as address(0)
      // check if the item is sold or owned by anyone
      if(idToMarketItem[i+1].owner == address(0)){
        // unsold items
        uint currentId = idToMarketItem[i+1].itemId;
        MarketItem storage currentItem = idToMarketItem[currentId];
        // add to the items array
        items[currentItem] = currentItem;
        currentIndex +=1;
      }
    }
    return items;
  }

// create a function that user owned
function fetchMyNFTs() public view returns(MarketItem[] memory){
  uint ownerAddress = msg.sender;
  uint totalItemCount = _itemIds.current();
  uint itemCount = 0;
  uint currentIndex = 0;

  // get the number of items that the users own
  for (uint i = 0; i < totalItemCount ; i ++){
    if (idToMarketItem[i+1].owner == ownerAddress){
      itemCount+=1;
    }
  }

  MarketItem[] memory items = new MarketItem[](itemCount);
  for (uint i = 0 ; i< totalItemCount; i++){
        if (idToMarketItem[i+1].owner == ownerAddress){
        uint currentId = idToMarketItem[i+1].itemId;
        MarketItem storage currentItem = idToMarketItem[currentId];
        // add to the items array
        items[currentItem] = currentItem;
        currentIndex +=1;
    }
  }
  return items;
}

function fetchMyListingNFTs() public view returns(MarketItems[] memory){
    uint currentUserAddress = msg.sender;
  uint totalItemCount = _itemIds.current();
  uint itemCount = 0;
  uint currentIndex = 0;


  // get the number of items that the users listed
  for (uint i = 0; i < totalItemCount ; i ++){
    if (idToMarketItem[i+1].seller == currentUserAddress){
      itemCount+=1;
    }
  }

  MarketItem[] memory items = new MarketItem[](itemCount);

  for (uint i = 0 ; i < totalItemCount; i++){
        if (idToMarketItem[i+1].seller == currentUserAddress){
        uint currentId = idToMarketItem[i+1].itemId;
        MarketItem storage currentItem = idToMarketItem[currentId];
        // add to the items array
        items[currentItem] = currentItem;
        currentIndex +=1;
    }
  }
  return items;
  }
}