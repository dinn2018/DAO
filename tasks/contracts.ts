import '@nomiclabs/hardhat-ethers'
import 'hardhat-deploy'

import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { ECVRFImp__factory } from '../types/factories/ECVRFImp__factory'
import { Controller__factory } from '../types/factories/Controller__factory'
import { Nodes__factory } from '../types/factories/Nodes__factory'
import { StakeReward__factory } from '../types/factories/StakeReward__factory'
import { Stake__factory } from '../types/factories/Stake__factory'
import { NodeLending__factory } from '../types/factories/NodeLending__factory'
import { Auction__factory } from '../types/factories/Auction__factory'

export const ECVRFImp = async (env: HardhatRuntimeEnvironment) => {
	const deployment = await env.deployments.get(ECVRFImp.name)
	const signers = await env.ethers.getSigners()
	return ECVRFImp__factory.connect(deployment.address, signers[0])
}

export const Controller = async (env: HardhatRuntimeEnvironment) => {
	const deployment = await env.deployments.get(Controller.name)
	const signers = await env.ethers.getSigners()
	return Controller__factory.connect(deployment.address, signers[0])
}

export const Nodes = async (env: HardhatRuntimeEnvironment) => {
	const deployment = await env.deployments.get(Nodes.name)
	const signers = await env.ethers.getSigners()
	return Nodes__factory.connect(deployment.address, signers[0])
}

export const StakeReward = async (env: HardhatRuntimeEnvironment) => {
	const deployment = await env.deployments.get(StakeReward.name)
	const signers = await env.ethers.getSigners()
	return StakeReward__factory.connect(deployment.address, signers[0])
}

export const Stake = async (env: HardhatRuntimeEnvironment) => {
	const deployment = await env.deployments.get(Stake.name)
	const signers = await env.ethers.getSigners()
	return Stake__factory.connect(deployment.address, signers[0])
}

export const NodeLending = async (env: HardhatRuntimeEnvironment) => {
	const deployment = await env.deployments.get(NodeLending.name)
	const signers = await env.ethers.getSigners()
	return NodeLending__factory.connect(deployment.address, signers[0])
}

export const Auction = async (env: HardhatRuntimeEnvironment) => {
	const deployment = await env.deployments.get(Auction.name)
	const signers = await env.ethers.getSigners()
	return Auction__factory.connect(deployment.address, signers[0])
}
