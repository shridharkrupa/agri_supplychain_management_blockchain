// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract supplyChainAgriculture {

    constructor() {
        owner = msg.sender;
    }

    address private owner;
    bool seedPricePaid = false;
    bool elevatorToFarmerTransfer = false;

    enum CONTRACTSTATUS {idle,notCreated,created,sendRequestSubmitted}

    mapping(address=>CONTRACTSTATUS) contStat;

    Farmer[] farmerListArray;
    mapping(address =>bool) farmerListMapping;
    mapping(address =>uint) farmerListIndex;
    uint farmerCount = 0;

    SeedCompany[] seedCompanyListArray;
    mapping(address=>bool) seedCompanyListMapping;
    mapping(address => uint) seedCompanyIndex;
    mapping(address=>SeedDetails) seedTypeVariety;
    uint seedCompanyCount = 0;

    modifier onlyOwner {
        require(msg.sender == owner,"Sorry, This information is confidential.");
        _;
    }

    modifier onlyFarmer(address _farmer) {
        require(farmerListMapping[_farmer],"Farmer doesn't exsis!");
        _;
    }

    modifier onlySeedCompany(address _seedCompany)
    {
        require(seedCompanyListMapping[_seedCompany], "Seed company doesn't exist!");
        _;
    }

    struct Farmer {
        address payable farmerAddress;
        string hash;
    }


    struct SeedCompany {
        address payable companyAddress;
        string CompanyName;
        string hash;
    }

    struct SeedDetails {
        string seedType;
        string variety;
        uint quantity;
    }

    function addFarmer(string memory _hash) public {
        farmerListArray.push(Farmer(payable(msg.sender),_hash));
        farmerListMapping[msg.sender] = true;
        farmerListIndex[msg.sender] = farmerCount;
        farmerCount++;
    }

    function getListOfFarmer() view onlyOwner public returns(Farmer[] memory, uint) {
        return (farmerListArray, farmerCount);
    }

    function addSeedCompany(string memory _name, string memory _hash) public {
        seedCompanyListArray.push(SeedCompany(payable(msg.sender),_name,_hash));
        seedCompanyListMapping[msg.sender] = true;        
        seedCompanyIndex[msg.sender] = seedCompanyCount;       //storing in mapping to get index
        seedCompanyCount++;
    }

    function getListOfseedCompany() view public returns(SeedCompany[] memory,uint) {
        return (seedCompanyListArray,seedCompanyCount);
    }

    function updateSeedDetails(string memory _seedType,string memory _variety,uint _quantity) public onlySeedCompany(msg.sender) {
        seedTypeVariety[msg.sender] = SeedDetails(_seedType,_variety,_quantity);
    }

    function createContract() public onlyFarmer(msg.sender) {
        require(farmerListMapping[msg.sender],"Farmer doesn't exsist!");
        contStat[msg.sender] = CONTRACTSTATUS.created;
    }

    function buySeeds() public onlyFarmer(msg.sender) {

    }

    function sellSeeds() public onlySeedCompany(msg.sender) {
        
    }











}