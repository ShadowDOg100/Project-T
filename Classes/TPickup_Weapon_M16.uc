class TPickup_Weapon_M16 extends TPickup
        placeable;

defaultproperties
{
        bCollideActors=true
	CollisionType=COLLIDE_TouchAll;
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled=true
	End Object
	
	Components.Add(MyLightEnvironment)

	Begin Object Class=SkeletalMeshComponent Name=PickupMesh
		SkeletalMesh=SkeletalMesh'MyWeapons.SK_WP_SigCommando'
		LightEnvironment=MyLightEnvironment
	End Object

	Components.Add(PickupMesh)

	Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollisionRadius=32.0
		CollisionHeight=32.0
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)
	
        ammo = 120
	clipAmmo = 30
	WeapSlot = 3
	WeapSubClass = 1
	weapClass = class'TGame.TWeap_AssaultRifle_M16'
}