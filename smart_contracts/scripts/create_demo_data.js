
const {generateImage} = require ("./generate_image")
const {generateMetadata} = require ("./generate_metadata")

// Test data generation
for (let tokenId = 0; tokenId < 500; tokenId++) {

    // Generate random metadata
    const skinMetadata = generateMetadata(tokenId)

    if (skinMetadata == null) continue

    // Create image from metadata
    generateImage(
        tokenId,
        skinMetadata.attributes[0]['value'],
        skinMetadata.attributes[1]['value'],
        skinMetadata.attributes[2]['value'],
        skinMetadata.attributes[3]['value'],
        skinMetadata.attributes[4]['value'],
    )
}