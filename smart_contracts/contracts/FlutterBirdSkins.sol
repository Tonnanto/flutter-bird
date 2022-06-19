// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract FlutterBirdSkins is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  // Assign owner on contract creation
  address public owner = msg.sender;

  // Token DNA contains traits encoded in a bitfield
  mapping(uint256 => uint8) public tokenIdToDna;

  // Events
  event createdCollectible(uint256 indexed tokenId);

  constructor() ERC721("FlutterBirdSkins", "FBS") {}

  function createCollectible() public {
    // 1. Get next token Id
    uint256 newTokenId = _tokenIds.current();

    // 2. safe mint
    super._safeMint(msg.sender, newTokenId);

    // 3. assign token URI
    super._setTokenURI(newTokenId, "Metadata not yet generated");

    // 4. Increase token counter
    _tokenIds.increment();

    // 5. Emit Event
    emit createdCollectible(newTokenId);
  }

  function getNumberOfSkins() public view returns (uint256) {
    return _tokenIds._value;
  }

//  function setTokenUri(uint256 tokenId, string memory _tokenURI) public {
//    require(
//      _isApprovedOrOwner(_msgSender(), tokenId),
//      "ERC721: transfer caller is not owner nor approved"
//    );
//    _setTokenURI(tokenId, _tokenURI);
//  }
}
