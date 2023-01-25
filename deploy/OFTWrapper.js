const MULTI_SIGS = require("../constants/multisig.json")

module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()

    console.log(`Network: ${hre.network.name}`)
    console.log(`Deployer: ${deployer}`)

    // if (hre.network.name != "ethereum") {
    //     const signer = (await ethers.getSigners())[2]
    //
    //     await signer.sendTransaction({
    //         to: signer.address,
    //         value: ethers.utils.parseEther("0"), // Sends exactly 1.0 ether
    //     });
    // }

    const defaultBps = 2

    const { address } = await deploy("OFTWrapper", {
        from: deployer,
        args: [defaultBps],
        log: true,
        waitConfirmations: 3,
    })

    let accounts = await ethers.getSigners()
    let owner = accounts[2] // me
    let oftWrapper = await ethers.getContract("OFTWrapper")
    await oftWrapper.connect(owner).transferOwnership(MULTI_SIGS[hre.network.name])

    await hre.run("verifyContract", { contract: "OFTWrapper" })
}

module.exports.tags = ["OFTWrapper", "test"]
