# Roblox UI

Design în Figma: https://www.figma.com/design/zc5EGaNEOc0c8vjtEa9nqM

## sneak-hud/
Indicator de zgomot (difuzor cu 4 niveluri) + „HOLD CTRL TO SNEAK”.

- `SneakHud.client.lua` → LocalScript în **StarterPlayer > StarterPlayerScripts**
- `sound_0_stai.png`, `sound_1_ghemuit.png`, `sound_2_mers.png`, `sound_3_alergat.png` → se urcă în Roblox (Asset Manager → Bulk Import); ID-urile se pun în tabelul `ICONS` din script.
- Nivel 0 = stai pe loc, 1 = ghemuit (CTRL), 2 = mers normal, 3 = alergat (SHIFT).

## interaction-prompt/
Prompt de interacțiune pentru `ProximityPrompt` („E / Classroom door / open”), cu bară care se umple cât ții apăsat.

- `InteractionPrompt.client.lua` → LocalScript în **StarterPlayer > StarterPlayerScripts**
- Nu are nevoie de imagini. Fontul e `Enum.Font.PatrickHand`.
- Titlul vine din `ProximityPrompt.ObjectText`, acțiunea din `ActionText`, tasta din `KeyboardKeyCode`.
- Bara se umple doar dacă promptul are `HoldDuration > 0`.
- `FORCE_CUSTOM_STYLE = true` aplică stilul pe toate prompturile din `workspace`; pune `false` dacă vrei doar pe cele cu `Style = Custom`.

Specificații (din Figma):

| Element | Valoare |
|---|---|
| Card | fundal `rgb(20,16,16)` la 55% opacitate, colțuri 4px, padding 10 / 26 / 14 / 10, gap 14, lățime minimă 260 |
| Tastă | 64×64, `#F4F1EA`, colțuri 3px, literă 26px `#1A1A1A` |
| Titlu | Patrick Hand 26px, line-height 28, alb |
| Acțiune | Patrick Hand 18px, line-height 20, `#E8E4DC` |
| Bară | 4px jos, fundal alb 12%, umplere albă cu strălucire |
