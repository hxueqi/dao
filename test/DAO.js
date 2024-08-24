const { expect } = require('chai');
const { ethers } = require('hardhat');

const tokens = (n) => {
  return ethers.utils.parseUnits(n.toString(), 'ether')
}

const ether = tokens

describe('DAO', () => {
let token, dao, deployer, funder

  beforeEach(async () => {
    //Set up accounts
    let accounts = await ethers.getSigners()
    deployer = accounts[0]
    funder = accounts[1]  

    //Deploy Token 
    const Token = await ethers.getContractFactory('Token')
    token = await Token.deploy('Dapp University', 'DAPP', '1000000')

    //Deoploy DAO 
    const DAO = await ethers.getContractFactory('DAO')
    dao = await DAO.deploy(token.address, '50000000000000000000001')

    //Funder sends 100 ether to DAO treasury for Governance
    await funder.sendTransaction({
      to: dao.address,
      value: ether(100)
    })
  })

  describe('Deployment', () => {
    it('sends ether to the DAO treasury', async () => { 
      expect(await ethers.provider.getBalance(dao.address)).to.equal(ether(100))
    })

    it('has correct name', async () => {
      expect(await dao.token()).to.equal(token.address)
    })


    it('returns quorum', async () => {
      expect(await dao.quorum()).to.equal('50000000000000000000001')
    })

  })
})
