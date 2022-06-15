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

    SeedTrans[] seedTrans;
    ProcessorToFarmerTrans[] processorToFarmerTrans;
    RetailerToProcessorTrans[] retailerToProcessorTrans;
    CustomerToRetailerTrans[] customerToRetailerTrans;


    struct SeedTrans {
        address seedCompany;
        address farmer; 
        SeedDetails seedDetails;
    }

    struct ProcessorToFarmerTrans {
        address processor;
        address farmer;
        GrownGrain soldGrainFromProcessortoFarmer;
    }

    struct RetailerToProcessorTrans {
        address retailer;
        address processor;
        ProcessedGrain processedGrain;
    }

    struct CustomerToRetailerTrans {
        address customer;
        address retailer;
        ProcessedGrain soldToCustomer;
    }


    event transferCompleteSeed(address farmer, address Seedcompany,string seedType,string variety,uint quantity,uint Price,uint time);
    event sellOfSeeds(address farmer, address seedCompany, string seedType, string variety,uint quantity,uint time);
    event transferCompleteFromProcessorToFarmer(address processor, address farmer,string grownGrainType,string variety,uint quantity,uint Price,uint time);
    event sellGrainsToProcessorFromElevator(address Farmer,address Processor,string grainType,string variety,uint quantity,uint pricePer1q,uint purchaseDate);
    event transferCompleteFromRetailerToProcessor(address Retailer ,address Processor,string grainType,string variety,uint quantity,uint Price,uint time);
    event sellGrainsToRetailerFromProcessor(address Processor,address Retailer,string grainType,string variety,uint quantity,uint pricePer1q,uint purchaseDate);
    event transferCompleteFromCustomerToRetailer(address Customer ,address Retailer,string grainType,string variety,uint quantity,uint Price,uint time);
    event sellGrainsToCustomerFromRetailer(address Retailer,address Customer,string grainType,string variety,uint quantity,uint pricePer1q,uint purchaseDate);



    Farmer[] farmerListArray;
    mapping(address =>bool) public farmerListMapping;
    mapping(address =>uint) public farmerListIndex;
    uint farmerCount = 0;
    mapping(address=>mapping(uint=>GrownGrain)) grownGrain;
    address[] grownGrainAddress;
    RequestDetails[] requestFromProcessor;

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
    mapping(address=>mapping(uint=>ProcessedGrain)) processedGrainDetails;
    address[] public processorUpdateAddress;
    RequestDetails[] requestFromRetailer;

    Retailer[] retailerListArray;
    mapping(address=>bool) retailerListMapping;
    mapping(address=>uint) retailerListIndex;
    uint retailerCount;
    mapping(address=>mapping(uint=>ProcessedGrain)) retailerGrainDetails;
    address[] public retailerUpdateAddress;
    RequestDetails[] requestFromCustomer;

    Customer[] customerListArray;
    mapping(address=>bool) customerListMapping;
    mapping(address=>uint) customerLisIndex;
    uint customerCount;
    
    


    modifier onlyOwner {
        require(msg.sender == owner,"confidential.");
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

    modifier onlyRetailer(address _retailer) {
        require(retailerListMapping[_retailer],"Retailer doesn't exist");
        _;
    }

    modifier onlyCustomer(address _customer) {
        require(customerListMapping[_customer],"Customer doesn't exist");
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
        uint pricePerQuantity;
        uint manDate;
        uint expDate;
    }

    struct Retailer {
        address payable retailerAddress;
    }

    struct Customer {
        address payable customerAddress;
    }

    function addFarmer(address _farmer ) public onlyOwner {
        farmerListArray.push(Farmer(payable(_farmer)));
        farmerListMapping[_farmer] = true;
        farmerListIndex[_farmer] = farmerCount;
        farmerCount++;
    }

    function addSeedCompany(address _seedCompany) public onlyOwner{
        seedCompanyListArray.push(SeedCompany(payable(_seedCompany)));
        seedCompanyListMapping[_seedCompany] = true;        
        seedCompanyIndex[_seedCompany] = seedCompanyCount;       //storing in mapping to get index
        seedCompanyCount++;
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
            revert("Details exist!");
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

    function buySeeds(address payable _seedCompany,string memory _seedType,string memory _variety,uint _varietyID, uint _quantity) public payable onlyFarmer(msg.sender) {
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

    function sellSeeds(address _farmer,string memory _seedType, string memory _variety,uint _varietyID,uint _quantity,uint _pricePer10g) public onlySeedCompany(msg.sender) {
        if(seedPricePaid==true)
        {
            uint x;
            seedTrans.push(SeedTrans(msg.sender,_farmer,SeedDetails(_seedType,_variety,_quantity,_pricePer10g)));
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
            revert("Error");
        }
    }

    function updateGrainFarmerQuantity(string memory _grainTypeGrown,string memory _variety, uint _varietyID,uint _quantity, uint _pricePer1q) public onlyFarmer(msg.sender) {
        address x = address(0);
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
        if(x == address(0))
        {
            grownGrain[msg.sender][_varietyID] = GrownGrain(_grainTypeGrown,_variety,_quantity,_pricePer1q);
            grownGrainAddress.push(msg.sender);
        }
        else
        {
            revert("details exist");
        }
    }

    function updateGrainQuantityByFarmer(string memory _grainTypeGrown,string memory _variety,uint _varietyID,uint _quantity) public onlyFarmer(msg.sender) {
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
        require(_quantity <= grownGrain[x][_varietyID].quantity, "Not Available");
        if(_quantity <= grownGrain[x][_varietyID].quantity)
        {
            require(msg.value>0, "you have entered 0");
            require(msg.value == _quantity * grownGrain[x][_varietyID].pricePer1q, "rong value");
            address payable receiever = payable(_farmer);
            receiever.transfer(msg.value); 
            emit transferCompleteFromProcessorToFarmer(msg.sender, _farmer,_grainType,_variety,_quantity,msg.value,block.timestamp);
            grownGrain[x][_varietyID].quantity -= _quantity;
            processorToFarmerTransfer = true; 
            requestFromProcessor.push(RequestDetails(msg.sender,_farmer,_grainType,_variety,_varietyID,_quantity,block.timestamp));  
        }
    } 

    function sellGrianToProcessor(address _processor,string memory _grainType, string memory _variety,uint _varietyID,uint _quantity,uint _pricePer1q) public onlyFarmer(msg.sender) {
        if(processorToFarmerTransfer==true)
        {
            uint x;
            processorToFarmerTrans.push(ProcessorToFarmerTrans(msg.sender,_processor,GrownGrain(_grainType,_variety,_quantity,_pricePer1q)));
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
        address x = address(0);
        for(uint i=0;i<processorUpdateAddress.length;i++)
        {
            if(processorUpdateAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((processedGrainDetails[processorUpdateAddress[i]][_varietyID].grainType))) ==keccak256(abi.encodePacked((_grainType))))
                {
                    if(keccak256(abi.encodePacked((processedGrainDetails[processorUpdateAddress[i]][_varietyID].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        if(processedGrainDetails[processorUpdateAddress[i]][_varietyID].manDate == _manDate)
                        {
                            x   = processorUpdateAddress[i];
                        }
                    }
                }
            }
        }
        if(x == address(0))
        {
            processedGrainDetails[msg.sender][_varietyID] = ProcessedGrain(_grainType,_variety,_quantity,_pricePer10kg,_manDate,_expDate);
            processorUpdateAddress.push(msg.sender);
        }
        else
        {
            revert("Details are not found"); 
        }

    }

    function addProcessedGrainQuantity(string memory _grainType, string memory _variety,uint _varietyID, uint _quantity,uint _manDate) public onlyProcessor(msg.sender) {
        address x = address(0);
        for(uint i=0;i<processorUpdateAddress.length;i++)
        {
            if(processorUpdateAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((processedGrainDetails[processorUpdateAddress[i]][_varietyID].grainType))) ==keccak256(abi.encodePacked((_grainType))))
                {
                    if(keccak256(abi.encodePacked((processedGrainDetails[processorUpdateAddress[i]][_varietyID].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        if(processedGrainDetails[processorUpdateAddress[i]][_varietyID].manDate == _manDate)
                        {
                            x   = processorUpdateAddress[i];
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
            processedGrainDetails[x][_varietyID].quantity += _quantity;
        }

    }

    function addRetailer(address _retailer) public {
        retailerListArray.push(Retailer(payable(_retailer)));
        retailerListMapping[_retailer] = true;
        retailerListIndex[_retailer] = retailerCount;
        retailerCount++;
    }

    function buyGrainFromProcessor(address _processor,string memory _grainType, string memory _variety,uint _varietyID, uint _quantity,uint _manDate) public payable onlyRetailer(msg.sender) {
        address x;
        for(uint i=0;i<processorUpdateAddress.length;i++)
        {
            if(processorUpdateAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((processedGrainDetails[processorUpdateAddress[i]][_varietyID].grainType))) ==keccak256(abi.encodePacked((_grainType))))
                {
                    if(keccak256(abi.encodePacked((processedGrainDetails[processorUpdateAddress[i]][_varietyID].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        if(processedGrainDetails[processorUpdateAddress[i]][_varietyID].manDate == _manDate)
                        {
                            x = processorUpdateAddress[i];
                        }
                    }
                }
            }
        }
        require(_quantity <= processedGrainDetails[x][_varietyID].quantity, "This much qunatity of grain is not available");
        if(_quantity <= processedGrainDetails[x][_varietyID].quantity)
        {
            require(msg.value>0, "you have entered 0");
            require(msg.value == _quantity * processedGrainDetails[x][_varietyID].pricePerQuantity, "You haven't enterd the expected value");
            address payable receiever = payable(_processor);
            receiever.transfer(msg.value); 
            emit transferCompleteFromRetailerToProcessor(msg.sender, _processor,_grainType,_variety,_quantity,msg.value,block.timestamp);
            processedGrainDetails[x][_varietyID].quantity -= _quantity;
            retailerToProcessorTransfer = true;  
            requestFromRetailer.push(RequestDetails(msg.sender,_processor,_grainType,_variety,_varietyID,_quantity,block.timestamp));
        }

    }

    function sellGrianToRetailer(address _retailer,string memory _grainType, string memory _variety,uint _varietyID,uint _quantity,uint _pricePer10kg,uint _manDate) public onlyProcessor(msg.sender) {
        if(processorToFarmerTransfer==true)
        {
            uint x;
            retailerToProcessorTrans.push(RetailerToProcessorTrans(msg.sender,_retailer,ProcessedGrain(_grainType,_variety,_quantity,_pricePer10kg,_manDate,processedGrainDetails[msg.sender][_varietyID].expDate)));
            emit sellGrainsToRetailerFromProcessor(_retailer, msg.sender, _grainType, _variety,_quantity,_pricePer10kg,block.timestamp);
            for(uint i=0;i<requestFromRetailer.length;i++)
            {
                if(requestFromRetailer[i].to == msg.sender)
                {
                    if(keccak256(abi.encodePacked((requestFromRetailer[i].Type))) == keccak256(abi.encodePacked((_grainType))))
                    {
                        if(keccak256(abi.encodePacked((requestFromRetailer[i].variety))) == keccak256(abi.encodePacked((_variety))))
                        {
                            if(requestFromRetailer[i].varietyID == _varietyID)
                            {
                                x = i;
                            }
                        }
                    }
                }
            }
            requestFromRetailer[x] = requestFromRetailer[requestFromRetailer.length -1];
            requestFromRetailer.pop();
        }
        else {
            revert("error");
        }
    }

    function ProcessorDashBoard() public view onlyProcessor(msg.sender) returns(RequestDetails[] memory) {
        RequestDetails[] memory temp = new RequestDetails[](requestFromRetailer.length);
        uint count = 0;
        for(uint i=0;i<requestFromRetailer.length;i++)
        {
            if(requestFromRetailer[i].to == msg.sender)
            {
                temp[count] = requestFromRetailer[i];
                count++;
            }
        }
        if(temp.length == 0)
        {
            revert("You don't have any order");
        }
        return(temp);
    }

    function updateRetailerGrain(string memory _grainType,string memory _variety, uint _varietyID,uint _quantity, uint _pricePerkg,uint _manDate,uint _expDate) public onlyRetailer(msg.sender) {
        address x = address(0);
        for(uint i=0;i<retailerUpdateAddress.length;i++)
        {
            if(retailerUpdateAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((retailerGrainDetails[retailerUpdateAddress[i]][_varietyID].grainType))) ==keccak256(abi.encodePacked((_grainType))))
                {
                    if(keccak256(abi.encodePacked((retailerGrainDetails[retailerUpdateAddress[i]][_varietyID].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        if(retailerGrainDetails[retailerUpdateAddress[i]][_varietyID].manDate == _manDate)
                        {
                            x   = retailerUpdateAddress[i];
                        }
                    }
                }
            }
        }

        retailerGrainDetails[msg.sender][_varietyID] = ProcessedGrain(_grainType,_variety,_quantity,_pricePerkg,_manDate,_expDate);
        retailerUpdateAddress.push(msg.sender);
    }

    function updateRetailerGrainQuantity(string memory _grainType,string memory _variety, uint _varietyID,uint _quantity,uint _manDate) public onlyRetailer(msg.sender) {
        address x = address(0);
        for(uint i=0;i<retailerUpdateAddress.length;i++)
        {
            if(retailerUpdateAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((retailerGrainDetails[retailerUpdateAddress[i]][_varietyID].grainType))) ==keccak256(abi.encodePacked((_grainType))))
                {
                    if(keccak256(abi.encodePacked((retailerGrainDetails[retailerUpdateAddress[i]][_varietyID].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        if(retailerGrainDetails[retailerUpdateAddress[i]][_varietyID].manDate == _manDate)
                        {
                            x   = retailerUpdateAddress[i];
                        }
                    }
                }
            }
        }
        retailerGrainDetails[x][_varietyID].quantity += _quantity;
    }

    function buyGrainFromRetailer(address _retailer,string memory _grainType, string memory _variety,uint _varietyID, uint _quantity,uint _manDate) public payable onlyCustomer(msg.sender) {
        address x;
        for(uint i=0;i<retailerUpdateAddress.length;i++)
        {
            if(retailerUpdateAddress[i]==msg.sender)
            {
                if(keccak256(abi.encodePacked((retailerGrainDetails[retailerUpdateAddress[i]][_varietyID].grainType))) ==keccak256(abi.encodePacked((_grainType))))
                {
                    if(keccak256(abi.encodePacked((retailerGrainDetails[retailerUpdateAddress[i]][_varietyID].variety))) ==keccak256(abi.encodePacked((_variety))))
                    {
                        if(processedGrainDetails[retailerUpdateAddress[i]][_varietyID].manDate == _manDate)
                        {
                            x = retailerUpdateAddress[i];
                        }
                    }
                }
            }
        }
        require(_quantity <= processedGrainDetails[x][_varietyID].quantity, "Not Available");
        if(_quantity <= processedGrainDetails[x][_varietyID].quantity)
        {
            require(msg.value>0, "you have entered 0");
            require(msg.value == _quantity * retailerGrainDetails[x][_varietyID].pricePerQuantity, "enter right value");
            address payable receiever = payable(_retailer);
            receiever.transfer(msg.value); 
            emit transferCompleteFromCustomerToRetailer(msg.sender, _retailer,_grainType,_variety,_quantity,msg.value,block.timestamp);
            retailerGrainDetails[x][_varietyID].quantity -= _quantity;
            customerToRetailerTransfer = true;  
            requestFromCustomer.push(RequestDetails(msg.sender,_retailer,_grainType,_variety,_varietyID,_quantity,block.timestamp));
        }
    }

    function RetailerDashBoard() public view onlyRetailer(msg.sender) returns(RequestDetails[] memory) {
        RequestDetails[] memory temp = new RequestDetails[](requestFromRetailer.length);
        uint count = 0;
        for(uint i=0;i<requestFromCustomer.length;i++)
        {
            if(requestFromCustomer[i].to == msg.sender)
            {
                temp[count] = requestFromCustomer[i];
                count++;
            }
        }
        if(temp.length == 0)
        {
            revert("You don't have any order");
        }
        return(temp);
    }

    function sellGrianToCustomer(address _customer,string memory _grainType, string memory _variety,uint _varietyID,uint _quantity,uint _pricePerkg,uint _manDate) public onlyProcessor(msg.sender) {
        if(processorToFarmerTransfer==true)
        {
            uint x;
            customerToRetailerTrans.push(CustomerToRetailerTrans(msg.sender,_customer,ProcessedGrain(_grainType,_variety,_quantity,_pricePerkg,_manDate,retailerGrainDetails[msg.sender][_varietyID].expDate)));
            emit sellGrainsToCustomerFromRetailer(_customer, msg.sender, _grainType, _variety,_quantity,_pricePerkg,block.timestamp);
            for(uint i=0;i<requestFromRetailer.length;i++)
            {
                if(requestFromCustomer[i].to == msg.sender)
                {
                    if(keccak256(abi.encodePacked((requestFromCustomer[i].Type))) == keccak256(abi.encodePacked((_grainType))))
                    {
                        if(keccak256(abi.encodePacked((requestFromCustomer[i].variety))) == keccak256(abi.encodePacked((_variety))))
                        {
                            if(requestFromCustomer[i].varietyID == _varietyID)
                            {
                                x = i;
                            }
                        }
                    }
                }
            }
            requestFromCustomer[x] = requestFromCustomer[requestFromCustomer.length -1];
            requestFromCustomer.pop();
        }
        else {
            revert("error");
        }
    }

}