// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

import {Test, console} from "forge-std/Test.sol";
import {DeployBox} from "../script/DeployBox.s.sol";
import {UpgradeBox} from "../script/UpgradeBox.s.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {BoxV2} from "../src/BoxV2.sol";

contract DeployAndUpgradeTest is Test {
    DeployBox public deployer;
    UpgradeBox public upgrader;
    address public proxy;
    address public OWNER = makeAddr("OWNER");

    function setUp() public {
        deployer = new DeployBox();
        upgrader = new UpgradeBox();

        proxy = deployer.run(); // currently points to boxV1
    }

    function testDeploymentIsV1() public {
        uint256 expectedValue = 7;
        vm.expectRevert();
        BoxV2(proxy).setNumber(expectedValue);
    }

    function testUpgrade() public {
        uint8 expectedVersion = 2;
        uint256 expectedNumber = 3;

        BoxV2 boxV2 = new BoxV2();

        upgrader.upgradeBox(proxy, address(boxV2));
        uint8 currentVersion = BoxV2(proxy).getVersion();
        assert(currentVersion == expectedVersion);

        BoxV2(proxy).setNumber(3);
        assert(BoxV2(proxy).getNumber() == expectedNumber);
    }
}
