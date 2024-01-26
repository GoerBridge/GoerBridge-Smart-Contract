import {
  DeployedBridge as DeployedBridgeEvent,
  DepositToken as DepositTokenEvent,
  OwnershipTransferred as OwnershipTransferredEvent
} from "../generated/Factory/Factory"
import {
  DeployedBridge,
  OwnershipTransferred
} from "../generated/schema"
import { Bridge } from "../generated/templates";

export function handleDeployedBridge(event: DeployedBridgeEvent): void {
  let entity = new DeployedBridge(
    event.params.contractBridge.toHex()
  )
  entity.projectId = event.params.projectId
  entity.contractBridge = event.params.contractBridge
  entity.deployerAccount = event.params.deployerAccount
  entity.monitorAccount = event.params.monitorAccount
  entity.contractBridgeOrigin = event.params.contractBridgeOrigin
  entity.contractToken = event.params.contractToken
  entity.deployedFee = event.params.deployedFee

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
  Bridge.create(event.params.contractBridge);
}

export function handleDepositToken(event: DepositTokenEvent): void {}

export function handleOwnershipTransferred(
  event: OwnershipTransferredEvent
): void {
  let entity = new OwnershipTransferred(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.previousOwner = event.params.previousOwner
  entity.newOwner = event.params.newOwner

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}
