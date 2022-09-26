
# Flutter Bird (Prototype)

**TL;DR** A decentralized Flappy Bird clone making use of NFTs.

Flutter Bird immitates the icon minigame ["Flappy Bird"](https://en.wikipedia.org/wiki/Flappy_Bird) which domitated the AppStores in 2014.
On top of that Flutter Bird adds one basic feature to the original game: The ability to play with alternative skins.
These skins are realised as NFTs on the Ethereum Blockchain.
The Purpose of Flutter Bird is to demonstrate the processes of an Ethereum Authentication and Authorization with NFTs within a Flutter Application.
Flutter Bird has been developed as part of my bachelor thesis.

#### Flutter Application (*Flappy Bird App*)
The Frontend Application is built with Flutter.
The Game Logic as well as Authentication and Authorization processes are implemented in this application.
The Flutter Application is referred to as *Flutter Bird App*.
It runs on iOS, Android and the Web.

#### NFT-Collection (*Flappy Bird Skins*)
The NFT-Collection consists of 1000 Image Files that each represent a different skin for flutter bird.
These images are stored in the IPFS and ownership is managed with an ERC-721 Smart Contract.
The Smart Contract  is referred to as *Flutter Bird Skins*.
It has been deployed on the Ethereum Testnet "Goerli".
*Flutter Bird Skins* can be found on [Etherscan](https://goerli.etherscan.io/token/0x387f544e4c3b2351d015df57c30831ad58d6c798) and on [OpenSea](https://testnets.opensea.io/collection/flutterbirdskins).

## Authors

- [@Tonnanto](https://www.github.com/Tonnanto)


## Features

- Flappy Bird Clone
  - Play Flappy Bird
  - Track your Highscore
- Authenticate using a Cryto Wallet and your Ethereum Account
- Use your *Flutter Bird Skin NFTs* to play the game


## Tech Stack

**Client:** [Flutter](https://flutter.dev/) application for iOS, Android and Web

**Blockchain:** Ethereum ([Goerli Testnet](https://goerli.net/))

**Smart Contract Standard:** [ERC-721](https://ethereum.org/en/developers/docs/standards/tokens/erc-721/)

**Node Provider:** [Alchemy Supernode](https://www.alchemy.com/supernode)

**Storage:** [IPFS](https://ipfs.tech/)


## Demo

![Flutter Bird Demo](demo.gif)

