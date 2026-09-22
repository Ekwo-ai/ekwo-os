# Ekwo OS — install and first return, Estonia.
#
# One half of the install demo; docs/demo/README.md says how both halves
# are recorded and put side by side. Rendered by docs/demo/render.sh, never
# by hand: it needs an empty throwaway Supabase project in the environment.
# The output is PNG frames, which render.sh encodes: vhs 0.12 wrote no video
# at all next to ffmpeg 9, and said nothing about it.

Output ee-frames/

Require npx
Require node

Set Shell "bash"
Set FontSize 13
Set Width 960
Set Height 600
Set Padding 18
Set TypingSpeed 18ms
Set Theme "GitHub Dark"
Set Framerate 25

Hide
Type "DEMO_LABEL='Estonia' source ./shell.sh && clear"
Enter
Sleep 500ms
Show

Type "# Estonia — an empty Supabase project"
Sleep 900ms
Enter
Type `npx ekwo-os init --country EE --language en --fiscal-year 2026 \`
Enter
Type `  --org "Example Group" --company "Example Estonia OÜ" \`
Enter
Type `  --admin-email admin@example.com --admin-password "$EKWO_PASSWORD" --yes`
Enter
Wait@180s /\$\s*$/
Sleep 2500ms

Type "clear"
Enter
Type "npx ekwo-os status | head -9"
Enter
Wait@60s /\$\s*$/
Sleep 4s

Type "clear"
Enter
Type "# keeping books: as a person, under row level security"
Enter
Type "npx ekwo-os login --email admin@example.com"
Enter
Wait@60s /\$\s*$/
Type `npx ekwo-os use "Example Estonia OÜ"`
Enter
Wait@60s /\$\s*$/
Type `npx ekwo-os contact add "Harbour Studio" --type customer --country EE`
Enter
Wait@60s /\$\s*$/
Sleep 1s

Type "clear"
Enter
Type `npx ekwo-os doc new --contact "Harbour Studio" --date 2026-02-10 --ref inv-1 \`
Enter
Type `  --line "name=Consulting,price=1500.00,account=3000,tax=EE-S-24"`
Enter
Wait@60s /\$\s*$/
Sleep 1500ms
Type "npx ekwo-os post inv-1"
Enter
Wait@60s /\$\s*$/
Sleep 3s

Type "clear"
Enter
Type "# the return: vat_return(), asked through the MCP server as that person"
Enter
Type `node vat-return.mjs admin@example.com "Example Estonia OÜ" 2026-02-01 2026-02-28`
Enter
Wait@60s /\$\s*$/
Sleep 6s
