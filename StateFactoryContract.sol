pragma solidity ^0.5.12;


library StateFactoryContract {
    
    
    struct Building {
        string build_name;
        uint build_number;
        uint total_lots;
        uint size_sqm;
        uint fire_exits;
        address owner;
        address manager;
        address[] tenants;
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
        uint rule_number;
        address setter;
        address[] instructors;
        bytes rule;
        bool active;
    }
    
    struct Proposal {
        bytes proposal;
        uint proposal_count;
        uint up_votes;
        uint down_votes;
        uint start_date;
        uint finish_date;
        address creator;
    }
    
    struct Committee {
        string name;
        uint building;
        uint committee_num;
        uint total_members;
        uint proposals_made;
        address chairperson;
        address vice_chairperson;
        address[] members;
    }
   
   
    struct BuildingInfo {
        mapping (uint => mapping(address => Building)) owners;
        mapping (address => bool) authorized;
    }
    
   
    struct TenantInfo {
       mapping (address => Tenant) tenants;
       mapping (address => mapping (uint => uint)) localised;
       mapping (address => bool) active_tenants;
    }
    
    struct PaymentInfo {
        mapping (address => mapping (uint => Payment)) payments_created;
        mapping (address => mapping(uint => address)) payments_made;
        uint[] total_payments;
    }
    
    struct MessageInfo {
        mapping (address => mapping(uint => Message)) messages_sent;
        mapping (address => mapping(uint => Message)) messages_received;
    }
    
    struct RuleInfo {
        mapping(address => mapping(uint => Rule)) rules_set;
        mapping(address => mapping(uint => bytes)) rules;
        mapping(uint => address[]) rule_too_instructors;
        bytes[] rulings;
    }
    
    struct ProposalInfo {
        mapping (address => mapping(uint => Proposal)) proposals_set;
        uint[] total_proposals;
    }
    
    struct CommitteeInfo {
        mapping (uint => Committee) committees;
        mapping (address => mapping (uint => Committee)) members;
        uint[] total_committees;
    }
    
    function NewFactory(BuildingInfo storage build, string memory _name, uint _buildNum, uint maxlots, uint sizesqm, uint fire_exits, address _owner, address _manager) internal {
        require (build.authorized[msg.sender] == true,
                    "The creator of the Factory is an authorzied key");
        _buildNum = 0;
        address[] storage tenants = build.owners[_buildNum][msg.sender].tenants;
        build.owners[_buildNum][msg.sender] = Building(
            _name,
            _buildNum,
            maxlots,
            sizesqm,
            fire_exits,
            _owner,
            _manager,
            tenants);
    }
    
    function newTenant(TenantInfo storage tenant, string memory _name, uint _tenantNum, uint building_num,  uint _lot, uint _rent, bool _owner) internal {
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
    
    function changeTenantDetails(TenantInfo storage tenant, string memory _name, uint _tenantNumber, uint _building, uint _lot, uint _rent, bool _owner, bool _active, address _key) internal {
        tenant.tenants[_key] = Tenant(
            _name,
            _tenantNumber,
            _building,
            _lot,
            _rent,
            _owner,
            _active,
            false,
            _key);
    }
    
    function createPayment(PaymentInfo storage payment, uint _amount, uint _timeLength) internal {
        payment.total_payments.length++;
        uint payment_num = payment.total_payments.length;
        payment.payments_created[msg.sender][payment_num] = Payment(
            _timeLength, 
            _amount, 
            0, 
            0, 
            payment.total_payments.length, 
            false, 
            address(0),
            msg.sender);
    }
    
    function changePaymentDetails(PaymentInfo storage payment, uint new_time, uint new_amount, uint _payNum) internal {
        payment.payments_created[msg.sender][_payNum].time = new_time;
        payment.payments_created[msg.sender][_payNum].payable_amount = new_amount;
    }
    
    function newRule(RuleInfo storage rule, uint _rule_num, string memory _rule, address[] memory _instructors, uint _buildNumber) internal {
        bytes memory new_rule = abi.encode(_rule);
        _rule_num = rule.rulings.push(new_rule) - 1;
        rule.rules_set[msg.sender][_buildNumber] = Rule(
            _buildNumber, 
            rule.rulings.length, 
            msg.sender, 
            _instructors, 
            new_rule, 
            true);
        rule.rules[msg.sender][_rule_num] = new_rule;
        rule.rule_too_instructors[_rule_num] = _instructors;
    }
    
    function newProposal(ProposalInfo storage prop, string memory _prop, uint _start_date, uint _finish_date) internal {
        bytes memory new_prop = abi.encode(_prop);
        prop.proposals_set[msg.sender][prop.total_proposals.length] = Proposal(
            new_prop, 
            prop.total_proposals.length, 
            0,
            0,
            _start_date, 
            _finish_date, 
            msg.sender);
        prop.total_proposals.push(_start_date);
    }
    
    function newCommittee(CommitteeInfo storage commit, string memory _name, uint _buildNum, address _viceChair, address[] memory _members) internal {
        commit.total_committees.length++;
        commit.committees[commit.total_committees.length] = Committee(
            _name, 
            _buildNum, 
            commit.total_committees.length, 
            _members.length, 
            0, 
            msg.sender, 
            _viceChair, 
            _members); 
        
    }
    
}
