const fs = require('fs');

const dirname = "../output/metadata"

const cid = "bafybeib3ss7fb7wejue2b7nv3frucl3xvhd27yycyw37csodsytvv5ipou";

fs.readdir(dirname, function (err, filenames) {
    if (err) {
        console.error(err)
        return
    }
    filenames.forEach(function (filename) {
        const filePath = dirname + "/" + filename;
        fs.readFile(filePath, 'utf-8', function (err, content) {
            if (err) {
                console.error(err)
                return
            }

            let metadata = JSON.parse(content)
            let imageName = filename.split(".")[0] + ".png"
            metadata.image = "ipfs://" + cid + "/" + imageName

            fs.writeFileSync(filePath, JSON.stringify(metadata))
        });
    });
});