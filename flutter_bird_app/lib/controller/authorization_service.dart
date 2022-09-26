import 'dart:convert';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

import '../flutterbirds.g.dart';
import '../model/skin.dart';

/// Authorizes authenticated users to use skins and perks by
/// communicating with smart contracts in order to get the owned NFTs
abstract class AuthorizationService {
  Map<int, Skin>? get skins;
  Future authorizeUser(String? ownerAddress, {Function(List<Skin>?)? onSkinsUpdated});
}

class AuthorizationServiceImpl implements AuthorizationService {

  @override
  Map<int, Skin>? skins;
  final String contractAddress;
  final String rpcUrl;

  AuthorizationServiceImpl({
    required this.contractAddress,
    required this.rpcUrl,
  });

  @override
  Future authorizeUser(String? ethAddress, {Function(List<Skin>?)? onSkinsUpdated}) async {
    if (ethAddress == null) {
      // Reset Skins
      skins = {};
      onSkinsUpdated?.call(skins?.values.toList());
      return;
    }

    Web3Client client = Web3Client(rpcUrl, Client());
    EthereumAddress address = EthereumAddress.fromHex(ethAddress);

    Flutterbirds contract = Flutterbirds(
        address: address,
        client: client
    );

    List<BigInt> tokenIds = await contract.getTokensForOwner(address);
    skins = {};
    List<Future> futures = [];

    for (BigInt tokenId in tokenIds) {

      // Populate with placeholder Skin until metadata is loaded
      String skinName = "Flutter Bird #$tokenId";
      skins?[tokenId.toInt()] = Skin(name: skinName, tokenId: tokenId.toInt());
      onSkinsUpdated?.call(skins?.values.toList());

      futures.add(contract.tokenURI(tokenId).then((tokenUri) async {
        // Replace placeholder with actual skin
        Skin? skin = await getSkin(tokenUri, tokenId.toInt());
        if (skin == null) {
          skins?.remove(tokenId.toInt());
        } else {
          skins?[tokenId.toInt()] = skin;
        }
        onSkinsUpdated?.call(skins?.values.toList());
      }));
    }

    await Future.value(futures);
  }

  /// Uses the token URI to fetch the image file from IPFS
  /// @return the Skin Object with the correct image data
  Future<Skin?> getSkin(String tokenUri, int tokenId) async {
    Uri metadataUrl = Uri.parse(_ipfsUriToGateway(tokenUri));

    print(metadataUrl);

    try {
      Response? metadataResponse = await http.get(metadataUrl, headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*",
      });
      Map<String, dynamic> metadata = jsonDecode(metadataResponse.body);

      String skinName = metadata["name"];
      String imageIpfsUri = metadata["image"];
      String imageUrl = _ipfsUriToGateway(imageIpfsUri);

      print(imageUrl);

      return Skin(
        tokenId: tokenId,
        name: skinName,
        imageLocation: imageUrl
      );

    } on Exception catch (e) {
      print("Failed to load metadata for tokenURI $tokenUri");
      print(e);
    }
    return null;
  }

  // "https://gateway.pinata.cloud/ipfs/"
  // "http://ipfs.io/ipfs/"
  // "https://nftstorage.link/ipfs/"
  String _ipfsUriToGateway(String ipfsUri) => "https://nftstorage.link/ipfs/" + ipfsUri.substring(7);
}