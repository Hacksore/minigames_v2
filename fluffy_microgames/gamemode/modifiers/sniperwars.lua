MOD.Name = "Sniperwars Mini"
MOD.RoundTime = 25
MOD.Elimination = true
MOD.SurviveValue = 3

MOD.KillValue = 1

function MOD:Initialize()
    GAMEMODE:Announce("Snipers", "Take Cover!")
end

function MOD:Loadout(ply)
    ply:Give("weapon_mg_sniper")
    ply:Give("weapon_mg_knife")
end