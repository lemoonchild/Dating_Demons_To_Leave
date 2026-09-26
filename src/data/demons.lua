-- Listado de los demonios que pueden ayudar al jugador a escapar 
--
-- Cada demonio:
--   stat           la estadística que le enseña al jugador cuando le cae bien
--   cards          las cartas que le regala al jugador al cruzar cada umbral de afinidad
--                  (ver src/rules/Affinity.lua), en orden
--   conversations  lo que le dice al jugador

local demons = {
    {
        id = "azazel",
        name = "Azazel",
        title = "Archivista del Limbo",
        stat = "astucia",
        color = { 0.45, 0.4, 0.9 },
        cards = {
            { name = "Mapa Robado", stat = "astucia", power = 2 },
            { name = "Pregunta Trampa", stat = "astucia", power = 3 },
            { name = "Cláusula Oculta", stat = "astucia", power = 5 },
        },
        conversations = {
            {
                line = "¿Otro demonio buscando la salida? Todos preguntan por la puerta. Nadie pregunta por el archivo.",
                options = {
                    { text = "¿Qué guardas en el archivo?", affinity = 2, stat = 1,
                      reaction = "Contratos. Miles. Y cada uno tiene una cláusula de escape... si sabes leer." },
                    { text = "Solo quiero la puerta.", affinity = 0, stat = 0,
                      reaction = "Como todos. Por eso siguen aquí." },
                    { text = "Tus libros huelen a azufre viejo.", affinity = -1, stat = 0,
                      reaction = "Y tú a impaciencia. Vete." },
                },
            },
            {
                line = "El guardián de la primera puerta responde acertijos con acertijos. ¿Sabes por qué?",
                options = {
                    { text = "Porque teme una respuesta directa.", affinity = 2, stat = 1,
                      reaction = "...Nadie lo había dicho en voz alta. Me agradas." },
                    { text = "¿Porque es aburrido?", affinity = 0, stat = 0,
                      reaction = "Eso también, sí." },
                    { text = "Lo golpeo y ya.", affinity = -1, stat = 0,
                      reaction = "Suerte con eso. Muchos lo intentaron." },
                },
            },
            {
                line = "Si te doy lo que sé, ¿qué me darás tú cuando salgas?",
                options = {
                    { text = "Te escribiré. Desde arriba.", affinity = 2, stat = 1,
                      reaction = "Una carta del mundo de arriba... acepto." },
                    { text = "Nada. Es un favor.", affinity = 1, stat = 0,
                      reaction = "Honesto. Poco común aquí abajo." },
                    { text = "Mi alma, obviamente.", affinity = -1, stat = 0,
                      reaction = "Ya tengo demasiadas. Otra respuesta." },
                },
            },
        },
    },
    {
        id = "lilim",
        name = "Lilim",
        title = "Anfitriona del Salón Carmesí",
        stat = "encanto",
        color = { 0.9, 0.3, 0.5 },
        cards = {
            { name = "Sonrisa Afilada", stat = "encanto", power = 2 },
            { name = "Brindis Perverso", stat = "encanto", power = 3 },
            { name = "Promesa Eterna", stat = "encanto", power = 5 },
        },
        conversations = {
            {
                line = "Cariño, nadie entra a mi salón sin un cumplido. Sorpréndeme.",
                options = {
                    { text = "Tus cuernos brillan más que el lago de fuego.", affinity = 2, stat = 1,
                      reaction = "Ohh, tienes lengua de plata. Quédate." },
                    { text = "Bonito salón.", affinity = 0, stat = 0,
                      reaction = "El salón ya lo sabe. Yo pregunté por mí." },
                    { text = "No vine a coquetear.", affinity = -1, stat = 0,
                      reaction = "Entonces viniste al lugar equivocado." },
                },
            },
            {
                line = "Los guardianes son solitarios. Un poco de encanto abre más puertas que una llave.",
                options = {
                    { text = "Enséñame a abrirlas.", affinity = 2, stat = 1,
                      reaction = "Primera lección: mírame a los ojos al mentir." },
                    { text = "Prefiero la llave.", affinity = 0, stat = 0,
                      reaction = "Aburrido, pero práctico." },
                    { text = "Eso es manipulación.", affinity = -1, stat = 0,
                      reaction = "Estamos en el infierno, cielo." },
                },
            },
            {
                line = "Si sales de aquí... ¿te acordarás de mí?",
                options = {
                    { text = "Eres imposible de olvidar.", affinity = 2, stat = 1,
                      reaction = "Lo sé. Pero me gusta oírlo." },
                    { text = "Tal vez.", affinity = 0, stat = 0,
                      reaction = "'Tal vez' es lo que dicen todos antes de irse." },
                    { text = "Quiero olvidar todo esto.", affinity = -1, stat = 0,
                      reaction = "Qué cruel. Me gusta un poco." },
                },
            },
        },
    },
    {
        id = "brasa",
        name = "Brasa",
        title = "Herrera de las Calderas",
        stat = "furia",
        color = { 1.0, 0.55, 0.15 },
        cards = {
            { name = "Puño Candente", stat = "furia", power = 2 },
            { name = "Grito de Fragua", stat = "furia", power = 3 },
            { name = "Martillo del Abismo", stat = "furia", power = 5 },
        },
        conversations = {
            {
                line = "¡Eh, tú! ¿Vas a quedarte mirando o vas a sostener el yunque?",
                options = {
                    { text = "Pásamelo.", affinity = 2, stat = 1,
                      reaction = "¡Ja! Brazos flacos, pero agallas gordas." },
                    { text = "Solo estaba mirando.", affinity = 0, stat = 0,
                      reaction = "Pues mira desde más lejos, que salpica." },
                    { text = "Eso es trabajo de demonios menores.", affinity = -1, stat = 0,
                      reaction = "Entonces eres uno. Largo." },
                },
            },
            {
                line = "Los guardianes solo respetan una cosa: que no te tiemblen las piernas.",
                options = {
                    { text = "Entréname.", affinity = 2, stat = 1,
                      reaction = "Cien golpes al día. Empiezas ahora." },
                    { text = "¿Y si me tiemblan?", affinity = 1, stat = 0,
                      reaction = "Al menos lo admites. Eso ya es valor." },
                    { text = "Yo no necesito respeto.", affinity = -1, stat = 0,
                      reaction = "Necesitas algo. Todos aquí abajo necesitan algo." },
                },
            },
            {
                line = "Forjé la cerradura de la puerta del segundo círculo. ¿Quieres saber su debilidad?",
                options = {
                    { text = "Solo si me la enseñas golpe a golpe.", affinity = 2, stat = 1,
                      reaction = "Así se habla. Agarra el martillo." },
                    { text = "Dímela y ya.", affinity = 0, stat = 0,
                      reaction = "Nada es gratis en la fragua." },
                    { text = "Seguro ni tiene.", affinity = -1, stat = 0,
                      reaction = "Todo lo que se forja se puede romper. Tú incluido." },
                },
            },
        },
    },
}

-- Índice por id, para que los sistemas encuentren un demonio sin recorrer la lista.
for _, demon in ipairs(demons) do
    demons[demon.id] = demon
end

return demons
