extends TextureRect

class_name Item

var itemName = "None"

var itemPopup = null

var moneyValue : int

var rarity : Rarity
var type : Type
var actualItem : theItem

enum Type {GEM, MATERIAL}
enum Rarity {COMMON, RARE, SUPER_RARE, LEGENDARY, UNSEEN}
enum theItem {COPPER_GEM}

var amount = 0
