const FlutterBirdSkins = artifacts.require("FlutterBirdSkins");

module.exports = async callback => {
    const flutterBirdSkins = await FlutterBirdSkins.deployed()
    console.log('Creating one Collectible (Flutter Bird Skin) on contract:', flutterBirdSkins.address)
    // TODO: Find unminted tokenIds
    const tx = await flutterBirdSkins.createCollectible(20)
    callback(tx.tx)
}
