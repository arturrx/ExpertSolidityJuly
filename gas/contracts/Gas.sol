// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

//1.change solidity version to 0.8.15
//2.remove unnesesery requires..
//3.remove unchecked events ( Transfer is noly event checked by tests)
//4.variable packing // to do 
//5.evnt optimization 
//6. remove function getpaymentHistory and underlying data structures 
//7. simplyfy function getTradingMode()
//8. tune whiteTransfer function // to do 

contract GasContract  {

    uint256 public immutable totalSupply;  // cannot be updated
    uint32 private paymentCounter;  //AR
    address[5] public administrators;
    mapping(address => uint256) private balances;
    mapping(address => Payment[]) private payments;
    mapping(address => uint256) public whitelist;
    

    enum PaymentType {
        Unknown,
        BasicPayment,
        Refund,
        Dividend }
    struct Payment {
        uint32 paymentID; // AR 
        PaymentType paymentType;
        uint32 amount;
    }
    struct ImportantStruct {
        uint256 valueA; // max 3 digits
        uint256 bigValue;
        uint256 valueB; // max 3 digits
        //AR  reducing variable size increase deployment cost but reduce whiteTransfer function call 
    }

    modifier onlyAdminOrOwner() {
        if (checkForAdmin(msg.sender)) {
            _;
        }
         else {
            revert(
                "Error in Gas contract - onlyAdminOrOwner modifier : revert happened because the originator of the transaction was not the admin, and furthermore he wasn't the owner of the contract, so he cannot run this function"
            );
        }
    }


    event Transfer(address recipient, uint32 amount);

    constructor(address[5] memory _admins, uint256 _totalSupply) {
        totalSupply = _totalSupply;
        administrators = _admins;
        balances[msg.sender] = _totalSupply;
    }

    function checkForAdmin(address _user) public view returns (bool admin_) {
        bool admin = false;
        for (uint256 ii = 0; ii < 5; ++ii) {
            if (administrators[ii] == _user) {
                admin = true;
               // break;  reduce call cost increase deployment cost 
            }
        }
        return admin;
    }

    function balanceOf(address _user) public view returns (uint256 balance_) {
        return balances[_user];
    }
   function getTradingMode() public pure returns (bool mode_) {
        return true;
    }
    function getPayments(address _user)
        public
        view
        returns (Payment[] memory payments_)
    {
        return payments[_user];
    }

    function transfer(
        address _recipient,
        uint32 _amount,
        string calldata _name
    ) public {

        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        emit Transfer(_recipient, _amount);

        Payment memory payment;
        payment.paymentType = PaymentType.BasicPayment;
        payment.amount = _amount;
        payment.paymentID = ++paymentCounter;
        payments[msg.sender].push(payment);
    }

    function updatePayment(
        address _user,
        uint32 _ID,
        uint32 _amount,
        PaymentType _type
    ) public onlyAdminOrOwner 
    {
        payments[_user][_ID - 1].paymentType = _type;
        payments[_user][_ID - 1].amount = _amount;
    }

    function addToWhitelist(address  _userAddrs, uint256 _tier)
        public
    {     whitelist[_userAddrs] = _tier;   } 

  
    function whiteTransfer(address _recipient, uint256 _amount, ImportantStruct calldata _struct) public {
        uint256 x = _amount - whitelist[msg.sender]; // AR:check
        balances[msg.sender] -= x;
        balances[_recipient] += x;
    }

}
