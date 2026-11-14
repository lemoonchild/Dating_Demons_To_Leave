local cards = {
    rarities = {
        { id = 1, name = "Común",      color = { 0.70, 0.70, 0.70 } },
        { id = 2, name = "Rara",       color = { 0.45, 0.75, 1.00 } },
        { id = 3, name = "Prohibida",  color = { 1.00, 0.70, 0.25 } },
    },

    astucia = {
        { name = "Nota al Margen",     power = 1, rarity = 1, effect = "Recuerdas un detalle que nadie anotó." },
        { name = "Silencio Calculado", power = 2, rarity = 1, effect = "No respondes, y eso incomoda más." },
        { name = "Expediente Viejo",   power = 3, rarity = 2, effect = "Sabes algo que él preferiría olvidar." },
        { name = "Doble Sentido",      power = 4, rarity = 2, effect = "Una frase, dos salidas." },
        { name = "Letra Pequeña",      power = 6, rarity = 3, effect = "El contrato tenía una grieta y la encontraste." },
    },

    encanto = {
        { name = "Guiño Oportuno",     power = 1, rarity = 1, effect = "Pequeño, pero llega." },
        { name = "Cumplido Medido",    power = 2, rarity = 1, effect = "Justo lo que quería escuchar." },
        { name = "Copa Compartida",    power = 3, rarity = 2, effect = "Nadie discute con un brindis." },
        { name = "Secreto Prestado",   power = 4, rarity = 2, effect = "Le confías algo para que te confíe más." },
        { name = "Última Palabra",     power = 6, rarity = 3, effect = "Te vas antes de que pueda responder." },
    },

    furia = {
        { name = "Mirada Firme",       power = 1, rarity = 1, effect = "No bajas los ojos." },
        { name = "Puerta Golpeada",    power = 2, rarity = 1, effect = "El ruido dice lo que tú no." },
        { name = "Chispa de Fragua",   power = 3, rarity = 2, effect = "Algo se prende y no se apaga." },
        { name = "Grito Contenido",    power = 4, rarity = 2, effect = "Lo que no dices pesa más." },
        { name = "Yunque Partido",     power = 6, rarity = 3, effect = "Rompes lo que se suponía irrompible." },
    },
}

return cards
