
const  fs = require("fs");
const { createCanvas, loadImage } = require("canvas");

const imageSize = {
    width: 750,
    height: 750
};

async function generateImage(tokenId, bird, accessory, head) {

    // Create Canvas
    const canvas = createCanvas(imageSize.width, imageSize.height);
    const context = canvas.getContext("2d");

    const outputDirectory = "./outputs/images"
    const birdDirectory = "./layers/bird"
    const accessoryDirectory = "./layers/accessory"
    const headDirectory = "./layers/head"

    // Draw bird first
    const birdImage = await loadImage(`${birdDirectory}/${bird}.png`);
    context.drawImage(birdImage, 0, 0, imageSize.width, imageSize.height);

    // Draw accessory
    if (accessory != null && accessory !== "") {
        const accessoryImage = await loadImage(`${accessoryDirectory}/${accessory}.png`);
        context.drawImage(accessoryImage, 0, 0, imageSize.width, imageSize.height);
    }

    // Draw hat
    if (head != null && head !== "") {
        const headImage = await loadImage(`${headDirectory}/${head}.png`);
        context.drawImage(headImage, 0, 0, imageSize.width, imageSize.height);
    }

    // Save image as png
    fs.writeFileSync(
        `${outputDirectory}/${tokenId}.png`,
        canvas.toBuffer("image/png")
    );
}

module.exports = { generateImage }
