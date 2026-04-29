extends RigidBody2D
class_name Projectile

var velocity: Vector2 = Vector2.ZERO

var shooter: Turret
var damage: int
var target: Node2D
var speed: float
var pierce : int = 0
var enemiesPierced : int
var enemy: Enemy

# Effect flags - still live here, but only used to BUILD the packet
var execute: bool = false
var poison: bool = false
var poisonDamage: float = 0
var poisonTime: float = 0.0
var burn: bool = false
var burnTime: float = 0.0
var burnDamage: float = 0.0
var curse: bool = false
var curseTime: float = 0.0
var explosion: bool = false

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body == shooter:
		return
	if not body is Enemy:
		return
	enemy = body
	EntityManager.enemyTakeDamage(buildPacket(), enemy)
	if pierce > 0:
		enemiesPierced += 1
		if enemiesPierced >= pierce:
			queue_free()  # projectile frees itself here
	else:
		queue_free()

func buildPacket() -> DamagePacket:
	var fx = []
	var fxData = {}

	if execute: fx.append(EffectClass.Effect.EXECUTE)
	if poison:
		fx.append(EffectClass.Effect.POISON)
		fxData["poisonDamage"] = poisonDamage
		fxData["poisonTime"] = poisonTime
	if burn:
		fx.append(EffectClass.Effect.BURN)
		fxData["burnDamage"] = burnDamage
		fxData["burnTime"] = burnTime
	if curse:
		fx.append(EffectClass.Effect.CURSE)
		fxData["curseTime"] = curseTime
	if explosion:
		fx.append(Explosion.new(shooter,enemy))

	return DamagePacket.new(damage, DamagePacket.Type.PROJECTILE, shooter, fx, fxData)
