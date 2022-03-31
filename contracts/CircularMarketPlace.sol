//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract CircularMarketPlace {
    Orders orderList;
    uint256 orderId;
    struct Offer{
        uint256 orderId;
        uint256 price;
        string usecase;
        uint earliestBlock;
        string _address;
    }
    struct Order{
        uint256  orderId;
        string name;
        string unit;
        uint categories;
        uint256 quantity;
        uint expirationBlock;
        string itemDescription;
        uint condition;
        uint256 price;
        address buyer;
        string location;
    }
    struct Orders{
        mapping(address => Order[]) orders;
        mapping(uint256 => Offer[]) Offers;

    }


    constructor() {
        
    }

    function addOrder(Order memory newOrder) public {
        orderList.orders[msg.sender].push(newOrder);
        orderId = orderId + 1;
    }

    function nextOrderID() public view returns(uint256) {
        return orderId;
    }

    function getOrders(address user) public view returns(Order[] memory){
        return orderList.orders[user];
    }
}
