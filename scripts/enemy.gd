extends Area2D

export(int) var speed
export(float) var freezeTime
export(int) var numberOfCells
var isFrozen = false
var isAttachedToPlayer = false

var defaultTexture = preload('res://sprites/enemy.png')
var frozenTexture = preload('res://sprites/enemy__frozen.png')
var attachedTexture # TODO create texture

onready var CELL_WIDTH = get_viewport().size.x / numberOfCells
onready var CELL_HEIGHT = get_viewport().size.y / numberOfCells
onready var enemy_state = {
	'freezeTimer': get_node('freeze')
}

func get_velocity(delta):
	var velocity = Vector2()
	if Input.is_action_pressed('right'):
		velocity.x += 1
	if Input.is_action_pressed('left'):
		velocity.x -= 1
	if Input.is_action_pressed('down'):
		velocity.y += 1
	if Input.is_action_pressed('up'):
		velocity.y -= 1
	return velocity.normalized() * speed * delta

func _process(delta):
	if isAttachedToPlayer:
		position += get_velocity(delta)
	else:
		if not isFrozen:
			var player = get_node('/root/world/player')
			var direction = (player.position - position).normalized()
			position += direction * speed * delta

func getGridPosition(offsetX, offsetY):
	var cellWidth = get_viewport().size.x / numberOfCells
	var cellHeight = get_viewport().size.y / numberOfCells
	offsetX *= cellWidth
	offsetY *= cellHeight
	return Vector2(position.x + offsetX, position.y + offsetY)

func updateNeighbors():
	var enemies = get_tree().get_nodes_in_group('enemies')
	for enemy in enemies:
		if enemy.isFrozen:
			var hasNeighbors = false
			if position == enemy.getGridPosition(-1, 0):
				enemy.queue_free()
				hasNeighbors = true
			if position == enemy.getGridPosition(1, 0):
				enemy.queue_free()
				hasNeighbors = true
			if position == enemy.getGridPosition(0, -1):
				enemy.queue_free()
				hasNeighbors = true
			if position == enemy.getGridPosition(0, 1):
				enemy.queue_free()
				hasNeighbors = true
			if hasNeighbors:
				queue_free()

func resetFreezeWaitTime():
	enemy_state.freezeTimer.set_wait_time(freezeTime)
	enemy_state.freezeTimer.start()

func freeze():
	isFrozen = true
	get_node('sprite').texture = frozenTexture
	resetFreezeWaitTime()

func explode():
	get_node('/root/world').addToScore(1)
	queue_free()

func attachToPlayer():
	if isAttachedToPlayer:
		explode()
	isAttachedToPlayer = true
	# get_node('sprite').texture = attachedTexture

func _on_freeze_timeout():
	isFrozen = false
	get_node('sprite').texture = defaultTexture
	pass

func _on_enemy_area_entered(area):
	if self.is_queued_for_deletion():
		return

	if area.is_in_group("player"):
		print('muerto por jugarle al vergas')
		get_tree().quit()
	elif area.is_in_group("enemies"):
		area.queue_free()
		get_node('/root/world').addToScore(-1)
		queue_free()
