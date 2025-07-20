FROM opensearchproject/opensearch:3.1.0

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

