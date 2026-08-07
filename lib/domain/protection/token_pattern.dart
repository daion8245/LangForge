/// Order of token pattern regex branches is critical.
/// 1. %% (Escaped percent) BEFORE %s
/// 2. §x HEX BEFORE single §
/// 3. %1$s (positional) BEFORE %s
/// 4. {{name}} BEFORE {name}
final RegExp tokenPattern = RegExp(
  // 1. Escaped percent
  r'%%'
  // 2. HEX color §x§F§F§A§A§0§0
  r'|§x(?:§[0-9a-fA-F]){6}'
  // 3. Single format code §a, §r
  r'|§[0-9a-fk-orA-FK-OR]'
  // 4. Positional printf (%1$s, %2$d, %1$.1f)
  r'|%\d+\$[-#+ 0,(]*[\d.]*[sdfn]'
  // 5. Normal printf (%s, %d, %f, %02d)
  r'|%[-#+ 0,(]*[\d.]*[sdfn]'
  // 6. Shell style ${player}
  r'|\$\{[A-Za-z0-9_.]+\}'
  // 7. Double braces {{name}}
  r'|\{\{[A-Za-z0-9_.]+\}\}'
  // 8. Single braces {0}, {name}
  r'|\{[A-Za-z0-9_.]+\}'
  // 9. JSON escape sequences (\n, \t, \", \\)
  r'|\\[nrt"\\]',
);
