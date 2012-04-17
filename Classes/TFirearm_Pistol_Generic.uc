class TFirearm_Pistol_Generic extends TFirearm;

defaultproperties
{
	// firearm mesh
	begin object name=FirearmMesh
		SkeletalMesh = SkeletalMesh'T.Mesh.SK_WP_Generic'
		AnimSets(0) = AnimSet'T.Anims.Generic_Anims'
	end object
}