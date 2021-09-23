import 'hardhat-deploy'
import '@nomiclabs/hardhat-ethers'

import { task } from 'hardhat/config'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { Auction } from './contracts'
import { toToken } from './utils'

task('auction:voteWithMortgage')
	.addParam('id')
	.addParam('value')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const auction = await Auction(env)
		const tx = await auction.voteWithMortgage(args.id, {value: toToken(args.value)})
		const receipt = await tx.wait()
		console.log('receipt', receipt)
	})

task('auction:voteWithLending')
	.addParam('id')
	.addParam('amount')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const auction = await Auction(env)
		const tx = await auction.voteWithLending(args.id, toToken(args.amount))
		const receipt = await tx.wait()
		console.log('receipt', receipt)
	})

task('auction:release')
	.addParam('id')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const auction = await Auction(env)
		const tx = await auction.release(args.id)
		const receipt = await tx.wait()
		console.log('receipt', receipt)
	})

task('auction:isEnded')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const auction = await Auction(env)
		const isEnded = await auction.isEnded()
		console.log('isEnded', isEnded)
	})

task('auction:votes')
	.addParam('id')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const auction = await Auction(env)
		const signers = await env.ethers.getSigners()
		const votes = await auction.votes(signers[0].address, args.id)
		console.log('votes', votes)
	})

module.exports = {}