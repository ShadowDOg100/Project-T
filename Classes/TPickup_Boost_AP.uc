class TPickup_Boost_AP extends TPickup_Boost
        placeable;

defaultproperties
{
        Begin Object class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
                bEnabled=TRUE
        End Object
        LightEnvironment=MyLightEnvironment
        Components.Add(MyLightEnvironment)

	Begin Object class=StaticMeshComponent name=Mesh
		StaticMesh=StaticMesh'T.Mesh.Armor'
		LightEnvironment=MyLightEnvironment
	End Object
	Components.Add(Mesh)
        CollisionComponent=Mesh
        CollisionType=COLLIDE_TouchAll

        item = "AP"
        restore = 100
}