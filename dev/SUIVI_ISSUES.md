# Suivi — passe `fix/multiple-issues`

## Issues traitées

### #129 — `gl_get_group_id()` plante quand le groupname est dupliqué
La fonction comparait/affichait `path_with_namespace`, qui est une
colonne de l'API **Projects**, pas Groups. L'API Groups expose
`full_path`. Quand `gitlab(req = "groups", ...)` retournait plusieurs
résultats avec le même `name`, l'accès à `matching[1, "path_with_namespace"]`
levait *Column `path_with_namespace` doesn't exist*.

- **Fix** : `path_with_namespace` -> `full_path` dans `R/groups.R`
  (filtrage, message d'avertissement, picking par défaut).
- **Test** : `tests/testthat/test-gl_get_group_id_duplicates.R`
  (`testthat::with_mocked_bindings()` simule `gitlab()` qui retourne
  plusieurs `outillage-data` ; vérifie que la fonction warn et
  retourne le premier id, et que matcher exactement par full_path
  cible la bonne ligne sans warning).

### #93 — Messages d'erreur HTTP explicites
`http_error_or_content()` déléguait à `httr::stop_for_status()` qui
sort un message générique style `Forbidden (HTTP 403)`. L'utilisateur
ne savait pas si c'était un token invalide, un dépôt inexistant ou un
dépôt privé.

- **Fix** : court-circuit avant `stop_for_status` pour `status >= 400`.
  Helper interne `gitlab_error_message()` qui :
  - extrait le `message` ou `error` du corps JSON renvoyé par GitLab,
  - ajoute un *hint* selon le code (401 -> token, 403 -> private/scope,
    404 -> not found, 429 -> rate limit).
- **Test** : `tests/testthat/test-http_error_messages.R` — 6 cas
  (401/403/404/429/500/200) avec des `httr::response` synthétisées.

## Issues envisagées mais non traitées

| # | Pourquoi pas |
|---|---|
| #127 | "Install all dependencies by default" — décision de design (changement de défaut). |
| #126 | usethis pr-helper equivalents — feature large. |
| #125 | latest tag/release — feature, demande shape API. |
| #124 | junit reporter — feature, parser custom. |
| #76, #71, #69, #58, #51, #43, #33, #26, #23, #16 | features ou design, pas des bugs ; à arbitrer avec le mainteneur. |
| #42 | doc seule. |
