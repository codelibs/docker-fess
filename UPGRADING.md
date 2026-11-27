# Upgrading

Notes for moving an existing docker-fess deployment to a newer Fess image line.

## Upgrading to 15.10

Four things differ for a deployment that carries files or settings over from a 15.9 image:

- **`tika.xml` is no longer read.** Fess 15.10 uses Apache Tika 4, which has no XML configuration
  file, so Fess builds the Tika parser in code. The 15.9 images move `tika.xml` into `/etc/fess`;
  the 15.10 images do not contain it. If you copied or mounted a `tika.xml` of your own into
  `/opt/fess` (the directory the images read overrides from) or `/etc/fess`, Fess ignores it and
  writes a warning to `fess.log` at startup, and the parsers it excluded run again. Delete the
  file. The location of `tesseract` can no longer be set either, so `tesseractPath` and
  `tessdataPath` in a Tesseract properties file have no effect; `tesseract` has to be on the `PATH`
  of the crawler process, which is where the `apk add` in `compose/tesseract` puts it.
- **A `FESS_PLUGINS` entry that names version 15.9.0 installs a 15.9 plugin into a 15.10 Fess.**
  Plugins built for 15.9.0 were started and used for crawling on 15.10 without being rebuilt, but
  `bin/fess-setup check` (run it with `docker exec`) reports them as FAIL ("built for another
  release"). Change the version of every entry to the 15.10 one. The seven plugins the images
  install themselves already match the image.
- **The compose files start OpenSearch 3.10.0 (15.9 used 3.9.0), and the move is one way.**
  `fess-opensearch:3.10.0` starts on the data and dictionary volumes a 3.9.0 container wrote, so
  keep the volume names and change only the tag, but a 3.9.0 container refuses data a 3.10.0 node
  has opened (`IndexFormatTooNewException`) and a snapshot taken on 3.10.0 cannot be restored
  into 3.9.0. Take a snapshot or a copy of the volumes before pulling, and to go back start a new
  3.9.0 node on empty volumes and restore the snapshot taken before the upgrade. Move the Fess
  image to 15.10 in the same step: Fess 15.10 supports OpenSearch 3.10.0 only.
- **A secret is given by an environment variable, not by a `-D` option.** `SEARCH_ENGINE_PASSWORD`
  (and `ES_PASSWORD`) used to be passed as `-Dfess.config.search_engine.password`, which `ps` and
  `docker top` show and which Fess repeats on the command line of the crawler, suggest and
  thumbnail processes. The entrypoint now exports `FESS_CONFIG_SEARCH_ENGINE_PASSWORD` instead, which
  Fess 15.10 reads. The 15.9 images also left `SEARCH_ENGINE_PASSWORD` in the environment of the
  Fess process, where the System Info page of the admin console lists it in clear text; the 15.10
  entrypoint removes `SEARCH_ENGINE_PASSWORD` and `ES_PASSWORD` from that environment, so the page
  shows only the masked `FESS_CONFIG_` entry. The same goes for any other secret you put in
  `FESS_JAVA_OPTS` (`-Dfess.config.rag.llm.<name>.api.key=...`,
  `-Dfess.system.storage.secretkey=...`): Fess 15.10 warns about it at start. Give it as the variable made from the key instead: `FESS_CONFIG_` or
  `FESS_SYSTEM_`, then the key in upper case with `.` written as `_`
  (`FESS_CONFIG_RAG_LLM_GEMINI_API_KEY`, `FESS_SYSTEM_STORAGE_SECRETKEY`).

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
