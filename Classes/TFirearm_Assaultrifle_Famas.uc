class TFirearm_Assaultrifle_Famas extends TFirearm;

defaultproperties
{
	// firearm mesh
	begin object name=FirearmMesh
		SkeletalMesh = SkeletalMesh'MyWeapons.SK_WP_Famas'
		AnimSets(0) = AnimSet'T.Anims.Famas_Anims'
	end object
}