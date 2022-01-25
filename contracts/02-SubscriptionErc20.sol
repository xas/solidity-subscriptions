//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ISubscriptionBasic.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SubscriptionErc20 is ISubscriptionBasic, ERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    mapping (address => uint256) private _subscriptions;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) Ownable() {
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view override returns (uint8) {
        // return 0, as we manage only 1 token for a subscription
        return 0;
    }

    function mint(address to, uint32 period) override public onlyOwner returns (bool) {
        require(to != address(0), "Fake address");
        require(period > 0, "Period cannot be zero");
        uint endTime = block.timestamp + period * 1 days;
        require(_subscriptions[to] < endTime, "You cannot set a smaller subscription time");
        _balances[to] = 1;
        _subscriptions[to] = endTime;
        _totalSupply += 1;
        emit MintedSubscription(to, endTime);
        return true;
    }

    function isSubscriptionValid(address to) override external view returns (bool) {
        require(to != address(0), "ERC20: mint to the zero address");
        require(to != owner(), "Owner cannot subscribe");
        return _subscriptions[to] > block.timestamp;
    }

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) override public view returns (uint256) {
        require(account != owner(), "Owner cannot subscribe");
        // return 0 or 1
        // 1 does not indicate the subscription is still valid
        return super.balanceOf(account);
    }

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) override public returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), 0);

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) override internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] > 0, "No subscription available");
        require(amount == 1, "Works with only one subscription");
        require(_subscriptions[sender] > block.timestamp, "You cannot transfer an expired subscription");
        uint endTime = _subscriptions[sender];
        require(_balances[recipient] == 0 || _subscriptions[recipient] < endTime, "Recipient has a better subscription");
        _balances[sender] = 0;
        _subscriptions[sender] = 0;
        _balances[recipient] = 1;
        _subscriptions[recipient] = endTime;
        
        emit Transfer(sender, recipient, 1);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) override internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        require(amount == 0 || amount == 1, "Only 0/1 allowed");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
