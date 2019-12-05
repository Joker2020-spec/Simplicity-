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
        Building[] buildings;
    }
    
    struct TenantInfo {
       mapping (address => Tenant) tenants;
       mapping (address => mapping (uint => Building)) localised;
       mapping (address => bool) active_tenants;
    }
    
    struct PaymentInfo {
        Payment[] payments_made;
        Payment[] payments_created;
        mapping (address => mapping(uint => Payment)) payment_made;
        mapping (uint => mapping(uint => address)) payed_too;
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
    }

}

contract Buildings {
    
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
        require (buildingInfo.authorized[msg.sender] = true);
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

contract Tenant is Buildings {
    
    uint public TOTAL_AMOUNT_OF_TENANTS = 0;
    
    using Contract for Contract.Tenant;
    using Contract for Contract.TenantInfo;
    
    
    Contract.Tenant tenant;
    Contract.TenantInfo tenantInfo;
    
    uint[] list_of_tenants;
    
     modifier isActive() {
        require (tenantInfo.active_tenants[msg.sender] == true);
        _;
    }
    
    function addNewTenant(string memory _name, uint building_num,  uint _lot, uint _rent, bool _owner) public returns (bool success) {
        tenantInfo.newTenant(_name, list_of_tenants.length, building_num, _lot, _rent, _owner);
        TOTAL_AMOUNT_OF_TENANTS++;
        list_of_tenants.push(TOTAL_AMOUNT_OF_TENANTS);
        return success;
    }
    
    function changeTenantDetails(uint _tenantNumber, string memory _name, uint _building, uint _lot, uint _rent, bool _owner, bool _active, address _key) public {
        
    }
    
    function totalTenants() public view returns (uint) {
        return(list_of_tenants.length);
    }
    
}
