// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract FlutterBirdSkins is ERC721Enumerable {
  using Strings for uint256;

  uint256 private _maxSupply = 1000;
  uint256 private _mintPrice = 0.01 ether;

  // Optional mapping for token URIs
  mapping(uint256 => string) private _tokenURIs;

  // Assign owner on contract creation
  address public owner = msg.sender;

  constructor() ERC721("FlutterBirdSkins", "FBS") {}

  event SkinMinted(uint256 indexed tokenId);

  function mintSkin(uint256 newTokenId) public payable {
    require(newTokenId < _maxSupply, "invalid tokenId. must be #999");
    require(msg.value >= _mintPrice, "insufficient funds");

    _safeMint(msg.sender, newTokenId);

    string memory _tokenURI = string.concat(Strings.toString(newTokenId), ".json");
    _setTokenURI(newTokenId, _tokenURI);

    emit SkinMinted(newTokenId);
  }

  /**
   * @notice returns a list of tokenIds that are owned by the given address
   */
  function getTokensForOwner(address _owner) public view returns (uint[] memory) {
    uint[] memory _tokensOfOwner = new uint[](ERC721.balanceOf(_owner));
    uint i;

    for (i=0; i < ERC721.balanceOf(_owner); i++) {
      _tokensOfOwner[i] = ERC721Enumerable.tokenOfOwnerByIndex(_owner, i);
    }
    return (_tokensOfOwner);
  }

  /**
   * @notice returns a list of boolean values indicating whether the skin with that index has been minted already.
   */
  function getMintedTokenList() public view returns (bool[] memory) {
    bool[] memory _unmintedTokes = new bool[](_maxSupply);
    uint i;

    for (i = 0; i < _maxSupply; i++) {
      if (_exists(i)) {
        _unmintedTokes[i] = true;
      }
    }
    return _unmintedTokes;
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return "ipfs://bafybeiexvqt3uabqzmhquokzyl7gcdxyowz2hf2hdbbifkkyx3waghezqe/";
  }

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

  function setTokenUri(uint256 tokenId, string memory _tokenURI) public {
    require(
      _isApprovedOrOwner(_msgSender(), tokenId),
      "ERC721: transfer caller is not owner nor approved"
    );
    _setTokenURI(tokenId, _tokenURI);
  }

  function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
    require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
    _tokenURIs[tokenId] = _tokenURI;
  }
}
