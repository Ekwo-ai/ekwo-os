# The MCP server, as a container that speaks MCP over stdio.
#
# Built from this checkout rather than from npm, so the image is the source it
# sits next to. Directories that index MCP servers (Glama) build it, start it
# with no environment and ask for its tools: the server answers that without a
# database, and every tool call says what to configure.
#
#   docker build -t ekwo-mcp .
#   docker run -i --rm -e SUPABASE_URL=… -e SUPABASE_ANON_KEY=… \
#     -e EKWO_EMAIL=… -e EKWO_PASSWORD=… ekwo-mcp

FROM node:22-slim AS build
WORKDIR /src
COPY . .
RUN npm ci --no-audit --no-fund
# The server and the workspaces it depends on, in dependency order.
RUN npm run build -w @ekwo-ai/fec -w @ekwo-ai/camt053 -w @ekwo-ai/cfonb120 \
      -w @ekwo-ai/coda -w @ekwo-ai/trial-balance -w @ekwo-ai/journal-items \
      -w @ekwo-ai/journal-report -w @ekwo-ai/xaf -w @ekwo-ai/core -w @ekwo-ai/mcp \
 && mkdir /pack \
 && npm pack --pack-destination /pack -w @ekwo-ai/fec -w @ekwo-ai/camt053 \
      -w @ekwo-ai/cfonb120 -w @ekwo-ai/coda -w @ekwo-ai/trial-balance \
      -w @ekwo-ai/journal-items -w @ekwo-ai/journal-report -w @ekwo-ai/xaf \
      -w @ekwo-ai/core -w @ekwo-ai/mcp

# What `npx @ekwo-ai/mcp` would install, from the tarballs above, plus the
# Postgres driver the direct-connection route needs (an optional peer).
FROM node:22-slim
WORKDIR /app
COPY --from=build /pack/*.tgz /tmp/pack/
RUN npm init -y >/dev/null \
 && npm install --omit=dev --no-audit --no-fund /tmp/pack/*.tgz postgres@^3.4.5 \
 && rm -rf /tmp/pack
USER node
ENTRYPOINT ["node", "/app/node_modules/@ekwo-ai/mcp/dist/bin.js"]
