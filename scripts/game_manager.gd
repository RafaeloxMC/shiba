extends Node

var difficulty = 1

var score = 0
var coins = 0
var hearts = 3

signal death()
signal coin_pickup()

func add_coin():
	coins += 1
	print("Coin picked up: ", coins)
	coin_pickup.emit()
	
func remove_heart():
	print("Removed heart!")
	hearts -= 1
	death.emit()
