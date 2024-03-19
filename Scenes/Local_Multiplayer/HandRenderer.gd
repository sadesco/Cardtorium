extends Control

var card_scene = preload ("res://Scenes/Card_Renderer/Card.tscn")

var player: Player
var XBOUND = [200, 952]
var YPOS = 550
var cards := []
var selected_index = -1
var card_clicked = false
signal card_selected(card: Card)

## Initializes the hand renderer by connecting it to a player's hand
func connect_to_player(p: Player):
	player = p
	player.cards_drawn.connect(render_cards)
	player.cards_removed.connect(remove_cards)

## Renders the cards in a player's hand.
func render_cards(hand: Array[Card]):

	for card_node in cards:
		card_node.queue_free()
	cards.clear()

	var cardsize = Vector2(1205, 1576)
	var num_cards = len(hand)
	var increment = float(XBOUND[1] - XBOUND[0]) / num_cards
	var xpos = XBOUND[0] + increment / 2
	for i in range(num_cards):
		var card = hand[i]
		var rendered = card_scene.instantiate()
		add_child(rendered)
		rendered.setup(card, i)
		call_deferred("setup_card", rendered, Vector2(xpos, YPOS), 0.12, cardsize)
		xpos += increment
	
		rendered.card_focused.connect(self.on_card_focused)
		rendered.card_unfocused.connect(self.on_card_unfocused)
		rendered.card_clicked.connect(self.on_card_clicked)
		cards.append(rendered)

## Bring card to front on hover
func on_card_focused(card_index: int):
	if not card_clicked:
		cards[card_index].z_index = 1

## Send card to back on no hover
func on_card_unfocused(card_index: int):
	if not card_clicked:
		cards[card_index].z_index = 0

## Select a card
func on_card_clicked(card_index: int):
	# Deselect the card if it's already selected
	if card_index == selected_index:
		selected_index = -1
		card_clicked = false
		return

	card_clicked = true
	# Deselect all cards except the clicked one
	for i in range(len(cards)):
		if i != card_index:
			cards[i].get_node("Focus").modulate.a = 0
			cards[i].z_index = 0
	cards[card_index].get_node("Focus").modulate.a = 1
	cards[card_index].z_index = 1

	emit_signal("card_selected", card_index)
	
## Removes a card from the player's hand
func remove_cards(old_hand: Array[Card], new_hand: Array[Card]):
	# TODO: Add an animation here instead of just re-rendering the hand
	render_cards(new_hand)

## Helper function for positioning a card
func setup_card(rendered, pos, scale, size):
	rendered.size = size
	rendered.position = pos - (size * scale) / 2
	rendered.scale.x = scale
	rendered.scale.y = scale
