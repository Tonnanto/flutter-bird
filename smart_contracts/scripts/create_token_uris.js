const FlutterBirdSkins = artifacts.require("FlutterBirdSkins")
const {generateImage} = require ("./generate_image")
const {generateMetadata} = require ("./generate_metadata")
const {uploadToIpfs} = require ("./upload_to_ipfs")

module.exports = async callback => {
    const flutterBirdSkins = await FlutterBirdSkins.deployed()
    length = await flutterBirdSkins.getNumberOfSkins()
    let tokenId = 0
    while (tokenId < length) {

        // Generate random metadata
        tokenId++
        const skinMetadata = generateMetadata(tokenId)

        if (skinMetadata == null) continue

        // Create image from metadata
        const imageData = await generateImage(
            tokenId,
            skinMetadata.attributes[0]['value'],
            skinMetadata.attributes[1]['value'],
            skinMetadata.attributes[2]['value'],
            skinMetadata.attributes[3]['value'],
            skinMetadata.attributes[4]['value'],
        )

        // Upload image to IPFS
        await uploadToIpfs(imageData);



        // Add URL to metadata
        // Upload metadata to IPFS
        // Set tokenUri
    }
    callback()
}