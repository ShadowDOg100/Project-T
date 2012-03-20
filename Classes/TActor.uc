/**
 *	TActor
 *
 *	Creation date: 09/02/2012 16:31
 *	Copyright 2012, Dominque
 */
class TActor extends Actor
placeable;

function PostBeginPlay()
{

    `log("Rotation:" @Rotation);

}

defaultproperties
{

    Begin Object Class=SpriteComponent Name=Sprite
    Sprite=Texture2D'EditorResources.S_NavP'
    End Object
    Components.Add(Sprite)

}
