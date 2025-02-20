import { describe, it, expect, beforeEach } from "vitest"

describe("Community Governance Contract", () => {
  let mockStorage: Map<string, any>
  let proposalNonce: number
  let currentBlockHeight: number
  
  beforeEach(() => {
    mockStorage = new Map()
    proposalNonce = 0
    currentBlockHeight = 0
  })
  
  const mockContractCall = (method: string, args: any[], sender: string) => {
    switch (method) {
      case "create-proposal":
        const [description, votingPeriod] = args
        proposalNonce++
        mockStorage.set(`proposal-${proposalNonce}`, {
          proposer: sender,
          description,
          votesFor: 0,
          votesAgainst: 0,
          status: 1, // STATUS_ACTIVE
          endBlock: currentBlockHeight + votingPeriod,
        })
        return { success: true, value: proposalNonce }
      case "vote":
        const [proposalId, voteFor] = args
        const proposal = mockStorage.get(`proposal-${proposalId}`)
        if (!proposal || currentBlockHeight >= proposal.endBlock) {
          return { success: false, error: "Invalid proposal or voting period ended" }
        }
        if (mockStorage.get(`vote-${proposalId}-${sender}`)) {
          return { success: false, error: "Already voted" }
        }
        mockStorage.set(`vote-${proposalId}-${sender}`, { vote: voteFor })
        if (voteFor) {
          proposal.votesFor++
        } else {
          proposal.votesAgainst++
        }
        mockStorage.set(`proposal-${proposalId}`, proposal)
        return { success: true }
      case "end-proposal":
        const [endProposalId] = args
        const endProposal = mockStorage.get(`proposal-${endProposalId}`)
        if (!endProposal || currentBlockHeight < endProposal.endBlock || endProposal.status !== 1) {
          return { success: false, error: "Invalid proposal or voting period not ended" }
        }
        endProposal.status = endProposal.votesFor > endProposal.votesAgainst ? 2 : 3 // STATUS_PASSED or STATUS_REJECTED
        mockStorage.set(`proposal-${endProposalId}`, endProposal)
        return { success: true }
      case "get-proposal":
        const [getProposalId] = args
        return { success: true, value: mockStorage.get(`proposal-${getProposalId}`) }
      case "get-vote":
        const [getVoteProposalId, voter] = args
        return { success: true, value: mockStorage.get(`vote-${getVoteProposalId}-${voter}`) }
      default:
        return { success: false, error: "Method not found" }
    }
  }
  
  it("should create a proposal", () => {
    const result = mockContractCall("create-proposal", ["Increase time credit minting rate", 100], "user1")
    expect(result.success).toBe(true)
    expect(result.value).toBe(1)
  })
  
  it("should allow voting on a proposal", () => {
    mockContractCall("create-proposal", ["Increase time credit minting rate", 100], "user1")
    const result = mockContractCall("vote", [1, true], "user2")
    expect(result.success).toBe(true)
  })
  
  it("should not allow double voting", () => {
    mockContractCall("create-proposal", ["Increase time credit minting rate", 100], "user1")
    mockContractCall("vote", [1, true], "user2")
    const result = mockContractCall("vote", [1, false], "user2")
    expect(result.success).toBe(false)
  })
  
  it("should end a proposal after voting period", () => {
    mockContractCall("create-proposal", ["Increase time credit minting rate", 100], "user1")
    mockContractCall("vote", [1, true], "user2")
    mockContractCall("vote", [1, false], "user3")
    currentBlockHeight = 101
    const result = mockContractCall("end-proposal", [1], "anyone")
    expect(result.success).toBe(true)
  })
  
  it("should get proposal details", () => {
    mockContractCall("create-proposal", ["Increase time credit minting rate", 100], "user1")
    const result = mockContractCall("get-proposal", [1], "anyone")
    expect(result.success).toBe(true)
    expect(result.value.description).toBe("Increase time credit minting rate")
  })
  
  it("should get vote details", () => {
    mockContractCall("create-proposal", ["Increase time credit minting rate", 100], "user1")
    mockContractCall("vote", [1, true], "user2")
    const result = mockContractCall("get-vote", [1, "user2"], "anyone")
    expect(result.success).toBe(true)
    expect(result.value.vote).toBe(true)
  })
})

