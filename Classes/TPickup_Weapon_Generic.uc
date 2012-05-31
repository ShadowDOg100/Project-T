class TPickup_Weapon_Generic extends TPickup_Weapon
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
		SkeletalMesh=SkeletalMesh'T.Mesh.SK_WP_Generic'
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

        ammo = 90
	clipAmmo = 18
	WeapSlot = 1
	WeapSubClass = 1
	weapClass = class'TGame.TWeap_Pistol_Generic'
}