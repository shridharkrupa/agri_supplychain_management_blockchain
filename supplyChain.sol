// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract supplyChainAgri {

    constructor() {
        owner = msg.sender;
    }

    address private owner;

    bool seedPricePaid = false;

    mapping(uint=>SeedTrans) seedTrans;
    uint seedTransCount = 0;

    struct SeedTrans {
        address seedCompany;
        address farmer; 
    }


    event transferCompleteSeed(address farmer, address Seedcompany,string seedType,string variety,uint quantity,uint Price,uint time);
    event sellOfSeeds(address farmer, address seedCompany, string seedType, string variety,uint quantity,uint time);

    Farmer[] farmerListArray;
    mapping(address =>bool) public farmerListMapping;
    mapping(address =>uint) public farmerListIndex;
    uint farmerCount = 0;

    SeedCompany[] public seedCompanyListArray;
    mapping(address=>bool) public seedCompanyListMapping;
    mapping(address => uint) public seedCompanyIndex;
    uint public seedCompanyCount = 0;
    mapping(address=>mapping(uint =>SeedDetails)) public seedTypeVariety;
    address[] public seedUpdateAddress;
    RequestDetails[] requestFromFarmer;
    


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
        string name;
    }


    struct SeedCompany {
        address payable companyAddress;
        string CompanyName;
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

    function addFarmer(string memory  _name) public {
        farmerListArray.push(Farmer(payable(msg.sender),_name));
        farmerListMapping[msg.sender] = true;
        farmerListIndex[msg.sender] = farmerCount;
        farmerCount++;
    }

    function getListOfFarmer() view onlyOwner public returns(Farmer[] memory , uint) {
        return (farmerListArray, farmerCount);
    }

    function addSeedCompany(string memory _name) public {
        seedCompanyListArray.push(SeedCompany(payable(msg.sender),_name));
        seedCompanyListMapping[msg.sender] = true;        
        seedCompanyIndex[msg.sender] = seedCompanyCount;       //storing in mapping to get index
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

    function getQuantity(address _seedCompany,uint _varietyID) public view returns(uint) {
        return(seedTypeVariety[_seedCompany][_varietyID].quantity);
    }


}

