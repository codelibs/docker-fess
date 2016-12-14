FROM elasticsearch:2.3.5

RUN /usr/share/elasticsearch/bin/plugin install org.codelibs/elasticsearch-analysis-fess/2.3.0 && \
    /usr/share/elasticsearch/bin/plugin install org.codelibs/elasticsearch-analysis-ja/2.3.0 && \
    /usr/share/elasticsearch/bin/plugin install org.codelibs/elasticsearch-analysis-synonym/2.3.0 && \
    /usr/share/elasticsearch/bin/plugin install org.codelibs/elasticsearch-configsync/2.3.1 && \
    /usr/share/elasticsearch/bin/plugin install org.codelibs/elasticsearch-dataformat/2.3.0 && \
    /usr/share/elasticsearch/bin/plugin install org.codelibs/elasticsearch-langfield/2.3.0 && \
    /usr/share/elasticsearch/bin/plugin install http://maven.codelibs.org/archive/elasticsearch/plugin/kopf/elasticsearch-kopf-2.0.1.0.zip && \
    /usr/share/elasticsearch/bin/plugin install org.codelibs/elasticsearch-analysis-kuromoji-neologd/2.3.1

RUN (echo "network.host: 0.0.0.0"; \
    echo "cluster.name: elasticsearch"; \
    echo "discovery.zen.minimum_master_nodes: 1"; \
    echo "configsync.config_path: /usr/share/elasticsearch/config"; \
    echo "discovery.zen.ping.unicast.hosts: [ \"elasticsearch\" ]"; \
    echo "script.engine.groovy.inline.update: on") | \
    tee /usr/share/elasticsearch/config/elasticsearch.yml

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["elasticsearch"]

EXPOSE 9200 9300
