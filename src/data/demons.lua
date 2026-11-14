-- Listado de los demonios que pueden ayudar al jugador a escapar
--
-- Cada demonio:
--   stat           la estadística que le enseña al jugador cuando le cae bien
--   cards          las cartas que le regala al jugador al cruzar cada umbral de afinidad
--                  (ver src/rules/Affinity.lua), en orden
--   conversations  lo que le dice al jugador. `mood` es la banda de humor en la que
--                  sale (mal / neutral / bien) y `minAffinity` la confianza que pide (sin él, ninguna);
--                  cada banda es un hilo de su historia que se cuenta en el orden de la lista;
--                  src/rules/Talk.lua elige cuál toca
--   quiet          lo que dice cuando no le toca contar nada en su humor

local demons = {
    {
        id = "azazel",
        name = "Azazel",
        title = "Archivista del Limbo",
        stat = "astucia",
        color = { 0.45, 0.4, 0.9 },
        cards = {
            { name = "Mapa Robado", stat = "astucia", power = 2, rarity = 2,
              effect = "Sabes por dónde no hay guardia." },
            { name = "Pregunta Trampa", stat = "astucia", power = 3, rarity = 2,
              effect = "La respuesta lo compromete haga lo que haga." },
            { name = "Cláusula Oculta", stat = "astucia", power = 5, rarity = 3,
              effect = "Estaba escrito. Nadie lo leyó." },
        },
        quiet = {
            mal = "Hoy no tengo ganas de hablar con nadie. Ni con mis papeles.",
            neutral = "Hoy no hay nada nuevo en los estantes.",
            bien = "Hoy estoy de buenas, pero prefiero ordenar en silencio.",
        },
        conversations = {
            {
                id = "azazel-contrato-perdido", mood = "mal", demand = 2,
                line = "Hoy no. Hace mil años firmé un contrato para salir de aquí. Lo archivé yo mismo. Y no sé dónde.",
                options = {
                    { text = "Le ayudo a buscarlo.", affinity = 3,
                      reaction = "...Nadie se ofrece. Nunca. Empiece por la escalera, yo sigo por el sótano." },
                    { text = "¿Cómo pierde algo que archivó usted mismo?", affinity = 1,
                      reaction = "Archivando otras cuarenta mil cosas encima. Así se pierde todo aquí." },
                    { text = "Qué descuido más tonto.", affinity = -1,
                      reaction = "Sí. Y el suyo es seguir aquí parado. Fuera." },
                },
            },
            {
                id = "azazel-estantes", mood = "mal", minAffinity = 7, demand = 3,
                line = "Cada noche reviso un estante. Hay cuarenta mil. Haz la cuenta y después dime que no tengo motivo para estar así.",
                options = {
                    { text = "Entonces revisemos dos por noche.", affinity = 3,
                      reaction = "Dos. Nadie me había ofrecido la mitad del trabajo. Te tomo la palabra." },
                    { text = "¿Y si alguien lo sacó de su lugar?", affinity = 1,
                      reaction = "...No lo había pensado. Y ahora no voy a poder dejar de pensarlo." },
                    { text = "Cuarenta mil noches no es tanto para un demonio.", affinity = -1,
                      reaction = "Dímelo cuando hayas vivido una." },
                },
            },
            {
                id = "azazel-miedo", mood = "mal", minAffinity = 13, demand = 3,
                line = "Te digo la verdad: lo encontré hace siglos. Nunca lo leí. Me da miedo que la cláusula de escape diga que no hay escape.",
                options = {
                    { text = "Leámoslo juntos.", affinity = 3,
                      reaction = "Juntos. Bueno. Si dice que no, al menos no lo leí solo." },
                    { text = "Mejor no saber, entonces.", affinity = 0,
                      reaction = "Eso me dije por trescientos años. No me ayudó." },
                    { text = "Eres un cobarde con buena letra.", affinity = -1,
                      reaction = "Lo sé. Por eso te lo conté a ti y no a un espejo. Vete." },
                },
            },
            {
                id = "azazel-archivo", mood = "neutral", demand = 1,
                line = "Todo lo que se firma en el infierno termina aquí. Contratos, pactos, promesas de borrachos. Hasta la suya.",
                options = {
                    { text = "¿Mi promesa? ¿Cuál?", affinity = 3,
                      reaction = "Todavía no la hizo. Pero ya tiene estante." },
                    { text = "Solo quiero la puerta.", affinity = 0,
                      reaction = "Como todos. Por eso siguen aquí." },
                    { text = "Qué lugar más polvoriento.", affinity = -1,
                      reaction = "El polvo es lo único aquí que no firmó nada. Respételo." },
                },
            },
            {
                id = "azazel-grietas", mood = "neutral", minAffinity = 7, demand = 2,
                line = "Cada contrato tiene una grieta. Una palabra mal puesta, una coma de más. Por ahí se escapa la gente.",
                options = {
                    { text = "Enséñame a encontrarlas.", affinity = 3,
                      reaction = "Primera regla: lee lo que nadie lee. La letra chica es la puerta." },
                    { text = "¿Por qué no usas una para ti?", affinity = 1,
                      reaction = "Porque para eso necesito encontrar mi contrato. Otro día te cuento." },
                    { text = "Eso suena a trampa.", affinity = -1,
                      reaction = "Todo aquí es trampa. La diferencia es quién la pone." },
                },
            },
            {
                id = "azazel-guardian", mood = "neutral", minAffinity = 13, demand = 3,
                line = "El guardián de la puerta también firmó un contrato. Está en el estante trece. Lo leí. Tiene una grieta.",
                options = {
                    { text = "¿Me la muestras?", affinity = 3,
                      reaction = "Te la muestro si me prometes no usarla para nada más que salir." },
                    { text = "¿Por qué me lo cuentas a mí?", affinity = 1,
                      reaction = "Porque si tú sales, sé que es posible." },
                    { text = "La voy a vender al mejor postor.", affinity = -1,
                      reaction = "Entonces nunca existió. Olvídalo." },
                },
            },
            {
                id = "azazel-papel-nuevo", mood = "bien", demand = 1,
                line = "Hoy el archivo huele a papel nuevo. Me hizo pensar que, si saliera, me gustaría escribir algo que nadie tenga que firmar.",
                options = {
                    { text = "¿Como qué?", affinity = 3,
                      reaction = "Una carta. Sin cláusulas, sin letra chica. Solo lo que quiero decir." },
                    { text = "¿El papel nuevo es buena señal?", affinity = 1,
                      reaction = "Es rara. Y lo raro, aquí abajo, suele ser bueno." },
                    { text = "Nada, solo pasaba.", affinity = -1,
                      reaction = "Entonces siga pasando." },
                },
            },
            {
                id = "azazel-lluvia", mood = "bien", minAffinity = 7, demand = 2,
                line = "¿Sabes qué extraño de arriba? La lluvia. Aquí el papel nunca se moja. Arriba todo se moja y nadie se muere por eso.",
                options = {
                    { text = "Cuando salgamos, te llevo a ver llover.", affinity = 3,
                      reaction = "Eso lo archivo en el estante de las cosas que quiero que pasen." },
                    { text = "Es solo agua.", affinity = 0,
                      reaction = "Para ti. Para mí es lo único que borra la tinta." },
                    { text = "La lluvia te arruinaría el archivo.", affinity = -1,
                      reaction = "Exacto. Por eso la quiero." },
                },
            },
            {
                id = "azazel-perderse", mood = "bien", minAffinity = 13, demand = 3,
                line = "Si encuentro mi contrato, lo primero que voy a hacer afuera es perderme. A propósito. Sin mapa y sin índice.",
                options = {
                    { text = "Y yo te encuentro.", affinity = 3,
                      reaction = "Eso sí lo quiero archivar." },
                    { text = "Suena aterrador.", affinity = 1,
                      reaction = "Lo es. Por eso suena tan bien." },
                    { text = "Te vas a aburrir en un día.", affinity = -1,
                      reaction = "Mil años archivando y tú me hablas de aburrimiento." },
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
              effect = "No piensas cumplirla. Él tampoco." },
        },
        quiet = {
            mal = "Hoy el salón está cerrado. No es personal. O sí.",
            neutral = "Hoy no hay chismes nuevos en el salón.",
            bien = "Estoy de buenas, pero hoy prefiero escuchar la música.",
        },
        conversations = {
            {
                id = "lilim-promesa", mood = "mal", demand = 2,
                line = "Hoy no estoy para cumplidos. El último que me dijo algo bonito me prometió volver. Hace doscientos años.",
                options = {
                    { text = "Entonces no le digo nada y me quedo.", affinity = 3,
                      reaction = "...Ah. Eso sí es nuevo. Quédese." },
                    { text = "¿Quién era?", affinity = 1,
                      reaction = "Alguien que encontró la puerta y se olvidó del camino de vuelta." },
                    { text = "Seguro tuvo sus motivos.", affinity = -1,
                      reaction = "Siempre los tienen. Fuera." },
                },
            },
            {
                id = "lilim-salon-abierto", mood = "mal", minAffinity = 7, demand = 3,
                line = "Podría irme. Sé dónde está la grieta. Pero si cierro el salón, todos aquí se acuerdan de que están atrapados.",
                options = {
                    { text = "No es tu trabajo salvarlos a todos.", affinity = 3,
                      reaction = "Nadie me lo había dicho así. No sé si te creo, pero gracias." },
                    { text = "Entonces abre una noche más.", affinity = 1,
                      reaction = "Eso hago. Cada noche. Hace siglos." },
                    { text = "Que se acuerden. No es tu problema.", affinity = -1,
                      reaction = "Qué fácil decirlo cuando no tienes a nadie." },
                },
            },
            {
                id = "lilim-copa", mood = "mal", minAffinity = 13, demand = 3,
                line = "Todavía guardaba su copa. La limpiaba cada noche por si volvía. Hoy la rompí sin querer, y sentí alivio.",
                options = {
                    { text = "Quizás ya era hora de soltarla.", affinity = 3,
                      reaction = "Quizás. Ayúdame a juntar los pedazos y después los tiramos juntos." },
                    { text = "Te consigo otra.", affinity = 0,
                      reaction = "No es la copa, cielo. Nunca fue la copa." },
                    { text = "Qué dramática.", affinity = -1,
                      reaction = "Sí. Es lo único que me quedó de esa época." },
                },
            },
            {
                id = "lilim-cumplido", mood = "neutral", demand = 1,
                line = "Cariño, nadie entra a mi salón sin un cumplido. Es la regla. Aquí los demonios vienen a olvidar dónde están.",
                options = {
                    { text = "Sus cuernos brillan más que el lago de fuego.", affinity = 3,
                      reaction = "Ohh, tiene lengua de plata. Quédese." },
                    { text = "Bonito salón.", affinity = 0,
                      reaction = "El salón ya lo sabe. Yo pregunté por mí." },
                    { text = "No vine a coquetear.", affinity = -1,
                      reaction = "Entonces vino al lugar equivocado." },
                },
            },
            {
                id = "lilim-esquina", mood = "neutral", minAffinity = 7, demand = 2,
                line = "¿Ves al de la esquina? Era guardián. Una noche se rió aquí y no volvió a su puerta. El encanto abre más puertas que una llave.",
                options = {
                    { text = "Enséñame a hacer eso.", affinity = 3,
                      reaction = "Primera lección: mira a los ojos cuando mientes." },
                    { text = "Prefiero la llave.", affinity = 0,
                      reaction = "Aburrido, pero práctico." },
                    { text = "Eso es manipulación.", affinity = -1,
                      reaction = "Estamos en el infierno, cielo." },
                },
            },
            {
                id = "lilim-jueves", mood = "neutral", minAffinity = 13, demand = 3,
                line = "El guardián de la última puerta viene los jueves. Pide siempre lo mismo y nunca termina el trago. Espera a alguien, como yo.",
                options = {
                    { text = "Entonces sabes cómo hablarle.", affinity = 3,
                      reaction = "Sé qué le duele, que es más útil. Te lo cuento si me prometes tratarlo bien." },
                    { text = "¿A quién espera?", affinity = 1,
                      reaction = "A quien le cerró la puerta en la cara. Todos esperamos a alguien aquí." },
                    { text = "Lo emborracho y paso.", affinity = -1,
                      reaction = "Nunca termina el trago, ¿no me escuchaste?" },
                },
            },
            {
                id = "lilim-baile", mood = "bien", demand = 1,
                line = "Pase, pase. Hoy estoy tan de buenas que hasta pienso en salir. ¿Sabe qué haría primero? Bailar donde nadie me conozca.",
                options = {
                    { text = "¿Me guarda un baile?", affinity = 3,
                      reaction = "El primero. Y el último, si se porta bien." },
                    { text = "¿Aquí nadie baila?", affinity = 1,
                      reaction = "Aquí bailan para olvidar. Yo quiero bailar para acordarme." },
                    { text = "Seguro baila mal.", affinity = -1,
                      reaction = "Y usted seguro no baila. Qué pena." },
                },
            },
            {
                id = "lilim-ventanas", mood = "bien", minAffinity = 7, demand = 2,
                line = "Hoy se me ocurrió abrir otro salón, arriba. Con ventanas. Aquí nunca hubo ventanas.",
                options = {
                    { text = "Yo sería tu primer cliente.", affinity = 3,
                      reaction = "Cliente no. Socio. Los clientes se van." },
                    { text = "¿Para qué tantas ventanas?", affinity = 1,
                      reaction = "Para ver quién viene antes de que toque la puerta." },
                    { text = "Nadie iría a un salón de demonios.", affinity = -1,
                      reaction = "Tú viniste. Y no te fuiste." },
                },
            },
            {
                id = "lilim-recuerdo", mood = "bien", minAffinity = 13, demand = 3,
                line = "Si sales de aquí... ¿te vas a acordar de mí? Dímelo hoy, que estoy de buenas y me lo voy a creer.",
                options = {
                    { text = "Voy a volver por ti.", affinity = 3,
                      reaction = "Eso me dijeron una vez. Pero a ti te lo voy a creer." },
                    { text = "Tal vez.", affinity = 0,
                      reaction = "'Tal vez' es lo que dicen todos antes de irse." },
                    { text = "Quiero olvidar todo esto.", affinity = -1,
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
        quiet = {
            mal = "Hoy no. El martillo y yo estamos de malas.",
            neutral = "Hoy solo hay trabajo, nada que contar.",
            bien = "Hoy el fuego suena tan lindo que no quiero hablar.",
        },
        conversations = {
            {
                id = "brasa-no-abre", mood = "mal", demand = 2,
                line = "No se acerque. Hoy probé otra vez la cerradura de la primera puerta. La hice yo. Y no me abre.",
                options = {
                    { text = "Déjeme intentar a mí.", affinity = 3,
                      reaction = "...Ja. Tiene agallas. No va a abrir, pero me gusta que lo intente." },
                    { text = "¿Cómo que no le abre?", affinity = 1,
                      reaction = "Como le digo. La mano que la forjó es la única que no reconoce." },
                    { text = "Habrá hecho mal su trabajo.", affinity = -1,
                      reaction = "Hice el trabajo perfecto. Ese es el problema. Largo." },
                },
            },
            {
                id = "brasa-perfecta", mood = "mal", minAffinity = 7, demand = 3,
                line = "El que me encerró me pidió la cerradura perfecta. Le hice caso. Me salió perfecta hasta para mí.",
                options = {
                    { text = "Entonces eres la mejor herrera del infierno.", affinity = 3,
                      reaction = "La mejor y la más tonta. Pero gracias por la primera parte." },
                    { text = "¿Y no le puedes hacer un cambio?", affinity = 1,
                      reaction = "Si la toco, se funde. Le puse eso también. Te dije, perfecta." },
                    { text = "Qué error de novata.", affinity = -1,
                      reaction = "Novata no. Orgullosa. Es peor." },
                },
            },
            {
                id = "brasa-manos", mood = "mal", minAffinity = 13, demand = 3,
                line = "Todas las noches sueño que la cerradura se abre. Me despierto con las manos quemadas de tanto apretar el martillo.",
                options = {
                    { text = "Déjame ver esas manos.", affinity = 3,
                      reaction = "...Nadie me mira las manos. Solo lo que hacen con ellas." },
                    { text = "Es solo un sueño.", affinity = 0,
                      reaction = "Para ti. Yo lo sueño hace mil años." },
                    { text = "Por algo te encerraron.", affinity = -1,
                      reaction = "Sí. Por buena en lo mío. Vete." },
                },
            },
            {
                id = "brasa-yunque", mood = "neutral", demand = 1,
                line = "¡Eh, usted! ¿Va a quedarse mirando o va a sostener el yunque? Aquí se forjan las cerraduras de todo el círculo.",
                options = {
                    { text = "Pásemelo.", affinity = 3,
                      reaction = "¡Ja! Brazos flacos, pero agallas gordas." },
                    { text = "Solo estaba mirando.", affinity = 0,
                      reaction = "Pues mire desde más lejos, que salpica." },
                    { text = "Eso es trabajo de demonios menores.", affinity = -1,
                      reaction = "Entonces usted es uno. Largo." },
                },
            },
            {
                id = "brasa-respeto", mood = "neutral", minAffinity = 7, demand = 2,
                line = "Los guardianes solo respetan una cosa: que no te tiemblen las piernas. Los conozco bien, les hice las puertas.",
                options = {
                    { text = "Entréname.", affinity = 3,
                      reaction = "Cien golpes al día. Empiezas ahora." },
                    { text = "¿Y si me tiemblan?", affinity = 1,
                      reaction = "Al menos lo admites. Eso ya es valor." },
                    { text = "Yo no necesito respeto.", affinity = -1,
                      reaction = "Necesitas algo. Todos aquí abajo necesitan algo." },
                },
            },
            {
                id = "brasa-firma", mood = "neutral", minAffinity = 13, demand = 3,
                line = "Toda cerradura que forjo tiene un punto débil. Lo pongo sin querer, como una firma. La de la segunda puerta lo tiene abajo.",
                options = {
                    { text = "Enséñamelo golpe a golpe.", affinity = 3,
                      reaction = "Así se habla. Agarra el martillo." },
                    { text = "Dímelo y ya.", affinity = 0,
                      reaction = "Nada es gratis en la fragua." },
                    { text = "Seguro ni tiene.", affinity = -1,
                      reaction = "Todo lo que se forja se puede romper. Tú incluido." },
                },
            },
            {
                id = "brasa-herradura", mood = "bien", demand = 1,
                line = "¡Buen día para la fragua! El fuego sale derecho. En días así me imagino forjando algo que no encierre a nadie.",
                options = {
                    { text = "¿Como qué?", affinity = 3,
                      reaction = "Una herradura. Algo que sirva para irse lejos." },
                    { text = "¿Qué estamos haciendo hoy?", affinity = 1,
                      reaction = "Algo que todavía no sé. Así son los días buenos." },
                    { text = "Paso, gracias.", affinity = -1,
                      reaction = "Usted pasa mucho." },
                },
            },
            {
                id = "brasa-rio", mood = "bien", minAffinity = 7, demand = 2,
                line = "Si salgo, voy a poner una herrería al lado de un río. Para enfriar el metal en agua que corre, no en este caldo de azufre.",
                options = {
                    { text = "Yo te ayudo a cargar el yunque.", affinity = 3,
                      reaction = "¡Ja! Te tomo la palabra. Pesa como un pecado." },
                    { text = "¿Por qué un río?", affinity = 1,
                      reaction = "Porque el agua que corre no se queda. Como yo, algún día." },
                    { text = "El azufre te queda bien.", affinity = -1,
                      reaction = "Y a ti la boca cerrada." },
                },
            },
            {
                id = "brasa-llave", mood = "bien", minAffinity = 13, demand = 3,
                line = "Tengo un plan. Forja tú una llave, con tu mano, y yo te guío. La cerradura no sabe que la idea es mía.",
                options = {
                    { text = "Hagámoslo.", affinity = 3,
                      reaction = "Agarra el martillo. Esta vez no me va a temblar el pulso." },
                    { text = "¿Y si me sale mal?", affinity = 1,
                      reaction = "Te sale mal y lo hacemos de nuevo. Para eso hay fuego." },
                    { text = "¿Y yo qué gano?", affinity = -1,
                      reaction = "Una salida, tonto. Lo mismo que yo." },
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
