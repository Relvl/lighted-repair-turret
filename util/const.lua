local variants = { "big-electric-pole", "substation" }
local function rt_remote_present()
    return remote and remote.interfaces.repair_turret and remote.interfaces.repair_turret.add_alt_name
end

return {
    mod_id = "__lighted-repair-turret__",
    rt = "repair-turret",
    rt_mod_id = "__Repair_Turret__",
    -- do Klonan already adds remote support? ;)
    rt_remote_present = false,
    rt_remote_call = function()
        if rt_remote_present() then
            for _, variant in pairs(variants) do
                remote.call("repair_turret", "add_alt_name", "repair-turret-" .. variant)
            end
        end
    end,
    lpp_mod_id = "__LightedPolesPlus__",
    variants = variants,
    -- Переменная локальная в LPP+, копипастим...
    lighted_icon = { icon = "__LightedPolesPlus__/graphics/icons/lighted.png",
        icon_size = 32,
        tint = { r = 1, g = 1, b = 1, a = 0.85 }
    }
}
