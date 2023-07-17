// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address priceFeedAddress;
    }

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_FEED_PRICE = 2000e8;

    NetworkConfig public s_activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            s_activeNetworkConfig = getSepoliaEthConfig();
        } else {
            s_activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // Sepolia ETH/USD pricefeeed address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        NetworkConfig memory sepoliaConfig =
            NetworkConfig({priceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return (sepoliaConfig);
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if(s_activeNetworkConfig.priceFeedAddress != address(0)) {
            return (s_activeNetworkConfig);
        }

        // price feed address
        // 1. Deploy mocks
        // 2. Return mock address(es)
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_FEED_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeedAddress: address(mockPriceFeed)});
        return (anvilConfig);
    }
}
