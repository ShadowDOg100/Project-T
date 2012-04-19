class TFirearm_Pistol_Generic extends TFirearm;

defaultproperties
{
	// firearm mesh
	begin object name=FirearmMesh
		SkeletalMesh = SkeletalMesh'MyPackage.Glock21_LowRes_SkMesh'
		AnimSets(0) = AnimSet'MyPackage.1p_GUN_Glock_Anims'
	end object
}