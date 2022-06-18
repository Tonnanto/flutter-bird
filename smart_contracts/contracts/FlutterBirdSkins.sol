// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract FlutterBirdSkins is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  address public owner = msg.sender;
  uint public last_completed_migration;

  // Bird Breeds
  enum Breed {
    FABY,
    TUCAN,
    PARROT,
    PIGEON
  }

  // Bird Colors
  enum Color {
    YELLOW,
    RED,
    GREEN,
    BLUE,
    PINK
  }

  // Mappings
  mapping(uint256 => uint) public tokenIdToBreed;
  mapping(uint256 => uint) public tokenIdToColor;

  // Events
  event createdCollectible(uint256 indexed tokenId);

  constructor() ERC721("FlutterBirdSkins", "FBS") {}

  function createCollectible() public {
    // 1. Get next token Id
    uint256 newTokenId = _tokenIds.current();

    // TODO: Get random number from Chainlink VRF

    // 2. Set random breed and color
    Breed breed = Breed(newTokenId % 4);
    Color color = Color(newTokenId % 5);
    tokenIdToBreed[newTokenId] = uint(breed);
    tokenIdToColor[newTokenId] = uint(color);

    // 3. safe mint
    super._safeMint(msg.sender, newTokenId);

    // 4. assign token URI
    super._setTokenURI(newTokenId, Strings.toString(newTokenId));

    // 5. Increase token counter
    _tokenIds.increment();

    // 6. Emit Event
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
