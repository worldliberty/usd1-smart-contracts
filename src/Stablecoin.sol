// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/Ownable2StepUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/security/PausableUpgradeable.sol";

contract Stablecoin is ERC20PermitUpgradeable, Ownable2StepUpgradeable, PausableUpgradeable {

    mapping(address => bool) public frozen;

    event Mint(address indexed caller, address indexed to, uint256 amount);
    event Burn(address indexed caller, address indexed from, uint256 amount);
    event Freeze(address indexed caller, address indexed account);
    event Unfreeze(address indexed caller, address indexed account);

    function initialize(string memory _name, string memory _symbol) public initializer {
        __Context_init();
        __ERC20_init(_name, _symbol);
        __ERC20Permit_init(_name);
        __Ownable2Step_init();
        __Pausable_init();
    }
    
    /**
     * @dev Throws if account is frozen.
     */
    modifier notFrozen(address account) {
        require(!frozen[account], "Account is frozen");
        _;
    }

    /** 
     * @dev See {ERC20-_mint}.
     * @param amount Mint amount
     * @return True if successful
     * Can only be called by the current owner.
     */
    function mint(uint256 amount) external onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        emit Mint(_msgSender(), _msgSender(), amount);
        return true;
    }

    /**
     * @dev See {ERC20-_burn}.
     * @param amount Burn amount
     * @return True if successful
     * Can only be called by the current owner.
     */
    function burn(uint256 amount) external onlyOwner returns (bool) {
        _burn(_msgSender(), amount);
        emit Burn(_msgSender(), _msgSender(), amount);
        return true;
    }
    
    /**
     * @dev Adds account to frozen state.
     * Can only be called by the current owner.
     */
    function freeze(address account) external onlyOwner {
        frozen[account] = true;
        emit Freeze(_msgSender(), account);
    }

    /**
     * @dev Removes account from frozen state.
     * Can only be called by the current owner.
     */
    function unfreeze(address account) external onlyOwner {
        delete frozen[account];
        emit Unfreeze(_msgSender(), account);
    }

    /**
     * @dev Triggers stopped state.
     * Can only be called by the current owner.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Returns to normal state.
     * Can only be called by the current owner.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Unsupported. Leaves the contract without owner.
     */
    function renounceOwnership() public view override onlyOwner {
        revert("Unsupported");
    }

    /**
     * @dev See {ERC20-_transfer}.
     * @param from Source address
     * @param to Destination address
     * @param amount Transfer amount
     */
    function _transfer(address from, address to, uint256 amount) internal override whenNotPaused notFrozen(from) notFrozen(to) {
        super._transfer(from, to, amount);
    }

    /**
     * @dev See {ERC20-_approve}.
     * @param owner Owners's address
     * @param spender Spender's address
     * @param amount Allowance amount
     */
    function _approve(address owner, address spender, uint256 amount) internal override whenNotPaused notFrozen(owner) notFrozen(spender) {
        super._approve(owner, spender, amount);
    }
}
