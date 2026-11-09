local stats = {
    { id = "astucia", name = "Astucia", color = { 0.45, 0.40, 0.90 },
      description = "Lo que valora Azazel. Mejora cómo reacciona a tus respuestas." },
    { id = "encanto", name = "Encanto", color = { 0.90, 0.30, 0.50 },
      description = "Lo que valora Lilim. Mejora cómo reacciona a tus respuestas." },
    { id = "furia",   name = "Furia",   color = { 1.00, 0.55, 0.15 },
      description = "Lo que valora Brasa. Mejora cómo reacciona a tus respuestas." },
}

for _, stat in ipairs(stats) do
    stats[stat.id] = stat
end

return stats
