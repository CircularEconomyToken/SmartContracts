//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract CircularMarketPlace {
    Orders orderList;
    mapping(address => uint256) orderId;
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

    constructor() {}

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

    function buy(uint256 OrderID, address seller) public {
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