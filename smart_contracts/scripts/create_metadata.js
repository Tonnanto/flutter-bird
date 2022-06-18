const FlutterBirdSkins = artifacts.require("FlutterBirdSkins");
const fs = require('fs')
const {getBreed, getColor} = require("./helper_scrips");

module.exports = async callback => {
    const flutterBirdSkins = await FlutterBirdSkins.deployed()
    length = await flutterBirdSkins.getNumberOfSkins()
    let tokenId = 0
    while (tokenId < length) {
        console.log('Creating metadata for skin ' + tokenId + ' of ' + length)
        const skinMetadata = require('../outputs/metadata/metadata_template.json')
        const skinBreedId = (await flutterBirdSkins.tokenIdToBreed.call(tokenId)).words[0]
        const skinBreed = getBreed(skinBreedId)
        const skinColorId = (await flutterBirdSkins.tokenIdToColor.call(tokenId)).words[0]
        const skinColor = getColor(skinColorId)
        tokenId++
        skinMetadata['name'] = skinColor + ' ' + skinBreed
        if (fs.existsSync('metadata/' + skinMetadata['name'].toLowerCase().replace(/\s/g, '-') + '.json')) {
            console.log('Metadata for ' + skinColor + ' ' + skinBreed + ' already exists')
            continue
        }
        console.log(skinMetadata['name'])
        skinMetadata['attributes'][0]['value'] = skinBreed.toLowerCase()
        skinMetadata['attributes'][1]['value'] = skinColor.toLowerCase()
        const filename = 'metadata/' + skinMetadata['name'].toLowerCase().replace(/\s/g, '-')
        const data = JSON.stringify(skinMetadata)
        fs.writeFileSync(filename + '.json', data)
    }
    callback(flutterBirdSkins)
}