// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import './interfaces/INodeLending.sol';
import './interfaces/IStake.sol';

contract NodeAuction {
	using SafeMath for uint256;

	INodeLending public immutable lending;
	IStake public immutable stake;
	uint256 public immutable startTime;
	uint256 public immutable candleStartTime;
	uint256 public immutable endTime;

	bool public isCandleEnded;

	struct HighestVoter {
		address account;
		uint256 amount;
	}

	struct Mortgage {
		uint256 amount;
		uint256 apy;
	}

	// `voter` => `nodeID` => `Mortgage`
	mapping(address => mapping(uint256 => Mortgage)) public mortgages;

	// `voter` => `nodeID` => `unrealisedLoans`
	mapping(address => mapping(uint256 => uint256)) public unrealisedLoans;

	mapping(uint256 => HighestVoter) public highest;

	uint256 public immutable minimumVotes = 2000 * 1e18;

	event VoteWithMortgage(address to, uint256 amount);

	event VoteWithLending(address to, uint256 amount);

	event CandleEnded(address to, uint256 rands);

	constructor(
		IStake stake_,
		INodeLending lending_,
		uint256 startTime_,
		uint256 candleStartTime_,
		uint256 endTime_
	) {
		require(startTime_ > block.timestamp, 'Auction: invalid startTime');
		require(
			startTime_ < candleStartTime_,
			'Auction: invalid candleStartTime'
		);
		require(candleStartTime_ < endTime_, 'Auction: invalid endTime');
		stake = stake_;
		lending = lending_;
		startTime = startTime_;
		candleStartTime = candleStartTime_;
		endTime = endTime_;
	}

	function voteWithMortgage(uint256 nodeId) external payable validateAuction {
		require(msg.value >= minimumVotes, 'Auction: not up to minimumVotes.');
		address to = msg.sender;
		mortgages[to][nodeId].amount = mortgages[to][nodeId].amount.add(msg.value);
		// use max apy.
		if (stake.apy() > mortgages[to][nodeId].apy) {
			mortgages[to][nodeId].apy = stake.apy();
		}
		require(
			maxLoan(to, nodeId) >= unrealisedLoans[to][nodeId],
			'Auction: exceed max loans.'
		);
		update(nodeId);

		emit VoteWithMortgage(to, msg.value);
	}

	function voteWithLending(uint256 nodeId, uint256 amount) external validateAuction {
		address to = msg.sender;
		uint256 loans = unrealisedLoans[to][nodeId].add(amount);
		require(maxLoan(to, nodeId) >= loans, 'Auction: exceed max loans.');
		unrealisedLoans[to][nodeId] = loans;
		update(nodeId);

		emit VoteWithLending(to, amount);
	}

	function votes(address to, uint256 nodeId) public view returns (uint256) {
		uint256 currentMortgages = mortgages[to][nodeId].amount;
		return currentMortgages.add(unrealisedLoans[to][nodeId]);
	}

	function withdrawMortgage(uint256 nodeId) external AuctionEnd {
		address to = msg.sender;
		require(to != highest[nodeId].account, 'Auction: you are the auction winner');
		uint256 amount = mortgages[to][nodeId].amount;
		require(amount > 0, 'AuctionLending: no mortgages.');
		payable(to).transfer(amount);
		delete mortgages[to][nodeId];
		delete unrealisedLoans[to][nodeId];
	}

	function manualEnd(uint256 nodeId) external AuctionEnd {
		realisedBorrow(nodeId);
	}

	function maxLoan(address to, uint256 nodeId) public view returns (uint256) {
		uint256 amount = mortgages[to][nodeId].amount;
		uint256 unrealisedRewardInOneYear = amount
			.mul(mortgages[to][nodeId].apy)
			.div(stake.NUMERATOR());
		return unrealisedRewardInOneYear
				.add(amount)
				.div(stake.RMAX())
				.mul(stake.NUMERATOR());
	}

	function isEnded() external view returns (bool) {
		return block.timestamp > endTime || isCandleEnded;
	}

	function realisedBorrow(uint256 nodeId) internal {
		address to = highest[nodeId].account;
		lending.borrow(nodeId, unrealisedLoans[to][nodeId]);
	}

	function update(uint256 nodeId) internal {
		updateHighestVotes(msg.sender, nodeId);
		updateCandle(nodeId);
	}

	function updateHighestVotes(address to, uint256 nodeId) internal {
		uint256 toVotes = votes(to, nodeId);
		if (toVotes > highest[nodeId].amount) {
			highest[nodeId].amount = toVotes;
			highest[nodeId].account = to;
		}
	}

	function updateCandle(uint256 nodeId) internal {
		if (block.timestamp >= candleStartTime && block.timestamp < endTime) {
			bytes32 hash = keccak256(
				abi.encodePacked(blockhash(block.number), msg.sender)
			);
			if (
				uint256(hash) <
				0x00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
			) {
				isCandleEnded = true;
				realisedBorrow(nodeId);

				emit CandleEnded(msg.sender, uint256(hash));
			}
		}
	}

	modifier validateAuction() {
		require(
			block.timestamp >= startTime,
			'Auction: auction is not started'
		);
		require(block.timestamp < endTime, 'Auction: auction is ended');
		require(!isCandleEnded, 'Auction: candle ended.');
		_;
	}

	modifier AuctionEnd() {
		require(!isCandleEnded, 'Auction: candle ended.');
		require(block.timestamp >= endTime, 'Auction: auction is not ended');
		_;
	}
}
