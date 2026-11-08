local stats = {
    { id = "astucia", name = "Astucia", color = { 0.45, 0.40, 0.90 } },
    { id = "encanto", name = "Encanto", color = { 0.90, 0.30, 0.50 } },
    { id = "furia",   name = "Furia",   color = { 1.00, 0.55, 0.15 } },
}

for _, stat in ipairs(stats) do
    stats[stat.id] = stat
end

return stats
