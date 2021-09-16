import '@nomiclabs/hardhat-ethers'
import 'hardhat-deploy'

import { task } from 'hardhat/config'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { FourEverVRF } from './contracts'

task('vrf:verify', 'verify')
	.addParam('pubk', 'publicKey')
	.addOptionalParam('proof', 'proof')
	.addOptionalParam('msg', 'msg')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const fourEverVRF = await FourEverVRF(env)
		const publicKey = await fourEverVRF.decodePoint(args.pubk)
		const proofs = await fourEverVRF.decodeProof(args.proof)
		const verified = await fourEverVRF.verify(
			publicKey,
			proofs,
			args.msg
		)
		console.log('verified', verified)
	})

task('vrf:computeFastVerifyParams', 'computeFastVerifyParams')
	.addParam('pubk', 'publicKey')
	.addOptionalParam('proof', 'proof')
	.addOptionalParam('msg', 'msg')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const fourEverVRF = await FourEverVRF(env)
		const publicKey = await fourEverVRF.decodePoint(args.pubk)
		const proofs = await fourEverVRF.decodeProof(args.proof)
		const computeFastVerifyParams = await fourEverVRF.computeFastVerifyParams(
			publicKey,
			proofs,
			args.msg
		)
		console.log('computeFastVerifyParams', computeFastVerifyParams)
	})

module.exports = {}