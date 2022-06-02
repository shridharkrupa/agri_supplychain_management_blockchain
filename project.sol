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

    event transferCompleteSeed(address farmer, address Seedcompany,string seedType,string variety,uint quantity,uint Price,uint time);
    event transferCompletegrownGrain(address elevator, address farmer,string grownGrainType,string variety,uint quantity,uint Price,uint time);
    event sellOfSeeds(address farmer, address seedCompany, string seedType, string variety,uint quantity,uint time);
    event sellGrainsToElevator(address farmer,address elevator,string grainType,string variety,uint quantity,uint pricePer1q,uint purchaseDate);

    mapping(address=>CONTRACTSTATUS) contStat;
    mapping(uint=>SeedTrans) seedTrans;
    uint seedTransCount = 0;
    mapping(uint=>FarmerToElevatorTrans) farmerToElevatorTrans;
    uint farmerToElevatorTransCount = 0;

    struct SeedTrans {
        address farmer;
        address seedCompany;
    }

    struct FarmerToElevatorTrans {
        address farmer;
        address elevator;
    }

    Farmer[] farmerListArray;
    mapping(address =>bool) farmerListMapping;
    mapping(address =>uint) farmerListIndex;
    uint farmerCount = 0;
    mapping(address=>GrownGrain) grownGrain;
    address[] grownGrainAddress;

    SeedCompany[] seedCompanyListArray;
    mapping(address=>bool) seedCompanyListMapping;
    mapping(address => uint) seedCompanyIndex;
    mapping(address=>SeedDetails) seedTypeVariety;
    address[] seedUpdateAddress;
    uint seedCompanyCount = 0;

    Elevator[] elevatorListArray;
    mapping(address=>bool) elevatorListMapping;
    mapping(address=>uint) elevatorListIndex;
    uint elevatorCount = 0;
    mapping(address=>GrainDetails) grainDetails;
    address[] grainUpdateaAddress;
    mapping(address=> soldGrainDetailsFromElevator) grainFromElevatorDetails;
    address[] grainUpdateElevatorAddress;

    Processor[] processorListArray;
    mapping(address =>bool) processorListMapping;
    mapping(address =>uint) processorListIndex;
    uint processorCount = 0;



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

    modifier onlyElevator(address _elevator)
    {
        require(elevatorListMapping[_elevator], "Elevator doesn't exist");
        _;
    }

    modifier onlyProcessor(address _processor)
    {
        require(processorListMapping[_processor],"Processor doesn't exist");
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
        uint pricePer1q;
        uint purchaseDate;
    }

    struct GrownGrain {
        string grainTypeGrown;
        string variety;
        uint quantity;
        uint pricePer1q;
    }

    struct Processor {
        address payable processorAddress;
        string processorName;
        string hash;
    }

    struct soldGrainDetailsFromElevator {
        string grainType;
        string grainVariety;
        uint quantity;
        uint pricePer1q;
    }

    struct ProcessorBoughtGrainFromElevator {
        string grainType;
        string grainVariety;
        uint quantity;
        uint pricePer1q;
        uint purcahseDate;
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
        require(_quantity <= seedTypeVariety[x].quantity, "This much qunatity of seed is not available");
        if(_quantity <= seedTypeVariety[x].quantity)
        {
            require(msg.value>0, "you have entered 0");
            require(msg.value == _quantity * seedTypeVariety[x].pricePer10g, "You haven't enterd the expected value");
            address payable receiever = payable(_seedCompany);
            receiever.transfer(msg.value); 
            emit transferCompleteSeed(msg.sender, _seedCompany,_seedType,_variety,_quantity,msg.value,block.timestamp);
            seedTypeVariety[x].quantity -= _quantity;
            seedPricePaid = true;
        }

    }

    function sellSeeds(address _farmer,string memory _seedType, string memory _variety,uint _quantity) public onlySeedCompany(msg.sender) {
        require(seedCompanyListMapping[msg.sender], "Seed Company Doesn't Exist");
        if(seedPricePaid==true)
        {
            seedTrans[seedTransCount] = SeedTrans(_farmer,msg.sender);
            seedTransCount++;
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

    function updateStorageQuantity(uint _storageQuantity) public onlyElevator(msg.sender) {
        uint index;
        for(uint i = 0;i<elevatorListArray.length;i++)
        {
            if(msg.sender == elevatorListArray[i].elevatorAddress)
            {
                index = i;
            }
        }
        elevatorListArray[index].storageQuantity = _storageQuantity;
    } 

    function updateGrainFarmerQuantity(string memory _seedType,string memory _variety, uint _quantity, uint _pricePer1q) public onlyFarmer(msg.sender) {
        grownGrain[msg.sender] = GrownGrain(_seedType,_variety,_quantity,_pricePer1q);
        grownGrainAddress.push(msg.sender);
    }

    function updateGrainPriceByFarmer(string memory _grainTypeGrown,string memory _variety,uint _pricePer1q) public onlyFarmer(msg.sender) {
        require(farmerListMapping[msg.sender], "Farmer doesn't exist");
        address x;
        for(uint i=0;i<grownGrainAddress.length;i++)
        {
            if(grownGrainAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((grownGrain[grownGrainAddress[i]].grainTypeGrown))) ==keccak256(abi.encodePacked((_grainTypeGrown))))
                {
                    if(keccak256(abi.encodePacked((grownGrain[grownGrainAddress[i]].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        x = grownGrainAddress[i];
                    }
                }
            }
        }
        grownGrain[x].pricePer1q = _pricePer1q;

    }

    function buyGrainFromFarmer(address payable _farmer,string memory _grainTypeGrown,string memory _variety,uint _quantity) public payable onlyElevator(msg.sender) {
        require(elevatorListMapping[msg.sender],"Elevator doesn't exist");
        address x;
        for(uint i=0;i<grownGrainAddress.length;i++)
        {
            if(grownGrainAddress[i]==_farmer)
            {
                if(keccak256(abi.encodePacked((grownGrain[grownGrainAddress[i]].grainTypeGrown))) ==keccak256(abi.encodePacked((_grainTypeGrown))))
                {
                    if(keccak256(abi.encodePacked((grownGrain[grownGrainAddress[i]].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        x = grownGrainAddress[i];
                    }
                }
            }
        }
        require(_quantity <= grownGrain[x].quantity, "This much qunatity of seed is not available");
        if(_quantity <= grownGrain[x].quantity)
        {
            require(msg.value>0, "you have entered 0");
            require(msg.value == _quantity * grownGrain[x].pricePer1q, "You haven't enterd the expected value");
            address payable receiever = payable(_farmer);
            receiever.transfer(msg.value); 
            emit transferCompletegrownGrain(msg.sender, _farmer,_grainTypeGrown,_variety,_quantity,msg.value,block.timestamp);
            grownGrain[x].quantity -= _quantity;
            elevatorToFarmerTransfer = true;   
        }
    }


    function sellGrainToElevator(address _elevator, string memory _grainType,string memory _variety,uint _quantity,uint _moisture,uint _temperature,uint _pricePer1q,uint _purchaseDate  ) public onlyFarmer(msg.sender) {
        require(elevatorListMapping[_elevator],"Elevator doesn't exist");
        grainDetails[_elevator] = GrainDetails(_grainType,_variety,_quantity,_moisture,_temperature,_pricePer1q,_purchaseDate);
        grainUpdateaAddress.push(_elevator);
        if(elevatorToFarmerTransfer==true )
        {
            farmerToElevatorTrans[farmerToElevatorTransCount] = FarmerToElevatorTrans(msg.sender,_elevator);
            emit sellGrainsToElevator(msg.sender,_elevator,_grainType,_variety,_quantity,_pricePer1q,_purchaseDate);
        }
        else
        {
            revert("elevator doesn't exist or he didn't pay the bills");
        }
        
    }

    function updategrainDetailsFromElevator(string memory _grainType,string memory _variety,uint quantity, uint _pricePer1q ) public onlyElevator(msg.sender) {
        
    }

    function addProcessor(string memory _hash,string memory _name) public {
        processorListArray.push(Processor(payable(msg.sender),_name,_hash));
        processorListMapping[msg.sender] = true;
        processorListIndex[msg.sender] = processorCount;
        processorCount++;
    }

    function buyGrainFromProcessor() public payable onlyProcessor(msg.sender) {

    }


}