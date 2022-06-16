// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract FlutterBirdSkins is ERC721URIStorage {
  address public owner = msg.sender;
  uint public last_completed_migration;
  uint256 tokenCounter;

  // Bird Breeds
  enum Breed{
    FABY,
    TUCAN,
    PARROT,
    PIGEON
  }

  // Mappings
  mapping(uint256 => Breed) tokenIdToBreed;

  // Events
  event createdCollectible(uint256 indexed tokenId);

  constructor() ERC721("FlutterBirdSkins", "FBS") {
    tokenCounter = 1;
  }

  modifier restricted() {
    require(
      msg.sender == owner,
      "This function is restricted to the contract's owner"
    );
    _;
  }

  function setCompleted(uint completed) public restricted {
    last_completed_migration = completed;
  }

  function createCollectible() public {
    // 1. Get next token Id
    uint256 newTokenId = tokenCounter;

    // 2. Set random breed

    // 3. safe mint
    super._safeMint(msg.sender, newTokenId);

    // 4. assign token URI
    super._setTokenURI(newTokenId, Strings.toString(newTokenId));

    // 5. Increase token counter
    tokenCounter++;

    // 6. Emit Event
    emit createdCollectible(newTokenId);
  }

//  function setTokenUri(uint256 tokenId, string memory _tokenURI) public {
//    require(
//      _isApprovedOrOwner(_msgSender(), tokenId),
//      "ERC721: transfer caller is not owner nor approved"
//    );
//    _setTokenURI(tokenId, _tokenURI);
//  }
}
