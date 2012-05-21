class TPickup_Weapon extends TPickup;

event Touch (Actor Other, PrimitiveComponent OtherComp, Object.Vector HitLocation, Object.Vector HitNormal)
{
        local Pawn P;

        P = Pawn(Other);
        PC = PlayerController(P.Controller);

        if (P != none)
        {
                bTouch = true;
                WorldInfo.Game.BroadCast(Other,"Health Pickup");
                SetTouch(bTouch,,Self,"HP");
        }
}

event UnTouch(Actor Other)
{
        bTouch = false;
        SetTouch(bTouch,,Self,"HP");
}

defaultproperties
{
        item = "WP"
}