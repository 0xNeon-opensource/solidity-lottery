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
    const Lottery = await deploy('Lottery', {
        from: deployer,
        args: [1],
        log: true
    })

    log('')
    log('📜  📜  📜  📜  📜')
    log(`You have deployed an NFT contract to ${Lottery.address}`)
    log('📜  📜  📜  📜  📜')
    log('')
    const lotteryContract = await ethers.getContractFactory("Lottery")
    const accounts = await hre.ethers.getSigners()
    const signer = accounts[0]
    const lotteryContractInstance = new ethers.Contract(Lottery.address, lotteryContract.interface, signer)
    const networkName = networkConfig[chainId]['name']

    if (networkName === 'rinkeby') {
        log('')
        log('🔎  🔎  🔎  🔎  🔎')
        log(`View the contract on https://rinkeby.etherscan.io/address/${lotteryContractInstance.address}`)
        log('🔎  🔎  🔎  🔎  🔎')
        log('')
    }

    log('')
    log('✅  ✅  ✅  ✅  ✅')
    log(`Verify with:\n npx hardhat verify --network ${networkName} ${lotteryContractInstance.address}`)
    log('✅  ✅  ✅  ✅  ✅')
    log('')
}

module.exports.tags = ['all', 'lottery']
