pragma solidity ^0.4.21;

import "./ERC223ReceivingContract.sol";
import "./ERC223.sol";

library SafeMath {
   function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
     if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
}
}

contract ERC223Token is ERC223, ERC223ReceivingContract  {
    mapping(address => uint) balances;
    mapping(address => mapping (address => uint)) internal _allowances;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    using SafeMath for uint256;

    function ERC223Token() public {
        symbol = "CTK";
        name = "Cut Token";
        decimals = 0;
        totalSupply = 10000;
        balances[msg.sender] = totalSupply;
    }

    // function to access name of token
    function name() public view returns (string _name){
        return name;
    }

    //function to access symbol of token
    function symbol() public view returns (string _symbol) {
        return symbol;
    }

    //function to access decimals of token
    function decimals() public view returns (uint8 _decimals) {
        return decimals;
    }

    //function to access total supply of tokens
    function totalSupply() public view returns (uint256 _totalSupply) {
        return totalSupply;
    }

    // assemble the given address bytecode. If bytecode exists then the _addr is a contract
    function isContract(address _addr) private view returns (bool is_contract) {
        uint length;
        assembly {
            length := extcodesize(_addr)
        }
        return (length >0);
    }

    // function that is called when tracsaction target is an address
    function transfertoAddress(address _to, uint _value, bytes _data) private returns (bool success){
        if(balanceOf(msg.sender) < _value) revert();

        //take ether from sender and send it to receiver
        balances[msg.sender] = balanceOf(msg.sender).sub(_value);
        balances[_to] = balanceOf(_to).add(_value);

        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }

    //function that is called when tracsaction target is contract
    function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
        if(balanceOf(msg.sender) < _value) revert();

        //take ether from sender and send it to contract
        balances[msg.sender] = balanceOf(msg.sender).sub(_value);
        balances[_to] = balanceOf(_to).add(_value);

        ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }


    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

    //Standard function transfer similar to erc20 transfer with no_data
    function transfer(address _to, uint _value) public returns (bool success) {
        bytes memory empty;

        if(isContract(_to)){
            return transferToContract(_to, _value, empty);
        }else {
            return transfertoAddress(_to, _value, empty);
        }
    }

    // Function that is called when a user or another contract wants to transfer funds .
    function transfer(address _to, uint _value, bytes _data) public returns (bool success) {
        if(isContract(_to)) {
            return transferToContract(_to, _value, _data);
        } else {
            return transfertoAddress(_to, _value, _data);
        }
    }

}