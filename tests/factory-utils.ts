import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt } from "@graphprotocol/graph-ts"
import {
  DeployedBridge,
  DepositToken,
  OwnershipTransferred
} from "../generated/Factory/Factory"

export function createDeployedBridgeEvent(
  projectId: string,
  contractBridgeClone: Address,
  deployerAccount: Address,
  adminDefaultAccount: Address,
  monitorAccount: Address,
  adminAccount: Address,
  contractBridgeOrigin: Address,
  contractToken: Address,
  deployedFee: BigInt
): DeployedBridge {
  let deployedBridgeEvent = changetype<DeployedBridge>(newMockEvent())

  deployedBridgeEvent.parameters = new Array()

  deployedBridgeEvent.parameters.push(
    new ethereum.EventParam("projectId", ethereum.Value.fromString(projectId))
  )
  deployedBridgeEvent.parameters.push(
    new ethereum.EventParam(
      "contractBridgeClone",
      ethereum.Value.fromAddress(contractBridgeClone)
    )
  )
  deployedBridgeEvent.parameters.push(
    new ethereum.EventParam(
      "deployerAccount",
      ethereum.Value.fromAddress(deployerAccount)
    )
  )
  deployedBridgeEvent.parameters.push(
    new ethereum.EventParam(
      "adminDefaultAccount",
      ethereum.Value.fromAddress(adminDefaultAccount)
    )
  )
  deployedBridgeEvent.parameters.push(
    new ethereum.EventParam(
      "monitorAccount",
      ethereum.Value.fromAddress(monitorAccount)
    )
  )
  deployedBridgeEvent.parameters.push(
    new ethereum.EventParam(
      "adminAccount",
      ethereum.Value.fromAddress(adminAccount)
    )
  )
  deployedBridgeEvent.parameters.push(
    new ethereum.EventParam(
      "contractBridgeOrigin",
      ethereum.Value.fromAddress(contractBridgeOrigin)
    )
  )
  deployedBridgeEvent.parameters.push(
    new ethereum.EventParam(
      "contractToken",
      ethereum.Value.fromAddress(contractToken)
    )
  )
  deployedBridgeEvent.parameters.push(
    new ethereum.EventParam(
      "deployedFee",
      ethereum.Value.fromUnsignedBigInt(deployedFee)
    )
  )

  return deployedBridgeEvent
}

export function createDepositTokenEvent(
  contractBridge: Address,
  amount: BigInt,
  toBlockchain: string,
  toAddress: string
): DepositToken {
  let depositTokenEvent = changetype<DepositToken>(newMockEvent())

  depositTokenEvent.parameters = new Array()

  depositTokenEvent.parameters.push(
    new ethereum.EventParam(
      "contractBridge",
      ethereum.Value.fromAddress(contractBridge)
    )
  )
  depositTokenEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )
  depositTokenEvent.parameters.push(
    new ethereum.EventParam(
      "toBlockchain",
      ethereum.Value.fromString(toBlockchain)
    )
  )
  depositTokenEvent.parameters.push(
    new ethereum.EventParam("toAddress", ethereum.Value.fromString(toAddress))
  )

  return depositTokenEvent
}

export function createOwnershipTransferredEvent(
  previousOwner: Address,
  newOwner: Address
): OwnershipTransferred {
  let ownershipTransferredEvent = changetype<OwnershipTransferred>(
    newMockEvent()
  )

  ownershipTransferredEvent.parameters = new Array()

  ownershipTransferredEvent.parameters.push(
    new ethereum.EventParam(
      "previousOwner",
      ethereum.Value.fromAddress(previousOwner)
    )
  )
  ownershipTransferredEvent.parameters.push(
    new ethereum.EventParam("newOwner", ethereum.Value.fromAddress(newOwner))
  )

  return ownershipTransferredEvent
}
