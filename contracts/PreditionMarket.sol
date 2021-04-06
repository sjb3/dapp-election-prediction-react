pragma solidity ^0.7.3;

contract PredictionMarket {
    enum Side {Biden, Trump}
    struct Result {
        Side winner;
        Side loser;
    }

    Result public result;

    bool public electionFinished;

    mapping(Side => uint256) public bets;
    mapping(address => mapping(Side => uint256)) public betsPerGambler;
    address public oracle;

    constructor(address _oracle) {
        oracle = _oracle;
    }

    function placeBet(Side _side) external payable {
        require(electionFinished == false, "Election is finished");
        bets[_side] += msg.value;
        betsPerGambler[msg.sender][_side] += msg.value;
    }

    function withdrawGain() external {
        uint256 gambleBet = betsPerGambler[msg.sender][result.winner];
        require(gambleBet > 0, "No winning bet");
        require(electionFinished == true, "Election not finished");
        uint256 gain =
            gambleBet + (bets[result.loser] * gambleBet) / bets[result.winner];
        betsPerGambler[msg.sender][Side.Biden] = 0;
        betsPerGambler[msg.sender][Side.Trump] = 0;
        msg.sender.transfer(gain);
    }

    function reportResult(Side _winner, Side _loser) external {
        require(oracle == msg.sender, "Only Oracle");
        require(electionFinished == false, "Election has finished");
        result.winner = _winner;
        result.loser = _loser;
        electionFinished = true;
    }
}
