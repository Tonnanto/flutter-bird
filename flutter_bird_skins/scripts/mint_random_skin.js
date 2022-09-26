const FlutterBirdSkins = artifacts.require("FlutterBirdSkins");


/**
 * This function mints a random Flutter Bird Skin
 */
module.exports = async callback => {
    const flutterBirdSkins = await FlutterBirdSkins.deployed()
    console.log('Minting a random Flutter Bird Skin on contract:', flutterBirdSkins.address)

    // Get minted status list of all tokens
    const mintedStatusList = await flutterBirdSkins.getMintedTokenList();
    // Get random unminted token
    const unmintedTokenId = getUnmintedTokenId(mintedStatusList);

    if (unmintedTokenId === undefined) {
        console.log("No unminted token available. All tokenIds have been minted.")
        return;
    }

    const tx = await flutterBirdSkins.mintSkin(unmintedTokenId, {value: ethToWei(0.01)})

    console.log("Minting successful\nToken ID of new Skin: " + unmintedTokenId);

    callback(tx.tx)
}


/**
 * Converts eth to wei
 */
function ethToWei(ethValue) {
    return ethValue * 1_000_000_000_000_000_000;
}


/**
 *
 * @param mintedStatusList array of boolean values whether the skin at that index has been minted
 * @returns int a random tokenId of an unminted token
 */
function getUnmintedTokenId(mintedStatusList) {
    let tokenIds = [];
    for (let i = 0; i < mintedStatusList.length; i++) {
        if (!mintedStatusList[i]) {
            tokenIds.push(i);
        }
    }
    return tokenIds[Math.floor(Math.random() * tokenIds.length)];
}
