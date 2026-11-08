-- Listado de los demonios que pueden ayudar al jugador a escapar 
--
-- Cada demonio:
--   stat           la estadística que le enseña al jugador cuando le cae bien
--   cards          las cartas que le regala al jugador al cruzar cada umbral de afinidad
--                  (ver src/rules/Affinity.lua), en orden
--   conversations  lo que le dice al jugador. `mood` es la banda de humor en la que
--                  sale (mal / neutral / bien) y `minAffinity` la confianza que pide;
--                  src/rules/Talk.lua elige cuál toca

local demons = {
    {
        id = "azazel",
        name = "Azazel",
        title = "Archivista del Limbo",
        stat = "astucia",
        color = { 0.45, 0.4, 0.9 },
        cards = {
            { name = "Mapa Robado", stat = "astucia", power = 2, rarity = 2,
              effect = "Sabés por dónde no hay guardia." },
            { name = "Pregunta Trampa", stat = "astucia", power = 3, rarity = 2,
              effect = "La respuesta lo compromete haga lo que haga." },
            { name = "Cláusula Oculta", stat = "astucia", power = 5, rarity = 3,
              effect = "Estaba escrito. Nadie lo leyó." },
        },
        conversations = {
            {
                id = "azazel-archivo", mood = "neutral", minAffinity = 0, demand = 1,
                line = "¿Otro demonio buscando la salida? Todos preguntan por la puerta. Nadie pregunta por el archivo.",
                options = {
                    { text = "¿Qué guardas en el archivo?", affinity = 3, stat = 1,
                      reaction = "Contratos. Miles. Y cada uno tiene una cláusula de escape... si sabes leer." },
                    { text = "Solo quiero la puerta.", affinity = 0, stat = 0,
                      reaction = "Como todos. Por eso siguen aquí." },
                    { text = "Tus libros huelen a azufre viejo.", affinity = -1, stat = 0,
                      reaction = "Y tú a impaciencia. Vete." },
                },
            },
            {
                id = "azazel-papel-nuevo", mood = "bien", minAffinity = 0, demand = 1,
                line = "Hoy el archivo huele a papel nuevo. Eso no pasa nunca. Preguntame algo, lo que sea.",
                options = {
                    { text = "¿Qué fue lo primero que archivaste?", affinity = 3, stat = 1,
                      reaction = "Mi propio contrato. Por eso sé que todos tienen grietas." },
                    { text = "¿Papel nuevo es buena señal?", affinity = 1, stat = 0,
                      reaction = "Es rara. Y lo raro, aquí abajo, suele ser bueno." },
                    { text = "Nada, solo pasaba.", affinity = -1, stat = 0,
                      reaction = "Entonces seguí pasando." },
                },
            },
            {
                id = "azazel-expedientes", mood = "mal", minAffinity = 0, demand = 2,
                line = "Hoy no. Perdí tres expedientes y alguien los va a pagar.",
                options = {
                    { text = "Te ayudo a buscarlos.", affinity = 3, stat = 1,
                      reaction = "...Nadie se ofrece. Nunca. Están bajo la escalera. Vení." },
                    { text = "¿Tres? Te hacía más ordenado.", affinity = 1, stat = 0,
                      reaction = "Lo era. Hasta esta mañana." },
                    { text = "Problema tuyo.", affinity = -1, stat = 0,
                      reaction = "Sí. Y ahora el tuyo es irte." },
                },
            },
            {
                id = "azazel-acertijos", mood = "neutral", minAffinity = 7, demand = 2,
                line = "El guardián de la primera puerta responde acertijos con acertijos. ¿Sabes por qué?",
                options = {
                    { text = "Porque teme una respuesta directa.", affinity = 3, stat = 1,
                      reaction = "...Nadie lo había dicho en voz alta. Me agradas." },
                    { text = "¿Porque es aburrido?", affinity = 0, stat = 0,
                      reaction = "Eso también, sí." },
                    { text = "Lo golpeo y ya.", affinity = -1, stat = 0,
                      reaction = "Suerte con eso. Muchos lo intentaron." },
                },
            },
            {
                id = "azazel-promesa-rota", mood = "mal", minAffinity = 7, demand = 3,
                line = "No me mires así. Sé que prometí ayudarte y sé que hoy no sirvo para nada.",
                options = {
                    { text = "Entonces hoy te escucho yo.", affinity = 3, stat = 1,
                      reaction = "...Eso no me lo decía nadie desde hace mil años." },
                    { text = "Puedo volver mañana.", affinity = 1, stat = 0,
                      reaction = "Volvé. Pero volvé de verdad." },
                },
            },
            {
                id = "azazel-deuda", mood = "bien", minAffinity = 13, demand = 3,
                line = "Si te doy lo que sé, ¿qué me darás tú cuando salgas?",
                options = {
                    { text = "Te escribiré. Desde arriba.", affinity = 3, stat = 1,
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
            { name = "Sonrisa Afilada", stat = "encanto", power = 2, rarity = 2,
              effect = "Encantadora hasta que duele." },
            { name = "Brindis Perverso", stat = "encanto", power = 3, rarity = 2,
              effect = "Nadie se niega a un brindis." },
            { name = "Promesa Eterna", stat = "encanto", power = 5, rarity = 3,
              effect = "No pensás cumplirla. Él tampoco." },
        },
        conversations = {
            {
                id = "lilim-cumplido", mood = "neutral", minAffinity = 0, demand = 1,
                line = "Cariño, nadie entra a mi salón sin un cumplido. Sorpréndeme.",
                options = {
                    { text = "Tus cuernos brillan más que el lago de fuego.", affinity = 3, stat = 1,
                      reaction = "Ohh, tienes lengua de plata. Quédate." },
                    { text = "Bonito salón.", affinity = 0, stat = 0,
                      reaction = "El salón ya lo sabe. Yo pregunté por mí." },
                    { text = "No vine a coquetear.", affinity = -1, stat = 0,
                      reaction = "Entonces viniste al lugar equivocado." },
                },
            },
            {
                id = "lilim-salon-alegre", mood = "bien", minAffinity = 0, demand = 1,
                line = "Pasá, pasá. Hoy el salón está insoportablemente alegre y necesito con quién reírme.",
                options = {
                    { text = "¿De quién nos reímos?", affinity = 3, stat = 1,
                      reaction = "De los que todavía creen que se sale por la puerta grande. Sentate." },
                    { text = "¿Siempre está así?", affinity = 1, stat = 0,
                      reaction = "Nunca. Por eso hay que aprovecharlo." },
                    { text = "No vine a reírme.", affinity = -1, stat = 0,
                      reaction = "Qué desperdicio de buen día." },
                },
            },
            {
                id = "lilim-copa-robada", mood = "mal", minAffinity = 0, demand = 2,
                line = "Hoy no estoy para cumplidos. El último que me dijo algo bonito me robó una copa.",
                options = {
                    { text = "Entonces no te digo nada y me quedo.", affinity = 3, stat = 1,
                      reaction = "...Ah. Eso sí es nuevo. Quedate." },
                    { text = "¿Era una copa cara?", affinity = 1, stat = 0,
                      reaction = "Era mía. Eso la hacía cara." },
                    { text = "Yo te habría robado dos.", affinity = -1, stat = 0,
                      reaction = "Y yo te habría cobrado las dos. Fuera." },
                },
            },
            {
                id = "lilim-llaves", mood = "neutral", minAffinity = 7, demand = 2,
                line = "Los guardianes son solitarios. Un poco de encanto abre más puertas que una llave.",
                options = {
                    { text = "Enséñame a abrirlas.", affinity = 3, stat = 1,
                      reaction = "Primera lección: mírame a los ojos al mentir." },
                    { text = "Prefiero la llave.", affinity = 0, stat = 0,
                      reaction = "Aburrido, pero práctico." },
                    { text = "Eso es manipulación.", affinity = -1, stat = 0,
                      reaction = "Estamos en el infierno, cielo." },
                },
            },
            {
                id = "lilim-todos-se-van", mood = "mal", minAffinity = 7, demand = 3,
                line = "¿Sabés lo peor de tener buen humor casi siempre? Que el día que no lo tengo, todos se van.",
                options = {
                    { text = "Yo me quedo igual.", affinity = 3, stat = 1,
                      reaction = "Ya lo noté. Por eso te lo estoy contando." },
                    { text = "Es entendible que se vayan.", affinity = 1, stat = 0,
                      reaction = "Entendible y cobarde son dos cosas distintas." },
                    { text = "Yo también me voy.", affinity = -1, stat = 0,
                      reaction = "Claro. Como todos." },
                },
            },
            {
                id = "lilim-recuerdo", mood = "bien", minAffinity = 13, demand = 3,
                line = "Si sales de aquí... ¿te acordarás de mí?",
                options = {
                    { text = "Eres imposible de olvidar.", affinity = 3, stat = 1,
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
            { name = "Puño Candente", stat = "furia", power = 2, rarity = 2,
              effect = "Deja marca." },
            { name = "Grito de Fragua", stat = "furia", power = 3, rarity = 2,
              effect = "Se oye en todo el círculo." },
            { name = "Martillo del Abismo", stat = "furia", power = 5, rarity = 3,
              effect = "Lo que se forja se puede romper." },
        },
        conversations = {
            {
                id = "brasa-yunque", mood = "neutral", minAffinity = 0, demand = 1,
                line = "¡Eh, tú! ¿Vas a quedarte mirando o vas a sostener el yunque?",
                options = {
                    { text = "Pásamelo.", affinity = 3, stat = 1,
                      reaction = "¡Ja! Brazos flacos, pero agallas gordas." },
                    { text = "Solo estaba mirando.", affinity = 0, stat = 0,
                      reaction = "Pues mira desde más lejos, que salpica." },
                    { text = "Eso es trabajo de demonios menores.", affinity = -1, stat = 0,
                      reaction = "Entonces eres uno. Largo." },
                },
            },
            {
                id = "brasa-buen-fuego", mood = "bien", minAffinity = 0, demand = 1,
                line = "¡Buen día para la fragua! El fuego sale derecho y no me quema las manos. Agarrá algo.",
                options = {
                    { text = "¿Qué estamos haciendo?", affinity = 3, stat = 1,
                      reaction = "Algo que todavía no sé. Así son los días buenos." },
                    { text = "¿Siempre te quema?", affinity = 1, stat = 0,
                      reaction = "Siempre. Hoy no. Por eso grito." },
                    { text = "Paso, gracias.", affinity = -1, stat = 0,
                      reaction = "Pasás mucho, vos." },
                },
            },
            {
                id = "brasa-metal-terco", mood = "mal", minAffinity = 0, demand = 2,
                line = "No te acerques. Hoy el metal no me obedece y yo tampoco.",
                options = {
                    { text = "Entonces golpeo yo y vos mirás.", affinity = 3, stat = 1,
                      reaction = "...Ja. Dale. Pero si lo arruinás te fundo a vos." },
                    { text = "¿Lo dejo para mañana?", affinity = 1, stat = 0,
                      reaction = "Mañana el metal es otro. Pero sí, dejalo." },
                    { text = "Se nota que hoy no servís.", affinity = -1, stat = 0,
                      reaction = "Se nota que no sabés cuándo callarte." },
                },
            },
            {
                id = "brasa-respeto", mood = "neutral", minAffinity = 7, demand = 2,
                line = "Los guardianes solo respetan una cosa: que no te tiemblen las piernas.",
                options = {
                    { text = "Entréname.", affinity = 3, stat = 1,
                      reaction = "Cien golpes al día. Empiezas ahora." },
                    { text = "¿Y si me tiemblan?", affinity = 1, stat = 0,
                      reaction = "Al menos lo admites. Eso ya es valor." },
                    { text = "Yo no necesito respeto.", affinity = -1, stat = 0,
                      reaction = "Necesitas algo. Todos aquí abajo necesitan algo." },
                },
            },
            {
                id = "brasa-te-vas", mood = "mal", minAffinity = 7, demand = 3,
                line = "Te vas a ir y yo voy a seguir acá, golpeando. Eso me tiene de malas, no vos.",
                options = {
                    { text = "Vení conmigo.", affinity = 3, stat = 1,
                      reaction = "...No puedo. Pero gracias por decirlo en voz alta." },
                    { text = "No sé si me voy a ir.", affinity = 1, stat = 0,
                      reaction = "Te vas. Lo veo en cómo mirás la puerta." },
                    { text = "No es mi problema.", affinity = -1, stat = 0,
                      reaction = "No. Nunca lo es." },
                },
            },
            {
                id = "brasa-cerradura", mood = "bien", minAffinity = 13, demand = 3,
                line = "Forjé la cerradura de la puerta del segundo círculo. ¿Quieres saber su debilidad?",
                options = {
                    { text = "Solo si me la enseñas golpe a golpe.", affinity = 3, stat = 1,
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
    for _, conversation in ipairs(demon.conversations) do
        demon.conversations[conversation.id] = conversation
    end
end

return demons
