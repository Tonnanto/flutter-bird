function getBreed(breedId) {
    switch (breedId) {
        case 0:
            return "Faby"
        case 1:
            return "Tucan"
        case 2:
            return "Parrot"
        case 3:
            return "Pigeon"
        default:
            return "None"
    }
}

function getColor(colorId) {
    switch (colorId) {
        case 0:
            return "Yellow"
        case 1:
            return "Red"
        case 2:
            return "Green"
        case 3:
            return "Blue"
        case 4:
            return "Pink"
        default:
            return "None"
    }
}

module.exports = { getBreed, getColor }