import '@nomiclabs/hardhat-ethers'
import 'hardhat-deploy'

import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { FourEverVRF__factory } from '../types/factories/FourEverVRF__factory'

export const FourEverVRF = async (env: HardhatRuntimeEnvironment) => {
	const deployment = await env.deployments.get(FourEverVRF.name)
	const signers = await env.ethers.getSigners()
	return FourEverVRF__factory.connect(deployment.address, signers[0])
}