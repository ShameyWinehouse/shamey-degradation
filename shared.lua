function generateWeaponDurabilityDescription(degradationInDecimalOutOfOne)
    return string.format("Durability = %.1f%%", 100.0 - tonumber(degradationInDecimalOutOfOne * 100.0))
end

exports("generateWeaponDurabilityDescription", generateWeaponDurabilityDescription)