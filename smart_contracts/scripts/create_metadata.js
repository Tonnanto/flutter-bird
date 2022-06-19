const FlutterBirdSkins = artifacts.require("FlutterBirdSkins")
const fs = require('fs')
const {getBreed, getColor} = require("./helper_scrips")
const {generateImage} = require ("./generate_image")

module.exports = async callback => {
    const flutterBirdSkins = await FlutterBirdSkins.deployed()
    length = await flutterBirdSkins.getNumberOfSkins()
    let tokenId = 0
    while (tokenId < length) {
        console.log('Creating metadata for skin ' + tokenId + ' of ' + length)

        // Generate random metadata
        tokenId++
        const skinMetadata = getRandomMetadata(tokenId)

        // Check if metadata exists already
        if (fs.existsSync('outputs/metadata/' + skinMetadata['name'].toLowerCase().replace(/\s/g, '-') + '.json')) {
            console.log('Metadata for ' + skinColor + ' ' + skinBreed + ' already exists')
            continue
        }

        // Write metadata to json file
        const filename = 'outputs/metadata/' + skinMetadata['name'].toLowerCase().replace(/\s/g, '-')
        const data = JSON.stringify(skinMetadata)
        fs.writeFileSync(filename + '.json', data)

        // Create image from metadata
        await generateImage(
            tokenId,
            skinMetadata.attributes[0]['value'],
            skinMetadata.attributes[1]['value'],
            skinMetadata.attributes[2]['value']
        )
    }
    callback(flutterBirdSkins)
}



const traits = require("../layers/traits.json");
const skinMetadata = require('../outputs/metadata/metadata_template.json')

function getRandomMetadata(tokenId) {

    const birdList = traits.bird;
    const headList = traits.head;
    const accessoryList = traits.accessory;

    const randomBird = getRandomWeightedTrait(birdList)
    const randomAccessory = getRandomWeightedTrait(accessoryList)
    const randomHead = getRandomWeightedTrait(headList)

    skinMetadata['name'] = 'Flutter Bird #' + tokenId.toString()
    skinMetadata['attributes'][0]['value'] = randomBird.toLowerCase()
    if (randomAccessory != null)
        skinMetadata['attributes'][1]['value'] = randomAccessory.toLowerCase()
    if (randomHead != null)
        skinMetadata['attributes'][2]['value'] = randomHead.toLowerCase()

    return skinMetadata
}

function getRandomWeightedTrait(traitList) {
    // Calculate total weights
    let totalWeight = 0;
    traitList.forEach(function(trait) {
        totalWeight += trait.weight
    })

    // Get random number
    const randomNumber = Math.random() * totalWeight
    totalWeight = 0;

    // Find trait for random number
    for (let index in traitList) {
        let trait = traitList[index]
        totalWeight += trait.weight
        if (totalWeight >= randomNumber) {
            if (trait.name === "none") return null;
            return trait.name
        }
    }
}