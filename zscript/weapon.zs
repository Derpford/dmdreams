Class DMWeapon : Weapon {
    Default {
        Weapon.KickBack 100;
    }

    states {
        Select:
            "####" "#" 1 A_Raise(35);
            Loop;
        
        Deselect:
            "####" "#" 1 A_Lower(35);
            Loop;

        Ready:
            "####" "#" 1;
            Goto Deselect;
        
        Fire:
            "####" "#" 1;
            Goto Deselect;
    }
}