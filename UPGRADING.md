# Upgrading

Notes for moving an existing docker-fess deployment to a newer Fess image line.

## Upgrading to 15.9

Fess 15.9 removed the embedded search engine, so a Fess container always needs an OpenSearch to
talk to. The compose files here already start one, so nothing changes for them, but three
behaviours differ:

- **A search engine older than OpenSearch 3 now stops startup** instead of logging an error and
  continuing. Earlier engines do not implement the `_shard_doc` sort that document export, purge,
  backup and suggest dictionary builds rely on, and over HTTP those requests hang rather than
  fail, so the mismatch is refused up front.
- **`SEARCH_ENGINE_HOME` no longer does anything.** It pointed at the bundled engine's directory.
- **The legacy `elasticsearch.*` configuration keys are gone.** The `ES_*` environment variables
  these images accept are unaffected; the entrypoint translates them to `SEARCH_ENGINE_*`.

**No image installs the Playwright crawler.** In 15.8 it was part of the war, which is why
`compose/playwright` only added the system libraries Chromium needs. From 15.9 it is the
`fess-crawler-playwright` plugin, and it runs on Node.js, which the distribution no longer carries.
`compose/playwright` installs both.
