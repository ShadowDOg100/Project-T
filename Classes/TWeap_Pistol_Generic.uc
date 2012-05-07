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
	
	// -------------------------------------- SOUNDS
	FireSound = SoundCue'T.Sounds.Generic_Fire_Cue'
	EquipSound = SoundCue'T.Sounds.Generic_Equip_Cue'
	UnequipSound = SoundCue'T.Sounds.Generic_Unequip_Cue'
	
	// muzzle flash
	MuzzleFlashClass = class'TMuzzleFlash_Pistol_Generic'
	
	// firearm
	FirearmClass = class'TFirearm_Pistol_Generic'
	
	// ironsight
	AimingFOV = 80.0f

	InventorySlot = 0;
	WeaponSubClass = 0;
}
