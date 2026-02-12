// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TimelockedSavingsVault {
    struct Vault {
        uint256 amount;
        uint256 unlockTime;
    }

    mapping(address => Vault) private vaults;

    event Deposited(address indexed user, uint256 amount, uint256 unlockTime);
    event Withdrawn(address indexed user, uint256 amount);

    error VaultAlreadyExists();
    error NoActiveVault();
    error UnlockTimeInPast();
    error AmountMustBePositive();
    error NotUnlocked();
    error TransferFailed();

    function deposit(uint256 unlockTime) external payable {
        if (msg.value == 0) revert AmountMustBePositive();
        Vault storage v = vaults[msg.sender];
        if (v.amount != 0) revert VaultAlreadyExists();
        if (unlockTime <= block.timestamp) revert UnlockTimeInPast();

        v.amount = msg.value;
        v.unlockTime = unlockTime;

        emit Deposited(msg.sender, msg.value, unlockTime);
    }

    function withdraw() external {
        Vault storage v = vaults[msg.sender];
        if (v.amount == 0) revert NoActiveVault();
        if (block.timestamp < v.unlockTime) revert NotUnlocked();

        uint256 amount = v.amount;

        // Reset vault before transfer to prevent reentrancy
        v.amount = 0;
        v.unlockTime = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");
        if (!sent) revert TransferFailed();

        emit Withdrawn(msg.sender, amount);
    }

    // Reject direct ETH transfers to force users to call `deposit`
    receive() external payable {
        revert("Direct transfers not allowed");
    }

    fallback() external payable {
        revert("Direct transfers not allowed");
    }

    /// @notice Returns the vault details for `user`.
    function getVault(
        address user
    ) external view returns (uint256 amount, uint256 unlockTime) {
        Vault storage v = vaults[user];
        return (v.amount, v.unlockTime);
    }
}
