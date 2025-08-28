// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script} from "forge-std/Script.sol";
import {myERC} from "../src/MyToken.sol";

contract Deploy is Script {
    function run() external returns (myERC) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);
        myERC token = new myERC(deployer, deployer);
        vm.stopBroadcast();

        return token;
    }
}
