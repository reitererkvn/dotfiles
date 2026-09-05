---
description: Guardrails for modifying Home Assistant dashboards (lovelace.dashboard_overview)
---

# Home Assistant Dashboard Generation Guardrails

When modifying, generating, or analyzing Home Assistant dashboards via JSON (e.g., `lovelace.dashboard_overview`), strictly adhere to the following baseline constraints:

1.  **Never Create Double Headings in Sections Layout**: 
    When using the modern `sections` layout (`type: "sections"`), the inner `type: "grid"` objects natively support a `"title"` property. However, if you inject a custom interactive heading card (e.g., `{"type": "heading", "tap_action": ...}` or a `mushroom-template-card` acting as a header) as the first card in that grid, you **MUST omit** the `"title"` property on the parent grid. Otherwise, Home Assistant will render the title twice on the dashboard.

2.  **Respect Manual Customizations (No Global Renaming)**:
    Do not universally rename entities by concatenating device names (even if `has_entity_name: true`) unless specifically instructed or when explicitly targeting known-generic names (e.g., FritzBox "Internet access"). Global programmatic renaming will silently destroy the user's manual UI customizations. Treat the user's existing `name` fields as the source of truth.

3.  **Do Not Overwrite Manual Icons**:
    Avoid hardcoding custom icons for areas, rooms, or entities unless specifically requested. If a user previously "cleaned up" (bereinigt) an icon in the UI, overwriting the entire JSON with a new hardcoded default will revert their work. When in doubt, omit the `icon` field so HA uses the user's defined default.

4.  **Preserve Element Order & Structure (Mutate, Don't Regenerate)**:
    Once a dashboard baseline is established, **never** run a script that regenerates the entire dashboard from scratch. Doing so destroys the user's manual UI edits, such as the order of tabs, the order of cards, and manual icon selections. 
    *Actionable Rule:* To add or change elements, you must load the *current* `.storage/lovelace.dashboard_overview` JSON, locate the specific list/array, and surgically insert/update only the requested elements. Leave all other arrays, orders, and properties exactly as they are.

5.  **Check Prerequisites Before Hacking (e.g., `card_mod`)**:
    Never assume frontend tools or custom components (like `card_mod`) are installed. Before injecting custom CSS or relying on non-native extensions, actively check if they exist or explicitly inform the user that a specific HACS tool is required. Do not silently inject code that relies on missing tools, as it will fail without errors and lead to frustrating "trial and error" loops. Ask the user to install the tool first instead of breaking the system.

6.  **Mushroom Ghost Attribute `"color"` Bug**:
    When applying color logic (like Jinja templates) to `"icon_color"` in `custom:mushroom-template-card` (or similar), explicitly verify and delete any existing `"color"` attribute in the JSON. Home Assistant's frontend renderer will silently prioritize this non-standard `"color"` attribute, causing valid `icon_color` logic to be completely ignored.

7.  **Frontend Cache Crashes (HACS Installations)**:
    If a user installs a new frontend plugin via HACS (e.g., `card_mod`) during a session, be aware that their browser cache will often cause *all* custom Lovelace cards to simultaneously crash and display a "Configuration error". Always instruct the user to perform a hard-refresh (Ctrl+F5, Cmd+Shift+R, or clear app cache) immediately after installation to prevent panic.

8.  **Xiaomi Vacuum Map Card (`custom:xiaomi-vacuum-map-card`) Color Overrides**:
    To successfully override tile background colors on this card via `card_mod` (e.g., removing a clashing Material You purple theme color), targeting `--secondary-background-color` is not enough. You must aggressively target all internal variables at the `:host` level. Always include:
    * `--map-card-secondary-color`
    * `--map-card-tertiary-color`
    * `--map-card-internal-secondary-color`
    * `--map-card-internal-tertiary-color`
    * `--secondary-background-color`
