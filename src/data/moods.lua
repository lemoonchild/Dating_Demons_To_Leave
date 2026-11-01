local moods = {
    { id = "radiante",  name = "Radiante",  gain = 1.5,  loss = 0.5, quality =  2, color = { 1.0, 0.85, 0.30 } },
    { id = "receptivo", name = "Receptivo", gain = 1.25, loss = 0.75, quality = 1, color = { 0.45, 0.85, 0.50 } },
    { id = "neutral",   name = "Neutral",   gain = 1.0,  loss = 1.0, quality =  0, color = { 0.70, 0.70, 0.70 } },
    { id = "arisco",    name = "Arisco",    gain = 0.5,  loss = 1.5, quality = -1, color = { 0.90, 0.55, 0.30 } },
    { id = "furioso",   name = "Furioso",   gain = 0.25, loss = 2.0, quality = -2, color = { 0.90, 0.25, 0.25 } },
}

for _, mood in ipairs(moods) do
    moods[mood.id] = mood
end

return moods
