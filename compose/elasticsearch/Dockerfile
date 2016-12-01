FROM elasticsearch:2.3.5

RUN /usr/share/elasticsearch/bin/plugin install org.codelibs/elasticsearch-analysis-fess/2.3.0 && \
    /usr/share/elasticsearch/bin/plugin install org.codelibs/elasticsearch-analysis-ja/2.3.0 && \
    /usr/share/elasticsearch/bin/plugin install org.codelibs/elasticsearch-analysis-synonym/2.3.0 && \
    /usr/share/elasticsearch/bin/plugin install org.codelibs/elasticsearch-configsync/2.3.1 && \
    /usr/share/elasticsearch/bin/plugin install org.codelibs/elasticsearch-dataformat/2.3.0 && \
    /usr/share/elasticsearch/bin/plugin install org.codelibs/elasticsearch-langfield/2.3.0 && \
    /usr/share/elasticsearch/bin/plugin install http://maven.codelibs.org/archive/elasticsearch/plugin/kopf/elasticsearch-kopf-2.0.1.0.zip && \
    /usr/share/elasticsearch/bin/plugin install org.codelibs/elasticsearch-analysis-kuromoji-neologd/2.3.1

RUN echo -e "configsync.config_path: /usr/share/elasticsearch/config\nscript.engine.groovy.inline.update: on" && \
    tee -a /usr/share/elasticsearch/config/elasticsearch.yml

EXPOSE 9200 9300

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["elasticsearch"]
