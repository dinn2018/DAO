import 'hardhat-deploy'
import '@nomiclabs/hardhat-ethers'

import { task } from 'hardhat/config'
import { HardhatRuntimeEnvironment } from 'hardhat/types'

task('mine')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		env.network.provider.send('evm_mine')
	})

module.exports = {}