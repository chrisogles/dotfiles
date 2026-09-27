-- Web app bindings. Omarchy's preinstalled bindings point Email/Calendar at HEY
-- and SUPER+SHIFT+A at ChatGPT, so unbind before rebinding. All of these are
-- Chromium --app windows sharing one profile and one login.
hl.unbind("SUPER + SHIFT + E")
o.bind("SUPER + SHIFT + E", "Gmail", { webapp = "https://mail.google.com/mail/u/0/", focus = true })
hl.unbind("SUPER + SHIFT + ALT + E")
o.bind("SUPER + SHIFT + ALT + E", "New email", { webapp = "https://mail.google.com/mail/?view=cm&fs=1" })
hl.unbind("SUPER + SHIFT + C")
o.bind("SUPER + SHIFT + C", "Google Calendar", { webapp = "https://calendar.google.com/calendar/u/0/r", focus = true })
hl.unbind("SUPER + SHIFT + A")
o.bind("SUPER + SHIFT + A", "Claude", { webapp = "https://claude.ai/new", focus = true })
o.bind("SUPER + SHIFT + K", "Slack", { webapp = "https://app.slack.com/client", focus = true })
o.bind("SUPER + SHIFT + ALT + N", "Notion", { webapp = "https://www.notion.so/", focus = true })
