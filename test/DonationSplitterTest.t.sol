// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import {Test} from "forge-std/Test.sol";
import {DonationSplitter} from "../src/DonationSplitter.sol";

contract DonationSplitterTest is Test {
    DonationSplitter donationSplitter;

    receive() external payable {}
    fallback() external payable {}

    address payable[] payees = [
        payable(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266),
        payable(0x70997970C51812dc3A010C7d01b50e0d17dc79C8),
        payable(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC)
    ];

    function setUp() public {
        donationSplitter = new DonationSplitter();
    }

    function testInitialState() public view {
        assertEq(donationSplitter.totalDonated(), 0);
        assertEq(donationSplitter.totalDistributed(), 0);
        assertEq(donationSplitter.payees(0), payees[0]);
        assertEq(donationSplitter.payees(1), payees[1]);
        assertEq(donationSplitter.payees(2), payees[2]);
    }

    function testSplitDonation() public {
        // Arrange
        uint256 donationAmount = 3 ether;
        // Directly fund the contract for testing
        vm.deal(address(donationSplitter), donationAmount);

        // Act
        donationSplitter.splitDonation();

        // Assert
        assertEq(donationSplitter.totalDistributed(), 3 ether);
        assertEq(address(donationSplitter).balance, 0);

        for (uint256 i = 0; i < payees.length; i++) {
            assertEq(payees[i].balance, 1 ether);
        }
    }

    function testSplitDonationWithDust() public {
        //Arrange
        uint256 donationAmount = 5 ether;
        address ownerAddress = donationSplitter.owner();
        uint256 ownerStartBalance = ownerAddress.balance;

        // Directly fund the contract for testing
        vm.deal(address(donationSplitter), donationAmount);

        // Act
        donationSplitter.splitDonation();

        // Calculate expected values
        uint256 expectedShare = donationAmount / payees.length; // 1.666... ETH per payee
        uint256 expectedTotal = expectedShare * payees.length; // 3 ETH total to payees
        uint256 expectedDust = donationAmount - expectedTotal; // 2 ETH dust to owner

        // Assert
        assertEq(donationSplitter.totalDistributed(), expectedTotal); // Only 3 ETH sent to payees
        assertEq(address(donationSplitter).balance, 0); // Contract should be empty

        for (uint256 i = 0; i < payees.length; i++) {
            assertEq(payees[i].balance, expectedShare);
        }
        // Compare delta instead of absolute balance
        uint256 ownerEndBalance = ownerAddress.balance;
        assertEq(ownerEndBalance - ownerStartBalance, expectedDust);
    }

    function testOnlyOwnerCanSplit() public {
        // Arrange
        uint256 donationAmount = 1 ether;
        // Directly fund the contract for testing
        vm.deal(address(donationSplitter), donationAmount);

        // Act & Assert
        vm.expectRevert("Only the contract owner can call this function");
        vm.prank(payees[0]); // Simulate a call from a non-owner
        donationSplitter.splitDonation();
    }

    function testCannotSplitWithoutFunds() public {
        // Act & Assert
        vm.expectRevert("No balance to distribute");
        donationSplitter.splitDonation();
    }

    function testDonationTooSmallToSplit() public {
        //Arrange
        uint256 donationAmount = 2 wei; // Too small to split between 3
        // Directly fund the contract with a small amount
        vm.deal(address(donationSplitter), donationAmount);
        //Act & Assert
        vm.expectRevert("Share must be greater than zero");
        donationSplitter.splitDonation();
    }

    function testReceiveAndEmitDonation() public {
        //Arrange
        uint256 donationAmount = 1 ether;

        // Expect the Received event before sending ETH
        vm.expectEmit(true, true, false, true);
        emit DonationSplitter.Received(address(this), donationAmount);

        // Act: Send ETH directly to the contract
        (bool success, ) = address(donationSplitter).call{
            value: donationAmount
        }("");
        require(success, "Failed to send ETH to contract");

        // Assert: Chech if the donation was received
        assertEq(donationSplitter.totalDonated(), donationAmount);
        assertEq(address(donationSplitter).balance, donationAmount);
    }

    function testSplitDonationEmitsEventsAndDistributesCorrectly() public {
        uint256 donationAmount = 3 ether;
        vm.deal(address(donationSplitter), donationAmount);

        // Expect the DonationDistributed event when splitting
        vm.expectEmit(true, true, false, true);
        emit DonationSplitter.DonationDistributed(
            payees[0],
            donationAmount / 3
        );
        vm.expectEmit(true, true, false, true);
        emit DonationSplitter.DonationDistributed(
            payees[1],
            donationAmount / 3
        );
        vm.expectEmit(true, true, false, true);
        emit DonationSplitter.DonationDistributed(
            payees[2],
            donationAmount / 3
        );

        // Act: Split the donation
        donationSplitter.splitDonation();

        // Assert: Check if the donation was split correctly
        assertEq(donationSplitter.totalDistributed(), donationAmount);
    }

    function testFallbackFunction() public {
        // Arrange
        uint256 donationAmount = 1 ether;
        vm.deal(address(this), donationAmount);

        // Expect the fallback
        vm.expectEmit(true, true, false, true);
        emit DonationSplitter.FallBackCalled(address(this), donationAmount);

        //Act: Send call with data to trigger fallback
        (bool success, ) = address(donationSplitter).call{
            value: donationAmount
        }(abi.encodeWithSignature("nonexistentFunction()"));
        require(success, "failed to send ETH to contract");

        // Assert: Check if the fallback was called
        assertEq(address(donationSplitter).balance, donationAmount);
    }
}
