import 'package:flappy_bird/flutterbirds.g.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

import '../model/skin.dart';

 const String contractAddress = '0x5c3812763c095733c2EaE3854a61BEDFDDA09117';
const String rpcUrl = 'http://localhost:7545'; // Local Ganache Chain

/// Authorizes authenticated users to use skins and perks by
/// communicating with smart contracts in order to get the owned NFTs
class AuthorizationService {

  Future<List<Skin>> getSkinsForOwner(String? ownerAddress) async {

    if (ownerAddress == null) {
      return [];
    }

    final client = Web3Client(rpcUrl, Client());

    Flutterbirds contract = Flutterbirds(
        address: EthereumAddress.fromHex(contractAddress),
        client: client
    );

    var _owner = EthereumAddress.fromHex(ownerAddress);
    List<BigInt> tokenIds = await contract.getTokensForOwner(_owner);


    List<Skin> skins = [];
    for (BigInt tokenId in tokenIds) {
      String tokenUri = await contract.tokenURI(tokenId);
      print(tokenUri);
    }

    return skins;
  }
}