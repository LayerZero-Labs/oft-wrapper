module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()

    console.log(`Network: ${hre.network.name}`)

    const { address } = await deploy("OFTWrapper", {
        from: deployer,
        args: [0],
        log: true,
        waitConfirmations: 1,
    })
}

module.exports.tags = ["OFTWrapper", "test"]