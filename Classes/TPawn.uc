class TPawn extends UDKPawn
	config(Game)
	notplaceable;

//The pawn's light environment 
var DynamicLightEnvironmentComponent LightEnvironment;

var float DeathTime;

var float RagdollLifespan;

var AnimNodeSlot FullBodyAnimSlot;
var AnimNodeSlot TopHalfAnimSlot;

var float CameraScale, CurrentCameraScale;

var vector CamOffset;

var bool bStopDeathCamera;

var float CameraZOffset;

var vector OldCameraPosition;

var name WeaponSocket, WeaponSocket2;

simulated event FellOutOfWorld(class<DamageType> dmgType)
{
    super.FellOutOfWorld(DmgType);
    bStopDeathCamera = true;
}

simulated function float GetEyeHeight()
{
	if ( !IsLocallyControlled() )
		return BaseEyeHeight;
	else
		return EyeHeight;
}

simulated function SwitchWeapon(byte NewGroup)
{
	local TPlayerController PC;
	if (TInventoryManager(InvManager) != None)
	{
		TInventoryManager(InvManager).SwitchWeapon(NewGroup);
		PC = TPlayerController(Controller);
		PC.ClientMessage("Pawn Switch");
	}
}

function GiveWeapon(Inventory inv)
{
	if (TInventoryManager(InvManager) != None)
	{
		TInventoryManager(InvManager).AddInventory(inv);
	}
}

simulated function GetWeaponList(out array<TWeapon> WeaponList, optional bool bNoEmpty)
{
	TInventoryManager(InvManager).GetWeaponList(WeaponList, bNoEmpty);
}

function setHeight(float height)
{
	EyeHeight = height;
	SetBaseEyeHeight();
}

defaultproperties
{
	Components.Remove(Sprite)

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bSynthesizeSHLight=TRUE
		bIsCharacterLightEnvironment=TRUE
		bUseBooleanEnvironmentShadowing=FALSE
	End Object
	Components.Add(MyLightEnvironment)
	LightEnvironment=MyLightEnvironment
	
	Begin Object Class=SkeletalMeshComponent Name=WPawnSkeletalMeshComponent
		bCacheAnimSequenceNodes=FALSE
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		bOwnerNoSee=true
		CastShadow=true
		BlockRigidBody=TRUE
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=TRUE
		bUpdateKinematicBonesFromAnimation=true
		bCastDynamicShadow=true
		Translation=(Z=8.0)
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		LightEnvironment=MyLightEnvironment
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=FALSE
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		bHasPhysicsAssetInstance=true
		TickGroup=TG_PreAsyncWork
		MinDistFactorForKinematicUpdate=0.2
		bChartDistanceFactor=true
		//bSkipAllUpdateWhenPhysicsAsleep=TRUE
		RBDominanceGroup=20
		Scale=1.075
		// Nice lighting for hair
		bUseOnePassLightingOnTranslucency=TRUE
		bPerBoneMotionBlur=true
	End Object
	Mesh=WPawnSkeletalMeshComponent
	Components.Add(WPawnSkeletalMeshComponent)
	
	BaseTranslationOffset=6.0

	Begin Object Name=OverlayMeshComponent0 Class=SkeletalMeshComponent
		Scale=1.015
		bAcceptsDynamicDecals=FALSE
		CastShadow=false
		bOwnerNoSee=true
		bUpdateSkelWhenNotRendered=false
		bOverrideAttachmentOwnerVisibility=true
		TickGroup=TG_PostAsyncWork
		bPerBoneMotionBlur=true
	End Object
	OverlayMesh=OverlayMeshComponent0

	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object class=AnimNodeSequence Name=MeshSequenceB
	End Object

	Begin Object Class=UDKSkeletalMeshComponent Name=FirstPersonArms
		PhysicsAsset=None
		FOV=55
		Animations=MeshSequenceA
		DepthPriorityGroup=SDPG_Foreground
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bOnlyOwnerSee=true
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=FALSE
		AbsoluteTranslation=false
		AbsoluteRotation=true
		AbsoluteScale=true
		bSyncActorLocationToRootRigidBody=false
		CastShadow=false
		TickGroup=TG_DuringASyncWork
	End Object
	ArmsMesh[0]=FirstPersonArms

	Begin Object Class=UDKSkeletalMeshComponent Name=FirstPersonArms2
		PhysicsAsset=None
		FOV=55
		Scale3D=(Y=-1.0)
		Animations=MeshSequenceB
		DepthPriorityGroup=SDPG_Foreground
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bOnlyOwnerSee=true
		bOverrideAttachmentOwnerVisibility=true
		HiddenGame=true
		bAcceptsDynamicDecals=FALSE
		AbsoluteTranslation=false
		AbsoluteRotation=true
		AbsoluteScale=true
		bSyncActorLocationToRootRigidBody=false
		CastShadow=false
		TickGroup=TG_DuringASyncWork
	End Object
	ArmsMesh[1]=FirstPersonArms2
	
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0021.000000
		CollisionHeight=+0044.000000
	End Object
	CylinderComponent=CollisionCylinder

	ViewPitchMin=-18000
	ViewPitchMax=18000
	MaxYawAim=7000

	WalkingPct=+0.4
	CrouchedPct=+0.4
	BaseEyeHeight=38.0
	EyeHeight=38.0
	GroundSpeed=440.0
	AirSpeed=440.0
	WaterSpeed=220.0
	AccelRate=2048.0
	JumpZ=322.0
	CrouchHeight=29.0
	CrouchRadius=21.0
	WalkableFloorZ=0.78

	AlwaysRelevantDistanceSquared=+1960000.0
	InventoryManagerClass=class'TInventoryManager'

	MeleeRange=+20.0
	bMuffledHearing=true

	Buoyancy=+000.99000000
	UnderWaterTime=+00020.000000
	bCanStrafe=True
	bCanSwim=true
	RotationRate=(Pitch=20000,Yaw=20000,Roll=20000)
	MaxLeanRoll=2048
	AirControl=+0.35
	bCanCrouch=true
	bCanClimbLadders=True
	bCanPickupInventory=True
	bCanDoubleJump=true
	SightRadius=+12000.0

	MaxMultiJump=1
	MultiJumpRemaining=1
	MultiJumpBoost=-45.0

	MaxStepHeight=26.0
	MaxJumpHeight=49.0

	DamageParameterName=DamageOverlay
	SaturationParameterName=Char_DistSatRangeMultiplier

	TeamBeaconMaxDist=3000.f

	bPhysRigidBodyOutOfWorldCheck=TRUE
	bRunPhysicsWithNoController=true

	ControllerClass=class'UTGame.UTBot'

	LeftFootControlName=LeftFootControl
	RightFootControlName=RightFootControl
	bEnableFootPlacement=true
	MaxFootPlacementDistSquared=56250000.0 // 7500 squared

	CustomGravityScaling=1.0
	SlopeBoostFriction=0.2
	FireRateMultiplier=1.0

	MaxFallSpeed=+1250.0
	AIMaxFallSpeedFactor=1.1 // so bots will accept a little falling damage for shorter routes

	bReplicateRigidBodyLocation=true

	WeaponSocket=WeaponPoint
	WeaponSocket2=DualWeaponPoint
	
	FeignDeathPhysicsBlendOutSpeed=2.0
	TakeHitPhysicsBlendOutSpeed=0.5

	TorsoBoneName=b_Spine2
	FallImpactSound=SoundCue'A_Character_BodyImpacts.BodyImpacts.A_Character_BodyImpact_BodyFall_Cue'
	FallSpeedThreshold=125.0

	SwimmingZOffset=-30.0
	SwimmingZOffsetSpeed=45.0

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveformFall
		Samples(0)=(LeftAmplitude=50,RightAmplitude=40,LeftFunction=WF_Sin90to180,RightFunction=WF_Sin90to180,Duration=0.200)
	End Object

	RagdollLifespan=18.0
	
	CurrentCameraScale=1.0
	CamOffset=(X=4.0,Y=16.0,Z=-13.0)
}

