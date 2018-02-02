pragma solidity ^0.4.16;

contract Evenement {
   // The name of the event
   bytes32 mName;

   // The number of people who can attend the event
   uint32 mAvailable;
   

   // The tickets that are sold for this event
   // associated with the owner of the ticket
   mapping (address => address) mTickets;

   // The number of tickets sold
   uint32 soldTickets;

   // The wallet that organises the event
   EventWallet mWallet;

   modifier onlyOwner() {
      require(mWallet.isOwner(msg.sender));
      _;
   }

   /**
     * Primary constructor of the event
     * This should be called from an EventWallet
     * 
     * @param name the name of the event
     * @param available the number of people who can attend the event
     * @param w the event wallet that created the event, this will be used as the owner of the event
     */
   function Evenement(bytes32 name, uint32 available, EventWallet w) public {
      mName = name;
      mAvailable = available;
      mWallet = w;
   }

   /**
     * Change the name of the event. Only the owner of the EventWallet associated with the event can do that
     *
     * @param name the new name of the event
     */
   function setName(bytes32 name) public onlyOwner() {
      mName = name;
   }


   /**
     * Get the name of the event
     *
     * @return the name of the event
     */
   function getName() public view {
      return mName;
   }

   /**
     * Get the number of tickets sold
     *
     * @return the number of tickets sold
     */
   function getSoldTickets() public view {
      return soldTickets;
   }

   /**
     * Change the number of people who can attend the event
     *
     * @param available the number of people who can attend the event
     */
   function changeAvailable(uint32 available) public onlyOwner() {
      mAvailable = available;
   }

   /**
     * Sell a ticket to the caller of this method
     * 
     * @return the newly created ticket
     */
   function sellTicket() public payable returns(Ticket) {
      // TODO: check the amount payed to ensure the user pays enough for the ticket
      Ticket t = new Ticket(this);

      // associate the sender with the ticket, to get fast lookup
      mTickets[t] = msg.sender;
      return t;
   }  


}

contract Ticket {
   // The event for which the ticket was sold
   Evenement mEvenement;

   // The owner of the ticket
   address mOwner;
   
   modifier onlyOwner() {
      require (this.sender == mOwner);
      _;
   }

   /**
     * Primary constructor of the ticket
     *
     * @param e the event for which this ticket was sold
     */
   function Ticket(Evenement e) public {
      mOwner = msg.sender;
      mEvenement = e;
   }

   /**
     * Change the owner of the ticket.
     * Caution: if you do this you might lose access to the ticket through other applications
     * 
     * @param newOwner the new owner of the ticket
     */
    function changeOwner(address newOwner) public onlyOwner() {
      mOwner = newOwner;
    }

    /**
      * Get the owner of the ticket
      *
     * @return the owner of the ticket
     */
    function getOwner() returns(address) {
      return mOwner;
    }
}

/**
 * A wallet that contains a list of Evenement
 * and is able to sell tickets for them
 *
 * A third party should contact the EventWallet
 * when it wants to know if a ticket-evenement combination is valid
 */
contract EventWallet{
   // A list of owners that own the wallet
   // An owner is allowed to change events, add them and delete them
   address mOwner;

   // The list of events that are managed by this wallet
   Evenement[] mEvenement;

   // The list of tickets that are sold by this wallet
   Ticket[] mTickets;

   /**
     * Primary constructor, used to initialize the internal data structures
     */
   function EventWallet() public {
      // Add the creator of the wallet to the owner list
      mOwner = msg.sender;
   }

   function isOwner(address p) public view returns(bool) {
      // An akward way in solidity to check if a certain key exists in the mapping
      // That is because there is not a function "contains" for mappings in Solidity
      return mOwner == p;
   }

   /**
     * Only owner filter, scans the list of owners and checks that the sender is one of them
     */
   modifier only_owner() {
      require(isOwner(msg.sender));
      _;
   }

   /**
     * Create and add an event to the wallet
     * 
     * @param name the name of the new event
     * @param available_places the number of people that can attend the event
     * @return the addres of the created event
     */
   function addEvent(bytes32 name, uint32 available_places) only_owner() public returns(address)  {
      Evenement e = new Evenement(name, available_places, this);
      mEvenement.push(e);
      return e;
   }

   /**
     * Get the lists of events on this wallet
     *
     * @return the list of events
     */
   function getEvents() public view returns(Evenement[]){
      return mEvenement;
   }

}
