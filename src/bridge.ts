import { log } from "@graphprotocol/graph-ts";
import { CrossRequest, DeployedBridge } from "../generated/schema"
import { 
    CrossRequest as CrossRequestEvent, 
    FeePercentageBridgeChanged, 
    MinTokenAmountChanged, 
    OwnerChanged, 
    Paused, 
    RoleAdminChanged, 
    RoleGranted, 
    RoleRevoked, 
    TokenChanged, 
    Unpaused 
} from "../generated/templates/Bridge/Bridge"

export function handleCrossRequest(event: CrossRequestEvent): void {
    let deployedBridge = DeployedBridge.load(event.address.toHex())
    if (deployedBridge !== null) {
        let crReq = new CrossRequest(
            event.transaction.hash.toHex()
        );
        crReq.bridgeContract = event.address
        crReq.fromAddress = event.params.from
        crReq.amount = event.params.amount
        crReq.toAddress = event.params.toAddress
        crReq.toBlockchain = event.params.toBlockchain
        crReq.deployedBridge = deployedBridge.id
        crReq.blockNumber = event.block.number
        crReq.blockHash = event.block.hash
        crReq.hash = event.transaction.hash
        crReq.logIndex = event.logIndex

        crReq.save()
    }
}

export function handleFeePercentageBridgeChanged(event: FeePercentageBridgeChanged): void{}
export function handleMinTokenAmountChanged(event: MinTokenAmountChanged): void{}
export function handleOwnerChanged(event: OwnerChanged): void{}
export function handlePaused(event: Paused): void{}
export function handleRoleAdminChanged(event: RoleAdminChanged): void{}
export function handleRoleGranted(event: RoleGranted): void{}
export function handleRoleRevoked(event: RoleRevoked): void{}
export function handleTokenChanged(event: TokenChanged): void{}
export function handleUnpaused(event: Unpaused): void{}