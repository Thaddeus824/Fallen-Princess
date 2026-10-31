extends Node

var score = 0
@onready var score_label = $ScoreLabel
@onready var coins = %Coins
@onready var player = $"../Entities/Player"
@onready var coin_counter = %CoinCounter
var total_coins

const GAME_VERSION = "0.2"


func _ready():
	DisplayServer.window_set_title("Fallen Princess")
	total_coins = coins.get_child_count(false)
	coin_counter.text = "Coins collected: " + str(score) + " / " + str(total_coins) +  " coins."

func _input(event):
	if event.is_action_pressed("enter") and score == total_coins:
		get_tree().paused = false
		get_tree().reload_current_scene()
	

func add_point():
	score += 1
	score_label.text = "You collected " + str(score) + " / " + str(total_coins) +  " coins."
	if score == total_coins:
		await get_tree().create_timer(1).timeout
		get_tree().paused = true
		print("paused")
	coin_counter.text = "Coins collected: " + str(score) + " / " + str(total_coins) +  " coins."
		
