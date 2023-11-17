// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";

interface IBridge {
  function getMinTokenAmount(string calldata blockchainName)
    external
    view
    returns (uint256);

  function getTokenBalance() external view returns (uint256);

  function receiveTokens(
    uint256 amount,
    string memory toBlockchain,
    string memory toAddress
  ) payable external returns (bool);

  function acceptTransfer(
    address payable receiver,
    uint256 amount,
    string calldata fromBlockchain,
    bytes32 blockHash,
    bytes32 transactionHash,
    uint32 logIndex
  ) external returns (bool);

  function getTransactionId(
    bytes32 blockHash,
    bytes32 transactionHash,
    address receiver,
    uint256 amount,
    uint32 logIndex
  ) external returns (bytes32);

  function existsBlockchainFrom(string calldata name) external view returns (bool);
  function existsBlockchainTo(string calldata name) external view returns (bool);

  function listBlockchainFrom() external view returns (string[] memory);
  function listBlockchainTo() external view returns (string[] memory);

  event CrossRequest(address from, uint256 amount, string toAddress, string toBlockchain);
  event FeePercentageBridgeChanged(uint256 oldFee, uint256 newFee);
  event TokenChanged(address tokenAddress);
  event OwnerChanged(address owner);
  event MinTokenAmountChanged(string blockchainName, uint256 oldAmount, uint256 newAmount);

  function setDeployBridge(address token, address owner, address monitor, uint256 feeNative, uint256 feePercentage) external ;
}
