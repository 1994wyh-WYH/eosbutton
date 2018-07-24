pragma solidity ^0.4.24;

contract button is Ownable {
    using SafeMath for *;
    
    uint256 initAKeyPrice = 10000000000000000; // 0.18% up per new key
    uint256 initBKeyPrice = 10000000000000000; // 0.18% down per new key
    uint256 lastAKeyPrice;
    uint256 lastBKeyPrice;
    
    uint256 launchTime; // ? to be decided
    uint256 countdown_cap = 43200; //12 h countdown cap
    uint256 countdown_increase_step = 120; //Increase 2 minutes per share when pressed
    uint256 round_interval = 600; //10 minutes between each round
    
    uint256 shares_for_first_press = 10000; //10000 means 1 share

    uint256 BRewardPercent = 40;
    uint256 reservedPercent = 10;
    uint256 ARewardPercent = 40;
    uint256 lastPlayerPercent = 10;
    
    uint256 lastPID = 0;    // current max player ID => total # of player
    uint256 public currRID;    // current round ID => total # of rounds
    
    uint256[] latePlayers; // players eligible for B rewards. arr index => PID
    
    mapping (uint256 => Round) public rounds;   // rID => round data
    mapping (address => uint256) public addrToPID; // addr => PID
    mapping (uint256 => Player) public PIDToPlayers;   // PID => player data
    // mapping (uint256 => mapping (uint256 => PlayerRounds)) public playerRounds;
   
    struct Player{
        uint256 PID; // if new, assign and update last PID;
        address account;
        uint256 AShares;
        uint256 BShares;
        uint256 lastPressAShares; //needed?
        uint256 lastPressBShares; //needed?
        uint256 lastPressTime;
        uint256 AEarning;
        uint256 BEarning;
    }
    
    // struct PlayerRound {
    //     uint256 PID;
    //     // address account;
    //     uint256 shares;
    //     uint256 lastPressShare;
    //     uint256 lastPressInfo;
    //     uint256 lastPressRemainingTime;
    //     uint256 eth;    // eth player has added to round (used for eth limiter)
    //     uint256 keys;   // keys
    // }
    
    struct Round{
        uint256 RID;
        // uint256 lastPressedShares;  ??
        uint256 totalAShares;
        uint256 totalBShares;
        uint256 pot;
        // uint256 nextRoundReserved;  ??
        // uint256 dev_fee;
        // address lastPressedPlayer;
        uint256 start;
        uint256 end;
        uint256 lastPressTime;
        uint256 lastPressRemainingTime;
    }
    
    // fired whenever a withdraw forces end round to be ran
    event Withdraw
    (
        address playerAddress,
        uint256 amount
        );
    
    event distributes(
        uint256 compressedData,
        uint256 compressedIDs,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot,
        uint256 P3DAmount,
        uint256 genAmount        
        );
    
    /**
     * @dev sets boundaries for incoming eth in wei 
     */
    modifier checkBoundaries(uint256 amount) {
        require(amount >= 1000000000);
        require(amount <= 100000000000000000000000);
        _;    
    }
    
    constructor() public {
        lastAKeyPrice = 10000000000000000;
        lastBKeyPrice = 10000000000000000;
    }
    
    /**
     * @dev for checking if a game has ended.
     */
    function isCurrRoundEnded() public view return(bool) {
        return now >= rounds[currRID].end;
    }
    
    /**
     * @dev calculates the number of A keys given amount of eth
     */
     function AKeysOf(uint256 _quantity) public view returns (uint256) {
         
     }
     
    /**
     * @dev calculates the number of B keys given amount of eth
     */
     function BKeysOf(uint256 _quantity) public view returns (uint256) {
    
     }
         
    
    /**
     * @dev core buy-key logic
     */
    function press(address _account, uint256 _quantity) checkBoundaries(_quantity) public onlyOwner {
        
        Round game = rounds[RID];
        uint256 remaining_time_right_after_last_full_press;
        // TODO: need to modify!!!
        uint256 addup = game.lastPressRemainingTime.add(countdown_increase_step.mul(game.lastPressedShares).div(10000));
        if(countdown_cap < addup){
            remaining_time_right_after_last_full_press = countdown_cap;
        }
        else{
            remaining_time_right_after_last_full_press = addup;
        }
        
        // for consistency
        uint256 _now = now;
        
        // 2 scenarios: last round has ended; you are still in a round
        /////////////////
        // if (_now >= game.lastPressedTime.add(remaining_time_right_after_last_full_press)) {
        if(isCurrRoundEnded()){
        //Round ended or not started
        
        //foundation withdraw
        withdraw(pot.mul(reservedPercent).div(100));
        
        if (_now >= game.lastPressedTime.add(remaining_time_right_after_last_full_press).add(round_interval)) {
            //Start a new round !

            //Transfer B rewards to players
            //Run this logic no matter the pot is 0 or not. If it is 0, it doesn't mean there is no player (if there is only one press last round, the pot is 0).
            for (uint256 i = 1; i <= latePlayers.length; i++) {
                //Calculate the reward
                uint256 last_round_reward;
                Player p = latePlayers[i];

                //normal player B reward
                last_round_reward = (game.pot).mul(100.sub(ARewardPercent).sub(reservedPercent)).mul(p.BShares).div(game.BShares);
                
                if (last_round_reward.amount > 0) {
                    // uodate player info, maybe round player info
                    
                    // payPlayer, player withdraw
                    // clear B shares
                   
                        //rewarding 
                        // accstates accstates_table( _self, _self );
                        // auto accstates_itr = accstates_table.find(itr->account);
                        // if (accstates_itr == accstates_table.end()) {
                        //     accstates_table.emplace( account, [&]( auto& a ) {
                        //         a.account = itr->account;
                        //         a.eos_balance = last_round_reward;
                        //   });
                        // } else {
                        //     accstates_table.modify( accstates_itr, 0, [&]( auto& a ) {
                        //         a.eos_balance = a.eos_balance + last_round_reward;
                        //     });
                        // }
                    
                    //Transfered last round reward to p.account
                    }
                //erase p? nah
            }
            
            // ??????????
            // if (now < launchTime) {
            //     return;
            // }
            
            // //Emplace this pressed player's A shares record, shares_for_first_press
            // press valid, maybe
            Player memory thisP = PIDToPlayers[addrToPID[_account]];
            thisP.AShares = ;
            
            // TODO: pay this player
            payPlayer(thisP.PID, "A");
            
            // players_table.emplace(account, [&](auto& p){
            //     p.account = account;
            //     p.shares = shares_for_first_press;
            //     p.last_press_shares = shares_for_first_press;
            //     p.last_press_remaining_time = 0;
            // });

            //Set initial values for a new round
            Round memory r = Round({
                RID: currRID + 1,
                totalAShares: shares_for_first_press,
                totalBShares: 0,
                pot: r.nextRoundReserved,
                nextRoundReserved: 0,
                start: _now,
                end: _now + countdown_cap,
                lastPressTime: _now,
                lastPressRemainingTime: countdown_cap
            });
            currRID++;
            rounds[r.RID] = r;
                // g.total_shares = s_add(g.total_shares, shares_for_first_press);  //add up???
                // g.last_full_press_remaining_time = 0;    // ??????????????? should be countdown cap
            }
            
            // next round not started yet
            else {
            // do nothing, for now
            }
            
        }
        // Round still active.
        else{
            //update end time
            rounds[currRID].end = (game.lastPressTime).add(remaining_time_right_after_last_full_press);
            
            uint256 remaining = remaining_time_right_after_last_full_press.sub(_now.sub(game.lastPressTime));
                    
            uint256 timeElapsedSinceStart = _now.sub(game.start);
            // To be modified
            uint256 shares = _quantity.mul(1036800000).div((remaining.power(2).add(2280)).mul(timeElapsedSinceStart.add(86400)));
            
            // TODO: update A reward info 
            payPlayer(addrToPID[_account], "A");
            
            
            //Update shares and check if it is a full press  ???
            // shares = shares.add(additional_shares_for_referee);
            //full press needed ??

            //Update player info
            uint256 pid= addrToPID[_account];
            //check if player exists
            if(pid == 0) {
                 //update 
                Player memory p2 = Player ({
                    //init default
                    PID: lastPID; // if new, 
                    account: _account;
                    AShares: shares;
                    BShares: 0;
                    lastPressAShares: shares;
                    lastPressBShares: 0;
                    lastPressTime: _now;
                    AEarning: ; // TODO: to be decided
                    BEarning: ; // TODO: to be decided
                });
                
                lastPID ++;
                
                // TODO: pay player for A? push to arr
                
                
            } else {
                Player memory p2 = PIDToPlayers[pid];
                p2.shares = (p2.shares).add(shares);
                p2.lastPressShare = shares;
                p2.lastPressRemainingTime = remaining;
            }
            
            
            // TODO: update late player list
    
            //Update game info
            //Calculate pot and shares
            uint256 foundationReserved = quantity.mul(reservedPercent).div(100);
            
            games_table.modify(games_itr, account, [&](auto& g){
                g.shares = s_add(s_add(g.shares, shares), additional_shares_for_referrer);
                g.total_shares = s_add(s_add(g.total_shares, shares), additional_shares_for_referrer);
                g.pot = g.pot + quantity - token_reserved_for_next_round - dev_fee;
                g.token_reserved_for_next_round += token_reserved_for_next_round;
                g.dev_fee += dev_fee;
                if (full_press) {
                    g.last_full_press_shares = shares;
                    g.last_full_press_player = account;
                    g.last_full_press_time = now();
                    g.last_full_press_remaining_time = remaining;
                }
            });

        }

        
    }
    
    // /**
    //  * @dev return the price buyer will pay for next 1 individual key.
    //  * @return price for next key bought (in wei format)
    //  */
    // function getBuyPrice()
    //     public 
    //     view 
    //     returns(uint256)
    // {  
    //     // setup local rID
    //     uint256 _rID = rID_;
        
    //     // grab time
    //     uint256 _now = now;
        
    //     // are we in a round?
    //     if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
    //         return ( (round_[_rID].keys.add(1000000000000000000)).ethRec(1000000000000000000) );
    //     else // rounds over.  need price for new round
    //         return ( 75000000000000 ); // initial value
    // }
    
    /**
     * @dev Ends current round, starts cooling down 
     * 
     */
    function endRound() private returns(){
        //Calculate shares
        uint256 remaining_time_right_after_last_full_press;
        uint256 addup = games_itr->last_full_press_remaining_time.add(countdown_increase_step.mul(games_itr->last_full_press_shares).div(10000));
        if(countdown_cap < addup){
            remaining_time_right_after_last_full_press = countdown_cap;
        }
        else{
            remaining_time_right_after_last_full_press = addup;
        }
        uint256 remaining = remaining_time_right_after_last_full_press.sub(now.sub(games_itr->last_full_press_time));
        uint256 timeElapsedSinceStart = now.sub(games_itr->start_time);
        uint256 shares = quantity.mul(1036800000).div((remaining.power(2).add(2280)).mul(timeElapsedSinceStart.add(86400)));
        /////////////////////////////////////////
        // setup local rID
        uint256 _rID = rID_;
        
        // grab our winning player and team id's
        uint256 _winPID = round_[_rID].plyr;
        // grab our pot amount
        uint256 _pot = round_[_rID].pot;
        
        // calculate our winner share, community rewards, gen share, 
        // p3d share, and amount reserved for next pot 
        uint256 _win = (_pot.mul(5)) / 100;
        uint256 _com = (_pot / 50);
        uint256 _gen = (_pot.mul(potSplit_[_winTID].gen)) / 100;
        uint256 _res = (((_pot.sub(_win)).sub(_com)).sub(_gen)).sub(_p3d);
        
        // calculate ppt for round mask
        uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
        uint256 _dust = _gen.sub((_ppt.mul(round_[_rID].keys)) / 1000000000000000000);
        if (_dust > 0)
        {
            _gen = _gen.sub(_dust);
            _res = _res.add(_dust);
        }
        
        // pay our winner
        plyr_[_winPID].win = _win.add(plyr_[_winPID].win);
        
        // community rewards
        if (!address(Jekyll_Island_Inc).call.value(_com)(bytes4(keccak256("deposit()"))))
        {
            // This ensures Team Just cannot influence the outcome of FoMo3D with
            // bank migrations by breaking outgoing transactions.
            // Something we would never do. But that's not the point.
            // We spent 2000$ in eth re-deploying just to patch this, we hold the 
            // highest belief that everything we create should be trustless.
            // Team JUST, The name you shouldn't have to trust.
            _p3d = _p3d.add(_com);
            _com = 0;
        }
        
        // distribute gen portion to key holders
        round_[_rID].mask = _ppt.add(round_[_rID].mask);

    }
    
    /**
     * @dev Pays a player. Transfer specified earnings to the player. Clear balance immediately.
     * @param _pid, player ID
     * @param _kind, a string indicating the reward type
     * 
     */
    function payPlayer(uint256 _pid, string _kind)
        public
        onlyOwner
    {
        // check player ID
        require(_pid != 0);
      
        // grab time
        uint256 _now = now;
        
        // setup temp var for player eth
        uint256 _eth;
        
        // check to see if round has ended and no one has run round end yet
        if (_now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
        {
            // set up our tx event data
            F3Ddatasets.EventReturns memory _eventData_;
            
            // end the round (distributes pot)
			round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);
            
			// get their earnings
            _eth = withdrawEarnings(_pID);
            
            // gib moni
            if (_eth > 0)
                plyr_[_pID].addr.transfer(_eth);    
            
            // build event data
            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
            _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
            
            // fire withdraw and distribute event
            emit WithdrawAndDistribute
            (
                msg.sender, 
                plyr_[_pID].name, 
                _eth, 
                _eventData_.compressedData, 
                _eventData_.compressedIDs, 
                _eventData_.winnerAddr, 
                _eventData_.winnerName, 
                _eventData_.amountWon, 
                _eventData_.newPot, 
                _eventData_.P3DAmount, 
                _eventData_.genAmount
            );
            
        // in any other situation
        } else {
            // get their earnings
            _eth = withdrawEarnings(_pID);
            
            // gib moni
            if (_eth > 0)
                PIDToPlayers[_pID].addr.transfer(_eth);
            
            // fire withdraw event
            emit F3Devents.onWithdraw(_pID, msg.sender, plyr_[_pID].name, _eth, _now);
        }
    }
    
    /**
     * @dev calculates how many keys would exist with given an amount of eth
     * @param _eth eth "in contract"
     * @return number of keys that would exist
     */
    function keysOf(uint256 _eth) 
        internal
        pure
        returns(uint256)
    {
        return ((((((_eth).mul(1000000000000000000)).mul(312500000000000000000000000)).add(5624988281256103515625000000000000000000000000000000000000000000)).sqrt()).sub(74999921875000000000000000000000)) / (156250000);
    }
    
    /**
     * @dev calculates number of keys received given X eth 
     * @param _curEth current amount of eth in contract 
     * @param _newEth eth being spent
     * @return amount of ticket purchased
     */
    function keysRec(uint256 _curEth, uint256 _in)
        internal
        pure
        returns (uint256)
    {
        return(keysOf((_curEth).add(_in)).sub(keysOf(_curEth)));
    }
    
    /**
     * @dev calculates how much eth would be in contract given a number of keys
     * @param _keys number of keys "in contract" 
     * @return eth that would exists
     */
    function ethOf(uint256 _keys) 
        internal
        pure
        returns(uint256)  
    {
        return ((78125000).mul(_keys.sq()).add(((149999843750000).mul(_keys.mul(1000000000000000000))) / (2))) / ((1000000000000000000).sq());
    }
}
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

      /**
      * @dev Multiplies two numbers, throws on overflow.
      */
      function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
          return 0;
        }
    
        c = a * b;
        assert(c / a == b);
        return c;
      }
    
      /**
      * @dev Integer division of two numbers, truncating the quotient.
      */
      function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
      }
    
      /**
      * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
      */
      function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
      }
    
      /**
      * @dev Adds two numbers, throws on overflow.
      */
      function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
      }
    
    /**
     * @dev gives square root of given x.
     */
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y) 
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y) 
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }
    
    /**
     * @dev x to the power of y 
     */
    function power(uint256 x, uint256 y)
        internal 
        pure 
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else 
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


//////////////////////////////////////////////////////////////
void eos_button::claimad( account_name account )
{
    //print("claimad - Start |");
    require_auth( account );

    asset airdrop_claim_quantity = asset(500000000, string_to_symbol(4, "EBT"));
    time airdrop_claim_interval = 86400;
    time airdrop_start_time = 1531908000;
    time airdrop_end_time = 1533117600;

    accstates accstates_table( _self, _self );
    auto accstates_itr = accstates_table.find(account);
    /*
    systemstates systemstates_table( _self, _self );
    auto systemstates_itr = systemstates_table.find(0);
    eosio_assert(systemstates_itr != systemstates_table.end(), "No airdrop");
    eosio_assert(systemstates_itr->airdrop_available >= systemstates_itr->airdrop_claim_quantity, "Airdrop unavailable");
    eosio_assert(now() >= systemstates_itr->airdrop_start_time, "Airdrop has not started");
    eosio_assert(now() < systemstates_itr->airdrop_end_time, "Airdrop is ended");
    */
    eosio_assert(now() >= airdrop_start_time, "Airdrop has not started");
    eosio_assert(now() < airdrop_end_time, "Airdrop is ended");

    if(accstates_itr != accstates_table.end()) {
        //eosio_assert( now() >= accstates_itr->last_airdrop_claim_time + systemstates_itr->airdrop_claim_interval, "claim is too frequent");
        eosio_assert( now() >= accstates_itr->last_airdrop_claim_time + airdrop_claim_interval, "claim is too frequent");
    }

    //Update last_airdrop_claim_time
    if( accstates_itr == accstates_table.end() ) {
        //print("itr == end |");
        accstates_table.emplace(account, [&](auto& a){
            a.account = account;
            a.last_airdrop_claim_time = now();
            a.eos_balance = asset(0, string_to_symbol(4, "EOS"));
        });
    } else {
        //print("itr != end |");
        accstates_table.modify(accstates_itr, account, [&](auto& a){
            a.account = account;
            a.last_airdrop_claim_time = now();
        });
    }

    //Update available airdrop
    /*
    systemstates_table.modify(systemstates_itr, account, [&](auto& a){
        a.airdrop_available = a.airdrop_available - a.airdrop_claim_quantity;
    });
    */

    //Issue
    //cissue(account, systemstates_itr->airdrop_claim_quantity, "eosbutton.io - Airdrop");
    //Use mtransfer to replace cissue
    mtransfer(_self, account, airdrop_claim_quantity, account);

    //print("claimad - End |");
}
