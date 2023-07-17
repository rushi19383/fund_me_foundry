// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 private constant SEND_VAL = 0.1 ether;
    address private mostRecentFundMe;

    function fundFundMe(address mostRecentDeployed) external {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployed)).fund{value: SEND_VAL}();
        vm.stopBroadcast();
        console.log("Funded %s with %d Ether", mostRecentDeployed, SEND_VAL);
    }

    function run() external {
        // vm.startBroadcast();
        mostRecentFundMe = DevOpsTools.get_most_recent_deployment("FundMe",block.chainid);
        // vm.stopBroadcast();
    }

}

contract WithdrawFundMe is Script {
    uint256 private constant SEND_VAL = 0.1 ether;
    address private mostRecentFundMe;

    function withdrawFundMe(address mostRecentDeployed) external {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Withdrew ETH from %s", mostRecentDeployed);
    }

    function run() external {
        // vm.startBroadcast();
        mostRecentFundMe = DevOpsTools.get_most_recent_deployment("FundMe",block.chainid);
        // vm.stopBroadcast();
    }

}