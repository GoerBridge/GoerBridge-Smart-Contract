// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AccessControl.sol";
import "./Pausable.sol";
import "./IBridge.sol";


contract Bridge is AccessControl, IBridge, Pausable {

  struct BlockchainStruct {
    uint256 minTokenAmount;
  }

  address private constant ZERO_ADDRESS = address(0);
  bytes32 private constant NULL_HASH = bytes32(0);
  bytes32 public constant MONITOR_ROLE = keccak256("MONITOR_ROLE");

  uint256 constant public PERCENTS_DIVIDER = 1000;

  address public token;
  uint256 public totalFeeReceivedBridge; // fee received per Bridge, not for transaction in other blockchain
  uint256 public FEE_NATIVE;
  uint256 public feePercentageBridge;
  address public OWNER_WALLET;

  mapping(bytes32 => bool) public processed;
  // mapping(string => uint256) private blockchainIndex;
  mapping(string => uint256) private blockchainIndexFrom;
  mapping(string => uint256) private blockchainIndexTo;
  BlockchainStruct[] private blockchainInfoFrom;
  BlockchainStruct[] private blockchainInfoTo;
  // string[] public blockchain;
  string[] public fromBlockchainReceive;
  string[] public toBlockchainTransfer;

  modifier onlyOwner() {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "not owner");
    _;
  }

  modifier onlyMonitor() {
    require(hasRole(MONITOR_ROLE, _msgSender()), "not monitor");
    _;
  }

  modifier onlyEOAs() {
    require(_msgSender() == tx.origin, "Caller is not EOA");
    _;
  }

  function compareStrings(string memory a, string memory b)
    private
    pure
    returns (bool)
  {
    return (keccak256(abi.encodePacked((a))) ==
      keccak256(abi.encodePacked((b))));
  }

  function receiveTokens(
    uint256 amount,
    string memory toBlockchain,
    string memory toAddress
  ) payable external override onlyEOAs whenNotPaused returns (bool) {
    require(existsBlockchainTo(toBlockchain), "toBlockchain not exists");
    require(!compareStrings(toAddress, ""), "toAddress is null");

    uint256 index = blockchainIndexTo[toBlockchain] - 1;
    require(amount > 0, "amount is 0");
    require(amount >= blockchainInfoTo[index].minTokenAmount, "amount is less than minimum");
    require(bytes(toAddress).length == 42, "invalid destination address");
    require(msg.value >= FEE_NATIVE, "Invalid fee native bridge.");
    if(token == ZERO_ADDRESS) {
      require(msg.value == amount + FEE_NATIVE, "required: fee native not enough");
    }

    uint256 bridgeFee = (amount * feePercentageBridge) / PERCENTS_DIVIDER;
    uint256 amountMinusFees = amount - bridgeFee;
    totalFeeReceivedBridge += bridgeFee;

    if(token != ZERO_ADDRESS) {
        if(FEE_NATIVE > 0) {
          payable(OWNER_WALLET).transfer(msg.value);
        }
        IERC20(token).transferFrom(_msgSender(), address(this), amountMinusFees);
        IERC20(token).transferFrom(_msgSender(), OWNER_WALLET, bridgeFee);
    } else {
      payable(OWNER_WALLET).transfer(FEE_NATIVE);
      payable(address(this)).transfer(amountMinusFees);
    }

    emit CrossRequest(_msgSender(), amountMinusFees, toAddress, toBlockchain);

    return true;
  }

  function acceptTransfer(
    address payable receiver,
    uint256 amount,
    string calldata fromBlockchain,
    bytes32 blockHash,
    bytes32 transactionHash,
    uint32 logIndex
  ) external override onlyMonitor whenNotPaused returns (bool) {
    require(receiver != ZERO_ADDRESS, "receiver is zero");
    require(amount > 0, "amount is 0");
    require(existsBlockchainFrom(fromBlockchain), "fromBlockchain not exists");
    require(blockHash != NULL_HASH, "blockHash is null");
    require(transactionHash != NULL_HASH, "transactionHash is null");

    _processTransaction(blockHash, transactionHash, receiver, amount, logIndex);
    _sendToken(receiver, amount);
    return true;
  }

  function setDeployBridge(address tokenAddress, address owner, address monitor, uint256 feeNative, uint256 feePercentage) public override {
    require(token == ZERO_ADDRESS, "Not set token");
    require(OWNER_WALLET == ZERO_ADDRESS, "Not set owner wallet");
    require(FEE_NATIVE == 0, "Not set admin default role");
    require(feePercentageBridge == 0, "Not set admin default role");
    require(feePercentage <= 100, "Fee percent > 10%");
    token = tokenAddress;
    OWNER_WALLET = owner;
    _grantRole(DEFAULT_ADMIN_ROLE, owner);
    _grantRole(MONITOR_ROLE, monitor);
    FEE_NATIVE = feeNative;
    feePercentageBridge = feePercentage;
  }

  function getTransactionId(
    bytes32 blockHash,
    bytes32 transactionHash,
    address receiver,
    uint256 amount,
    uint32 logIndex
  ) public pure override returns (bytes32) {
    return
      keccak256(
        abi.encodePacked(blockHash, transactionHash, receiver, amount, logIndex)
      );
  }

  function _processTransaction(
    bytes32 blockHash,
    bytes32 transactionHash,
    address receiver,
    uint256 amount,
    uint32 logIndex
  ) private {
    bytes32 transactionId = getTransactionId(
      blockHash,
      transactionHash,
      receiver,
      amount,
      logIndex
    );
    require(!processed[transactionId], "processed");
    processed[transactionId] = true;
  }

  function _sendToken(address payable to, uint256 amount) private returns (bool) {
    if(token == ZERO_ADDRESS) {
      require(address(this).balance >= amount, "Insufficient native token balance in contract");
      to.transfer(amount);
    } else {
      require(IERC20(token).balanceOf(address(this)) >= amount, "insufficient balance");
      IERC20(token).transfer(to, amount);
    }
    return true;
  }

  function getTokenBalance() external view override returns (uint256) {
    if(token != ZERO_ADDRESS) {
          return IERC20(token).balanceOf(address(this));
    }
    return address(this).balance;
  }

  function withdrawToken(uint256 amount, address payable receiverWallet) external onlyOwner returns (bool) {
    if(token != ZERO_ADDRESS) {
      require(amount <= IERC20(token).balanceOf(address(this)), "insuficient balance");
      IERC20(token).transfer(receiverWallet, amount);
      return true;
    }
    else {
      require(address(this).balance >= amount, "Insufficient native token balance in contract");
      receiverWallet.transfer(amount);
    }
    return true;
  }

  function setFeeNative(uint256 amount) external onlyOwner returns (bool) {
    FEE_NATIVE = amount;
    return true;
  }

  function addMonitor(address account)
    external
    onlyOwner
    whenNotPaused
    returns (bool)
  {
    grantRole(MONITOR_ROLE, account);
    return true;
  }

  function delMonitor(address account)
    external
    onlyOwner
    whenNotPaused
    returns (bool)
  {
    //Can be called only by the account defined in constructor: DEFAULT_ADMIN_ROLE
    revokeRole(MONITOR_ROLE, account);
    return true;
  }

  function renounceRole(bytes32 role, address account) public virtual override {
    require(role != DEFAULT_ADMIN_ROLE, "can not renounce role owner");
    require(account == _msgSender(), "can only renounce roles for self");
    super.renounceRole(role, account);
  }

  function revokeRole(bytes32 role, address account)
    public
    virtual
    override
    onlyRole(getRoleAdmin(role))
  {
    super.revokeRole(role, account);
  }

  function getMinTokenAmount(string memory blockchainName)
    external
    view
    override
    returns (uint256)
  {
    return blockchainInfoTo[blockchainIndexTo[blockchainName] - 1].minTokenAmount;
  }

  function transferOwnership(address newOwner) public onlyOwner whenNotPaused returns (bool) {
    OWNER_WALLET = newOwner;
    _grantRole(DEFAULT_ADMIN_ROLE, newOwner);
    revokeRole(DEFAULT_ADMIN_ROLE, _msgSender());
    return true;
  }

  function setMinTokenAmount(string memory blockchainName, uint256 newAmount)
    public
    onlyOwner
    whenNotPaused
    returns (bool)
  {
    require(existsBlockchainTo(blockchainName), "blockchain not exists");
    uint256 index = blockchainIndexTo[blockchainName] - 1;
    emit MinTokenAmountChanged(
      blockchainName,
      blockchainInfoTo[index].minTokenAmount,
      newAmount
    );
    blockchainInfoTo[index].minTokenAmount = newAmount;
    return true;
  }

  function setFeePercentageBridge(uint256 newFee)
    external
    onlyOwner
    whenNotPaused
    returns (bool)
  {
    require(newFee <= 100, "Bigger than 10%");
    emit FeePercentageBridgeChanged(feePercentageBridge, newFee);
    feePercentageBridge = newFee;
    return true;
  }

  function existsBlockchainFrom(string memory name)
    public
    view
    override
    returns (bool)
  {
    if (blockchainIndexFrom[name] == 0) return false;
    else return true;
  }

  function existsBlockchainTo(string memory name)
    public
    view
    override
    returns (bool)
  {
    if (blockchainIndexTo[name] == 0) return false;
    else return true;
  }

  function listBlockchainFrom() external view override returns (string[] memory) {
    return fromBlockchainReceive;
  }

  function listBlockchainTo() external view override returns (string[] memory) {
    return toBlockchainTransfer;
  }

  function addBlockchainFrom(
    string memory name
  ) external onlyOwner whenNotPaused returns (uint256) {
    require(!existsBlockchainFrom(name), "Blockchain exists");

    BlockchainStruct memory b;
    blockchainInfoFrom.push(b);
    fromBlockchainReceive.push(name);
    uint256 index = blockchainInfoFrom.length;
    blockchainIndexFrom[name] = index;
    return (index);
  }

  function addBlockchainTo(
    string memory name,
    uint256 minTokenAmount
  ) external onlyOwner whenNotPaused returns (uint256) {
    require(!existsBlockchainTo(name), "blockchain exists");

    BlockchainStruct memory b;
    b.minTokenAmount = minTokenAmount;
    blockchainInfoTo.push(b);
    toBlockchainTransfer.push(name);
    uint256 index = blockchainInfoTo.length;
    blockchainIndexTo[name] = index;
    return (index);
  }

  function delBlockchainFrom(string memory name)
    external
    onlyOwner
    whenNotPaused
    returns (bool)
  {
    require(existsBlockchainFrom(name), "blockchain not exists");

    uint256 indexToDelete = blockchainIndexFrom[name] - 1;
    uint256 indexToMove = blockchainInfoFrom.length - 1;
    string memory keyToMove = fromBlockchainReceive[indexToMove];

    blockchainInfoFrom[indexToDelete] = blockchainInfoFrom[indexToMove];
    fromBlockchainReceive[indexToDelete] = fromBlockchainReceive[indexToMove];
    blockchainIndexFrom[keyToMove] = indexToDelete + 1;

    delete blockchainIndexFrom[name];
    blockchainInfoFrom.pop();
    fromBlockchainReceive.pop();
    return true;
  }

  function delBlockchainTo(string memory name)
    external
    onlyOwner
    whenNotPaused
    returns (bool)
  {
    require(existsBlockchainTo(name), "blockchain not exists");
    uint256 indexToDelete = blockchainIndexTo[name] - 1;
    uint256 indexToMove = blockchainInfoTo.length - 1;
    string memory keyToMove = toBlockchainTransfer[indexToMove];

    blockchainInfoTo[indexToDelete] = blockchainInfoTo[indexToMove];
    toBlockchainTransfer[indexToDelete] = toBlockchainTransfer[indexToMove];
    blockchainIndexTo[keyToMove] = indexToDelete + 1;

    delete blockchainIndexTo[name];
    blockchainInfoTo.pop();
    toBlockchainTransfer.pop();
    return true;
  }

  function pause() external onlyOwner {
    _pause();
  }

  function unpause() external onlyOwner {
    _unpause();
  }
  
  receive() external payable {}

}
