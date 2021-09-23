import 'hardhat-deploy'
import '@nomiclabs/hardhat-ethers'

import { task } from 'hardhat/config'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { Nodes} from './contracts'

task('nodes:ownerOf')
	.addParam('id')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const nodes = await Nodes(env)
		const ownerOf = await nodes.ownerOf(args.id)
		console.log('ownerOf', ownerOf)
	})

task('nodes:balanceOf')
	.addOptionalParam('to')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const nodes = await Nodes(env)
		const signers = await env.ethers.getSigners()
		const balanceOf = await nodes.balanceOf(args.to || signers[0].address)
		console.log('balanceOf', balanceOf)
	})

task('nodes:get')
	.addParam('id')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const nodes = await Nodes(env)
		const get = await nodes.get(args.id)
		console.log('get', get)
	})

task('nodes:mortgageEndTime')
	.addParam('id')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const nodes = await Nodes(env)
		const mortgageEndTime = await nodes.mortgageEndTime(args.id)
		console.log('mortgageEndTime', mortgageEndTime)
	})

module.exports = {}