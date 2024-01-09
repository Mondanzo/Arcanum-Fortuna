class_name EnemyBrainStats extends Resource

@export_category("Spawn chance")
@export var spawn_chance_by_turn : Curve
@export var spawn_chance_by_front_row_fill : Curve
@export var spawn_chance_by_back_row_fill : Curve

@export_category("Spawn Limits")
@export var min_enemies_per_front_row : int
@export var max_enemies_per_front_row : int
@export var min_enemies_per_back_row : int
@export var max_enemies_per_back_row : int
@export var min_total_enemies : int
@export var max_total_enemies : int

@export_category("Health")
@export var min_health : int
@export var max_health : int
