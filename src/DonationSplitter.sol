// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

contract DonationSplitter {
    ///////* Variables *///////
    uint256 public totalDonated; // total ETH donated
    uint256 public totalDistributed; // total ETH sent to payees
    address payable[] public payees = [
        // Array of payees to receive donations
        payable(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266),
        payable(0x70997970C51812dc3A010C7d01b50e0d17dc79C8),
        payable(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC)
    ];
    address public immutable owner; // Contract Owner

    ///////* Events *///////
    event Received(address indexed sender, uint256 amount);
    event FallBackCalled(address indexed sender, uint256 amount);
    event DonationDistributed(address indexed payee, uint256 amount);

    ///////* Modifiers *///////
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function"
        );
        _;
    }

    ///////* Constructor *///////
    constructor() {
        owner = msg.sender;
    }

    ///////* Functions *////////
    // Distribute ETH equally among payees, send any dust to owner
    function splitDonation() public onlyOwner {
        uint256 balance = address(this).balance; // Get contract balance and ensure there are donations to split
        require(balance > 0, "No balance to distribute"); // Check balance > 0
        uint256 donationShare = balance / payees.length; // Calculate share = balance / payees.length
        require(donationShare > 0, "Share must be greater than zero");

        for (uint256 i = 0; i < payees.length; i++) {
            // Loop through payees
            address payable payee = payees[i];
            (bool success, ) = payee.call{value: donationShare}(""); // Send share using call()
            require(success, "Transfer failed"); // Ensure transfer was successful
            emit DonationDistributed(payee, donationShare); // Emit event
            totalDistributed += donationShare; // Update total distributed
        }
        // Send leftover balance (dust) to owner
        uint256 remainingDust = address(this).balance;
        if (remainingDust > 0) {
            (bool dustSuccess, ) = payable(owner).call{value: remainingDust}(
                ""
            );
            require(dustSuccess, "Dust transfer to owner failed");
        }
    }

    // receive direct ETH transfers
    receive() external payable {
        totalDonated += msg.value;
        emit Received(msg.sender, msg.value);
    }

    // Fallback to catch accidental calls or unknown data
    fallback() external payable {
        emit FallBackCalled(msg.sender, msg.value);
    }
}
