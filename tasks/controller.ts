import '@nomiclabs/hardhat-ethers'
import 'hardhat-deploy'

import { task } from 'hardhat/config'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { Controller } from './contracts'

task('controller:enable')
	.addParam('to')
	.addParam('auth')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const controller = await Controller(env)
		const tx = await controller.enable(
			args.to,
			args.auth
		)
		const receipt = await tx.wait()
		console.log('receipt', receipt)
	})

task('controller:addNode')
	.addParam('id')
	.addParam('period')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const controller = await Controller(env)
		const tx = await controller.addNode(
			args.id,
			args.period,
			Buffer.from(Buffer.from('杭州').toString('hex').padStart(64,'0'), 'hex')
		)
		const receipt = await tx.wait()
		console.log('receipt', receipt)
	})

task('controller:removeNode')
	.addParam('id')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const controller = await Controller(env)
		const tx = await controller.removeNode(
			args.id
		)
		const receipt = await tx.wait()
		console.log('receipt', receipt)
	})

task('controller:exitNode')
	.addParam('id')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const controller = await Controller(env)
		const tx = await controller.exitNode(
			args.id
		)
		const receipt = await tx.wait()
		console.log('receipt', receipt)
	})

task('controller:owner')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const controller = await Controller(env)
		const owner = await controller.owner()
		console.log('owner', owner)
	})

module.exports = {}