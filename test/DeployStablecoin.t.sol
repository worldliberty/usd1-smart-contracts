// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../src/Stablecoin.sol";

contract DeployStablecoinTest is Test {
    uint256 internal ownerPrivateKey;
    address internal owner;
    string internal constant NAME = "$ Token";
    string internal constant SYMBOL = "$";
    Stablecoin internal impl;
    ProxyAdmin internal proxyAdmin;
    TransparentUpgradeableProxy internal proxy;

    function setUp() public {
        ownerPrivateKey = 0xA11CE;
        owner = vm.addr(ownerPrivateKey);

        vm.startPrank(owner);
        
        // refer to script/DeployStablecoin.s.sol
        impl = new Stablecoin();
        proxyAdmin = new ProxyAdmin();
        proxy = new TransparentUpgradeableProxy(
            address(impl),
            address(proxyAdmin),
            abi.encodeWithSignature("initialize(string,string)", NAME, SYMBOL)
        );
        impl.initialize(NAME, SYMBOL);

        vm.stopPrank();
    }

    function test_Initialize() public {
        assertEq(proxyAdmin.owner(), owner);
        assertEq(proxyAdmin.getProxyAdmin(proxy), address(proxyAdmin));
        assertEq(proxyAdmin.getProxyImplementation(proxy), address(impl));
        assertEq(keccak256(abi.encodePacked(Stablecoin(address(proxy)).name())), keccak256(abi.encodePacked(NAME)));
        assertEq(keccak256(abi.encodePacked(Stablecoin(address(proxy)).symbol())), keccak256(abi.encodePacked(SYMBOL)));
        assertEq(keccak256(abi.encodePacked(impl.name())), keccak256(abi.encodePacked(NAME)));
        assertEq(keccak256(abi.encodePacked(impl.symbol())), keccak256(abi.encodePacked(SYMBOL)));
    }
}
