import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as/assembly/index"
import { Address, BigInt } from "@graphprotocol/graph-ts"
import { DeployedBridge } from "../generated/schema"
import { DeployedBridge as DeployedBridgeEvent } from "../generated/Factory/Factory"
import { handleDeployedBridge } from "../src/factory"
import { createDeployedBridgeEvent } from "./factory-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

describe("Describe entity assertions", () => {
  beforeAll(() => {
    let projectId = "Example string value"
    let contractBridgeClone = Address.fromString(
      "0x0000000000000000000000000000000000000001"
    )
    let deployerAccount = Address.fromString(
      "0x0000000000000000000000000000000000000001"
    )
    let adminDefaultAccount = Address.fromString(
      "0x0000000000000000000000000000000000000001"
    )
    let monitorAccount = Address.fromString(
      "0x0000000000000000000000000000000000000001"
    )
    let adminAccount = Address.fromString(
      "0x0000000000000000000000000000000000000001"
    )
    let contractBridgeOrigin = Address.fromString(
      "0x0000000000000000000000000000000000000001"
    )
    let contractToken = Address.fromString(
      "0x0000000000000000000000000000000000000001"
    )
    let deployedFee = BigInt.fromI32(234)
    let newDeployedBridgeEvent = createDeployedBridgeEvent(
      projectId,
      contractBridgeClone,
      deployerAccount,
      adminDefaultAccount,
      monitorAccount,
      adminAccount,
      contractBridgeOrigin,
      contractToken,
      deployedFee
    )
    handleDeployedBridge(newDeployedBridgeEvent)
  })

  afterAll(() => {
    clearStore()
  })

  // For more test scenarios, see:
  // https://thegraph.com/docs/en/developer/matchstick/#write-a-unit-test

  test("DeployedBridge created and stored", () => {
    assert.entityCount("DeployedBridge", 1)

    // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
    assert.fieldEquals(
      "DeployedBridge",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "projectId",
      "Example string value"
    )
    assert.fieldEquals(
      "DeployedBridge",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "contractBridgeClone",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "DeployedBridge",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "deployerAccount",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "DeployedBridge",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "adminDefaultAccount",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "DeployedBridge",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "monitorAccount",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "DeployedBridge",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "adminAccount",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "DeployedBridge",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "contractBridgeOrigin",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "DeployedBridge",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "contractToken",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "DeployedBridge",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "deployedFee",
      "234"
    )

    // More assert options:
    // https://thegraph.com/docs/en/developer/matchstick/#asserts
  })
})
