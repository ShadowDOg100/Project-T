class TWeap_Pistol_Generic extends TWeapon;

defaultproperties
{
	// mesh settings
	ArmViewOffset = (X=43.0)
	
	begin object name=ArmsMeshComp
		SkeletalMesh = SkeletalMesh'MyPackage.1p_Arms_LowRes_SkMesh'
		AnimSets(0) = AnimSet'MyPackage.1p_Arms_Glock_Anims'
	end object
	
	// firearm
	FirearmClass = class'TFirearm_Pistol_Generic'
	
	InventorySlot = 0;
	WeaponSubClass = 0;
}
