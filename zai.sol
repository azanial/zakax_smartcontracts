// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}

contract ZAI is IERC20 {

    string constant _name = "ZAI";
    string constant _symbol = "ZAI";
    uint256 constant _decimals = 2;
    
    uint256 _totalSupply = 0;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;

    address admin;

    using SafeMath for uint256;

    constructor() {
        admin = msg.sender;
    }
    
    function name() public pure returns (string memory) {
        return _name;
    }
    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    
    function decimals() public pure returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view override returns (uint256) {
        return balances[owner];
    }
    
    function allowance(address owner, address delegate) public view override returns (uint256) {
        return allowed[owner][delegate];
    }

    function transfer(address receiver, uint256 amount) public override returns (bool) {
        require(amount <= balances[msg.sender], "Balance less than amount transferred");
        
        balances[msg.sender] = balances[msg.sender].sub(amount);
        balances[receiver] = balances[receiver].add(amount);
        
        emit Transfer(msg.sender, receiver, amount);
        
        return true;
    }

    function approve(address delegate, uint256 amount) public override returns (bool) {
        allowed[msg.sender][delegate] = amount;
        
        emit Approval(msg.sender, delegate, amount);
        
        return true;
    }

    function transferFrom(address owner, address receiver, uint256 amount) public override returns (bool) {
        require(amount <= balances[owner], "Balance less than amount transferred");
        require(amount <= allowed[owner][msg.sender], "Allowed less than amount transferred");

        balances[owner] = balances[owner].sub(amount);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(amount);
        balances[receiver] = balances[receiver].add(amount);
        
        emit Transfer(owner, receiver, amount);
        
        return true;
    }
    
    function mint(address receiver, uint256 amount) public returns (bool) {
        require(msg.sender == admin, "Not admin");
        
        balances[receiver] = balances[receiver].add(amount);
        _totalSupply = _totalSupply.add(amount);
        
        emit Mint(receiver, amount);
        
        return true;
    }
    
    function burn(address owner, uint256 amount) public returns (bool) {
        require(msg.sender == admin, "Not admin");
        require(amount <= balances[owner], "Balance less than amount to be burnt");
        
        balances[owner] = balances[owner].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        
        emit Burn(owner, amount);
        
        return true;
    }

    function changeAdmin(address newAdmin) external {
        require(msg.sender == admin, "Not admin");

        admin = newAdmin;
    }
    
}
