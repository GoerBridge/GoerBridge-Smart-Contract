// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Address.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./IERC20.sol";
import "./CloneFactory.sol";
import "./SafeMath.sol";
import "./IBridge.sol";
import "./ReentrancyGuard.sol";

contract Factory is CloneFactory, ReentrancyGuard, Ownable {
    using Address for address;
    using SafeMath for uint256;

    event DeployedBridge(
        string projectId,
        address contractBridge,
        address deployerAccount,
        address adminDefaultAccount,
        address monitorAccount,
        address adminAccount,
        address contractBridgeOrigin,
        address contractToken,
        uint256 deployedFee
    );

    event DepositToken(address contractBridge, uint256 amount, string toBlockchain, string toAddress);

    string private _name = "Bridge Factory V1";
    address payable public projectWallet = payable(0x071a5B1451c55153Df15243d0Ff64c8078F75E46);
    uint256 public deployFee;
    mapping(address => bool) public listBridge;
    mapping(address => mapping (string => bool)) public checkUnique;

    function name() public view returns (string memory) {
        return _name;
    }

    constructor(address contractOrigin) {
        listBridge[contractOrigin] = true;
    }
//0x0000000000000000000000000000000000000000
    function deployedBridge(
        address contractOrigin,
        address token,
        address adminDefault,
        address monitorAcoount,
        address adminAccount,
        string memory projectId,
        uint256 feeNative,
        uint256 feePercentBridge
    ) public payable {
        require(
            listBridge[contractOrigin] == true,
            "Contract bridge not found."
        );
        require(msg.value >= deployFee, "Invalid amount");
        payable(projectWallet).transfer(deployFee);
        address bridgeClone = createClone(contractOrigin);
        IBridge(bridgeClone).setDeployBridge(token, _msgSender(), adminDefault, monitorAcoount, adminAccount, feeNative, feePercentBridge);
        checkUnique[contractOrigin][projectId] = true;

        emit DeployedBridge(
            projectId,
            bridgeClone,
            _msgSender(),
            adminDefault,
            monitorAcoount,
            adminAccount,
            contractOrigin,
            token,
            deployFee
        );
    }

    function setListBridge(address contractOrigin, bool active)
        public
        onlyOwner
    {
        listBridge[contractOrigin] = active;
    }

    function setDeployFee(uint256 fee) public onlyOwner {
        deployFee = fee;
    }

    receive() external payable {}
}
