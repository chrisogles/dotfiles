-- Start hyprsunset at login so the scheduled profiles in hyprsunset.conf apply
-- on their own. `omarchy toggle nightlight` still works for a manual override.
o.launch_on_start("hyprsunset")
