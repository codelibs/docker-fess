FROM opensearchproject/opensearch:2.19.2

# Install S3 repository plugin for snapshot support (not bundled by default)
RUN bin/opensearch-plugin install --batch repository-s3

# Install optional analysis plugins to match AWS Service analyzers
RUN bin/opensearch-plugin install --batch \
    analysis-icu \
    analysis-kuromoji \
    analysis-nori \
    analysis-smartcn \
    analysis-phonetic \
    analysis-stempel \
    analysis-ukrainian

