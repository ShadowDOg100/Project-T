class TPawn extends UDKPawn
	config(Game)
	placeable;

// Armor
var int armor;

// -------------------------------------- WEAPON
/** weapon attachment class */
var repnotify class<TWeaponAttachment> WeaponAttachmentClass;
/** weapon attachment */
var TWeaponAttachment WeaponAttachment;

/** crouch eye height */
var float CrouchEyeHeight;

/** stamina amount used for sprinting*/
var float stamina;
var bool useStamina;
var bool canWalk; //used to make sure that the player does not become infinately slower

/** default inventory */
var array< class<Inventory> > Defaultinventory;

/** replication */
replication
{
	if(bNetDirty)
		WeaponAttachmentClass;
}

/** replicated event */
simulated event ReplicatedEvent(name VarName)
{
	if(VarName == 'WeaponAttachmentClass')
	{
		AttachWeapon();
		return;
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

/** replicated: weapon attachment changed */
simulated function AttachWeapon()
{
	// weapon attachment is new or been destroyed
	if(WeaponAttachment == none || WeaponAttachment.Class != WeaponAttachmentClass)
	{
		// detach current attachment if it exists
		if(WeaponAttachment != none)
		{
			WeaponAttachment.DetachFrom(Mesh);
			WeaponAttachment.Destroy();
		}

		// spawn weapon attachment
		if(WeaponAttachmentClass != none)
		{
			WeaponAttachment = Spawn(WeaponAttachmentClass, self);
			WeaponAttachment.Instigator = self;
		}
		else
		{
			// destroy weapon attachment
			WeaponAttachment = none;
		}

		// attach weapon attachment
		if(WeaponAttachment != none)
		{
			WeaponAttachment.AttachTo(self);
			WeaponAttachment.ChangeVisibility(false);
		}
	}
}

/** overloaded: play dying */
simulated function PlayDying(class<DamageType> DamageType, vector HitLocation)
{
	// destory weapon attachment
	WeaponAttachmentClass = none;
	AttachWeapon();

	super.PlayDying(DamageType, HitLocation);
}

/** overloaded: weapon fired */
simulated function WeaponFired(Weapon InWeapon, bool bVieReplication, optional vector HitLocation)
{
	super.WeaponFired(InWeapon, bVieReplication, HitLocation);

	// play impact effects
	if(WeaponAttachment != none)
	{
		if(HitLocation != vect(0,0,0) && (WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_Standalone || bVieReplication))
		{
			//PlayImpactEffects(HitLocation);
			WeaponAttachment.PlayImpactEffects(HitLocation);
		}
	}
}

/** overloaded: process view rotation */
simulated function ProcessViewRotation(float DeltaTime, out rotator out_ViewRotation, out rotator out_DeltaRot)
{
	if(Weapon != none)
	{
		TWeapon(Weapon).ProcessViewRotation(DeltaTime, out_ViewRotation, out_DeltaRot);
	}

	out_ViewRotation += out_DeltaRot;
	out_DeltaRot = rot(0,0,0);

	if(PlayerController(Controller) != none)
	{
		out_ViewRotation = PlayerController(Controller).LimitViewRotation(out_ViewRotation, ViewPitchMin, ViewPitchMax);
	}
}


/** set movement physics */
function SetMovementPhysics()
{
	if(PhysicsVolume.bWaterVolume)
	{
		SetPhysics(PHYS_Swimming);
	}
	else
	{
		if(Physics != PHYS_Falling)
		{
			SetPhysics(PHYS_Falling);
		}
	}
}

function tick(float DeltaTime)
{
    super.tick(DeltaTime);
    
    if(useStamina)
    {
        stamina = stamina - 1;
        if(stamina <= 0)
        {
            endSprint();
        }
    }else if (!useStamina && stamina < 100)
    {
        stamina = stamina + 0.5;
    }

}

/** changes the walking speed, if multiplier is greater than 1, speed increases, if it is a decimal, speed decreases*/
simulated function changeWalkSpeed(float multiplier)
{
    GroundSpeed *= multiplier;
}

exec function sprint()
{
    if (stamina >0 && useStamina == false)
    {
       changeWalkSpeed(2);
       useStamina = true;
       PlayerController(Controller).ClientMessage("sprint stamina: ");
       PlayerController(Controller).ClientMessage(stamina);
    }
}

exec function endSprint()
{
    if(useStamina)
    {
        changeWalkSpeed(0.5);
        useStamina = false;
        canWalk = false;
        PlayerController(Controller).ClientMessage("endSprint stamina: ");
        PlayerController(Controller).ClientMessage(stamina);
    }

}

/** overloaded: start crouch */
simulated event StartCrouch(float HeightAdjust)
{
        PlayerController(Controller).ClientMessage("StartCrouch");
        changeWalkSpeed(0.5);
	//SetBaseEyeHeight();
	BaseEyeHeight = CrouchEyeHeight;
	EyeHeight += HeightAdjust;
	CrouchMeshZOffset = HeightAdjust;

	if(Mesh != none)
	{
		Mesh.SetTranslation(Mesh.Translation + vect(0,0,1) * HeightAdjust);
	}
}

/** overloaded: end crouch */
simulated event EndCrouch(float HeightAdjust)
{
        PlayerController(Controller).ClientMessage("EndCrouch");
        changeWalkSpeed(2);
	//SetBaseEyeHeight();
	BaseEyeHeight = default.BaseEyeHeight;
	EyeHeight -= HeightAdjust;
	CrouchMeshZOffset = 0.0;

	if(Mesh != none)
	{
		Mesh.SetTranslation(Mesh.Translation - vect(0,0,1) * HeightAdjust);
	}
}

/** overloaded: force crouch height */
simulated function SetBaseEyeHeight()
{
	if(!bIsCrouched)
	{
		BaseEyeHeight = default.BaseEyeHeight;
	}
	else
	{
		BaseEyeHeight = CrouchEyeHeight;
	}
}

/** overloaded: interpolate eye height */
event UpdateEyeHeight(float DeltaTime)
{
	if(bTearOff)
	{
		EyeHeight = default.BaseEyeHeight;
		bUpdateEyeHeight = false;
		return;
	}

	EyeHeight = FInterpTo(EyeHeight, BaseEyeHeight, DeltaTime, 10.0);
}

/** overloaded: get pawn view location */
simulated event vector GetPawnViewLocation()
{
	if(bUpdateEyeHeight)
	{
		return Location + EyeHeight * vect(0,0,1);
	}
	else
	{
		return Location + BaseEyeHeight * vect(0,0,1);
	}
}

/** overloaded: become view target and begin eye height interp */
simulated event BecomeViewTarget(PlayerController PC)
{
	super.BecomeViewTarget(PC);

	if(LocalPlayer(PC.Player) != none)
	{
		bUpdateEyeHeight = true;
	}
}

/** current eye height */
simulated function float GetEyeHeight()
{
	if(!IsLocallyControlled())
	{
		return baseEyeHeight;
	}
	else
	{
		return EyeHeight;
	}
}

/** add default inventory */
function AddDefualtInventory()
{
	local class<Inventory> InvClass;
	local Inventory Inv;

	foreach DefaultInventory(InvClass)
	{
		Inv = FindInventoryType(InvClass);

		if(Inv == none)
		{
			CreateInventory(InvClass, Weapon != none);
		}
	}
}

/** get weapon list */
simulated function GetWeaponList(out array<TWeapon> WeaponList, optional bool bNoEmpty)
{
	TInventoryManager(InvManager).GetWeaponList(WeaponList, bNoEmpty);
}

/** switch weapon */
simulated function SwitchWeapon(byte NewGroup)
{
	if (TInventoryManager(InvManager) != None)
	{
		TInventoryManager(InvManager).SwitchWeapon(NewGroup);
	}
}

// get pawn health
function int getHealth()
{
        return health;
}

// set pawn health
function setHealth(int value)
{
        if (value <= 100)
                health = value;
        else
                health = 100;
}

// get pawn armor
function int getArmor()
{
        return armor;
}

// set pawn armor
function setArmor(int value)
{
        if (value <= 100)
                armor = value;
        else
                armor = 100;
}

defaultproperties
{
	InventoryManagerClass = class'TGame.TInventoryManager'
	ControllerClass = none

	// default inventory
	DefaultInventory(0) = class'TGame.TWeap_Pistol_Generic'

	// mesh
	begin object class=SkeletalMeshComponent name=SkelMesh
		BlockZeroExtent = true
		CollideActors = true
		BlockRigidBody = true
		RBChannel = RBCC_Pawn
		RBCollideWithChannels = (Default=true, Pawn=true, DeadPawn=false, BlockingVolume=true, EffectPhysics=true, FracturedMeshPart=true, SoftBody=true)
		MinDistFactorForKinematicUpdate = 0.2
		bAcceptsStaticDecals = false
		bAcceptsDynamicDecals = false
		bUpdateSkelWhenNotRendered = true
		bIgnoreControllersWhenNotRendered = false
		bTickAnimNodesWhenNotRendered = true
		bUseOnePassLightingOnTranslucency = true
		bPerBoneMotionBlur = true
		bHasPhysicsAssetInstance = true
		bOwnerNoSee = true
	end object
	Mesh = SkelMesh
	Components.Add(SkelMesh)
	
	// collision cylinder
	begin object name=CollisionCylinder
		CollisionHeight = +0044.000000
		CollisionRadius = +0021.000000
		BlockZeroExtent = false
	end object
	CylinderComponent = CollisionCylinder
	
	// pawn settings
	CrouchHeight = +00.29.000000
	CrouchRadius = +00.34.000000
	EyeHeight = +0038.000000
	CrouchEyeHeight = +0023.000000
	BaseEyeHeight = +0038.000000
	
	// movement
	GroundSpeed = 880.0
	WalkingPct = 0.4
	CrouchedPct = 0.4
	JumpZ = 322.0
	AccelRate = 2048.0
	stamina = 100;
	useStamina = false;
	canWalk = false;
	
	// settings
	bBlocksNavigation = true
	bNoEncroachCheck = true
	bCanStepUpOn = false
	bCanStrafe = true
	bCanCrouch = true
	bCanClimbLadders = true
	bCanPickupInventory = true
	bCanWalkOffLedges = true
	bCanSwim = true
	
	// camera
	ViewPitchMin = -16000
	ViewPitchMax = 14000
	
	health = 50
	armor = 0
}
