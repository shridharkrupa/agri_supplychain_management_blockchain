// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract supplyChainAgriculture {

    constructor() {
        owner = msg.sender;
    }

    address private owner;
    bool seedPricePaid = false;
    bool elevatorToFarmerTransfer = false;
    bool processorToElevatorTransfer = false;
    bool distributorToProcessorTransfer = false;

    enum CONTRACTSTATUS {idle,notCreated,created,sendRequestSubmitted}

    event transferCompleteSeed(address farmer, address Seedcompany,string seedType,string variety,uint quantity,uint Price,uint time);
    event transferCompletegrownGrain(address elevator, address farmer,string grownGrainType,string variety,uint quantity,uint Price,uint time);
    event sellOfSeeds(address farmer, address seedCompany, string seedType, string variety,uint quantity,uint time);
    event sellGrainsToElevator(address farmer,address elevator,string grainType,string variety,uint quantity,uint pricePer1q,uint purchaseDate);
    event transferCompleteFromProcessorToElevator(address Processor ,address elevator,string grainType,string variety,uint quantity,uint Price,uint time);
    event sellGrainsToProcessorFromElevator(address Elevator,address Processor,string grainType,string variety,uint quantity,uint pricePer1q,uint purchaseDate);
    event transferCompleteFromDistributorToProcessor(address Distributor ,address Processor,string grainType,string variety,uint quantity,uint Price,uint time);
    event sellGrainsToDsitributorFromProcessor(address Processor,address Distributor,string grainType,string variety,uint quantity,uint pricePer1q,uint purchaseDate);

    mapping(address=>CONTRACTSTATUS) contStat;
    mapping(uint=>SeedTrans) seedTrans;
    uint seedTransCount = 0;
    mapping(uint=>FarmerToElevatorTrans) farmerToElevatorTrans;
    uint farmerToElevatorTransCount = 0;
    mapping (uint=>ElevatorToProcessorTrans) elevatorToProcessorTrans; 
    uint elevatorToProcessorTransCount = 0;
    mapping (uint => ProcessorToDistributorTransfer) processorToDistributorTrans;
    uint processorToDistributorTransCount;

    struct SeedTrans {
        address seedCompany;
        address farmer; 
    }

    struct FarmerToElevatorTrans {
        address farmer;
        address elevator;
    }

    struct ElevatorToProcessorTrans {
        address processor;
        address elevator;
    }

    struct ProcessorToDistributorTransfer {
        address processor;
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
    mapping(address=> GrainAvailableWithElevatorDetails) grainAvailableWithElevatorDetails;
    address[] grainUpdateElevatorAddress;

    Processor[] processorListArray;
    mapping(address =>bool) processorListMapping;
    mapping(address =>uint) processorListIndex;
    uint processorCount = 0;
    mapping(address=>ProcessorBoughtGrainFromElevator) processorGrainDetails;
    address[] processorGrain;
    mapping(address=>ProcessedGrainDetails) processedGrainDetails;
    address[] processedAddress;

    Distributor[] distributorListArray;
    mapping(address=>bool) distributorListMapping;
    mapping(address=>uint) distributorListIndex;
    uint distributorCount;
    mapping(address=>ProcessorToDistributorGrainDetails) processorToDistributorGrainDetails;
    address[] processorToDistributor;
    mapping(address=>DistributorAvailableGrainDetails) distributorAvailableGrainDetails;
    address[] distributorAvailableGrainAddress;

    Retailer[] retailerListArray;
    mapping(address=>bool) retailerListMapping;
    mapping(address=>uint) retailerListIndex;
    uint retailerCount;




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

    modifier onlyDistributor(address _distributor)
    {
        require(distributorListMapping[_distributor],"Distributor doesn't exist");
        _;
    }

    modifier onlyRetailer(address _retailer)
    {
        require(retailerListMapping[_retailer],"Retailer doesn't exist");
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

    struct GrainAvailableWithElevatorDetails {
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

    struct ProcessedGrainDetails {
        string processedGrainType;
        string processedGrainVariety;
        uint quantity;
        uint pricePerLot;
        uint manufactureDate;
        uint expDate;
    }

    struct Distributor {
        address payable distributorAddress;
        string distributorName;
        string hash;
    }

    struct ProcessorToDistributorGrainDetails {
        string grainType;
        string variety;
        uint quantity;
        uint price;
        uint soldDate;
        uint manufactureDate;
        uint expDate;
    }

    struct DistributorAvailableGrainDetails {
        string grainType;
        string variety;
        uint quantity;
        uint pricePer10kg;
        uint manufactureDate;
        uint expDate;
    }

    struct Retailer {
        address payable retailer;
        string retailerName;
        string hash;
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
            seedTrans[seedTransCount] = SeedTrans(msg.sender,_farmer);
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
        require(farmerListMapping[msg.sender], "Farmer doesn't exist");
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
        
        if(elevatorToFarmerTransfer==true )
        {
            grainDetails[_elevator] = GrainDetails(_grainType,_variety,_quantity,_moisture,_temperature,_pricePer1q,_purchaseDate);
            grainUpdateaAddress.push(_elevator);
            farmerToElevatorTrans[farmerToElevatorTransCount] = FarmerToElevatorTrans(msg.sender,_elevator);
            farmerToElevatorTransCount++;
            emit sellGrainsToElevator(msg.sender,_elevator,_grainType,_variety,_quantity,_pricePer1q,_purchaseDate);
        }
        else
        {
            revert("elevator doesn't exist or he didn't pay the bills");
        }
        
    }

    function updategrainDetailsFromElevator(string memory _grainType,string memory _variety,uint _quantity, uint _pricePer1q ) public onlyElevator(msg.sender) {
        require(elevatorListMapping[msg.sender],"Elevator doesn't exist");
        address x = address(0);
        for(uint i=0;i<grainUpdateElevatorAddress.length;i++)
        {
            if(grainUpdateElevatorAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((grainAvailableWithElevatorDetails[grainUpdateElevatorAddress[i]].grainType))) ==keccak256(abi.encodePacked((_grainType))))
                {
                    if(keccak256(abi.encodePacked((grainAvailableWithElevatorDetails[grainUpdateElevatorAddress[i]].grainVariety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        x = grainUpdateElevatorAddress[i];
                    }
                }
            }
        }
        if(x==address(0))
        {
            grainAvailableWithElevatorDetails[msg.sender] = GrainAvailableWithElevatorDetails(_grainType,_variety,_quantity,_pricePer1q);
            grainUpdateElevatorAddress.push(msg.sender);
        }
        else
        {
            grainAvailableWithElevatorDetails[msg.sender].quantity += _quantity; 
        }
        
    }

    function updateGrainPriceFromElevator(string memory _grainType,string memory _variety, uint _pricePer1q) public onlyElevator(msg.sender) {
        address x;
        for(uint i=0;i<grainUpdateElevatorAddress.length;i++)
        {
            if(grainUpdateElevatorAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((grainAvailableWithElevatorDetails[grainUpdateElevatorAddress[i]].grainType))) ==keccak256(abi.encodePacked((_grainType))))
                {
                    if(keccak256(abi.encodePacked((grainAvailableWithElevatorDetails[grainUpdateElevatorAddress[i]].grainVariety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        x = grainUpdateElevatorAddress[i];
                    }
                }
            }
        }
        grainAvailableWithElevatorDetails[x].pricePer1q = _pricePer1q;
    }

    function addGrainQuantityFromElevator(string memory _grainType,string memory _variety, uint _quantity) public onlyElevator(msg.sender) {
        address x;
        for(uint i=0;i<grainUpdateElevatorAddress.length;i++)
        {
            if(grainUpdateElevatorAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((grainAvailableWithElevatorDetails[grainUpdateElevatorAddress[i]].grainType))) ==keccak256(abi.encodePacked((_grainType))))
                {
                    if(keccak256(abi.encodePacked((grainAvailableWithElevatorDetails[grainUpdateElevatorAddress[i]].grainVariety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        x = grainUpdateElevatorAddress[i];
                    }
                }
            }
        }
        grainAvailableWithElevatorDetails[x].quantity += _quantity;
    }

    function removeGrainQuantityFromElevator(string memory _grainType,string memory _variety, uint _quantity) public onlyElevator(msg.sender) {
        address x;
        for(uint i=0;i<grainUpdateElevatorAddress.length;i++)
        {
            if(grainUpdateElevatorAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((grainAvailableWithElevatorDetails[grainUpdateElevatorAddress[i]].grainType))) ==keccak256(abi.encodePacked((_grainType))))
                {
                    if(keccak256(abi.encodePacked((grainAvailableWithElevatorDetails[grainUpdateElevatorAddress[i]].grainVariety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        x = grainUpdateElevatorAddress[i];
                    }
                }
            }
        }
        grainAvailableWithElevatorDetails[x].quantity -= _quantity;
    }



    function addProcessor(string memory _hash,string memory _name) public {
        processorListArray.push(Processor(payable(msg.sender),_name,_hash));
        processorListMapping[msg.sender] = true;
        processorListIndex[msg.sender] = processorCount;
        processorCount++;
    }

    function buyGrainFromElevator(address payable _elevator,string memory _grainType,string memory _variety,uint _quantity ) public payable onlyProcessor(msg.sender) {
        require(processorListMapping[msg.sender],"Elevator doesn't exist");
        address x;
        for(uint i=0;i<grainUpdateElevatorAddress.length;i++)
        {
            if(grainUpdateElevatorAddress[i]==_elevator)
            {
                if(keccak256(abi.encodePacked((grainAvailableWithElevatorDetails[grainUpdateElevatorAddress[i]].grainType))) ==keccak256(abi.encodePacked((_grainType))))
                {
                    if(keccak256(abi.encodePacked((grainAvailableWithElevatorDetails[grainUpdateElevatorAddress[i]].grainVariety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        x = grainUpdateElevatorAddress[i];
                    }
                }
            }
        }
        require(_quantity <= grainAvailableWithElevatorDetails[x].quantity, "This much qunatity of seed is not available");
        if(_quantity <= grainAvailableWithElevatorDetails[x].quantity)
        {
            require(msg.value>0, "you have entered 0");
            require(msg.value == _quantity * grainAvailableWithElevatorDetails[x].pricePer1q, "You haven't enterd the expected value");
            address payable receiever = payable(_elevator);
            receiever.transfer(msg.value); 
            emit transferCompleteFromProcessorToElevator(msg.sender, _elevator,_grainType,_variety,_quantity,msg.value,block.timestamp);
            grainAvailableWithElevatorDetails[x].quantity -= _quantity;
            processorToElevatorTransfer = true;   
        }

    }

    function sellGrainToProcessor(address _processor,string memory _grainType,string memory _grainVariety,uint _quantity,uint _pricePer1q,uint _purchaseDate) public onlyElevator(msg.sender) {
        require(elevatorListMapping[msg.sender], "elevator doesn't exist");
        require(processorListMapping[_processor], "Processor doesn't exist");
        if(processorToElevatorTransfer==true )
        {
            processorGrainDetails[_processor] = ProcessorBoughtGrainFromElevator(_grainType,_grainVariety,_quantity,_pricePer1q,_purchaseDate);
            processorGrain.push(_processor);
            elevatorToProcessorTrans[elevatorToProcessorTransCount] = ElevatorToProcessorTrans(msg.sender,_processor);
            elevatorToProcessorTransCount++;
            emit sellGrainsToProcessorFromElevator(msg.sender,_processor,_grainType,_grainVariety,_quantity,_pricePer1q,_purchaseDate);
        }
        else
        {
            revert("Processor doesn't exist or he didn't pay the bills");
        }
    }

    function updateProcessedGrainDetails(string memory _processedGrainType,string memory _processedGrainVariety,uint _quantity,uint _pricePerLot,uint _manufactureDate,uint _expDate) public onlyProcessor(msg.sender) {
        require(processorListMapping[msg.sender],"Processor doesn't exist");
        processedGrainDetails[msg.sender] = ProcessedGrainDetails(_processedGrainType,_processedGrainVariety,_quantity,_pricePerLot,_manufactureDate,_expDate);
        processedAddress.push(msg.sender);
    }

    function updateProcessedGrainPrice(string memory _processedGrainType, string memory _processedGrainVariety, uint _pricePerLot,uint _manufactureDate) public onlyProcessor(msg.sender) {
        require(processorListMapping[msg.sender],"Processor doesn't exist");
        address x = address(0);
        for(uint i=0;i<processedAddress.length;i++)
        {
            if(processedAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((processedGrainDetails[processedAddress[i]].processedGrainType))) ==keccak256(abi.encodePacked((_processedGrainType))))
                {
                    if(keccak256(abi.encodePacked((processedGrainDetails[processedAddress[i]].processedGrainVariety))) ==keccak256(abi.encodePacked((_processedGrainVariety))))
                    {
                        if(processedGrainDetails[processedAddress[i]].manufactureDate == _manufactureDate)
                        {
                            x   = processedAddress[i];
                        }
                    }
                }
            }
        }
          if(x == address(0))
        {
            revert("Details are not found");
        }
        else
        {
            processedGrainDetails[x].pricePerLot = _pricePerLot;
        }

    }

    function removeProcessedGrainQuantity(string memory _processedGrainType, string memory _processedGrainVariety, uint _quantity,uint _manufactureDate) public onlyProcessor(msg.sender) {
        require(processorListMapping[msg.sender],"Processor doesn't exist");
        address x = address(0);
        for(uint i=0;i<processedAddress.length;i++)
        {
            if(processedAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((processedGrainDetails[processedAddress[i]].processedGrainType))) ==keccak256(abi.encodePacked((_processedGrainType))))
                {
                    if(keccak256(abi.encodePacked((processedGrainDetails[processedAddress[i]].processedGrainVariety))) ==keccak256(abi.encodePacked((_processedGrainVariety))))
                    {
                        if(processedGrainDetails[processedAddress[i]].manufactureDate == _manufactureDate)
                        {
                            x = processedAddress[i];
                        }
                    }
                }
            }
        }
        if(x == address(0))
        {
            revert("Details are not found");
        }
        else
        {
            processedGrainDetails[x].quantity -= _quantity;
        }
    }

    function addDistributor(string memory _hash, string memory _distributorName) public {
        distributorListArray.push(Distributor(payable(msg.sender),_distributorName,_hash));
        distributorListMapping[msg.sender] = true;
        distributorListIndex[msg.sender] = processorCount;
        distributorCount++;
    }

    function buyGrainFromProcessor(address _processor, string memory _grainType, string memory _grainVariety,uint _quantity,uint _manufactureDate) public payable onlyDistributor(msg.sender) {
        require(distributorListMapping[msg.sender], "Distributor doesn't exist");
        address x;
        for(uint i=0;i<processedAddress.length;i++)
        {
            if(processedAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((processedGrainDetails[processedAddress[i]].processedGrainType))) ==keccak256(abi.encodePacked((_grainType))))
                {
                    if(keccak256(abi.encodePacked((processedGrainDetails[processedAddress[i]].processedGrainVariety))) ==keccak256(abi.encodePacked((_grainVariety))))
                    {
                        if(processedGrainDetails[processedAddress[i]].manufactureDate == _manufactureDate)
                        {
                            x = processedAddress[i];
                        }
                    }
                }
            }
        }
        require(_quantity <= processedGrainDetails[x].quantity, "This much qunatity of seed is not available");
        if(_quantity <= processedGrainDetails[x].quantity)
        {
            require(msg.value>0, "you have entered 0");
            require(msg.value == _quantity * processedGrainDetails[x].pricePerLot, "You haven't enterd the expected value");
            address payable receiever = payable(_processor);
            receiever.transfer(msg.value); 
            emit transferCompleteFromDistributorToProcessor(msg.sender, _processor,_grainType,_grainVariety,_quantity,msg.value,block.timestamp);
            processedGrainDetails[x].quantity -= _quantity;
            distributorToProcessorTransfer = true;   
        }
    }

    function sellGrainToDistributorFromProcessor(address _distributor,string memory _grainType,string memory _variety,uint _quantity,uint _pricePerLot,uint _soldDate,uint _manufactureDate) public onlyProcessor(msg.sender) {
        require(processorListMapping[msg.sender],"Processor doesn't exist");
        require(distributorListMapping[_distributor],"Distributor doesn't exist");
        address x;
        for(uint i=0;i<processedAddress.length;i++)
        {
            if(processedAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((processedGrainDetails[processedAddress[i]].processedGrainType))) ==keccak256(abi.encodePacked((_grainType))))
                {
                    if(keccak256(abi.encodePacked((processedGrainDetails[processedAddress[i]].processedGrainVariety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        if(processedGrainDetails[processedAddress[i]].manufactureDate == _manufactureDate)
                        {    
                            x = processedAddress[i];
                        }
                    }
                }
            }
        }

        if(distributorToProcessorTransfer==true )
        {
            processorToDistributorGrainDetails[_distributor] = ProcessorToDistributorGrainDetails(_grainType,_variety,_quantity,_pricePerLot,_soldDate,_manufactureDate,processedGrainDetails[x].expDate);
            processorToDistributor.push(_distributor);
            processorToDistributorTrans[processorToDistributorTransCount] = ProcessorToDistributorTransfer(msg.sender,_distributor);
            processorToDistributorTransCount++;
            emit sellGrainsToDsitributorFromProcessor(msg.sender, _distributor, _grainType, _variety, _quantity, _pricePerLot, _soldDate);
        }
        else
        {
            revert("Distributor doesn't exist or he didn't pay the bills");
        }

    }

    function updateDistributerGrain(string memory _grainType,string memory _variety,uint _quantity,uint _pricePer10kg,uint _manufactureDate) public onlyDistributor(msg.sender) {
        require(distributorListMapping[msg.sender], "Distributor doesn't Exist");
        address x = address(0);
        for(uint i=0;i<distributorAvailableGrainAddress.length;i++)
        {
            if(distributorAvailableGrainAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((distributorAvailableGrainDetails[distributorAvailableGrainAddress[i]].grainType))) ==keccak256(abi.encodePacked((_grainType))))
                {
                    if(keccak256(abi.encodePacked((distributorAvailableGrainDetails[distributorAvailableGrainAddress[i]].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        if(distributorAvailableGrainDetails[distributorAvailableGrainAddress[i]].manufactureDate == _manufactureDate)
                        {
                            x = distributorAvailableGrainAddress[i];
                        }
                    }
                }
            }
        }

        address y;
        for(uint i=0;i<processorToDistributor.length;i++)
        {
            if(processorToDistributor[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((processorToDistributorGrainDetails[processorToDistributor[i]].grainType))) ==keccak256(abi.encodePacked((_grainType))))
                {
                    if(keccak256(abi.encodePacked((processorToDistributorGrainDetails[processorToDistributor[i]].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        if(processorToDistributorGrainDetails[processorToDistributor[i]].manufactureDate == _manufactureDate)
                        {
                            y = processorToDistributor[i];
                        }
                    }
                }
            }
        }

        if(x==address(0))
        {
            distributorAvailableGrainDetails[msg.sender] = DistributorAvailableGrainDetails(_grainType,_variety,_quantity,_pricePer10kg,_manufactureDate,processorToDistributorGrainDetails[y].expDate);
            distributorAvailableGrainAddress.push(msg.sender);
        }
        else
        {
            distributorAvailableGrainDetails[x].quantity += _quantity; 
        }
    }

    function addDistributorAvailableGrainQuantity(string memory _grainType,string memory _variety,uint _manufactureDate,uint _quantity) public onlyDistributor(msg.sender) {
        require(distributorListMapping[msg.sender], "Distributor doesn't Exist");
        address x = address(0);
        for(uint i=0;i<distributorAvailableGrainAddress.length;i++)
        {
            if(distributorAvailableGrainAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((distributorAvailableGrainDetails[distributorAvailableGrainAddress[i]].grainType))) ==keccak256(abi.encodePacked((_grainType))))
                {
                    if(keccak256(abi.encodePacked((distributorAvailableGrainDetails[distributorAvailableGrainAddress[i]].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        if(distributorAvailableGrainDetails[distributorAvailableGrainAddress[i]].manufactureDate == _manufactureDate)
                        {
                            x = distributorAvailableGrainAddress[i];
                        }
                    }
                }
            }
        }

        if(x==address(0))
        {
            revert("Details are Not Found, You can't change the Quantity");
        }
        else{
            distributorAvailableGrainDetails[x].quantity += _quantity;
        }
    }

    function removeDistributorAvailableGrainQuantity(string memory _grainType,string memory _variety,uint _manufactureDate,uint _quantity) public onlyDistributor(msg.sender) {
        require(distributorListMapping[msg.sender], "Distributor doesn't Exist");
        address x = address(0);
        for(uint i=0;i<distributorAvailableGrainAddress.length;i++)
        {
            if(distributorAvailableGrainAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((distributorAvailableGrainDetails[distributorAvailableGrainAddress[i]].grainType))) ==keccak256(abi.encodePacked((_grainType))))
                {
                    if(keccak256(abi.encodePacked((distributorAvailableGrainDetails[distributorAvailableGrainAddress[i]].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        if(distributorAvailableGrainDetails[distributorAvailableGrainAddress[i]].manufactureDate == _manufactureDate)
                        {
                            x = distributorAvailableGrainAddress[i];
                        }
                    }
                }
            }
        }

        if(x==address(0))
        {
            revert("Details are Not Found, You can't change the Quantity");
        }
        else{
            distributorAvailableGrainDetails[x].quantity -= _quantity;
        }
    }

    function updateDistributorAvailableGrainPrice(string memory _grainType,string memory _variety,uint _manufactureDate,uint _pricePer10kg) public onlyDistributor(msg.sender) {
        require(distributorListMapping[msg.sender], "Distributor doesn't Exist");
        address x = address(0);
        for(uint i=0;i<distributorAvailableGrainAddress.length;i++)
        {
            if(distributorAvailableGrainAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((distributorAvailableGrainDetails[distributorAvailableGrainAddress[i]].grainType))) ==keccak256(abi.encodePacked((_grainType))))
                {
                    if(keccak256(abi.encodePacked((distributorAvailableGrainDetails[distributorAvailableGrainAddress[i]].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        if(distributorAvailableGrainDetails[distributorAvailableGrainAddress[i]].manufactureDate == _manufactureDate)
                        {
                            x = distributorAvailableGrainAddress[i];
                        }
                    }
                }
            }
        }

        if(x==address(0))
        {
            revert("Details are Not Found, You can't change the Quantity");
        }
        else{
            distributorAvailableGrainDetails[x].pricePer10kg -= _pricePer10kg;
        }
    }


    function addRetailer(string memory _hash,string memory _name) public {
        retailerListArray.push(Retailer(payable(msg.sender),_name,_hash));
        retailerListMapping[msg.sender] = true;
        retailerListIndex[msg.sender] = retailerCount;
        retailerCount++;
    }

    

}