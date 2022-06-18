
const  fs = require("fs");
const { createCanvas, loadImage } = require("canvas");

const imageSize = {
    width: 750,
    height: 750
};

async function generateImage(tokenId, bird, head, accessory) {

    // Create Canvas
    const canvas = createCanvas(imageSize.width, imageSize.height);
    const context = canvas.getContext("2d");

    const outputDirectory = "../outputs/images"
    const birdDirectory = "../layers/bird"
    const accessoryDirectory = "../layers/accessory"
    const headDirectory = "../layers/head"

    // Draw bird first
    const birdImage = await loadImage(`${birdDirectory}/${bird}.png`);
    context.drawImage(birdImage, 0, 0, imageSize.width, imageSize.height);

    // Draw accessory
    if (accessory != null) {
        const accessoryImage = await loadImage(`${accessoryDirectory}/${accessory}.png`);
        context.drawImage(accessoryImage, 0, 0, imageSize.width, imageSize.height);
    }

    // Draw hat
    if (head != null) {
        const headImage = await loadImage(`${headDirectory}/${head}.png`);
        context.drawImage(headImage, 0, 0, imageSize.width, imageSize.height);
    }

    // Save image as png
    fs.writeFileSync(
        `${outputDirectory}/${tokenId}.png`,
        canvas.toBuffer("image/png")
    );
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


// Test image generation
const traits = require("../layers/traits.json");

for (let index = 0; index < 500; index++) {

    const birdList = traits.bird;
    const headList = traits.head;
    const accessoryList = traits.accessory;

    const randomBird = getRandomWeightedTrait(birdList)
    const randomAccessory = getRandomWeightedTrait(accessoryList)
    const randomHead = getRandomWeightedTrait(headList)

    generateImage(index, randomBird, randomHead, randomAccessory)
}
