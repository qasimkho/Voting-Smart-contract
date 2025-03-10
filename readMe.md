# deploying on Ganache using truffle

## for new project use
    - `truffle init` command

## solidity version to use truffle
    - for best result solidity version ">=0.5.0 < 0.9.0"
    - change the solidity version in truffle-config.js to "^0.5.0"

## to compile
    - use `truffle compile`

## to compile and migrate in one command after migration files have been created
    - in order to deploy on ganache, make sure **development** is uncommented in truffle-config
    - use `truffle migrate`
    - use this command if there are changes in SC which truffle did not notice `truffle migrate --reset`
    - make sure the contract name is provided as an argument to artifacts.require() rather than the file name with extension 
    e.g. if file name is "Vote.sol" and contract name is "Voter", then "Voter" is the argument that should be provided. **TO AVOID THIS OVER ALL, MAKE THE FILE AND CONTRACT NAME SAME.**
    - if you get error "... "VoterContract" hit an invalid opcode while deploying...." make sure the solidity version and 
    truffle-config version are as mentioned above.
    - if using latest version of solidity and trying to use truffle/ganache (which only supports old versions), you may need to add this line `pragma experimental ABIEncoderV2;` under `pragma solidity x.x.x.
    You may also need to add "public" visibilty to constructors, if any.

# deploying on real testnet/mainnet using truffle

    - comment out ** development ** in truffle-config
    - goreli testnet is deprecated. Sepolia on arbitrum can still be used by using the configuration below:
    ```
        sepolia: {
          provider: () => new HDWalletProvider(
            private_key, 
            `https://arb-sepolia.g.alchemy.com/v2/${PROJECT_ID}`
          ),
          network_id: 421614, // Sepolia's network id
        },
    ```
    - uncomment these in truffle-config:
    ```
        require('dotenv').config();
        const { MNEMONIC, PROJECT_ID } = process.env;

        const HDWalletProvider = require('@truffle/hdwallet-provider');
    ```
    - replace ** "MNEMONIC"** with "private_key". 
    - use this command to install Dotenv 
        ```npm install dotenv```
    - fill dotenv fil with the following:
        ```
        private_key = <private key>
        PROJECT_ID = <API key from alchemy/ or any provider>
        ```
    