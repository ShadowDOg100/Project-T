/**
 *	TEnemy
 *
 *	Creation date: 12/02/2012 21:12
 *	Copyright 2012, Dominque
 */
class TEnemy extends TActor
placeable;

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class <DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
    if(EventInstigator != none && EventInstigator.PlayerReplicationInfo != none) 
    WorldInfo.Game.ScoreObjective(EventInstigator.PlayerReplicationInfo, 1);
    Destroy();
}



defaultproperties
{
    bBlockActors=True
    bCollideActors=True 
    Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
    bEnabled=TRUE 
    End Object 
    Components.Add(MyLightEnvironment) 
    Begin Object Class=StaticMeshComponent Name=PickupMesh 
    StaticMesh=StaticMesh'UN_SimpleMeshes.TexPropCube_Dup'
    Materials(0)=Material'EditorMaterials.WidgetMaterial_X' 
    LightEnvironment=MyLightEnvironment
    Scale3D=(X=0.25,Y=0.25,Z=0.5)
    End Object
    Components.Add(PickupMesh) 
    Begin Object Class=CylinderComponent Name=CollisionCylinder
    CollisionRadius=32.0 
    CollisionHeight=64.0 
    BlockNonZeroExtent=true
    BlockZeroExtent=true
    BlockActors=true 
    CollideActors=true 
    End Object 
    CollisionComponent=CollisionCylinder
    Components.Add(CollisionCylinder)




}
