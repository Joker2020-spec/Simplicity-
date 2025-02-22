pragma solidity ^0.5.12;

import"./StateFactoryContract.sol";
import"./BuildingsContract.sol";

contract TenantContract is BuildingsContract {
    
    
    uint TOTAL_AMOUNT_OF_TENANTS = 0;
    
    
    using StateFactoryContract for StateFactoryContract.BuildingInfo;
    using StateFactoryContract for StateFactoryContract.TenantInfo;
    
    
    StateFactoryContract.BuildingInfo buildingInfo;
    StateFactoryContract.TenantInfo tenantInfo;
    
    
    uint[] list_of_tenants;
    
    
     modifier isActive(address _key) {
        require (tenantInfo.active_tenants[_key] == true,
                    "Check to ensure that the key interacting with the function is active with contract");
        _;
    }
    
    function addNewTenant(string memory _name, uint building_num,  uint _lot, uint _rent, bool _owner, address build_manager) public returns (bool success) {
        TOTAL_AMOUNT_OF_TENANTS++;
        list_of_tenants.push(TOTAL_AMOUNT_OF_TENANTS);
        tenantInfo.localised[msg.sender][list_of_tenants.length] = building_num;
        tenantInfo.newTenant(_name, list_of_tenants.length, building_num, _lot, _rent, _owner);
        buildingInfo.owners[building_num][build_manager].tenants.push(msg.sender);
        return success;
    }
    
    function changeDetailsOfTenant(string memory _name, uint _building, uint _lot, uint _rent, bool _owner, bool _active, address _key) public returns (bool success) {
        tenantInfo.changeTenantDetails(_name, list_of_tenants.length, _building, _lot, _rent, _owner, _active, _key);
        return success;
    }
    
    function getTenantBasicInfo(address _key) public view returns (string memory, uint, uint, uint, bool, address) {
        return(tenantInfo.tenants[_key].name,
               tenantInfo.tenants[_key].tenant_number,
               tenantInfo.tenants[_key].building,
               tenantInfo.tenants[_key].lot,
               tenantInfo.tenants[_key].active,
               tenantInfo.tenants[_key].key);
    }
    
    function getTenantPrivateInfo(address _key) public view returns (uint, bool, bool) {
        return(tenantInfo.tenants[_key].rent_charge,
               tenantInfo.tenants[_key].owner,
               tenantInfo.tenants[_key].is_authorized);
    }
    
    function authorizeTenant(address _key) public returns (bool) {
        require(tenantInfo.tenants[_key].key == _key, 
                   "Check to see if the key being authorized matches the key linked to the tenant");
        tenantInfo.tenants[_key].is_authorized = true;
        addAuthorizedKey(_key);
        return true;
    }
    
    function deAuthorizeTenant(address _key) public returns (bool) {
        require(tenantInfo.tenants[_key].key == _key, 
                   "Check to see if the key being de-authorized matches the key linked to the tenant");
        require(tenantInfo.tenants[_key].is_authorized == true, 
                   "Check to see if the key is currently authorized");
        tenantInfo.tenants[_key].is_authorized = false;
        removeAuthorizedKey(_key);
        return true;
    }
    
    function totalTenants() public view returns (uint) {
        return(list_of_tenants.length);
    }
    
}
