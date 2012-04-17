class TFirearm_Assaultrifle_AK47 extends TFirearm;

defaultproperties
{
	// firearm mesh
	begin object name=FirearmMesh
		SkeletalMesh = SkeletalMesh'MyWeapons.SK_WP_AK47'
		AnimSets(0) = AnimSet'T.Anims.AK47_Anims'
	end object
}