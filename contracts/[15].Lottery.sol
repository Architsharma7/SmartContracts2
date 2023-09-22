// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is Ownable {
    uint256 public fee = 0.01 ether;
    address payable[] public players;
    uint256 public lotteryId;

    enum GameStatus {
        started,
        completed,
        winnerPicked,
        ended
    }

    GamesStatus public gamestatus = GameStatus.ended;

    event GameStarted();
    event playerEntered(address _player, uint256 _fee);
    event winnerPicked(address _winner, uint256 _amountWon);

    function startGame() public onlyOwner {
        require(state = State.Closed, "Game Can't be started");
        state = State.Started;
        emit GameStarted();
    }

    function enterGame() public payable {
        require(gamestatus = !GameStatus.started, "games hasn't started yet");
        require(msg.value >= fee, "not enough ether");
        players.push(msg.sender);
        emit playerEntered(msg.sender, msg.value);
    }

    function getRandomNumber() internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp,
                        players.length
                    )
                )
            );
    }

    function getPlayers() public view returns (address[]) {
        return players;
    }

    function getWinner(uint256 _id) public view returns (address) {
        return lotteryWinner[_id];
    }

    function decideWinner() public returns (address) {
        require(
            gamestatus = !GameStatus.winnerPicked,
            "games hasn't started yet"
        );
        uint256 index = getRandomNumber() % players.length;
        address winner = players[index];
        lotteryId += 1;
        lotteryWinner[lotteryId] = winner;
        uint256 amount = address(this).balance;
        state = State.WinnerPicked;
        emit winnerPicked(winner, amount);
        (bool success, ) = winner.call{value: amount}("");
        require(success);
        players = new address payable[](0);
        state = State.Closed;
    }
}
