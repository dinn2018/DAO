// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import './libraries/ECVRF.sol';

contract ECVRFImp {
	function verify(
		uint256[2] memory publicKey,
		uint256[4] memory proof,
		bytes memory alpha
	) external pure returns (uint256 beta) {
		bool verified = ECVRF.verify(publicKey, proof, alpha);
		require(verified, 'ECVRF: verify failed');
		beta = uint256(ECVRF.gammaToHash(proof[0], proof[1]));
	}

	function fastVerify(
		uint256[2] memory publicKey,
		uint256[4] memory proof,
		bytes memory alpha,
		uint256[2] memory uPoint,
		uint256[4] memory vComponents
	) external pure returns (uint256 beta) {
		bool verified = ECVRF.fastVerify(publicKey, proof, alpha, uPoint, vComponents);
		require(verified, 'ECVRF: fast verify failed');
		beta = uint256(ECVRF.gammaToHash(proof[0], proof[1]));
	}

	function computeFastVerifyParams(
		uint256[2] memory publicKey,
		uint256[4] memory proof,
		bytes memory alpha
	) external pure returns (uint256[2] memory, uint256[4] memory) {
		return ECVRF.computeFastVerifyParams(publicKey, proof, alpha);
	}

	function decodePoint(bytes memory publicKey) external pure returns (uint256[2] memory) {
		return ECVRF.decodePoint(publicKey);
	}

	function decodeProof(bytes memory proof) external pure returns (uint256[4] memory) {
		return ECVRF.decodeProof(proof);
	}

	function gammaToHash(uint256 gammaX, uint256 gammaY) external pure returns (bytes32) {
		return ECVRF.gammaToHash(gammaX, gammaY);
	}
}
