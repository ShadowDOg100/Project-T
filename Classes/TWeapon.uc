class TWeapon extends UDKWeapon
	dependson(TPlayerController)
	config(Weapon)
	abstract;

var ParticleSystem			MuzzleFlashPSCTemplate, MuzzleFlashAltPSCTemplate;
var bool					bShowAltMuzzlePSCWhenWeaponHidden;
var bool					bMuzzleFlashPSCLoops;
var UTParticleSystemComponent	MuzzleFlashPSC;
var	UDKExplosionLight		MuzzleFlashLight;
var class<UDKExplosionLight> MuzzleFlashLightClass;
var name					MuzzleFlashSocket;
var bool					bMuzzleFlashAttached;
var color					MuzzleFlashColor;
var() float					MuzzleFlashDuration;


//            Zoom variables
/** Zoom minimum time, from UT3 Sniper Rifle*/
var bool bAbortZoom;
/** Are we zoomed */
enum EZoomState
{
	ZST_NotZoomed,
	ZST_ZoomingOut,
	ZST_ZoomingIn,
	ZST_Zoomed,
};


var int InventorySlot;
var int WeaponSubClass;

var class<TWeaponAttachment> 	AttachmentClass;

var array<name> EffectSockets;

var(Sounds)	array<SoundCue>	WeaponFireSnd;
var(Sounds) SoundCue 	WeaponEquipSnd;
var(Sounds) SoundCue 	WeaponPutDownSnd;

var UIRoot.TextureCoordinates CrossHairCoordinates;

var array<CameraAnim> FireCameraAnim;
 
var int ClipCount;

/** Max ammo count */
var int MaxAmmoCount;

/** Max clip count */
var int MaxClipCount;

/** Holds the amount of ammo used for a given shot */
var array<int> ShotCost;

/** Offset from view center */
var(FirstPerson) vector PlayerViewOffset; 

/** Zoom stuff */
var() vector IronsightViewOffset;
var() float AimingMeshFOV;
var() float DefaultMeshFOV;
var float CurrentMeshFOV;
var float DesiredMeshFOV;
var(Animations) name ArmAimAnim;
var(Animations) name ArmAimIdlAnim;
var(Animations) name ArmAimFireAnim;
var float ArmAimAnimRate;
var float ArmAimIdleAnimRate;
var float ArmAimFireAnimRate;
var bool bIsAiming;
var() float AimingFOV;
var bool bAimingDelay;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
}

simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'AmmoCount' )
	{
		if ( !HasAnyAmmo() )
		{	
			WeaponEmpty();
		}
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated function int GetAmmoCount()
{
	return AmmoCount;
}

simulated function int GetClipCount()
{
	return ClipCount;
}
 
function ConsumeAmmo( byte FireModeNum )
{
	// Subtract the Ammo
	AddAmmo(-ShotCost[FireModeNum]);
}

simulated function bool EnableFriendlyWarningCrosshair()
{
	return true;
}

simulated function vector InstantFireEndTrace(vector StartTrace)
{
	return StartTrace + vector(GetAdjustedAim(StartTrace)) * GetTraceRange();
}

simulated function vector InstantFireStartTrace()
{
	return Instigator.GetWeaponStartTraceLocation();
}

simulated function FireAmmunition()
{
   // Use ammunition to fire
   ConsumeAmmo( CurrentFireMode );

   // Handle the different fire types
   switch( WeaponFireTypes[CurrentFireMode] )
   {
		case EWFT_InstantHit:
			InstantFire();
			break;

		case EWFT_Projectile:
			ProjectileFire();
			break;

		case EWFT_Custom:
			CustomFire();
			break;
   }
}

/**
 * This function is used to add ammo back to a weapon.&nbsp; It's called from the Inventory Manager
 */
function int AddAmmo( int Amount )
{
	ClipCount = Clamp(ClipCount + Amount,0,MaxClipCount);
	return ClipCount;
}

function int AddOtherAmmo(int Amount )
{
	AmmoCount = Clamp(AmmoCount + Amount,0,MaxAmmoCount);
	return AmmoCount;
}

function setAmmo(int ammo)
{
	AmmoCount = ammo;
}

function setClip(int clip)
{
	ClipCount = clip;
}

/**
 * Returns true if the ammo is maxed out
 */
simulated function bool AmmoMaxed(int mode)
{
	return (AmmoCount >= MaxAmmoCount);
}

simulated function bool HasAmmo( byte FireModeNum, optional int Amount )
{
	if (Amount==0)
		return (ClipCount >= ShotCost[FireModeNum]);
	else
		return ( ClipCount >= Amount );
}

/**
 * returns true if this weapon has any ammo
 */
simulated function bool HasAnyAmmo()
{
	return ( ( AmmoCount > 0 ) || (ShotCost[0]==0 && ShotCost[1]==0) );
}

/**
 * This function retuns how much of the clip is empty.
 */
simulated function float DesireAmmo(bool bDetour)
{
	return (1.f - float(ClipCount)/MaxClipCount);
}

/**
 * Returns true if the current ammo count is less than the default ammo count
 */
simulated function bool NeedAmmo()
{
	return ( AmmoCount < Default.AmmoCount );
}


simulated function Loaded(optional bool bUseWeaponMax)
{
	if (bUseWeaponMax)
		AmmoCount = MaxAmmoCount;
	else
		AmmoCount = 999;
	ClipCount = MaxClipCount;
}

/**
 * Called when the weapon runs out of ammo during firing
 */
simulated function WeaponEmpty()
{
	// If we were firing, stop
	if ( IsFiring() )
	{
		GotoState('Active');
	}

	if ( Instigator != none && Instigator.IsLocallyControlled() )
	{
		Instigator.InvManager.SwitchToBestWeapon( true );
	}
}


function PrintScreenDebug(string debugText)
{
	local PlayerController PC;
	PC = PlayerController(Pawn(Owner).Controller);
	if (PC != None)
		PC.ClientMessage("TWeapon: " $ debugText);
}

simulated function AttachWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName )
{
	local TPawn TP;

	TP = TPawn(Instigator);
	PrintScreenDebug("Attaching Weapon");
	// Attach 1st Person Muzzle Flashes, etc,
	if ( Instigator.IsFirstPerson() )
	{
		AttachComponent(Mesh);
		EnsureWeaponOverlayComponentLast();
		SetHidden(False);
		Mesh.SetLightEnvironment(TP.LightEnvironment);
		PrintScreenDebug("First Person Weapon Attached");
	}
	else
	{
		SetHidden(True);
		if (TP != None)
		{
			Mesh.SetLightEnvironment(TP.LightEnvironment);
		}
	}
	//SetSkin(TPawn(Instigator).ReplicatedBodyMaterial);
}

simulated event SetPosition(UDKPawn Holder)
{
	local vector DrawOffset, ViewOffset, FinalLocation;
	local rotator NewRotation, FinalRotation, SpecRotation;
	local TPlayerController PC;
	local vector2D ViewportSize;
	local bool bIsWideScreen;
	local vector SpecViewLoc;
    local float theta;
    local float z;
    local float x;
    local float y;
    local float xy;
        
        //y = 1000;

	if ( !Holder.IsFirstPerson() )
		return;

	Mesh.SetHidden(False);

	foreach LocalPlayerControllers(class'TPlayerController', PC)
	{
		LocalPlayer(PC.Player).ViewportClient.GetViewportSize(ViewportSize);
		break;
	}
	bIsWideScreen = (ViewportSize.Y > 0.f) && (ViewportSize.X/ViewportSize.Y > 1.7);

	Mesh.SetScale3D(default.Mesh.Scale3D);
	Mesh.SetRotation(default.Mesh.Rotation);

	ViewOffset = PlayerViewOffset;

	// Calculate the draw offset
	if ( Holder.Controller == None )
	{


			PC.GetPlayerViewPoint(SpecViewLoc, SpecRotation);
			DrawOffset = ViewOffset >> SpecRotation;
			//DrawOffset += UTPawn(Holder).WeaponBob(BobDamping, JumpDamping);
			FinalLocation = SpecViewLoc + DrawOffset;
			SetLocation(FinalLocation);
			SetBase(Holder);

			// Add some rotation leading
			//SpecRotation.Yaw = LagRot(SpecRotation.Yaw & 65535, LastRotation.Yaw & 65535, MaxYawLag, 0);
			//SpecRotation.Pitch = LagRot(SpecRotation.Pitch & 65535, LastRotation.Pitch & 65535, MaxPitchLag, 1);
			//LastRotUpdate = WorldInfo.TimeSeconds;
			//LastRotation = SpecRotation;

			if ( bIsWideScreen )
			{
				//SpecRotation += WidescreenRotationOffset;
			}
			SetRotation(SpecRotation);
			return;
	}
	else
	{

		DrawOffset.Z = TPawn(Holder).GetEyeHeight();
		//DrawOffset += TPawn(Holder).WeaponBob(BobDamping, JumpDamping);

		if ( TPlayerController(Holder.Controller) != None )
		{
			DrawOffset += TPlayerController(Holder.Controller).ShakeOffset >> Holder.Controller.Rotation;
		}

		DrawOffset = DrawOffset + ( ViewOffset >> Holder.Controller.Rotation );
	}

	// Adjust it in the world
	FinalLocation = Holder.Location + DrawOffset;
	SetLocation(FinalLocation);
	SetBase(Holder);

	NewRotation = (Holder.Controller == None) ? Holder.GetBaseAimRotation() : Holder.Controller.Rotation;

	// Add some rotation leading
	//if (Holder.Controller != None)
	//{
	//&nbsp;&nbsp; &nbsp;FinalRotation.Yaw = LagRot(NewRotation.Yaw & 65535, LastRotation.Yaw & 65535, MaxYawLag, 0);
	//&nbsp;&nbsp; &nbsp;FinalRotation.Pitch = LagRot(NewRotation.Pitch & 65535, LastRotation.Pitch & 65535, MaxPitchLag, 1);
	//&nbsp;&nbsp; &nbsp;FinalRotation.Roll = NewRotation.Roll;
	//}
	//else
	//{
	FinalRotation = NewRotation;
	//}
	//LastRotUpdate = WorldInfo.TimeSeconds;
	//LastRotation = NewRotation;

	if ( bIsWideScreen )
	{
		//FinalRotation += WidescreenRotationOffset;
	}
	SetRotation(FinalRotation);
}

/**
 * Returns true if we are currently zoomed
 */
simulated function EZoomState GetZoomedState()
{
	local PlayerController PC;
	PC = PlayerController(Instigator.Controller);
	if ( PC != none && PC.GetFOVAngle() != PC.DefaultFOV )
	{
		if ( PC.GetFOVAngle() == PC.DesiredFOV )
		{
			return ZST_Zoomed;
		}

		return ( PC.GetFOVAngle() < PC.DesiredFOV ) ? ZST_ZoomingOut : ZST_ZoomingIn;
	}
	return ZST_NotZoomed;
}

simulated function RaiseWeapon()
{
    if(IsInState('Inactive'))
    {
        return;
    }

    if(IsInState('WeaponReloading') || IsTimerActive('ReloadWeapon') || IsTimerActive('TimeReload'))
    {
        bAimingDelay = true;
        return;
    }

    if(IsTimerActive('PlayIdleAnimation')) ClearTimer('PlayerIdleAnimation');

    if(IsTimerActive('TimeWeaponRaising')) ClearTimer('TimeWeaponRaising');

    if(IsTimerActive('TimeWeaponLowering')) ClearTimer('TimWeaponLowering');

    bAmingDelay = true;

    if(IsPlayingAnim(ArmAimFireAnim))
    {
        SetTimer(GetAnimTimeLeft() + 0.01, false, 'PlayerIdleAnimation');
    }
    else if(IsPlayingAnim(ArmFireAnim))
    {
        SetTimer(GetAnimTimeLeft() + 0.01, false, 'TimeWeaponRaising');
    }
    else
    {
        TimeWeaponRaising();
    }
}

simulated function LowerWeapon()
{
    if(IsInState('Inactive'))
    {
        return;
    }

    if(IsInState('WeaponReloading') || IsTimerActive('ReloadWeapon') || IsTimerActive('TimeReload'))
    {
        bAmingDelay = true;
    }

    if(IsTimerActive('PlayIdleAnimation')) ClearTimer('PlayerIdleAnimation');

    if(IsTimerActive('TimeWeaponRaising')) ClearTimer('TimeWeaponRaising');

    if(IsTimerActive('TimeWeaponLowering')) ClearTimer('TimWeaponLowering');

    bAmingDelay = true;

    if(IsPlayingAnim(ArmAimFireAnim))
    {
        SetTimer(GetAnimTimeLeft() + 0.01, falsse, 'TimeWeaponLowering');
    }
    else if(IsPlayingAnim(ArmFireAnim))
    {
        SetTimer(GetAnimTimeLeft() + 0.01, false, 'PlayIdleAnimation');
    }
    else
    {
        TimeWeaponLowering();
    }
}

simulated function TimeWeaponRaising()
{
    local float AimTime;
    local float TimeDiff;

    if(IsPlayingAnim(ArmAimAnim))
    {
        TimeDiff = GetAnimTimeLeft();
        AnimTime = PlayWeaponAnim(ArmAimAnim, ArmAimAnimRate, false, , TimDiff);
    }
    else if(IsPlayingAnim(ArmAimFireAnim))
    {
        AnimTime = GetAnimTimeLeft() + 0.01;
    }
    else
    {
        AnimTime = PlayWeaponAnim(ArmAimAnim, ArmAimAnimRate, false);
    }

    bIsAiming = true;
    ArmIdleAnims[0] = ArmAimIdleAnim;
    ArmFireAnim = ArmAimFireAnim;
    ArmViewOffset = IronsightViewOffset;
    SetFOV(AimingFOV);
    SetMeshFOV(AimingMeshFOV);
    SetTimer(AimTime, false, 'PlayIdleAnimation');
}

simulated function TimeWeaponLowering()
{
    local float AimTime;
    local float TimeDiff;

    if(IsPlayingAnim(ArmAimAnim))
    {
        TimeDiff = GetAnimTimeLeft();
        AnimTime = PlayWeaponAnim(ArmAimAnim, -ArmAimAnimRate, false, , TimDiff);
    }
    else if(IsPlayingAnim(ArmAimFireAnim))
    {
        AnimTime = GetAnimTimeLeft() + 0.01;
    }
    else
    {
        AnimTime = PlayWeaponAnim(ArmAimAnim, -ArmAimAnimRate, false);
    }

    bIsAiming = false;
    ArmIdleAnims[0] = default.ArmIdleAnims[0];
    ArmFireAnim = default.ArmFirAnim;
    ArmViewOffset = default.ArmViewOffset;
    SetFOV();
    SetMeshFOV(DefaultMeshFOV);
    SetTimer(Abs(AimTime), false, 'PlayIdleAnimation');
}

simulated function SetFOV(optional float NewFOV)
{
    local TPlayerController PC;

    if((Instigator != none) && Instigator.Controller != none)
    {
        PC = TPlayerController(Instigator.Controller);
        if(NewFOV > 0.0)
        {
            PC.StartZoomNonlinear(NewFOV, 10.0f);
        }
        else
        {
            PC.EndZoomNonlinear(10.0f);
        }
    }
}

simulated function SetMeshFOV(float NewFOV, optional bool bForceFOV)
{
    if((Mesh != none) && Mesh.bAttached)
    {
        DesiredMeshFOV = NewFOV;
    }
}

simulated function AdjustMeshFOV(float DeltaTime)
{
    if((Mesh != none) && Mesh.bAttached)
    {
        if(CurrentMeshFOV != DesiredMeshFOV)
        {
            CurrentMeshFOV = FInterpTo(CurrentMeshFOV, DesiredMeshFOV, DeltaTime, 10.0f);
            UDKSkeletalMeshComponent(Mesh).SetFOV(CurrentMeshFOV);

            if((Firearm != none) && Firearm.Mesh != none)
            {
                UDKSkeletalMeshComponent(Firearm.Mesh).SetFOV(CurrentMeshFOV);
            }
        }
    }
}

simulated event Tick(float DeltaTime)
{
    super.Tick(DeltaTime);

    AdjustMeshFOV(DeltaTime);
}

simulated function PlayWeaponAnimation(name Sequence, float fDesiredDuration, optional bool bLoop, optional SkeletalMeshComponent SkelMesh)
{
	if (Mesh != None && Mesh.bAttached)
	{
		Super.PlayWeaponAnimation(Sequence, fDesiredDuration, bLoop, SkelMesh);
	}
}

simulated state WeaponEquipping
{
	simulated event BeginState(Name PreviousStateName)
	{
		PrintScreenDebug("Weapon Equipping");
		AttachWeaponTo(Instigator.Mesh);
		Super.BeginState(PreviousStateName);
	}
}

simulated state Active
{
	simulated event BeginState(Name PreviousStateName)
	{
		PrintScreenDebug("Active");
		Super.BeginState(PreviousStateName);
	}
}

simulated state WeaponFiring
{
	simulated event BeginState(Name PreviousStateName)
	{
		PrintScreenDebug("Firing");
		Super.BeginState(PreviousStateName);
	}

	/**
	* We override BeginFire() so that we can check for zooming and/or empty weapons
	*/

	simulated function BeginFire( Byte FireModeNum )
	{
		// No Ammo, then do a quick exit.
		if( !HasAmmo(FireModeNum) )
		{
			WeaponEmpty();
			return;
		}
		Global.BeginFire(FireModeNum);
	}
}

simulated function AttachMuzzleFlash()
{
	local SkeletalMeshComponent SKMesh;

	// Attach the Muzzle Flash
	bMuzzleFlashAttached = true;
	SKMesh = SkeletalMeshComponent(Mesh);
	if (  SKMesh != none )
	{
		if ( (MuzzleFlashPSCTemplate != none) || (MuzzleFlashAltPSCTemplate != none) )
		{
			MuzzleFlashPSC = new(Outer) class'UTParticleSystemComponent';
			MuzzleFlashPSC.bAutoActivate = false;
			MuzzleFlashPSC.SetDepthPriorityGroup(SDPG_Foreground);
			MuzzleFlashPSC.SetFOV(UDKSkeletalMeshComponent(SKMesh).FOV);
			SKMesh.AttachComponentToSocket(MuzzleFlashPSC, MuzzleFlashSocket);
		}
	}
}

simulated function DetachMuzzleFlash()
{
	local SkeletalMeshComponent SKMesh;

	bMuzzleFlashAttached = false;
	SKMesh = SkeletalMeshComponent(Mesh);
	if (  SKMesh != none )
	{
		if (MuzzleFlashPSC != none)
			SKMesh.DetachComponent( MuzzleFlashPSC );
	}
	MuzzleFlashPSC = None;
}

simulated event CauseMuzzleFlashLight()
{
	// don't do muzzle flashes when running too slow, except on mobile, where we need it to show off dynamic lighting
	if ( WorldInfo.bDropDetail && !WorldInfo.IsConsoleBuild(CONSOLE_Mobile) )
	{
		return;
	}

	if ( MuzzleFlashLight != None )
	{
		MuzzleFlashLight.ResetLight();
	}
	else if ( MuzzleFlashLightClass != None )
	{
		MuzzleFlashLight = new(Outer) MuzzleFlashLightClass;
		SkeletalMeshComponent(Mesh).AttachComponentToSocket(MuzzleFlashLight,MuzzleFlashSocket);
	}
}

simulated function EWeaponHand GetHand()
{
	return HAND_Right;
}

simulated event CauseMuzzleFlash()
{
	local TPawn P;
	local ParticleSystem MuzzleTemplate;

	if ( WorldInfo.NetMode != NM_Client )
	{
		P = TPawn(Instigator);
		if ( (P == None) || !P.bUpdateEyeHeight )
		{
			return;
		}
	}

	CauseMuzzleFlashLight();

	if (GetHand() != HAND_Hidden || (bShowAltMuzzlePSCWhenWeaponHidden && Instigator != None && Instigator.FiringMode == 1 && MuzzleFlashAltPSCTemplate != None))
	{
		if ( !bMuzzleFlashAttached )
		{
			AttachMuzzleFlash();
		}
		if (MuzzleFlashPSC != None)
		{
			if (!bMuzzleFlashPSCLoops || (!MuzzleFlashPSC.bIsActive || MuzzleFlashPSC.bWasDeactivated))
			{
				if (Instigator != None && Instigator.FiringMode == 1 && MuzzleFlashAltPSCTemplate != None)
				{
					MuzzleTemplate = MuzzleFlashAltPSCTemplate;

					// Option to not hide alt muzzle
					MuzzleFlashPSC.SetIgnoreOwnerHidden(bShowAltMuzzlePSCWhenWeaponHidden);
				}
				else if (MuzzleFlashPSCTemplate != None)
				{
					MuzzleTemplate = MuzzleFlashPSCTemplate;
				}
				if (MuzzleTemplate != MuzzleFlashPSC.Template)
				{
					MuzzleFlashPSC.SetTemplate(MuzzleTemplate);
				}
				SetMuzzleFlashParams(MuzzleFlashPSC);
				MuzzleFlashPSC.ActivateSystem();
			}
		}

		// Set when to turn it off.
		SetTimer(MuzzleFlashDuration,false,'MuzzleFlashTimer');
	}
}

exec function Reload()
{
	if(ClipCount < MaxClipCount)
	{
		if(AmmoCount > (MaxClipCount - ClipCount))
		{
			AmmoCount = AmmoCount - (MaxClipCount - ClipCount);
			ClipCount = MaxClipCount;
		}
		else
		{
			ClipCount = ClipCount + AmmoCount;
			AmmoCount = 0;
		}
	}
}

simulated function SetMuzzleFlashParams(ParticleSystemComponent PSC)
{
	PSC.SetColorParameter('MuzzleFlashColor', MuzzleFlashColor);
	PSC.SetVectorParameter('MFlashScale',Vect(0.5,0.5,0.5));
}

simulated function vector GetEffectLocation()
{
	local vector SocketLocation;

	if (GetHand() == HAND_Hidden)
	{
		SocketLocation = Instigator.Location;
	}
	else if (SkeletalMeshComponent(Mesh) != None && EffectSockets[CurrentFireMode] != '')
	{
		if (!SkeletalMeshComponent(Mesh).GetSocketWorldLocationAndrotation(EffectSockets[CurrentFireMode], SocketLocation))
		{
			SocketLocation = Location;
		}
	}
	else if (Mesh != None)
	{
		SocketLocation = Mesh.Bounds.Origin + (vect(45,0,0) >> Rotation);
	}
	else
	{
		SocketLocation = Location;
	}

 	return SocketLocation;
}

function int GetInventorySlot()
{
	return InventorySlot;
}

function int GetWeaponSubClass()
{
	return WeaponSubClass;
}

/**
 * Detach weapon from skeletal mesh
 *
 * @param	SkeletalMeshComponent weapon is attached to.
 */
simulated function DetachWeapon()
{
	local TPawn P;

	DetachComponent( Mesh );
	if (OverlayMesh != None)
	{
		DetachComponent(OverlayMesh);
	}

	SetSkin(None);

	P = TPawn(Instigator);
	/*if (P != None)
	{
		if (Role == ROLE_Authority && P.CurrentWeaponAttachmentClass == AttachmentClass)
		{
			P.CurrentWeaponAttachmentClass = None;
			if (Instigator.IsLocallyControlled())
			{
				P.WeaponAttachmentChanged();
			}
		}
	}*/

	SetBase(None);
	SetHidden(True);
	DetachMuzzleFlash();
	Mesh.SetLightEnvironment(None);
}

/**
 * Material control
 *
 * @Param 	NewMaterial		The new material to apply or none to clear it
 */
simulated function SetSkin(Material NewMaterial)
{
	local int i,Cnt;

	if ( NewMaterial == None )
	{
		// Clear the materials
		if ( default.Mesh.Materials.Length > 0 )
		{
			Cnt = Default.Mesh.Materials.Length;
			for (i=0;i<Cnt;i++)
			{
				Mesh.SetMaterial( i, Default.Mesh.GetMaterial(i) );
			}
		}
		else if (Mesh.Materials.Length > 0)
		{
			Cnt = Mesh.Materials.Length;
			for ( i=0; i < Cnt; i++ )
			{
				Mesh.SetMaterial(i, none);
			}
		}
	}
	else
	{
		// Set new material
		if ( default.Mesh.Materials.Length > 0 || Mesh.GetNumElements() > 0 )
		{
			Cnt = default.Mesh.Materials.Length > 0 ? default.Mesh.Materials.Length : Mesh.GetNumElements();
			for ( i=0; i < Cnt; i++ )
			{
				Mesh.SetMaterial(i, NewMaterial);
			}
		}
	}
}

defaultproperties
{
	Begin Object Name Class=UDKSkeletalMeshComponent Name=FirstPersonMesh
		DepthPriorityGroup=SDPG_Foreground
		bOnlyOwnerSee=true
		bOverrideAttachmentOwnerVisibility=true
		CastShadow=false
		bAllowAmbientOcclusion=false
	End Object
	Mesh=FirstPersonMesh

	Begin Object Name Class=SkeletalMeshComponent Name=PickupMesh
		bOnlyOwnerSee=false
		CastShadow=false
		bForceDirectLightMap=true
		bCastDynamicShadow=false
		CollideActors=false
		BlockRigidBody=false
		bUseAsOccluder=false
		MaxDrawDistance=6000
		bForceRefPose=1
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bAcceptsStaticDecals=FALSE
		bAcceptsDynamicDecals=FALSE
		bAllowAmbientOcclusion=false
	End Object
	DroppedPickupMesh=PickupMesh
	PickupFactoryMesh=PickupMesh

	MessageClass=class'UTPickupMessage'
	DroppedPickupClass=class'UTDroppedPickup'

	FiringStatesArray(0)=WeaponFiring
	FiringStatesArray(1)=WeaponFiring

	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_InstantHit

	WeaponProjectiles(0)=none
	WeaponProjectiles(1)=none

	FireInterval(0)=+0.5
	FireInterval(1)=+0.5

	Spread(0)=0.0
	Spread(1)=0.0

	ShotCost(0)=1
	ShotCost(1)=1 

	AmmoCount=10
	MaxAmmoCount=10
	
	ClipCount=10
	MaxClipCount=10

	InstantHitDamage(0)=0.0
	InstantHitDamage(1)=0.0
	InstantHitMomentum(0)=0.0
	InstantHitMomentum(1)=0.0
	InstantHitDamageTypes(0)=class'DamageType'
	InstantHitDamageTypes(1)=class'DamageType'
	WeaponRange=22000

	EffectSockets(0)=MuzzleFlashSocket
	EffectSockets(1)=MuzzleFlashSocket
	
	MuzzleFlashDuration=0.33
	
	WeaponFireSnd(0)=none
	WeaponFireSnd(1)=none
	
	MuzzleFlashSocket=MuzzleFlashSocket

	ShouldFireOnRelease(0)=0
	ShouldFireOnRelease(1)=0

	DefaultAnimSpeed=0.9

	EquipTime=+0.45
	PutDownTime=+0.33
	
    IronsightViewOffset = (X=40.0)
    DefaultMeshFOV = 60.0f
    CurrentMeshFOV = 60.0f
    DesiredMeshFOV = 60.0f
    AimingMeshFOV = 30.0f

    ArmAimAnim = 1p_ToAim
    ArmAimIdleAnim = 1p_AimIdle
    ArmAimFireAnim = 1p_AimFire

    ArmAimAnimRate = 1.0
    ArmAimIdleAnimRate = 1.0
    ArmAimFireAnimRate = 1.0

    AimingFOV = 60.0f

	InventorySlot = 0;
	WeaponSubClass = 0;
}
