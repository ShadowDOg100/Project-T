class TWeap_Assaultrifle_M16 extends TWeapon;

defaultproperties
{
	// mesh settings
	ArmViewOffset = (X=43.0)
	
	// firearm
	FirearmClass = class'TFirearm_Assaultrifle_M16'
	
	InventorySlot = 2;
	WeaponSubClass = 1;
	
	// -------------------------------------- AMMUNITION
	MagAmmo = 30
	MaxMagAmmo = 30
	AmmoCount = 90
	MaxAmmoCount = 90
	ShotCost(0) = 1
	ShotCost(1) = 0
}
