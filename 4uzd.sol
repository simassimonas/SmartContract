pragma solidity ^0.4.22;

contract penShop {
    //shop owner's address
    address public owner;
    
    // The Buyer struct  
    struct Buyer {
    uint amount;
    uint state;             //0-nothing 1-order accepted 2-ready for payment payed 3-payment payed
    address courier;
    uint penPrice;
    uint shipmentPrice;
    }
    
    //events
    event totalAmount(address buyerAddress, uint amount);
    event totalPrice(uint penPrice, uint shipmentPrice, address CourierAddress);
    event paymentSuccessful(string message);
    event orderDone(string orderStatus);
    
    //the mapping to store customers(buyers)
    mapping (address => Buyer) buyers;
    
    constructor() public {
        owner = msg.sender;
    }
    
    //function to send order
    function sendOrder(uint am) public {
        require(buyers[msg.sender].state==0, "Order is already accepted and in progress");
        buyers[msg.sender].amount+=am;
        buyers[msg.sender].state=1;
        emit totalAmount(msg.sender, buyers[msg.sender].amount);
    }
    
    //sends price and the courier's address
    function sendPrice(address buyerAddress, address courierAddress, uint penPr, uint shipmentPr) public {
        // Only the owner can use this function
        require(msg.sender == owner, "Only owner can use this function");
        // Validating the buyer's state
        require(buyers[buyerAddress].state==1, "Buyer's order state needs to be 1");
        
        buyers[buyerAddress].penPrice=penPr;
        buyers[buyerAddress].shipmentPrice=shipmentPr;
        buyers[buyerAddress].courier=courierAddress;
        buyers[buyerAddress].state=2;
        
        emit totalPrice(penPr, shipmentPr, courierAddress);
    }
    
    function sendPayment() payable public {
        // Validating the buyer's state
        require(buyers[msg.sender].state==2, "Buyer's order state needs to be 2");
        require((buyers[msg.sender].penPrice + buyers[msg.sender].shipmentPrice) == msg.value, "Not enough wei transfered");
        
        buyers[msg.sender].state=3;
        
        emit paymentSuccessful("Payment was successful");
    }
    
    function orderDelivered(address receiver) public {
        require(buyers[receiver].state==3, "Buyer's order state needs to be 1");
        require(buyers[receiver].courier==msg.sender, "The sender is not the buyer's courier");
        
        //transfering the money to owner and courier
        owner.transfer(buyers[receiver].penPrice);
        msg.sender.transfer(buyers[receiver].shipmentPrice);
        
        emit orderDone("Order is completed");
        
        //setting the customer's "shopping cart" to default
        buyers[receiver].state=0;
        buyers[receiver].amount=0;
        buyers[receiver].courier=address(0);
        buyers[receiver].penPrice=0;
        buyers[receiver].shipmentPrice=0;
    }
}