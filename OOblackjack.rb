# blackjack is a game with the objective of getting as close to 21 as possible without going over. If a player hits blackjack 21, then that player wins. The dealer goes first and continues to hit until he has more than 17. dealer wins tied values.


# classes: Players, Player, Dealer, Deck, Blackjack
# methods: hit_stay: hit or stay, check_winner: check for bust or if both players stay, player_turn, dealer_turn, calculate_values, 
#print_winner: check which winner won and then print that winner, cards: 2 - A, deck: assign cards to suits, 
#multiple_decks: create two decks for blackjack

require 'pry'

class Deck

  attr_accessor :deck, :cards

  def initialize
    @cards = {}
    @@deck = {}
  end

  def make_cards
    (2..10).each { |v| self.cards[v] = v }
    self.cards["Jack"] = 10
    self.cards["Queen"] = 10
    self.cards["King"] = 10
    self.cards["Ace"] = 11
    cards
  end

  def make_deck
    hearts = cards.map { |k , v| [" ♥#{k} of Hearts♥" , v] }
    diamonds = cards.map { |k, v| [" ♦︎#{k} of Diamonds♦︎", v] }
    clubs = cards.map { |k , v| [" ♣︎#{k} of Clubs♣︎" , v] }
    spades = cards.map { |k , v| [" ♠︎#{k} of Spades♠︎" , v] }
    @@deck = hearts + diamonds + clubs + spades
    multiple_decks
  end

  def multiple_decks
    @@deck = @@deck + @@deck
    @@deck.shuffle!
  end

  def deal_cards(playershand)
    newcard = Hash[*@@deck.shift]
    playershand.merge!(newcard)
    newcard
  end 
end


class Players

  attr_accessor :deck, :playershand, :playervalue

  def initialize
    @@deck = Deck.new
    @@deck.make_deck(@@deck.make_cards)
    @playershand = {}
    @playervalue
  end

  def player_value_calc(playershand)
    playervalue = 0
    playershand.each_value{ |v| playervalue += v }
    playervalue
  end

  def player_value(playershand)
    if playershand.has_value?(11)
      aces = playershand.select { |_, v| v == 11 }
      aces.count.times do
        ace = aces.shift
        if player_value_calc(playershand) > 21
          ace[1] = 1
          playershand.merge!(Hash[*ace.collect { |x| x }])
        end
      end
    end
    player_value_calc(playershand)
  end

end

class UserPlayer < Players

  attr_accessor :uservalue
  
  def initialize
    @@deck = Deck.new
    @uservalue
  end

  def display(userhand)
    system 'clear'
    self.uservalue = player_value(userhand)
    puts 
    puts "Your Cards Are: "
    puts 
    userhand.each_key { |k| puts k }
    puts
    puts "Total: #{uservalue}\n\n\n"
    sleep 0.5
    if endgame(userhand) then print $dealerputs end
  end

  def endgame(userhand)
    !(($dealerstay && $playerstay) || (player_value(userhand) == 21) || (player_value(userhand) > 21))
  end

  def user_hit_stay(userhand)
    begin
      display(userhand)
      if uservalue == 21 then break end
      puts "\n\nHit or Stay? (h/s)"
      hitstay = gets.chomp.downcase 
      if "h" == hitstay
        @@deck.deal_cards(userhand).each{ |c, v| userhand[c] = v}
        display(userhand)
      elsif "s" == hitstay
        $playerstay = true
      else
        puts 'Error: Please Enter an "h" or "s"'.center(70)
      end
    end until hitstay == "h" || hitstay == "s"
  end
end

class CompDealer < Players

  attr_accessor :dealervalue

  def initialize
    @@deck = Deck.new
    @dealervalue
  end

  def dealer_hit_stay(dealerhand)
    self.dealervalue = player_value(dealerhand)
    if dealervalue < 17
      @@deck.deal_cards(dealerhand).each{ |c, v| dealerhand[c] = v}
      $dealerputs = "The Dealer Hits\n\n"
    elsif dealervalue <= 21
      $dealerputs = "The Dealer Stays\n\n"
      $dealerstay = true
    end
  end
end

class Blackjack

  attr_accessor :user, :dealer, :name, :dealerhand, :userhand, :blackjackdeck, :playerstay, :dealerstay, :continue

  def initialize
    puts "Enter Name:"
    @name = gets.chomp
    @userhand = {}
    @dealerhand = {}
    @user = UserPlayer.new
    @dealer = CompDealer.new
    @blackjackdeck = Deck.new
    $playerstay = false
    $dealerstay = false
    $winner = false
    @continue = true
  end

  def check_winner
    if dealer.dealervalue == 21
      $winner = "\n\n" + "Dealer: #{dealer.dealervalue}  #{name}: #{user.uservalue}".center(70) + "\n\n\n" + "BlackJack, The Dealer Wins.".center(70)
    elsif user.uservalue == 21
      $blackjack = true
      $winner = "\n\n" + "Dealer: #{dealer.dealervalue}  #{name}: #{user.uservalue}".center(70) + "\n\n\n" + "BlackJack, #{self.name} Wins!".center(70)
    elsif user.uservalue > 21
      $winner = "\n\n" + "Dealer: #{dealer.dealervalue}  #{name}: #{user.uservalue}".center(70) + "\n\n\n" + "Sorry #{self.name}, you are over 21.".center(70)
    elsif dealer.dealervalue > 21
      $winner = "\n\n" + "Dealer: #{dealer.dealervalue}  #{name}: #{user.uservalue}".center(70) + "\n\n\n" + "The Dealer Busted".center(70)
    else
      $winner = false
    end
  end

  def players_stay
  ($playerstay) && ($dealerstay)
  end 

 def deal_cards
    blackjackdeck.deal_cards(userhand)
    blackjackdeck.deal_cards(dealerhand)
    blackjackdeck.deal_cards(userhand)
    blackjackdeck.deal_cards(dealerhand)
  end

  def create_blackjackdeck
    blackjackdeck.make_cards
    blackjackdeck.make_deck
  end

  def player_turn
    if $winner == false 
      if $playerstay == false
        user.user_hit_stay(userhand)
      end
    end
  end

  def dealer_turn
    if $winner == false
      dealer.dealer_hit_stay(dealerhand)
    end
  end 

  def print_winner
    sleep 0.5
    system 'clear'
    if players_stay && (user.uservalue > dealer.dealervalue)
      print "\n\n" + "#{name}: #{user.uservalue} Dealer: #{dealer.dealervalue}".center(70)
      print "\n\n" + "#{name} Wins!".center(70)
    elsif players_stay
      print "\n\n" + "Dealer: #{dealer.dealervalue}  #{name}: #{user.uservalue}".center(70)
      puts "\n\n" + "Sorry, Dealer wins."
    elsif $blackjack
      userblackjack = "Blackjack, #{name} Wins!"
      4.times do
        print "\r" + "#{userblackjack}".center(70)
        sleep 0.5
        print "\r" + "#{ ' ' * userblackjack.size }".center(70)
        sleep 0.5
      end
          print "\r" + "#{userblackjack}".center(70) + "\n"
    else
      print "\r" + "#{$winner}".center(70) + "\n"
    end
  end

  def play_again?
    loop do
      sleep 1.25
      puts "\n\nWould you like to play again?\n"
      answer = gets.chomp.downcase
      if answer.include? "y"
        self.userhand = {}
        self.dealerhand = {}
        $playerstay = false
        $dealerstay = false
        break
      elsif answer.include? "n"
        self.continue = false
        break
      else
        puts 'Please Enter "y" for Yes and "n" for No.'
      end
    end
  end

  def init_values
    user.uservalue = user.player_value(userhand)
    dealer.dealervalue = dealer.player_value(dealerhand)
  end

  def play
    begin
      create_blackjackdeck
      deal_cards
      init_values
      begin
        check_winner
        player_turn
        check_winner
        dealer_turn
      end until players_stay || $winner
        print_winner
        play_again?
    end until continue == false
  end
end

game = Blackjack.new
game.play