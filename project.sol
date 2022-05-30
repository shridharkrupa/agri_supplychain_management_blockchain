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

    event transferComplete(address farmer, address Seedcompany,string seedType,string variety,uint quantity,uint Price,uint time);
    event sellOfSeeds(address farmer, address seedCompany, string seedType, string variety,uint quantity,uint time);

    mapping(address=>CONTRACTSTATUS) contStat;

    Farmer[] farmerListArray;
    mapping(address =>bool) farmerListMapping;
    mapping(address =>uint) farmerListIndex;
    uint farmerCount = 0;

    SeedCompany[] seedCompanyListArray;
    mapping(address=>bool) seedCompanyListMapping;
    mapping(address => uint) seedCompanyIndex;
    mapping(address=>SeedDetails) seedTypeVariety;
    address[] seedUpdateAddress;
    uint seedCompanyCount = 0;

    Elevator[] elevatorListArray;
    mapping(address=>bool) elevatorListMapping;
    mapping(address=>uint) elevatorListIndex;
    uint elevatorCount;



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
        uint pricePer10g;
    }

    struct Elevator {
        address payable elevatorAddress;
        string elevatorName;
        string hash;
        uint storageQuantity;
    }

    struct GrainDetails {
        string grainType;
        string variety;
        uint quantity;
        uint moisture;
        uint temperature;
        uint pricePerKg;
        uint purchaseDate;
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


    function updateSeedDetails(string memory _seedType,string memory _variety,uint _quantity,uint _pricePer10g) public onlySeedCompany(msg.sender) {
        seedTypeVariety[msg.sender] = SeedDetails(_seedType,_variety,_quantity,_pricePer10g);
        seedUpdateAddress.push(msg.sender);
    }

    function addSeedQuantity(string memory _seedType, string memory _variety, uint _addQuantity) public onlySeedCompany(msg.sender) {
        address x;
        for(uint i=0;i<seedUpdateAddress.length;i++)
        {
            if(seedUpdateAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((seedTypeVariety[seedUpdateAddress[i]].seedType))) ==keccak256(abi.encodePacked((_seedType))))
                {
                    if(keccak256(abi.encodePacked((seedTypeVariety[seedUpdateAddress[i]].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        x = seedUpdateAddress[i];
                    }
                }
            }
        }
        seedTypeVariety[x].quantity += _addQuantity;
    }

    function removeSeedQuantity(string memory _seedType, string memory _variety, uint _addQuantity) public onlySeedCompany(msg.sender) {
        address x;
        for(uint i=0;i<seedUpdateAddress.length;i++)
        {
            if(seedUpdateAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((seedTypeVariety[seedUpdateAddress[i]].seedType))) ==keccak256(abi.encodePacked((_seedType))))
                {
                    if(keccak256(abi.encodePacked((seedTypeVariety[seedUpdateAddress[i]].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        x = seedUpdateAddress[i];
                    }
                }
            }
        }
        seedTypeVariety[x].quantity -= _addQuantity;

    }

    function updateSeedPrice(string memory _seedType, string memory _variety, uint _pricePer10g) public onlySeedCompany(msg.sender) {
        address x;
        for(uint i=0;i<seedUpdateAddress.length;i++)
        {
            if(seedUpdateAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((seedTypeVariety[seedUpdateAddress[i]].seedType))) ==keccak256(abi.encodePacked((_seedType))))
                {
                    if(keccak256(abi.encodePacked((seedTypeVariety[seedUpdateAddress[i]].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        x = seedUpdateAddress[i];
                    }
                }
            }
        }
        seedTypeVariety[x].pricePer10g = _pricePer10g;
    }

    function createContract() public onlyFarmer(msg.sender) {
        require(farmerListMapping[msg.sender],"Farmer doesn't exsist!");
        contStat[msg.sender] = CONTRACTSTATUS.created;
    }

    function buySeeds(address payable _seedCompany,string memory _seedType,string memory _variety, uint _quantity) public payable onlyFarmer(msg.sender) {
        require(farmerListMapping[msg.sender], "Farmer doesn't Exist");
        address x;
        for(uint i=0;i<seedUpdateAddress.length;i++)
        {
            if(seedUpdateAddress[i]==_seedCompany)
            {
                if(keccak256(abi.encodePacked((seedTypeVariety[seedUpdateAddress[i]].seedType))) ==keccak256(abi.encodePacked((_seedType))))
                {
                    if(keccak256(abi.encodePacked((seedTypeVariety[seedUpdateAddress[i]].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        x = seedUpdateAddress[i];
                    }
                }
            }
        }
        require(_quantity > seedTypeVariety[x].quantity, "This much qunatity of seed is not available");
        if(_quantity <= seedTypeVariety[x].quantity)
        {
            require(msg.value>0, "you have entered 0");
            require(msg.value == _quantity * seedTypeVariety[x].pricePer10g, "You haven't enterd the expected value");
            address payable receiever = payable(_seedCompany);
            receiever.transfer(msg.value); 
            emit transferComplete(msg.sender, _seedCompany,_seedType,_variety,_quantity,msg.value,block.timestamp);
            seedTypeVariety[x].quantity -= _quantity;
            seedPricePaid = true;
        }

    }

    function sellSeeds(address _farmer,string memory _seedType, string memory _variety,uint _quantity) public onlySeedCompany(msg.sender) {
        require(seedCompanyListMapping[msg.sender], "Seed Company Doesn't Exist");
        if(seedPricePaid==true)
        {
            emit sellOfSeeds(_farmer, msg.sender, _seedType, _variety,_quantity,block.timestamp);
        }
        else {
            revert("Farmer doesn't exist or he didn't pay the bills");
        }
    }

    function addElevator(string memory _hash,string memory _name,uint _storageQuantity) public {
        elevatorListArray.push(Elevator(payable(msg.sender),_name,_hash,_storageQuantity));
        elevatorListMapping[msg.sender] = true;
        elevatorListIndex[msg.sender] = elevatorCount;
        elevatorCount++;
    }


}