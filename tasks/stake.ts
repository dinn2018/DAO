import 'hardhat-deploy'
import '@nomiclabs/hardhat-ethers'

import { task } from 'hardhat/config'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { Stake } from './contracts'
import { toToken } from './utils'

task('stake:deposit')
	.addParam('value')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const stake = await Stake(env)
		const tx = await stake.deposit({value: toToken(args.value)})
		const receipt = await tx.wait()
		console.log('receipt', receipt)
	})

task('stake:apy')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const stake = await Stake(env)
		const apy = await stake.apy()
		console.log('apy', apy)
	})

task('stake:totalLoans')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const stake = await Stake(env)
		const totalLoans = await stake.totalLoans()
		console.log('totalLoans', totalLoans)
	})

task('stake:unrealisedReward')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const stake = await Stake(env)
		const signers = await env.ethers.getSigners()
		const unrealisedReward = await stake.unrealisedReward(signers[0].address)
		console.log('unrealisedReward', unrealisedReward)
	})

task('stake:availableReward')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const stake = await Stake(env)
		const signers = await env.ethers.getSigners()
		const availableReward = await stake.availableReward(signers[0].address)
		console.log('availableReward', availableReward)
	})

task('stake:withdrawDeposit')
	.addParam('amount')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const stake = await Stake(env)
		const tx = await stake.withdrawDeposit(args.amount)
		const receipt = await tx.wait()
		console.log('receipt', receipt)
	})

module.exports = {}