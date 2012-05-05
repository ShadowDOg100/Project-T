class TWeap_Pistol_Generic extends TWeapon;

defaultproperties
{
	// mesh settings
	ArmViewOffset = (X=6)
	IronsightViewOffset = (X=6)
	AimingMeshFOV = 45.0f
	
	begin object name=ArmsMeshComp
		SkeletalMesh = SkeletalMesh'T.Mesh.SK_Arms_Generic'
		AnimSets(0) = AnimSet'T.Anims.Anims_Arms_Generic'
	end object
	
	// firearm
	FirearmClass = class'TFirearm_Pistol_Generic'
	
	// ironsight
	AimingFOV = 80.0f
	
	InventorySlot = 0;
	WeaponSubClass = 0;
}
