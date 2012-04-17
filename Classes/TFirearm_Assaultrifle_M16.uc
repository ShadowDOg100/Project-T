class TFirearm_Assaultrifle_M16 extends TFirearm;

defaultproperties
{
	// firearm mesh
	begin object name=FirearmMesh
		SkeletalMesh = SkeletalMesh'MyWeapons.SK_WP_SigCommando'
		AnimSets(0) = AnimSet'T.Anims.M16_Anims'
	end object
}