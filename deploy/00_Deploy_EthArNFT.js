let { networkConfig } = require('../helper-hardhat-config')

module.exports = async ({
    getNamedAccounts,
    deployments,
    getChainId
}) => {

    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = await getChainId()

    log("----------------------------------------------------")
    const EthArNFT = await deploy('EthArNFT', {
        from: deployer,
        log: true
    })

    log('')
    log('📜  📜  📜  📜  📜')
    log(`You have deployed an NFT contract to ${EthArNFT.address}`)
    log('📜  📜  📜  📜  📜')
    log('')
    const ethArNftContract = await ethers.getContractFactory("EthArNFT")
    const accounts = await hre.ethers.getSigners()
    const signer = accounts[0]
    const ethArNftContractInstance = new ethers.Contract(EthArNFT.address, ethArNftContract.interface, signer)
    const networkName = networkConfig[chainId]['name']

    if (networkName === 'rinkeby') {
        log('')
        log('🔎  🔎  🔎  🔎  🔎')
        log(`View the contract on https://rinkeby.etherscan.io/address/${ethArNftContractInstance.address}`)
        log('🔎  🔎  🔎  🔎  🔎')
        log('')
    }

    log('')
    log('✅  ✅  ✅  ✅  ✅')
    log(`Verify with:\n npx hardhat verify --network ${networkName} ${ethArNftContractInstance.address}`)
    log('✅  ✅  ✅  ✅  ✅')
    log('')
    // tx = await ethArNftContractInstance.mint(
    //     'http://localhost:1984/fy9R3-Cm1wN9k3HHzvci-nBDbx5IzyollMHnG3VDOao',
    //     '0xe63fd0ddc7e34de7044b9603b6134a0154de0d0fdd1ff7b011497d045e27678a7cd83ab16a7f446fc3c4e71901f1273fd5f2a4996cbcb24b58917e5271ae7ae81b',
    //     { value: ethers.utils.parseEther(".01").toHexString() }
    // )
    // await tx.wait(1)
    // const totalSupply = await ethArNftContractInstance.totalSupply();
    // console.log('totalSupply :>> ', totalSupply.toNumber());
}

module.exports.tags = ['all', 'ethArNft']
