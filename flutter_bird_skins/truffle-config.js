/**
 * Use this file to configure your truffle project. It's seeded with some
 * common settings for different networks and features like migrations,
 * compilation, and testing. Uncomment the ones you need or modify
 * them to suit your project as necessary.
 *
 * More information about configuration can be found at:
 *
 * https://trufflesuite.com/docs/truffle/reference/configuration
 *
 * To deploy via Infura you'll need a wallet provider (like @truffle/hdwallet-provider)
 * to sign your transactions before they're sent to a remote public node. Infura accounts
 * are available for free at: infura.io/register.
 *
 * You'll also need a mnemonic - the twelve word phrase the wallet uses to generate
 * public/private key pairs. If you're publishing your code to GitHub make sure you load this
 * phrase from a file you've .gitignored so it doesn't accidentally become public.
 *
 */

require('dotenv').config();
const HDWalletProvider = require("@truffle/hdwallet-provider");
const {API_URL, MNEMONIC, ETHERSCAN_API_KEY} = process.env;

module.exports = {
    /**
     * Networks define how you connect to your ethereum client and let you set the
     * defaults web3 uses to send transactions. If you don't specify one truffle
     * will spin up a development blockchain for you on port 9545 when you
     * run `develop` or `test`. You can ask a truffle command to use a specific
     * network from the command line, e.g
     *
     * $ truffle test --network <network-name>
     */

    networks: {
        // Local Ganache Dummy-Blockchain
        development: {
            host: "127.0.0.1",
            port: 7545,
            network_id: "*",
        },

        // Public Goerli Testnet
        goerli: {
            provider: () => {
                return new HDWalletProvider(MNEMONIC, API_URL)
            },
            network_id: 5,
            gas: 4465030,
            gasPrice: 20000000000,
        },
    },

    // Configure your compilers
    compilers: {
        solc: {
            version: "0.8.14",
        }
    },

    plugins: [
        'truffle-plugin-verify'
    ],

    api_keys: {
        etherscan: ETHERSCAN_API_KEY
    }
};
