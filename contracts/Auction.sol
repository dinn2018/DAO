// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import './interfaces/INodes.sol';
import './interfaces/INodeLending.sol';

contract Auction {
	using SafeMath for uint256;

	INodes public immutable nodes;
	INodeLending public immutable lending;
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

	mapping(uint256 => HighestVoter) public highest;

	uint256 public immutable minimumVotes = 2000 * 1e18;

	event VoteWithMortgage(address to, uint256 amount);

	event VoteWithLending(address to, uint256 amount);

	event CandleEnded(address to, uint256 rands);

	constructor(
		INodes nodes_,
		INodeLending lending_,
		uint256 startTime_,
		uint256 candleStartTime_,
		uint256 endTime_
	) {
		require(startTime_ > block.timestamp, 'Auction: invalid startTime');
		require(startTime_ < candleStartTime_, 'Auction: invalid candleStartTime');
		require(candleStartTime_ < endTime_, 'Auction: invalid endTime');
		nodes = nodes_;
		lending = lending_;
		startTime = startTime_;
		candleStartTime = candleStartTime_;
		endTime = endTime_;
	}

	function voteWithMortgage(uint256 nodeId) external payable validateAuction {
		require(msg.value >= minimumVotes, 'Auction: not up to minimumVotes.');
		address to = msg.sender;
		lending.mortgage(to, nodeId, msg.value);
		update(nodeId);

		emit VoteWithMortgage(to, msg.value);
	}

	function voteWithLending(uint256 nodeId, uint256 amount) external validateAuction {
		address to = msg.sender;
		lending.unrealise(to, nodeId, amount);
		update(nodeId);
		emit VoteWithLending(to, amount);
	}

	function votes(address to, uint256 nodeId) public view returns (uint256) {
		return lending.mortgageOf(to, nodeId).add(lending.unrealisedLoans(to, nodeId));
	}

	function withdrawMortgage(uint256 nodeId) external AuctionEnd {
		address to = msg.sender;
		require(to != highest[nodeId].account, 'Auction: you are the auction winner');
		uint256 amount = lending.mortgageOf(to, nodeId);
		require(amount > 0, 'Auction: no mortgages.');
		payable(to).transfer(amount);
		lending.clear(to, nodeId);
	}

	function release(uint256 nodeId) public AuctionEnd {
		address to = highest[nodeId].account;
		lending.realise(to, nodeId);
		nodes.mortgage{ value: lending.mortgageOf(to, nodeId) }(nodeId, to);
	}

	function isEnded() external view returns (bool) {
		return block.timestamp > endTime || isCandleEnded;
	}

	function update(uint256 nodeId) internal {
		updateHighestVotes(msg.sender, nodeId);
		// updateCandle(nodeId);
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
			bytes32 hash = keccak256(abi.encodePacked(blockhash(block.number), msg.sender));
			if (uint256(hash) < 0x00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff) {
				isCandleEnded = true;
				release(nodeId);

				emit CandleEnded(msg.sender, uint256(hash));
			}
		}
	}

	modifier validateAuction() {
		require(block.timestamp >= startTime, 'Auction: auction is not started');
		require(block.timestamp < endTime, 'Auction: auction is ended');
		require(!isCandleEnded, 'Auction: candle ended.');
		_;
	}

	modifier AuctionEnd() {
		require(isCandleEnded || block.timestamp >= endTime, 'Auction: auction is not ended');
		_;
	}
}
