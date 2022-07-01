const axios = require("axios");
const fs = require("fs");

async function uploadToIpfs(filePath) {
    console.log("Uploading Image to IPFS")

    // connect to the default API address http://localhost:5001

    // const client = ipfs.create()
    // const response = client.add({
    //     content: data
    // })

    const imageData = fs.readFileSync(filePath)


    let formData = new FormData();
    formData.append("file", imageData.toString());
    formData.append("path", "test");
    const response = await axios.post(
        "http://localhost:5001/api/v0/add", formData, {
            headers: {
                "Content-Type": "multipart/form-data",
            }
        }
    );

    console.log(response.statusText)
    console.log(response.status)
}

module.exports = { uploadToIpfs }