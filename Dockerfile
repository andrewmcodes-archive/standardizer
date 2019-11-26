FROM andrewmcodes/ruby-node:version0.1

LABEL "repository"="https://github.com/andrewmcodes/standardizer"
LABEL "maintainer"="Andrew Mason <andrewmcodes@protonmail.com>"
LABEL "version"="0.0.1"

RUN apk --no-cache add jq bash curl postgresql-dev

COPY "entrypoint.sh" "/entrypoint.sh"
COPY README.md LICENSE /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["help"]
