// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract TestFundMe is Test {
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

    function testMinDollarsIsFive() external {
        uint256 minDollars = fundMe.getMinimumUSD();
        assertEq(minDollars, 5 * 10 ** 18);
    }

    function testContractIsOwner() external {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() external {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundingFailsWithInsfETH() external {
        vm.expectRevert();
        fundMe.fund{value: 10000}();
    }

    function testUpdateFundedStruct() external funded {
        assertEq(fundMe.getAddressToAmountFunded(address(USER)), SEND_VAL);
    }

    function testUserAddedToFundersArray() external funded {
        assertEq(fundMe.getFunders(0), address(USER));
    }

    function testOnlyOwnerCanWithdraw() external funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
    }

    function testOwnerWithdrawl() external funded {
        // Arrange
        uint256 initOwnerBalance = fundMe.getOwner().balance;
        uint256 initContractBalance = address(fundMe).balance;
        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 endOwnerBalance = fundMe.getOwner().balance;
        uint256 endContractBalance = address(fundMe).balance;
        // Assert
        assertEq(endContractBalance, 0);
        assertEq(initOwnerBalance + initContractBalance, endOwnerBalance);

    }

    function testWithdrawalFromMultipleFunders() external funded {
        // Arrange
        uint8 numFunders = 10;
        uint8 startFunderIndex = 1;
        for(uint8 i = startFunderIndex; i <= numFunders; i++) {
            hoax(address(uint160(i)), INIT_SEND);
            fundMe.fund{value: SEND_VAL}();
        }
        uint256 initOwnerBalance = fundMe.getOwner().balance;
        uint256 initContractBalance = address(fundMe).balance;
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 endOwnerBalance = fundMe.getOwner().balance;
        uint256 endContractBalance = address(fundMe).balance;
        uint256 gasEnd = gasleft();

        console.log("Gas used: %d", (gasStart - gasEnd) * tx.gasprice);

        // Assert
        assertEq(endContractBalance, 0);
        assertEq(initOwnerBalance + initContractBalance, endOwnerBalance);

    }
    function testCheapWithdrawalFromMultipleFunders() external funded {
        // Arrange
        uint8 numFunders = 10;
        uint8 startFunderIndex = 1;
        for(uint8 i = startFunderIndex; i <= numFunders; i++) {
            hoax(address(uint160(i)), INIT_SEND);
            fundMe.fund{value: SEND_VAL}();
        }
        uint256 initOwnerBalance = fundMe.getOwner().balance;
        uint256 initContractBalance = address(fundMe).balance;
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        // Act
        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        uint256 endOwnerBalance = fundMe.getOwner().balance;
        uint256 endContractBalance = address(fundMe).balance;
        uint256 gasEnd = gasleft();

        console.log("Gas used: %d", (gasStart - gasEnd) * tx.gasprice);
        
        // Assert
        assertEq(endContractBalance, 0);
        assertEq(initOwnerBalance + initContractBalance, endOwnerBalance);

    }

    
}
