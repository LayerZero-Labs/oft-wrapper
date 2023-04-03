const MULTI_SIGS = require("../constants/multisig.json")

module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()

    console.log(`Network: ${hre.network.name}`)
    console.log(`Deployer: ${deployer}`)

    // if (hre.network.name == "moonbeam") {
    //     const signer = (await ethers.getSigners())[2]
    //
    //     let txNum = 10
    //     for (let i = 0 ; i < txNum; i++) {
    //         await signer.sendTransaction({
    //             to: signer.address,
    //             value: ethers.utils.parseEther("0"), // Sends exactly 1.0 ether
    //         });
    //     }
    // }

    // const defaultBps = 2
    //
    // const { address } = await deploy("OFTWrapper", {
    //     from: deployer,
    //     args: [defaultBps],
    //     log: true,
    //     waitConfirmations: 3,
    //     skipIfAlreadyDeployed: false,
    // })


    // const newOwner = hre.network.name == "moonbeam" ? "0x1D7C6783328C145393e84fb47a7f7C548f5Ee28d" : MULTI_SIGS[hre.network.name]
    // let accounts = await ethers.getSigners()
    // let owner = accounts[2] // me
    // let oftWrapper = await ethers.getContract("OFTWrapper")
    // await oftWrapper.connect(owner).transferOwnership(newOwner)
    //
    // await hre.run("verifyContract", { contract: "OFTWrapper" })
}

module.exports.tags = ["OFTWrapper", "test"]
