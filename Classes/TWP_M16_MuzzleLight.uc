class TWP_M16_MuzzleLight extends UDKExplosionLight;

defaultproperties
{
        HighDetailFrameTime =+ 0.02
        Brightness = 8
        Radius = 96
        LightColor = (R=255,G=255,B=255,A=255)
        
        TimeShifts((StartTime=0.0, Radius=64, Brightness=5, LightColor=(R=240,G=237,B=17,A=255)),(StartTime=0.03,Radius=96,Brightness=8,LightColor=(R=248,G=192,B=12,A=255)),(StartTime=0.05,Radius=64,Brightness=0,LightColor=(R=255,G=150,B=20,A=255)))   
}