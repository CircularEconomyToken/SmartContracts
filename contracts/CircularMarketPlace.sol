//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface Token {

    /// @param _owner The address from which the balance will be retrieved
    /// @return balance the balance
    function balanceOf(address _owner) external view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transfer(address _to, uint256 _value)  external returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return success Whether the approval was successful or not
    function approve(address _spender  , uint256 _value) external returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return remaining Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Standard_Token is Token {
    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    uint256 public totalSupply;
    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier: eg SBX

    constructor(uint256 _initialAmount, string memory _tokenName, uint8 _decimalUnits, string  memory _tokenSymbol) {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }

    function transfer(address _to, uint256 _value) public override returns (bool success) {
        require(balances[msg.sender] >= _value, "token balance is lower than the value requested");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value, "token balance or allowance is lower than amount requested");
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function balanceOf(address _owner) public override view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public override returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function allowance(address _owner, address _spender) public override view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract CircularMarketPlace {
    Orders orderList;
    mapping(address => uint256) orderId;
    mapping(address => uint256) deposits;
    struct Offer {
        uint256 price;
        string usecase;
        uint256 earliestBlock;
        address _address;
        string status;
    }
    struct Order {
        uint256 orderId;
        string name;
        string unit;
        uint256 categories;
        uint256 quantity;
        uint256 expirationBlock;
        string itemDescription;
        uint256 condition;
        uint256 price;
        address buyer;
        string location;
        string status;
    }

    struct Orders {
        mapping(address => Order[]) orders;
        mapping(address => mapping(uint256 => Offer[])) Offers;
    }

    address[] sellers;
    Standard_Token USDT;
    constructor() {
        USDT = Standard_Token(0x67f6a7BbE0da067A747C6b2bEdF8aBBF7D6f60dc);
    }

    function addOrder(Order memory newOrder) public {
        require(nextOrderID(msg.sender) == newOrder.orderId);
        orderList.orders[msg.sender].push(newOrder);
        orderId[msg.sender] = orderId[msg.sender] + 1;
        sellers.push(msg.sender);
    }

    function updateOrder(Order memory newOrder) public {
        require(keccak256(abi.encodePacked((orderList.orders[msg.sender][newOrder.orderId].status))) != keccak256(abi.encodePacked(("Deleted"))));
        orderList.orders[msg.sender][newOrder.orderId] = newOrder;
    }

    function deleteOrder(uint oId) public {
        delete orderList.orders[msg.sender][oId];
        orderList.orders[msg.sender][oId].status = "Deleted";
    }

    function addOffer(Offer memory newOffer, address orderOwner, uint oId) public {
        require(msg.sender != orderOwner);
        require(msg.sender == newOffer._address);
        orderList.Offers[orderOwner][oId].push(newOffer);
    }

    function confirmOffer(address orderOwner, uint oId,uint offId) public{
        require(msg.sender == orderList.orders[orderOwner][oId].buyer);
        require(msg.sender == orderList.Offers[orderOwner][oId][offId]._address);
        require(keccak256(abi.encodePacked(("Picked"))) == keccak256(abi.encodePacked(orderList.Offers[orderOwner][oId][offId].status)));
        USDT.approve(address(this), orderList.Offers[orderOwner][oId][offId].price);
        USDT.transferFrom(msg.sender, address(this), orderList.Offers[orderOwner][oId][offId].price);
        
        deposits[msg.sender] += orderList.Offers[orderOwner][oId][offId].price;
    }

    function pickOffer(uint oId,uint offId) public{
        orderList.Offers[msg.sender][oId][offId].status = "Picked";
    }

    function confirmShipment(address orderOwner, uint oId,uint offId) public{
        require(msg.sender == orderList.orders[orderOwner][oId].buyer);
        require(msg.sender == orderList.Offers[orderOwner][oId][offId]._address);
        USDT.approve(address(this), orderList.Offers[orderOwner][oId][offId].price);
        USDT.transferFrom(address(this), orderOwner, orderList.Offers[orderOwner][oId][offId].price);
        deposits[msg.sender] -= orderList.Offers[orderOwner][oId][offId].price;
        orderList.orders[orderOwner][oId].status = "finished";
    }

    function updateOffer(Offer memory newOffer, address Owner,  uint oId, uint offId) public {
        require(keccak256(abi.encodePacked((orderList.Offers[Owner][oId][offId].status))) != keccak256(abi.encodePacked(("Deleted"))));
        require(msg.sender == orderList.Offers[Owner][oId][offId]._address);
        orderList.Offers[Owner][oId][offId] = newOffer;
    }

    function deleteOffer(uint oId, uint offId, address Owner) public {
        require(msg.sender == orderList.Offers[Owner][oId][offId]._address);
        delete orderList.Offers[Owner][oId][offId];
        orderList.Offers[Owner][oId][offId].status = "Deleted";
    }
    
    function getOffers(address user, uint oId) public view returns (Offer[] memory) {
        return orderList.Offers[user][oId];
    }

    function getOffer(address user, uint oId, uint offId) public view returns (Offer memory) {
        return orderList.Offers[user][oId][offId];
    }

    function pickOffer(uint256 OrderID, address seller) public {
        if (orderList.orders[seller][OrderID].buyer == address(0)) {
            orderList.orders[seller][OrderID].buyer = seller;
        }
        
    }



    function nextOrderID(address sender) public view returns (uint256) {
        return orderId[sender];
    }

    function getOrders(address user) public view returns (Order[] memory) {
        return orderList.orders[user];
    }

    
    function getAllSellers() public view returns (address[] memory) {
        return sellers;
    }

    function getOrder(address user, uint id) public view returns (Order memory) {
        return orderList.orders[user][id];
    }

}