
import { expect } from "chai";
import { network } from "hardhat";
const { networkHelpers } = await network.connect();

const { ethers } = await network.connect();


describe("milestone", function () {
let milestone : any;
const ZeroAddress = "0x0000000000000000000000000000000000000000";


beforeEach(async () => {
    milestone = await ethers.deployContract("Milestone");
    

  });


  describe("Create Auction", function (){
    it("should create an auction successfully", async () => {
    let [owner] = await ethers.getSigners()
     await expect(milestone.createAuction(1000, 1200)).to.emit(milestone, "AuctionInitialaized").withArgs(1n);
     const a = await milestone.auctionCounter();
     expect(a).to.equal(1);

     const createdAuction = await milestone.auctions(a);
     expect(createdAuction[0]).to.equal(1);
     expect(createdAuction[1]).to.equal(1000);
     expect(createdAuction[2]).to.equal(0);
     expect(createdAuction[3]).to.equal(owner);
     expect(createdAuction[4]).to.equal(ZeroAddress);
     expect(createdAuction[5]).to.equal(0);
     expect(createdAuction[6]).to.equal(1200);
     

    })

     it("should create more than an auction successfully", async () => {
    let [owner] = await ethers.getSigners()
    //  await expect(milestone.createAuction(1000, 1200)).to.emit(milestone, "AuctionInitialaized").withArgs(1n);
    await milestone.createAuction(1000, 1200);
     const a = await milestone.auctionCounter();
     expect(a).to.equal(1);

    //  await expect(milestone.createAuction(1500, 2000)).to.emit(milestone, "AuctionInitialaized").withArgs(2n);
    await milestone.createAuction(1500, 2000)
     
    const b =  await milestone.auctionCounter();
    
    
     const createdAuction = await milestone.auctions(b);
     expect(createdAuction[0]).to.equal(2);
     expect(createdAuction[1]).to.equal(1500);
     expect(createdAuction[2]).to.equal(0);
     expect(createdAuction[3]).to.equal(owner);
     expect(createdAuction[4]).to.equal(ZeroAddress);
     expect(createdAuction[5]).to.equal(0);
     expect(createdAuction[6]).to.equal(2000);
     

    })
  })

  describe.only("Start Auction", () => {
    it("Should Start Auction Successfully", async () => {
    let [owner] = await ethers.getSigners()
    await expect(milestone.createAuction(1000, 1200)).to.emit(milestone, "AuctionInitialaized").withArgs(1n);
    const a = await milestone.auctionCounter();
    
    await milestone.startAuction(a);
    const currentTime = await networkHelpers.time.latest()

     const startedAuction = await milestone.auctions(a);
     expect(startedAuction[2]).to.equal(1);
     expect(startedAuction[5]).to.be.closeTo(currentTime, 5);   
     
    })


    
      it("Should Fail When a Wrong address tries to start the Auction", async () => {
    let [owner, addr1] = await ethers.getSigners()
    await expect(milestone.createAuction(1000, 1200)).to.emit(milestone, "AuctionInitialaized").withArgs(1n);
    const a = await milestone.auctionCounter();

    await expect( milestone.connect(addr1).startAuction(a)).to.be.revertedWith("Not your Auction");  
     
    })
  })


  

});