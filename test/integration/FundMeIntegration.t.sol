// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe,WithdrawFundMe} from "../../script/Interactions.s.sol";

contract TestFundMeIntegration is Test {
    FundMe fundMe;
    address USER = makeAddr("user1");
    uint256 constant SEND_VAL = 0.1 ether;
    uint256 constant INIT_SEND = 10 ether;
    uint256 constant GAS_PRICE = 1;
    
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VAL}();
        _;
    }

    function setUp() external {
        DeployFundMe fundMeDeployer = new DeployFundMe();
        fundMe = fundMeDeployer.run();
        vm.deal(USER, INIT_SEND);
    }

    function testUserCanFundAndWithdraw() external {
        FundFundMe fundFundMe = new FundFundMe();
        // vm.prank(USER);
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
    }
}