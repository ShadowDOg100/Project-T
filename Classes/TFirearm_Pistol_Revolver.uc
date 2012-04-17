class TFirearm_Pistol_Revolver extends TFirearm;

defaultproperties
{
	// firearm mesh
	begin object name=FirearmMesh
		SkeletalMesh = SkeletalMesh'T.Mesh.SK_WP_Revolver'
		AnimSets(0) = AnimSet'T.Anims.Revolver_Anims'
	end object
}