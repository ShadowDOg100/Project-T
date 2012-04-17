class TFirearm_Pistol_Burst extends TFirearm;

defaultproperties
{
	// firearm mesh
	begin object name=FirearmMesh
		SkeletalMesh = SkeletalMesh'T.Mesh.SK_WP_Burst'
		AnimSets(0) = AnimSet'T.Anims.Burst_Anims'
	end object
}