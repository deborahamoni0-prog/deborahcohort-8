// SPDX License-Identifier: unlicensed
pragma solidity 0.8.28;

contract milestone {
    address public Client;
    address public Freelancer;
    bool public validMilestone;
    uint256 public totalMilestones;
    uint256 public AmountPerMilestone;

    uint256 public currentMilestoneId;

    enum MilestoneStatus {
        PENDING,
        COMPLETED,
        PAID
    }

    struct Milestone {
        uint256 id;
        bool isCompleted; // Marked by freelancer
        bool isPaid;
        MilestoneStatus status;
        // Marked by client/contract
    }
    mapping(address => uint256) public Milestones;

    modifier onlyClient() {
        require(msg.sender == Client, "Only client can call this function");
        _;
    }

    modifier onlyFreelancer() {
        require(
            msg.sender == Freelancer,
            "Only freelancer can call this function"
        );
        _;
    }

    constructor(
        address _client,
        address payable _freelancer,
        uint256 _ethPerMilestone,
        uint256 _totalMilestones,
        uint256 _currentMilestoneId
    ) payable {
        Client = _client;
        Freelancer = _freelancer;
        AmountPerMilestone = _ethPerMilestone;
        totalMilestones = _totalMilestones;
    }

    event MilestoneCreated(uint256 milestoneId);
    event MilestoneCompleted(uint256 milestoneId);
    event MilestonePaid(uint256 milestoneId, uint256 amount);

    function creatJob(
        address payable _freelancer,
        uint256 _totalMilestones,
        uint256 _ethPerMilestone
    ) public onlyClient {
        require(msg.sender == Client, "Only client can create a milestone");
        Freelancer = _freelancer;
        AmountPerMilestone = _ethPerMilestone;
    }

    function completeMilestone(
        uint256 _id
    ) public onlyFreelancer returns (bool isCompleted) {
        require(
            msg.sender == Freelancer,
            "Only freelancer can complete a milestone"
        );
        require(Milestones[msg.sender] == _id, "Milestone ID does not exist");
        Milestones[msg.sender] = _id;
        return true;
    }

    function payMilestone(
        uint256 _ethPerMilestone,
        uint256 _currentMilestonesId
    ) public onlyClient returns (bool isPaid) {
        require(msg.sender == Client, "Only client can pay for a milestone");
        require(Milestones[Freelancer] > 0, "Milestone does not exist");
        require(_ethPerMilestone > 0, "Payment amount must be greater than 0");
        payable(Freelancer).transfer(_ethPerMilestone);
        Milestones[Freelancer] = 0;
        return true;
    }

    function calculateMilestone()
        public
        pure
        returns (uint256 _totalMilestones, uint256 _ethPerMilestone)
    {
        return (10, 1000);
    }
}
