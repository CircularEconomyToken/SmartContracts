//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract CircularMarketPlace {
    Orders orderList;
    mapping(address => uint256) orderId;
    struct Offer {
        uint256 price;
        string usecase;
        uint256 earliestBlock;
        string _address;
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

    function updateOrder(Order memory newOrder, uint oId) public {
        orderList.orders[msg.sender][oId] = newOrder;
    }

    function deleteOrder(uint oId) public {
        delete orderList.orders[msg.sender][oId];
    }

    function addOffer(Offer memory newOffer, address orderOwner, uint oId) public {
        require(msg.sender != orderOwner);
        orderList.Offers[orderOwner][oId].push(newOffer);
    }

    function updateOffer(Offer memory newOffer, uint oId, uint offId) public {
        orderList.Offers[msg.sender][oId][offId] = newOffer;
    }

    function deleteOffer(uint oId, uint offId) public {
        delete orderList.Offers[msg.sender][oId][offId];
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