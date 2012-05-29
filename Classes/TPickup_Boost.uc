class TPickup_Boost extends TPickup
        abstract;

// Player touches pickup actor
event Touch (Actor Other, PrimitiveComponent OtherComp, Object.Vector HitLocation, Object.Vector HitNormal)
{
        local PlayerController PC;

        PC = PlayerController(Pawn(Other).Controller);

        if (PC != none)
        {
                WorldInfo.Game.BroadCast(Player,"Boost item touched");

                switch(item)
                {
                        case "":
                                return;
                        break;

                        case "HP":
                                WorldInfo.Game.BroadCast(Player,"You Gained: "@restore@" Health.");
                                // PlaySound()
                                amount = getHealth() + restore;
                                setHealth(amount);
                        break;
                
                        case "AP":
                                WorldInfo.Game.BroadCast(Player,"You Gained: "@restore@" Armor.");
                                // PlaySound()
                                amount = getArmor() + restore;
                                setArmor(amount);
                        break;
                }
                
                Destroy();
                bTouch = false;
        }
}

// Player untouches pickup actor
event UnTouch(Actor Other)
{
        WorldInfo.Game.BroadCast(Player,"Boost item untouched");

}

defaultproperties
{
        bShowHUD = false;
}