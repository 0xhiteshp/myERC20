// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {myERC} from "../src/MyToken.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract MyTokenTest is Test {
    myERC public token;

    address public deployer;
    address public recipient;
    address public ownerAddress;
    address public bob;
    address public alice;

    uint256 public constant INITIAL_SUPPLY = 100_000 ether;
    uint8 public constant EXPECTED_DECIMALS = 18;

    function setUp() public {
        deployer = makeAddr("deployer");
        recipient = makeAddr("recipient");
        ownerAddress = makeAddr("owner");
        bob = makeAddr("bob");
        alice = makeAddr("alice");

        // Deploy with recipient getting initial supply and ownerAddress as Ownable owner
        vm.prank(deployer);
        token = new myERC(recipient, ownerAddress);

        // Seed bob with some tokens from recipient's balance
        uint256 bobStartingAmount = 100 ether;
        vm.prank(recipient);
        token.transfer(bob, bobStartingAmount);
    }

    function test_Metadata() public view {
        assertEq(token.name(), "myERC");
        assertEq(token.symbol(), "SJ");
        assertEq(token.decimals(), EXPECTED_DECIMALS);
    }

    function test_InitialSupplyAndBalances() public view {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        // recipient received full supply then transferred 100 ether to bob in setUp
        assertEq(token.balanceOf(bob), 100 ether);
        assertEq(token.balanceOf(recipient), INITIAL_SUPPLY - 100 ether);
    }

    function test_OwnerIsInitialOwner() public view {
        assertEq(token.owner(), ownerAddress);
    }

    function test_TransfersUpdateBalances() public {
        uint256 amount = 25 ether;

        vm.prank(recipient);
        token.transfer(alice, amount);

        assertEq(token.balanceOf(alice), amount);
        assertEq(token.balanceOf(recipient), INITIAL_SUPPLY - 100 ether - amount);
    }

    function test_TransferRevertsOnInsufficientBalance() public {
        vm.prank(alice); // alice has 0
        vm.expectRevert();
        token.transfer(bob, 1 ether);
    }

    function test_ApproveAndTransferFrom() public {
        uint256 allowanceAmount = 1_000 ether;
        uint256 transferAmount = 250 ether;

        // recipient approves alice
        vm.prank(recipient);
        token.approve(alice, allowanceAmount);
        assertEq(token.allowance(recipient, alice), allowanceAmount);

        // alice spends from recipient to bob
        vm.prank(alice);
        token.transferFrom(recipient, bob, transferAmount);

        assertEq(token.balanceOf(bob), 100 ether + transferAmount);
        assertEq(token.balanceOf(recipient), INITIAL_SUPPLY - 100 ether - transferAmount);
        assertEq(token.allowance(recipient, alice), allowanceAmount - transferAmount);
    }

    function test_ApproveOverwrite() public {
        // Approve then overwrite approval per ERC20 spec
        vm.prank(recipient);
        token.approve(alice, 100);
        assertEq(token.allowance(recipient, alice), 100);

        vm.prank(recipient);
        token.approve(alice, 40);
        assertEq(token.allowance(recipient, alice), 40);
    }

    function test_NonExistentMintShouldRevert() public {
        // myERC does not expose a public mint; calling via interface should revert
        vm.expectRevert();
        MintableToken(address(token)).mint(address(this), 1 ether);
    }
}
