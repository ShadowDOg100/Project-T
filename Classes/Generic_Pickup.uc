class Generic_Pickup extends TPickup
    placeable;

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    if (Pawn(Other) != none)
    {
        //Ideally, we should also check that the touching pawn is a player-controlled one.
	    PC = PlayerController(Pawn(Other).Controller);
	    bTouch = true;
		SetTouch(bTouch, class'TGame.TWeap_Pistol_Generic', Self,"WP");
		PC.ClientMessage("Touch");
    }
}

event UnTouch( Actor Other )
{
    bTouch = false;
    SetTouch(bTouch, class'TGame.TWeap_Pistol_Generic', Self,"WP");
	PC.ClientMessage("Untouch");
}

DefaultProperties
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
	
	//clip + ammo
        ammo = 90
	clipAmmo = 18
	WeapSlot = 1
	WeapSubClass = 1
	item = "WP"
}