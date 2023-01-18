// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@layerzerolabs/solidity-examples/contracts/token/oft/IOFT.sol";
import "./interfaces/IOFTWrapper.sol";

contract OFTWrapper is IOFTWrapper, Ownable, ReentrancyGuard {
    using SafeERC20 for IOFT;

    uint256 public constant BPS_DENOMINATOR = 10000;
    uint256 public constant MAX_UINT = 2**256 - 1; // indicates a bp fee of 0 that overrides the default bps

    uint256 public defaultBps;
    mapping(address => uint256) public oftBps;

    constructor(uint256 _defaultBps) {
        require(_defaultBps < BPS_DENOMINATOR, "OFTWrapper: defaultBps >= 100%");
        defaultBps = _defaultBps;
    }

    function setDefaultBps(uint256 _defaultBps) external onlyOwner {
        require(_defaultBps < BPS_DENOMINATOR, "OFTWrapper: defaultBps >= 100%");
        defaultBps = _defaultBps;
    }

    function setOFTBps(address _oft, uint256 _bps) external onlyOwner {
        require(_bps < BPS_DENOMINATOR || _bps == MAX_UINT, "OFTWrapper: oftBps[_oft] >= 100%");
        oftBps[_oft] = _bps;
    }

    function withdrawFees(
        address _oft,
        address _to,
        uint256 _amount
    ) external onlyOwner {
        IOFT(_oft).safeTransfer(_to, _amount);
        emit WrapperFeeWithdrawn(_oft, _to, _amount);
    }

    function sendOFT(
        address _oft,
        uint16 _dstChainId,
        bytes calldata _toAddress,
        uint _amount,
        uint256 _minAmount,
        address payable _refundAddress,
        address _zroPaymentAddress,
        bytes calldata _adapterParams,
        FeeObj calldata _feeObj
    ) external payable override nonReentrant {
        (uint256 amount, uint256 wrapperFee) = _getAmountAndPayFee(_oft, _amount, _minAmount, _feeObj);

        IOFT(_oft).sendFrom{value: msg.value}(msg.sender, _dstChainId, _toAddress, amount, _refundAddress, _zroPaymentAddress, _adapterParams); // swap amount less fees

        emit WrapperSwapped(_feeObj.partnerId, _amount, wrapperFee);
    }

    // extracted out of sendOFT() due to too many local variables
    function _getAmountAndPayFee(
        address _oft,
        uint256 _amount,
        uint256 _minAmount,
        FeeObj calldata _feeObj
    ) internal returns (uint256, uint256) {
        (uint256 amount, uint256 wrapperFee, uint256 callerFee) = getAmountAndFees(_oft, _amount, _feeObj.callerBps);
        require(amount >= _minAmount, "OFTWrapper: amount to transfer < minAmount");

        IOFT oft = IOFT(_oft);

        oft.safeTransferFrom(msg.sender, address(this), wrapperFee); // pay wrapper
        oft.safeTransferFrom(msg.sender, _feeObj.caller, callerFee); // pay caller

        return (amount, wrapperFee);
    }

    function getAmountAndFees(
        address _oft,
        uint256 _amount,
        uint256 _callerBps
    )
        public
        view
        override
        returns (
            uint256 amount,
            uint256 wrapperFee,
            uint256 callerFee
        )
    {
        uint256 wrapperBps;

        if (oftBps[_oft] == MAX_UINT) {
            wrapperBps = 0;
        } else if (oftBps[_oft] > 0) {
            wrapperBps = oftBps[_oft];
        } else {
            wrapperBps = defaultBps;
        }

        require(wrapperBps + _callerBps < BPS_DENOMINATOR, "OFTWrapper: Fee bps >= 100%");

        wrapperFee = wrapperBps > 0 ? (_amount * wrapperBps) / BPS_DENOMINATOR : 0;
        callerFee = _callerBps > 0 ? (_amount * _callerBps) / BPS_DENOMINATOR : 0;
        amount = wrapperFee > 0 || callerFee > 0 ? _amount - wrapperFee - callerFee : _amount;
    }

    function estimateSendFee(
        address _oft,
        uint16 _dstChainId,
        bytes calldata _toAddress,
        uint _amount,
        bool _useZro,
        bytes calldata _adapterParams,
        FeeObj calldata _feeObj
    ) external view override returns (uint nativeFee, uint zroFee) {
        (uint256 amount, , ) = getAmountAndFees(_oft, _amount, _feeObj.callerBps);

        return IOFT(_oft).estimateSendFee(_dstChainId, _toAddress, amount, _useZro, _adapterParams);
    }
}
