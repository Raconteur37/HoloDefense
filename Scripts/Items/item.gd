extends TextureRect

class_name Item

enum Type {GEM, MATERIAL}
enum Rarity {COMMON, RARE, SUPER_RARE, LEGENDARY, UNSEEN}
enum theItem {COPPER_GEM, QUARTZ_GEM, AMETHYST_GEM, DIAMOND_GEM, GALACTITE_GEM, COMMON_SCRAP,
RARE_SCRAP,SUPER_RARE_SCRAP,LEGENDARY_SCRAP,UNSEEN_SCRAP}

var image

var itemName = "None"

var moneyValue : int
var energyValue : float
var scrapValue : int

var rarity : Rarity
var type : Type
var actualItem : theItem


var amount = 0
