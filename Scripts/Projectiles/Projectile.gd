extends RigidBody2D
class_name Projectile

var shooter
var damage: int
var target: Node2D
var speed: float
var piercing: bool = false

# Effect flags - still live here, but only used to BUILD the packet
var execute: bool = false
var poison: bool = false
var poisonDamage: int = 0
var poisonTime: float = 0.0
var curse: bool = false
var curseTime: float = 0.0

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body == shooter:
		return
	if not body is Enemy:
		return
	EntityManager.enemyTakeDamage(buildPacket(), body)
	if not piercing:
		queue_free()  # projectile frees itself here

func buildPacket() -> DamagePacket:
	var fx = []
	var fxData = {}

	if execute: fx.append("execution")
	if poison:
		fx.append("poison")
		fxData["poisonDamage"] = poisonDamage
		fxData["poisonTime"] = poisonTime
	if curse:
		fx.append("curse")
		fxData["curseTime"] = curseTime

	return DamagePacket.new(damage, DamagePacket.Type.PROJECTILE, shooter, fx, fxData)
