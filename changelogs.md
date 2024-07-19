Edited contract: [Bridge.sol](/Bridge.sol)

- [ ] BGB-03 RISK OF LOSING ADMIN ACCESS
- [ ] BGB-07 OWNER ABLE TO REVOKE OWN ROLE

```
function transferOwnership(address newOwner) public onlyOwner whenNotPaused returns (bool) {
    OWNER_WALLET = newOwner;
    // Requied newOwner is not _msgSender()
    require(newOwner != _msgSender(), "newOwner can not be msg.sender");
    _grantRole(DEFAULT_ADMIN_ROLE, newOwner);
    revokeRole(DEFAULT_ADMIN_ROLE, _msgSender());
    return true;
}
```

- [ ] BGB-04 UNCHECKED ERC-20 transfer() / transferFrom() CALL

```
  using SafeERC20 for IERC20;
```

- [ ] BGB-05 MISSING ZERO ADDRESS VALIDATION

```
function transferOwnership(address newOwner)
        public
        onlyOwner
        whenNotPaused
        returns (bool)
    {
        OWNER_WALLET = newOwner;
        // Requied newOwner is not _msgSender()
        require(newOwner != _msgSender(), "newOwner can not be msg.sender");
        require(newOwner != ZERO_ADDRESS, "newOwner can not be zero");
        _grantRole(DEFAULT_ADMIN_ROLE, newOwner);
        revokeRole(DEFAULT_ADMIN_ROLE, _msgSender());
        return true;
    }
```

```
    function withdrawToken(uint256 amount, address payable receiverWallet)
        external
        onlyOwner
        returns (bool)
    {
        require(receiverWallet != ZERO_ADDRESS, "receiver is zero");
        ...
    }
```

- [ ] GBS-04 USAGE OF transfer / send FOR SENDING NATIVE
TOKENS
- [ ] BGB-01 DISCUSSION ON bridgeFee COLLECTION IN
receiveTokens FUNCTION

```
import "@openzeppelin/contracts/utils/Address.sol";
using Address for address payable;

address payable reciever = payable(to);
reciever.sendValue(amount);
```

