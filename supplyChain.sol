// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract supplyChainAgri {

    constructor() {
        owner = msg.sender;
    }

    address private owner;

    bool seedPricePaid = false;
    bool processorToFarmerTransfer = false;
    bool retailerToProcessorTransfer = false;
    bool customerToRetailerTransfer = false;

    mapping(uint=>SeedTrans) seedTrans;
    uint seedTransCount = 0;

    ProcessorToFarmerTrans[] processorToFarmerTrans;
    RetailerToProcessorTrans[] retailerToProcessorTrans;
    CustomerToRetailerTrans[] customerToRetailerTrans;


    struct SeedTrans {
        address seedCompany;
        address farmer; 
    }

    struct ProcessorToFarmerTrans {
        address processor;
        address farmer;
    }

    struct RetailerToProcessorTrans {
        address retailer;
        address processor;
    }

    struct CustomerToRetailerTrans {
        address customer;
        address retailer;
    }


    event transferCompleteSeed(address farmer, address Seedcompany,string seedType,string variety,uint quantity,uint Price,uint time);
    event sellOfSeeds(address farmer, address seedCompany, string seedType, string variety,uint quantity,uint time);
    event transferCompleteFromProcessorToFarmer(address processor, address farmer,string grownGrainType,string variety,uint quantity,uint Price,uint time);
    event sellGrainsToProcessorFromElevator(address Farmer,address Processor,string grainType,string variety,uint quantity,uint pricePer1q,uint purchaseDate);

    Farmer[] farmerListArray;
    mapping(address =>bool) public farmerListMapping;
    mapping(address =>uint) public farmerListIndex;
    uint farmerCount = 0;
    mapping(address=>mapping(uint=>GrownGrain)) grownGrain;
    address[] grownGrainAddress;

    SeedCompany[] public seedCompanyListArray;
    mapping(address=>bool) public seedCompanyListMapping;
    mapping(address => uint) public seedCompanyIndex;
    uint public seedCompanyCount = 0;
    mapping(address=>mapping(uint =>SeedDetails)) public seedTypeVariety;
    address[] public seedUpdateAddress;
    RequestDetails[] requestFromFarmer;

    Processor[] processorListArray;
    mapping(address =>bool) processorListMapping;
    mapping(address =>uint) processorListIndex;
    uint processorCount = 0;
    RequestDetails[] requestFromProcessor;
    mapping(address=>mapping(uint=>ProcessedGrain)) processedGrainDetails;
    address[] public processorUpdateAddress;


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

    modifier onlyProcessor(address _processor)
    {
        require(processorListMapping[_processor],"Processor doesn't exist");
        _;
    }



    struct Farmer {
        address payable farmerAddress;
    }


    struct SeedCompany {
        address payable companyAddress;
    }

    struct SeedDetails {
        string seedType;
        string variety;
        uint quantity;
        uint pricePer10g;
    }

    struct RequestDetails {
        address from;
        address to;
        string Type;
        string variety;
        uint varietyID;
        uint quantity;
        uint requestTime;
    }

    struct Processor {
        address payable processorAddress;
    }

    struct GrownGrain {
        string grainTypeGrown;
        string variety;
        uint quantity;
        uint pricePer1q;
    }

    struct ProcessedGrain {
        string grainType;
        string variety;
        uint quantity;
        uint pricePer10kg;
        uint manDate;
        uint expDate;
    }

    function addFarmer(address _farmer ) public onlyOwner {
        farmerListArray.push(Farmer(payable(_farmer)));
        farmerListMapping[_farmer] = true;
        farmerListIndex[_farmer] = farmerCount;
        farmerCount++;
    }

    function getListOfFarmer() view onlyOwner public returns(Farmer[] memory , uint) {
        return (farmerListArray, farmerCount);
    }

    function addSeedCompany(address _seedCompany) public onlyOwner{
        seedCompanyListArray.push(SeedCompany(payable(_seedCompany)));
        seedCompanyListMapping[_seedCompany] = true;        
        seedCompanyIndex[_seedCompany] = seedCompanyCount;       //storing in mapping to get index
        seedCompanyCount++;
    }

    function getListOfseedCompany() view public returns(SeedCompany[] memory ,uint) {
        return (seedCompanyListArray,seedCompanyCount);
    }

    function updateSeedDetails(string memory  _seedType,string memory  _variety,uint _varietyID,uint _quantity,uint _pricePer10g) public onlySeedCompany(msg.sender) {
        address x = address(0);
        for(uint i=0;i<seedUpdateAddress.length;i++)
        {
            if(seedUpdateAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((seedTypeVariety[seedUpdateAddress[i]][_varietyID].seedType))) ==keccak256(abi.encodePacked((_seedType))))
                {
                    if(keccak256(abi.encodePacked((seedTypeVariety[seedUpdateAddress[i]][_varietyID].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        x = seedUpdateAddress[i];
                    }
                }
            }
        }
        if(x == address(0))
        {
            seedTypeVariety[msg.sender][_varietyID] = SeedDetails(_seedType,_variety,_quantity,_pricePer10g);
            seedUpdateAddress.push(msg.sender);
        }
        else{
            revert("Seed Details are already exist!");
        }
    }

    function addSeedQuantity(string memory  _seedType, string memory  _variety,uint _varietyID, uint _addQuantity) public onlySeedCompany(msg.sender) {
        address x;
        for(uint i=0;i<seedUpdateAddress.length;i++)
        {
            if(seedUpdateAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((seedTypeVariety[seedUpdateAddress[i]][_varietyID].seedType))) ==keccak256(abi.encodePacked((_seedType))))
                {
                    if(keccak256(abi.encodePacked((seedTypeVariety[seedUpdateAddress[i]][_varietyID].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        x = seedUpdateAddress[i];
                    }
                }
            }
        }
        seedTypeVariety[x][_varietyID].quantity += _addQuantity;
    }

    function removeSeedQuantity(string memory  _seedType, string memory  _variety,uint _varietyID, uint _addQuantity) public onlySeedCompany(msg.sender) {
        address x;
        for(uint i=0;i<seedUpdateAddress.length;i++)
        {
            if(seedUpdateAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((seedTypeVariety[seedUpdateAddress[i]][_varietyID].seedType))) ==keccak256(abi.encodePacked((_seedType))))
                {
                    if(keccak256(abi.encodePacked((seedTypeVariety[seedUpdateAddress[i]][_varietyID].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        x = seedUpdateAddress[i];
                    }
                }
            }
        }
        seedTypeVariety[x][_varietyID].quantity -= _addQuantity;
    }

     function updateSeedPrice(string memory  _seedType,string memory _variety,uint _varietyID, uint _pricePer10g) public onlySeedCompany(msg.sender) {
        address x;
        for(uint i=0;i<seedUpdateAddress.length;i++)
        {
            if(seedUpdateAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((seedTypeVariety[seedUpdateAddress[i]][_varietyID].seedType))) ==keccak256(abi.encodePacked((_seedType))))
                {
                    if(keccak256(abi.encodePacked((seedTypeVariety[seedUpdateAddress[i]][_varietyID].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        x = seedUpdateAddress[i];
                    }
                }
            }
        }
        seedTypeVariety[x][_varietyID].pricePer10g = _pricePer10g;
    }

    function buySeeds(address payable _seedCompany,string memory _seedType,string memory _variety,uint _varietyID, uint _quantity) public payable onlyFarmer(msg.sender) {
        require(farmerListMapping[msg.sender], "Farmer doesn't Exist");
        address x;
        for(uint i=0;i<seedUpdateAddress.length;i++)
        {
            if(seedUpdateAddress[i]==_seedCompany)
            {
                if(keccak256(abi.encodePacked((seedTypeVariety[seedUpdateAddress[i]][_varietyID].seedType))) ==keccak256(abi.encodePacked((_seedType))))
                {
                    if(keccak256(abi.encodePacked((seedTypeVariety[seedUpdateAddress[i]][_varietyID].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        x = seedUpdateAddress[i];
                    }
                }
            }
        }
        require(_quantity <= seedTypeVariety[x][_varietyID].quantity, "This much qunatity of seed is not available");
        if(_quantity <= seedTypeVariety[x][_varietyID].quantity)
        {
            require(msg.value>0, "you have entered 0");
            require(msg.value == _quantity * seedTypeVariety[x][_varietyID].pricePer10g, "You haven't enterd the expected value");
            address payable receiever = payable(_seedCompany);
            receiever.transfer(msg.value); 
            emit transferCompleteSeed(msg.sender, _seedCompany,_seedType,_variety,_quantity,msg.value,block.timestamp);
            seedTypeVariety[x][_varietyID].quantity -= _quantity;
            seedPricePaid = true;
            requestFromFarmer.push(RequestDetails(msg.sender,_seedCompany,_seedType,_variety,_varietyID,_quantity,block.timestamp));
        }
    }

    function seedCompanyDashBoard() public view onlySeedCompany(msg.sender) returns(RequestDetails[] memory) {
        RequestDetails[] memory temp = new RequestDetails[](requestFromFarmer.length);
        uint count = 0;
        for(uint i=0;i<requestFromFarmer.length;i++)
        {
            if(requestFromFarmer[i].to == msg.sender)
            {
                temp[count] = requestFromFarmer[i];
                count++;
            }
        }
        if(temp.length == 0)
        {
            revert("You don't have any order");
        }
        return(temp);
    }

    function sellSeeds(address _farmer,string memory _seedType, string memory _variety,uint _varietyID,uint _quantity) public onlySeedCompany(msg.sender) {
        require(seedCompanyListMapping[msg.sender], "Seed Company Doesn't Exist");
        if(seedPricePaid==true)
        {
            uint x;
            seedTrans[seedTransCount] = SeedTrans(msg.sender,_farmer);
            seedTransCount++;
            emit sellOfSeeds(_farmer, msg.sender, _seedType, _variety,_quantity,block.timestamp);
            for(uint i=0;i<requestFromFarmer.length;i++)
            {
                if(requestFromFarmer[i].to == msg.sender)
                {
                    if(keccak256(abi.encodePacked((requestFromFarmer[i].Type))) == keccak256(abi.encodePacked((_seedType))))
                    {
                        if(keccak256(abi.encodePacked((requestFromFarmer[i].variety))) == keccak256(abi.encodePacked((_variety))))
                        {
                            if(requestFromFarmer[i].varietyID == _varietyID)
                            {
                                x = i;
                            }
                        }
                    }
                }
            }
            requestFromFarmer[x] = requestFromFarmer[requestFromFarmer.length -1];
            requestFromFarmer.pop();
        }
        else {
            revert("Farmer doesn't exist or he didn't pay the bills");
        }
    }

    function updateGrainFarmerQuantity(string memory _seedType,string memory _variety, uint _varietyID,uint _quantity, uint _pricePer1q) public onlyFarmer(msg.sender) {
        require(farmerListMapping[msg.sender], "Farmer doesn't exist");
        grownGrain[msg.sender][_varietyID] = GrownGrain(_seedType,_variety,_quantity,_pricePer1q);
        grownGrainAddress.push(msg.sender);
    }

    function updateGrainPriceByFarmer(string memory _grainTypeGrown,string memory _variety,uint _varietyID,uint _pricePer1q) public onlyFarmer(msg.sender) {
        require(farmerListMapping[msg.sender], "Farmer doesn't exist");
        address x;
        for(uint i=0;i<grownGrainAddress.length;i++)
        {
            if(grownGrainAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((grownGrain[grownGrainAddress[i]][_varietyID].grainTypeGrown))) ==keccak256(abi.encodePacked((_grainTypeGrown))))
                {
                    if(keccak256(abi.encodePacked((grownGrain[grownGrainAddress[i]][_varietyID].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        x = grownGrainAddress[i];
                    }
                }
            }
        }
        grownGrain[x][_varietyID].pricePer1q = _pricePer1q;

    }

    function updateGrainQuantityByFarmer(string memory _grainTypeGrown,string memory _variety,uint _varietyID,uint _quantity) public onlyFarmer(msg.sender) {
        require(farmerListMapping[msg.sender], "Farmer doesn't exist");
        address x;
        for(uint i=0;i<grownGrainAddress.length;i++)
        {
            if(grownGrainAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((grownGrain[grownGrainAddress[i]][_varietyID].grainTypeGrown))) ==keccak256(abi.encodePacked((_grainTypeGrown))))
                {
                    if(keccak256(abi.encodePacked((grownGrain[grownGrainAddress[i]][_varietyID].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        x = grownGrainAddress[i];
                    }
                }
            }
        }
        grownGrain[x][_varietyID].quantity = _quantity;

    }

    function addProcessor(address _processor) public onlyOwner {
        processorListArray.push(Processor(payable(_processor)));
        processorListMapping[_processor] = true;
        processorListIndex[_processor] = processorCount;
        processorCount++;
    }

    function buyGrainFromFarmer(address payable _farmer,string memory _grainType,string memory _variety,uint _varietyID,uint _quantity ) public payable onlyProcessor(msg.sender) {
        require(processorListMapping[msg.sender],"Processor doesn't exist");
        address x;
        for(uint i=0;i<grownGrainAddress.length;i++)
        {
            if(grownGrainAddress[i]==_farmer)
            {
                if(keccak256(abi.encodePacked((grownGrain[grownGrainAddress[i]][_varietyID].grainTypeGrown))) ==keccak256(abi.encodePacked((_grainType))))
                {
                    if(keccak256(abi.encodePacked((grownGrain[grownGrainAddress[i]][_varietyID].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        x = grownGrainAddress[i];
                    }
                }
            }
        }
        require(_quantity <= grownGrain[x][_varietyID].quantity, "This much qunatity of seed is not available");
        if(_quantity <= grownGrain[x][_varietyID].quantity)
        {
            require(msg.value>0, "you have entered 0");
            require(msg.value == _quantity * grownGrain[x][_varietyID].pricePer1q, "You haven't enterd the expected value");
            address payable receiever = payable(_farmer);
            receiever.transfer(msg.value); 
            emit transferCompleteFromProcessorToFarmer(msg.sender, _farmer,_grainType,_variety,_quantity,msg.value,block.timestamp);
            grownGrain[x][_varietyID].quantity -= _quantity;
            processorToFarmerTransfer = true; 
            requestFromProcessor.push(RequestDetails(msg.sender,_farmer,_grainType,_variety,_varietyID,_quantity,block.timestamp));  
        }
    } 

    function sellGrianToProcessor(address _processor,string memory _grainType, string memory _variety,uint _varietyID,uint _quantity,uint _pricePer1q) public onlyFarmer(msg.sender) {
        require(farmerListMapping[msg.sender], "Farmer Doesn't Exist");
        if(processorToFarmerTransfer==true)
        {
            uint x;
            processorToFarmerTrans.push(ProcessorToFarmerTrans(msg.sender,_processor));
            emit sellGrainsToProcessorFromElevator(_processor, msg.sender, _grainType, _variety,_quantity,_pricePer1q,block.timestamp);
            for(uint i=0;i<requestFromProcessor.length;i++)
            {
                if(requestFromProcessor[i].to == msg.sender)
                {
                    if(keccak256(abi.encodePacked((requestFromProcessor[i].Type))) == keccak256(abi.encodePacked((_grainType))))
                    {
                        if(keccak256(abi.encodePacked((requestFromProcessor[i].variety))) == keccak256(abi.encodePacked((_variety))))
                        {
                            if(requestFromProcessor[i].varietyID == _varietyID)
                            {
                                x = i;
                            }
                        }
                    }
                }
            }
            requestFromProcessor[x] = requestFromProcessor[requestFromProcessor.length -1];
            requestFromProcessor.pop();
        }
        else {
            revert("Processor doesn't exist or he didn't pay the bills");
        }
    }

    function FarmerDashBoard() public view onlyFarmer(msg.sender) returns(RequestDetails[] memory) {
        RequestDetails[] memory temp = new RequestDetails[](requestFromProcessor.length);
        uint count = 0;
        for(uint i=0;i<requestFromProcessor.length;i++)
        {
            if(requestFromProcessor[i].to == msg.sender)
            {
                temp[count] = requestFromProcessor[i];
                count++;
            }
        }
        if(temp.length == 0)
        {
            revert("You don't have any order");
        }
        return(temp);
    }

    function updateProcessedGrain(string memory _grainType,string memory _variety, uint _varietyID,uint _quantity, uint _pricePer10kg,uint _manDate,uint _expDate) public onlyFarmer(msg.sender) {
        require(processorListMapping[msg.sender], "Processor doesn't exist");
        processedGrainDetails[msg.sender][_varietyID] = ProcessedGrain(_grainType,_variety,_quantity,_pricePer10kg,_manDate,_expDate);
        processorUpdateAddress.push(msg.sender);
    }


}