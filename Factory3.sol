pragma solidity ^0.5.12;

library Contract {
    
    struct Building {
        string build_name;
        uint build_number;
        uint total_lots;
        uint size_sqm;
        uint fire_exits;
        address owner;
        address manager;
    }
    
     struct Tenant {
        string name;
        uint tenant_number;
        uint building;
        uint lot;
        uint rent_charge;
        bool owner;
        bool active;
        bool is_authorized;
        address key;
    }
    
    struct Payment {
        uint time;
        uint payable_amount;
        uint start_date;
        uint finish_date;
        uint payment_number;
        bool payed;
        address sender;
        address receiver;
    }
    
     struct Message {
        bytes message;
        address from;
        address too;
    }
    
    struct Rule {
        uint building;
        address setter;
        address[] instructors;
        bytes rule;
        bool active;
    }
    
    struct BuildingInfo {
        mapping (address => Building) owners;
        mapping (address => bool) authorized;
    }
    
    struct TenantInfo {
       mapping (address => Tenant) tenants;
       mapping (address => mapping (uint => uint)) localised;
       mapping (address => bool) active_tenants;
    }
    
    struct PaymentInfo {
        mapping (address => Payment) payments_created;
        mapping (uint => mapping(uint => address)) payed_too;
        uint[] total_payments;
    }
    
    struct MessageInfo {
        mapping (address => mapping(uint => Message)) messages_sent;
        mapping (address => mapping(uint => Message)) messages_received;
    }
    
    struct RuleInfo {
        mapping(address => mapping(uint => Rule)) rules_set;
        Rule[] rules;
    }
    
    function NewFactory(BuildingInfo storage build, string memory _name, uint _buildNum, uint maxlots, uint sizesqm, uint fire_exits, address _owner, address _manager) internal {
        require (build.authorized[msg.sender] == true,
                    "The creator of the Factory is an authorzied key");
        _buildNum = 0;            
        build.owners[msg.sender] = Building(
            _name,
            _buildNum,
            maxlots,
            sizesqm,
            fire_exits,
            _owner,
            _manager);
    }
    
    function newTenant(TenantInfo storage tenant, string memory _name, uint _tenantNum, uint building_num,  uint _lot, uint _rent, bool _owner) internal {
        _tenantNum = 0;
        tenant.tenants[msg.sender] = Tenant(
            _name,
            _tenantNum,
            building_num,
            _lot,
            _rent,
            _owner,
            true,
            false,
            msg.sender);
        tenant.active_tenants[msg.sender] = true;
    }
    
    function changeTenantDetails(TenantInfo storage tenant, string memory _name, uint _tenantNumber, uint _building, uint _lot, uint _rent, bool _owner, bool _active, bool _isAuthorized, address _key) internal {
        tenant.tenants[msg.sender] = Tenant(
            _name,
            _tenantNumber,
            _building,
            _lot,
            _rent,
            _owner,
            _active,
            _isAuthorized,
            _key);
    }
    
    function createPayment(PaymentInfo storage payment, uint _amount, uint _timeLength) internal {
        payment.payments_created[msg.sender] = Payment(
            _timeLength, 
            _amount, 
            0, 
            0, 
            payment.total_payments.length, 
            false, 
            address(0),
            msg.sender);
        payment.total_payments.length++;    
    }
    
    function changePaymentDetails(PaymentInfo storage payment, uint new_time, uint new_amount) internal {
        payment.payments_created[msg.sender] = Payment(
            new_time, 
            new_amount, 
            0, 
            0, 
            payment.total_payments.length, 
            false, 
            address(0),
            msg.sender);
    }

}

contract BuildingsContract {
    
    address public owner;
    uint public current_buildings = 0;
    uint public max_buildings = 50;
    
    using Contract for Contract.Building;
    using Contract for Contract.BuildingInfo;
    
    Contract infomation;
    Contract.Building Building;
    Contract.BuildingInfo buildingInfo;
    
    uint[] buildings;
    
     constructor () internal {
        owner = msg.sender;
        buildingInfo.authorized[owner] = true;
    }
    
    modifier isOwnerOrManager(uint _buildNumber) {
        require (msg.sender == Building.owner || msg.sender == Building.manager,
                    "Caller of the function is the owner or manager of the building");
        _;
    }
    
    modifier isAuthorized() {
        require (buildingInfo.authorized[msg.sender] = true, "Check to see if the key calling the function is authorized to do so!");
        _;
    }
    
    function addAuthorizedKey(address newkey) internal {
        buildingInfo.authorized[newkey] = true;
    }
    
    function removeAuthorizedKey(address badKey) internal {
        buildingInfo.authorized[badKey] = false;
    }
    
    function newBuilding(string memory _name, uint maxlots, uint sizesqm, uint fire_exits, address _owner, address _manager) public returns (bool success) {
        require (max_buildings > buildings.length,
                        "The amount of buildings using the contract is not above the MAX LIMIT of 50");
        buildingInfo.NewFactory(_name, buildings.length, maxlots, sizesqm, fire_exits, _owner, _manager);
        current_buildings++;
        buildings.push(current_buildings);
        return success;
    }
    
}

contract TenantContract is BuildingsContract {
    
    uint public TOTAL_AMOUNT_OF_TENANTS = 0;
    
    using Contract for Contract.Tenant;
    using Contract for Contract.TenantInfo;
    
    
    Contract.Tenant tenant;
    Contract.TenantInfo tenantInfo;
    
    uint[] list_of_tenants;
    
     modifier isActive() {
        require (tenantInfo.active_tenants[msg.sender] == true,
                    "Check to ensure that the key calling the function is active with contract");
        _;
    }
    
    function addNewTenant(string memory _name, uint building_num,  uint _lot, uint _rent, bool _owner) public returns (bool success) {
        tenantInfo.newTenant(_name, list_of_tenants.length, building_num, _lot, _rent, _owner);
        tenantInfo.localised[msg.sender][list_of_tenants.length] = building_num;
        TOTAL_AMOUNT_OF_TENANTS++;
        list_of_tenants.push(TOTAL_AMOUNT_OF_TENANTS);
        return success;
    }
    
    function changeDetailsOfTenant(string memory _name, uint _tenantNumber, uint _building, uint _lot, uint _rent, bool _owner, bool _active, bool _isAuthorized, address _key) public returns (bool success) {
        tenantInfo.changeTenantDetails(_name, _tenantNumber, _building, _lot, _rent, _owner, _active, _isAuthorized, _key);
        return success;
    }
    
    function getTenantInfo(address _key) public view returns (string memory, uint, uint, uint, bool, bool, address) {
        return(tenantInfo.tenants[_key].name,
               tenantInfo.tenants[_key].building,
               tenantInfo.tenants[_key].lot,
               tenantInfo.tenants[_key].rent_charge,
               tenantInfo.tenants[_key].owner,
               tenantInfo.tenants[_key].active,
               tenantInfo.tenants[_key].key);
    }
    
    function authorizeTenant(address _key) public returns (bool) {
        require(tenantInfo.tenants[_key].key == _key, "Check to see if the key being authorized matches the key linked to the tenant");
        tenantInfo.tenants[_key].is_authorized = true;
        addAuthorizedKey(_key);
        return true;
    }
    
    function deAuthorizeTenant(address _key) public returns (bool) {
        require(tenantInfo.tenants[_key].key == _key, "Check to see if the key being de-authorized matches the key linked to the tenant");
        require(tenantInfo.tenants[_key].is_authorized == true, "Check to see if the key is currently authorized");
        tenantInfo.tenants[_key].is_authorized = false;
        removeAuthorizedKey(_key);
        return true;
    }
    
    function totalTenants() public view returns (uint) {
        return(list_of_tenants.length);
    }
    
}

contract PaymentContract is TenantContract {
    
    using Contract for Contract.Payment;
    using Contract for Contract.PaymentInfo;
    
    Contract.Payment payment;
    Contract.PaymentInfo payment_info;
    
    uint8 NON_PAYMENT = 0;
    uint public TOTAL_PAYMENTS_MADE = 0;
    uint8 public TOTAL_PAYMENTS_CREATED = 0;
    uint24 MAX_PAYMENT_TERMS = 30 days;
    uint24 MIN_PAYMENT_TERMS = 1 days;
    
    uint[] payments_made;
    uint[] payments_created;
    
    
    function generatePayment(uint _amount, uint _timeLength) public returns (bool success) {
        require (MIN_PAYMENT_TERMS <= _timeLength, 
                    "The time allocated to the payment is greater or equal to the minimum payment terms of 1 day!");
        require (MAX_PAYMENT_TERMS >= _timeLength, 
                    "The time allocated to the payment is less than or equal to the maximum payment terms of 30 days!");
        payment_info.createPayment(_amount, _timeLength);
        TOTAL_PAYMENTS_CREATED++;
        payments_made.push(TOTAL_PAYMENTS_CREATED);
        return success;
    }
    
    function getPaymentDetails(address _key) public view returns (uint, uint, uint, uint, uint, bool) {
        return(payment_info.payments_created[_key].time,
               payment_info.payments_created[_key].payable_amount,
               payment_info.payments_created[_key].start_date,
               payment_info.payments_created[_key].finish_date,
               payment_info.payments_created[_key].payment_number,
               payment_info.payments_created[_key].payed);
    }
    
    function changeDetailsOfPayment(uint _payment, uint new_time, uint new_amount) public returns (bool) {
        for (uint i = 0; i < payments_made.length; i++) {
                if (payments_made[i] == _payment) {
                    payment_info.changePaymentDetails(new_time, new_amount);
                    return true;
                }  
        }
        
    }

}
