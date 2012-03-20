class MidAuto_Pickup extends TPickup
    placeable;

var() int ammo;
var int clipAmmo;
var PlayerController PC;
var bool bTouch;
var int WeapSlot;
var int WeapSubClass;



event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    if (Pawn(Other) != none)
    {
        //Ideally, we should also check that the touching pawn is a player-controlled one.
	    PC = PlayerController(Pawn(Other).Controller);
	    bTouch = true;
		(TGFxHudWrapper(PC.myHUD)).SetTouch(bTouch, class'TGame.TWeap_Shotgun_MidAuto', Self);
		PC.ClientMessage("Touch");
    }
}

event UnTouch( Actor Other )
{
    bTouch = false;
    (TGFxHudWrapper(PC.myHUD)).SetTouch(bTouch, class'TGame.TWeap_Shotgun_MidAuto', Self);
	PC.ClientMessage("Untouch");
}

function int GetWeapSlot()
{
	return WeapSlot;
}

function int GetWeapSubClass()
{
	return WeapSubClass;
}

function int getAmmo()
{
	return ammo;
}

function int getClip()
{
	return clipAmmo;
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
		SkeletalMesh=SkeletalMesh'MyWeapons.SK_WP_MidAuto'
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
        ammo = 0
	clipAmmo = 0
	WeapSlot = 0
	WeapSubClass = 0
}