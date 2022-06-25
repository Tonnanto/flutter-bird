
const  fs = require("fs");
const { createCanvas, loadImage } = require("canvas");

const imageSize = {
    width: 750,
    height: 750
};

async function generateImage(tokenId, bird, head, eyes, mouth, neck) {

    // Create Canvas
    const canvas = createCanvas(imageSize.width, imageSize.height);
    const context = canvas.getContext("2d");

    const outputDirectory = "../output/images"
    const birdDirectory = "../input/layers/bird"
    const headDirectory = "../input/layers/head"
    const eyesDirectory = "../input/layers/eyes"
    const mouthDirectory = "../input/layers/mouth"
    const neckDirectory = "../input/layers/neck"

    // Draw bird first
    const birdImage = await loadImage(`${birdDirectory}/${bird}.png`);
    context.drawImage(birdImage, 0, 0, imageSize.width, imageSize.height);

    // Draw neck
    if (neck != null && neck !== "") {
        const neckImage = await loadImage(`${neckDirectory}/${neck}.png`);
        context.drawImage(neckImage, 0, 0, imageSize.width, imageSize.height);
    }

    // Draw mouth
    if (mouth != null && mouth !== "") {
        const mouthImage = await loadImage(`${mouthDirectory}/${mouth}.png`);
        context.drawImage(mouthImage, 0, 0, imageSize.width, imageSize.height);
    }

    // Draw eyes
    const eyesImage = await loadImage(`${eyesDirectory}/${eyes}.png`);
    context.drawImage(eyesImage, 0, 0, imageSize.width, imageSize.height);

    // Draw head
    if (head != null && head !== "") {
        const headImage = await loadImage(`${headDirectory}/${head}.png`);
        context.drawImage(headImage, 0, 0, imageSize.width, imageSize.height);
    }

    // Save image as png
    fs.writeFileSync(
        `${outputDirectory}/#${tokenId}.png`,
        canvas.toBuffer("image/png")
    );
}

module.exports = { generateImage }
