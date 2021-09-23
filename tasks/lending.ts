import 'hardhat-deploy'
import '@nomiclabs/hardhat-ethers'

import { task } from 'hardhat/config'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { NodeLending } from './contracts'

task('lending:maxLoan')
	.addParam('id')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const lending = await NodeLending(env)
		const signers = await env.ethers.getSigners()
		const maxLoan = await lending.maxLoan(signers[0].address, args.id)
		console.log('maxLoan', maxLoan)
	})

module.exports = {}