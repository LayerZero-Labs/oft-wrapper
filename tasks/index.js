task("getSigners", "show the signers of the current mnemonic", require("./getSigners")).addOptionalParam("n", "how many to show", 3, types.int)


task("verifyContract", "", require("./verifyContract.js"))
    .addParam("contract", "contract name")
