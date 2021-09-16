// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';

library EnumerableNodeId {
	using EnumerableSet for EnumerableSet.Bytes32Set;

	struct Map {
		// Storage of keys
		EnumerableSet.Bytes32Set _keys;
		mapping(uint256 => uint256) _values;
	}

	function set(
		Map storage map,
		uint256 key,
		uint256 value
	) internal returns (bool) {
		map._values[key] = value;
		return map._keys.add(bytes32(key));
	}

	function remove(Map storage map, uint256 key) internal returns (bool) {
		delete map._values[key];
		return map._keys.remove(bytes32(key));
	}

	function contains(Map storage map, uint256 key) internal view returns (bool) {
		return map._keys.contains(bytes32(key));
	}

	function length(Map storage map) internal view returns (uint256) {
		return map._keys.length();
	}

	function at(Map storage map, uint256 index) internal view returns (uint256, uint256) {
		uint256 key = uint256(map._keys.at(index));
		return (key, map._values[key]);
	}

	function tryGet(Map storage map, uint256 key) internal view returns (bool, uint256) {
		uint256 value = map._values[key];
		if (value == uint256(0)) {
			return (contains(map, key), uint256(0));
		} else {
			return (true, value);
		}
	}

	function get(Map storage map, uint256 key) internal view returns (uint256) {
		uint256 value = map._values[key];
		require(value != 0 || contains(map, key), 'EnumerableMap: nonexistent key');
		return value;
	}

	function get(
		Map storage map,
		uint256 key,
		string memory errorMessage
	) internal view returns (uint256) {
		uint256 value = map._values[key];
		require(value != 0 || contains(map, key), errorMessage);
		return value;
	}
}
