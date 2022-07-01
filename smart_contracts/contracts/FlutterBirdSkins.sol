// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract FlutterBirdSkins is ERC721Enumerable {
  using Counters for Counters.Counter;
  using Strings for uint256;

  Counters.Counter private _tokenIds;

  // Optional mapping for token URIs
  mapping(uint256 => string) private _tokenURIs;

  // Assign owner on contract creation
  address public owner = msg.sender;

  // Events
  event createdCollectible(uint256 indexed tokenId);

  constructor() ERC721("FlutterBirdSkins", "FBS") {}

  function createCollectible() public returns (uint256) {
    // 1. Get next token Id
    uint256 newTokenId = _tokenIds.current();

    // 2. safe mint
    _safeMint(msg.sender, newTokenId);

    // 3. assign token URI
    _setTokenURI(newTokenId, "Metadata not yet generated");

    // 4. Increase token counter
    _tokenIds.increment();

    // 5. Emit Event
    emit createdCollectible(newTokenId);

    return newTokenId;
  }

  function getNumberOfSkins() public view returns (uint256) {
    return _tokenIds._value;
  }

  function getTokensForOwner(address _owner) public view returns (uint[] memory) {
    uint[] memory _tokensOfOwner = new uint[](ERC721.balanceOf(_owner));
    uint i;

    for (i=0; i < ERC721.balanceOf(_owner); i++){
      _tokensOfOwner[i] = ERC721Enumerable.tokenOfOwnerByIndex(_owner, i);
    }
    return (_tokensOfOwner);
  }

  // TODO: Used to set token URI after mint
  function setTokenUri(uint256 tokenId, string memory _tokenURI) public {
//    require(
//      _isApprovedOrOwner(_msgSender(), tokenId),
//      "ERC721: transfer caller is not owner nor approved"
//    );
    _setTokenURI(tokenId, _tokenURI);
  }

  /**
   * @dev See {IERC721Metadata-tokenURI}.
   */
  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

    string memory _tokenURI = _tokenURIs[tokenId];
    string memory base = _baseURI();

    // If there is no base URI, return the token URI.
    if (bytes(base).length == 0) {
      return _tokenURI;
    }
    // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
    if (bytes(_tokenURI).length > 0) {
      return string(abi.encodePacked(base, _tokenURI));
    }

    return tokenURI(tokenId);
  }

  /**
   * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
   *
   * Requirements:
   *
   * - `tokenId` must exist.
   */
  function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
    require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
    _tokenURIs[tokenId] = _tokenURI;
  }

  /**
   * @dev Destroys `tokenId`.
   * The approval is cleared when the token is burned.
   *
   * Requirements:
   *
   * - `tokenId` must exist.
   *
   * Emits a {Transfer} event.
   */
  function _burn(uint256 tokenId) internal virtual override {
    super._burn(tokenId);

    if (bytes(_tokenURIs[tokenId]).length != 0) {
      delete _tokenURIs[tokenId];
    }
  }
}
